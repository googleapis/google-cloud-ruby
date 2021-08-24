# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "time"
require "date"
require "stringio"
require "base64"
require "bigdecimal"
require "google/cloud/spanner/data"

module Google
  module Cloud
    module Spanner
      ##
      # @private Helper module for converting Spanner values.
      module Convert
        # rubocop:disable all

        module ClassMethods
          def to_query_params params, types = nil
            types ||= {}
            formatted_params = params.map do |key, obj|
              [String(key), object_to_grpc_value_and_type(obj, types[key])]
            end
            Hash[formatted_params]
          end

          def object_to_grpc_value_and_type obj, field = nil
            obj = obj.to_column_value if obj.respond_to? :to_column_value

            if obj.respond_to? :to_grpc_value_and_type
              return obj.to_grpc_value_and_type
            end

            field ||= field_for_object obj
            [object_to_grpc_value(obj, field), grpc_type_for_field(field)]
          end

          def object_to_grpc_value obj, field = nil
            obj = obj.to_column_value if obj.respond_to? :to_column_value

            if obj.respond_to? :to_grpc_value_and_type
              return obj.to_grpc_value_and_type.first
            end

            case obj
            when NilClass
              Google::Protobuf::Value.new null_value: :NULL_VALUE
            when String
              Google::Protobuf::Value.new string_value: obj.to_s
            when Symbol
              Google::Protobuf::Value.new string_value: obj.to_s
            when TrueClass
              Google::Protobuf::Value.new bool_value: true
            when FalseClass
              Google::Protobuf::Value.new bool_value: false
            when Integer
              Google::Protobuf::Value.new string_value: obj.to_s
            # BigDecimal must be put before Numeric.
            when BigDecimal
              Google::Protobuf::Value.new string_value: obj.to_s("F")
            when Numeric
              if obj == Float::INFINITY
                Google::Protobuf::Value.new string_value: "Infinity"
              elsif obj == -Float::INFINITY
                Google::Protobuf::Value.new string_value: "-Infinity"
              elsif obj.respond_to?(:nan?) && obj.nan?
                Google::Protobuf::Value.new string_value: "NaN"
              else
                Google::Protobuf::Value.new number_value: obj.to_f
              end
            when Time
              Google::Protobuf::Value.new(string_value:
                obj.to_time.utc.strftime("%FT%T.%NZ"))
            when DateTime
              Google::Protobuf::Value.new(string_value:
                obj.to_time.utc.strftime("%FT%T.%NZ"))
            when Date
              Google::Protobuf::Value.new string_value: obj.to_s
            when Array
              arr_field = nil
              arr_field = field.first if Array === field
              Google::Protobuf::Value.new list_value:
                Google::Protobuf::ListValue.new(values:
                  obj.map { |o| object_to_grpc_value(o, arr_field) })
            when Hash
              if field.is_a? Fields
                field.struct(obj).to_grpc_value
              else
                Google::Protobuf::Value.new string_value: obj.to_json
              end
            else
              if obj.respond_to?(:read) && obj.respond_to?(:rewind)
                obj.rewind
                content = obj.read.force_encoding("ASCII-8BIT")
                encoded_content = Base64.strict_encode64(content)
                Google::Protobuf::Value.new(string_value: encoded_content)
              else
                raise ArgumentError,
                      "A value of type #{obj.class} is not supported."
              end
            end
          end

          def field_for_object obj
            case obj
            when NilClass
              raise ArgumentError, "Cannot determine type for nil values."
            when String
              :STRING
            when Symbol
              :STRING
            when TrueClass
              :BOOL
            when FalseClass
              :BOOL
            when Integer
              :INT64
            # BigDecimal must be put before Numeric.
            when BigDecimal
              :NUMERIC
            when Numeric
              :FLOAT64
            when Time
              :TIMESTAMP
            when DateTime
              :TIMESTAMP
            when Date
              :DATE
            when Array
              if obj.empty?
                raise ArgumentError,
                      "Cannot determine type for empty array values."
              end
              non_nil_fields = obj.compact.map { |e| field_for_object e }.compact
              if non_nil_fields.empty?
                raise ArgumentError,
                      "Cannot determine type for array of nil values."
              end
              if non_nil_fields.uniq.count > 1
                raise ArgumentError,
                      "Cannot determine type for array of different values."
              end
              [non_nil_fields.first]
            when Hash
              raw_type_pairs = obj.map do |key, value|
                [key, field_for_object(value)]
              end
              Fields.new Hash[raw_type_pairs]
            when Data
              obj.fields
            else
              if obj.respond_to?(:read) && obj.respond_to?(:rewind)
                :BYTES
              else
                raise ArgumentError,
                      "Cannot determine type for #{obj.class} values."
              end
            end
          end

          def grpc_type_for_field field
            return field.to_grpc_type if field.respond_to? :to_grpc_type

            if Array === field
              V1::Type.new(
                code: :ARRAY,
                array_element_type: grpc_type_for_field(field.first)
              )
            else
              V1::Type.new(code: field)
            end
          end

          def grpc_value_to_object value, type
            return nil if value.kind == :null_value

            case type.code
            when :BOOL
              value.bool_value
            when :INT64
              Integer value.string_value
            when :FLOAT64
              if value.kind == :string_value
                if value.string_value == "Infinity"
                  Float::INFINITY
                elsif value.string_value == "-Infinity"
                  -Float::INFINITY
                elsif value.string_value == "NaN"
                  Float::NAN
                else
                  Float value.string_value
                end
              else
                value.number_value
              end
            when :TIMESTAMP
              Time.parse value.string_value
            when :DATE
              Date.parse value.string_value
            when :STRING
              value.string_value
            when :BYTES
              StringIO.new Base64.decode64 value.string_value
            when :ARRAY
              value.list_value.values.map do |v|
                grpc_value_to_object v, type.array_element_type
              end
            when :STRUCT
              Data.from_grpc value.list_value.values, type.struct_type.fields
            when :NUMERIC
              BigDecimal value.string_value
            when :JSON
              JSON.parse value.string_value
            end
          end

          def row_to_pairs row_types, row
            row_types.zip(row).map do |field, value|
              [field.name.to_sym, grpc_value_to_object(value, field.type)]
            end
          end

          def row_to_object row_types, row
            Hash[row_to_pairs(row_types, row)]
          end

          def number_to_duration number
            return nil if number.nil?

            Google::Protobuf::Duration.new \
              seconds: number.to_i,
              nanos: (number.remainder(1) * 1000000000).round
          end

          def duration_to_number duration
            return nil if duration.nil?

            return duration.seconds if duration.nanos == 0

            duration.seconds + (duration.nanos / 1000000000.0)
          end

          def time_to_timestamp time
            return nil if time.nil?

            # Force the object to be a Time object.
            time = time.to_time

            Google::Protobuf::Timestamp.new \
              seconds: time.to_i,
              nanos: time.nsec
          end

          def timestamp_to_time timestamp
            return nil if timestamp.nil?

            Time.at timestamp.seconds, Rational(timestamp.nanos, 1000)
          end

          def to_key_range range
            range_opts = {
              start_closed: object_to_grpc_value(Array(range.begin)).list_value,
              end_closed: object_to_grpc_value(Array(range.end)).list_value }

            if range.respond_to?(:exclude_begin?) && range.exclude_begin?
              range_opts[:start_open] = range_opts[:start_closed]
              range_opts.delete :start_closed
            end
            if range.exclude_end?
              range_opts[:end_open] = range_opts[:end_closed]
              range_opts.delete :end_closed
            end

            V1::KeyRange.new range_opts
          end

          def to_key_set keys
            return V1::KeySet.new(all: true) if keys.nil?
            keys = [keys] unless keys.is_a? Array
            return V1::KeySet.new(all: true) if keys.empty?

            if keys_are_ranges? keys
              key_ranges = keys.map { |r| to_key_range(r) }
              return V1::KeySet.new(ranges: key_ranges)
            end

            key_list = keys.map do |key|
              key = [key] unless key.is_a? Array
              object_to_grpc_value(key).list_value
            end
            V1::KeySet.new keys: key_list
          end

          def keys_are_ranges? keys
            keys.each do |key|
              return true if key.is_a? ::Range
              return true if key.is_a? Google::Cloud::Spanner::Range
            end
            false
          end

          def to_input_params_and_types params, types
            input_params = nil
            input_param_types = nil
            unless params.nil?
              input_param_pairs = to_query_params params, types
              input_params = Google::Protobuf::Struct.new \
                fields: Hash[input_param_pairs.map { |k, v| [k, v.first] }]
              input_param_types = Hash[
                  input_param_pairs.map { |k, v| [k, v.last] }]
            end

            [input_params, input_param_types]
          end

          ##
          # Build request options by replacing tag to respecitve statistics
          # collection tag type.
          #
          # @param [Hash] options Common request options.
          #   * `:tag` (String) A tag used for statistics collection.
          #
          # @param [Symbol] tag_type Request tag type.
          #   Possible values are `request_tag`, `transaction_tag`
          # @return [Hash, nil]
          #
          def to_request_options options, tag_type: nil
            return unless options

            return options unless options.key? :tag

            options.transform_keys { |k| k == :tag ? tag_type : k }
          end
        end

        # rubocop:enable all

        extend ClassMethods
      end
    end
  end
end
