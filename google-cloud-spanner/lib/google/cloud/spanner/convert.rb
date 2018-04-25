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
              [String(key), raw_to_value_and_type(obj, types[key])]
            end
            Hash[formatted_params]
          end

          def raw_to_value_and_type obj, field = nil
            obj = obj.to_column_value if obj.respond_to? :to_column_value
            field ||= field_for_raw obj

            [raw_to_value(obj), type_for_field(field)]
          end

          def field_for_raw obj
            if NilClass === obj
              raise ArgumentError, "Cannot determine type for nil values."
            elsif String === obj || Symbol === obj
              :STRING
            elsif TrueClass === obj || FalseClass === obj
              :BOOL
            elsif Integer === obj
              :INT64
            elsif Numeric === obj # Any number not an integer gets to be a float
              :FLOAT64
            elsif Time === obj || DateTime === obj
              :TIMESTAMP
            elsif Date === obj
              :DATE
            elsif Array === obj
              if obj.empty?
                raise ArgumentError,
                      "Cannot determine type for empty array values."
              end
              non_nil_fields = obj.compact.map { |e| field_for_raw e }.compact
              if non_nil_fields.empty?
                raise ArgumentError,
                      "Cannot determine type for array of nil values."
              end
              if non_nil_fields.uniq.count > 1
                raise ArgumentError,
                      "Cannot determine type for array of different values."
              end
              [non_nil_fields.first]
            # elsif Hash === obj
            #   raw_type_pairs = obj.map do |key, value|
            #     [key, field_for_raw(value)]
            #   end
            #   Fields.new Hash[raw_type_pairs]
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              :BYTES
            else
              raise ArgumentError,
                    "Cannot determine type for #{obj.class} values."
            end
          end

          def type_for_field field
            if Array === field
              Google::Spanner::V1::Type.new(
                code: :ARRAY,
                array_element_type: type_for_field(field.first)
              )
            else
              Google::Spanner::V1::Type.new(code: field)
            end
          end

          def raw_to_value obj
            obj = obj.to_column_value if obj.respond_to? :to_column_value

            if NilClass === obj
              Google::Protobuf::Value.new null_value: :NULL_VALUE
            elsif String === obj || Symbol === obj
              Google::Protobuf::Value.new string_value: obj.to_s
            elsif TrueClass === obj
              Google::Protobuf::Value.new bool_value: true
            elsif FalseClass === obj
              Google::Protobuf::Value.new bool_value: false
            elsif Integer === obj
              Google::Protobuf::Value.new string_value: obj.to_s
            elsif Numeric === obj # Any number not an integer gets to be a float
              if obj == Float::INFINITY
                Google::Protobuf::Value.new string_value: "Infinity"
              elsif obj == -Float::INFINITY
                Google::Protobuf::Value.new string_value: "-Infinity"
              elsif obj.respond_to?(:nan?) && obj.nan?
                Google::Protobuf::Value.new string_value: "NaN"
              else
                Google::Protobuf::Value.new number_value: obj.to_f
              end
            elsif Time === obj || DateTime === obj
              Google::Protobuf::Value.new(string_value:
                obj.to_time.utc.strftime("%FT%T.%NZ"))
            elsif Date === obj
              Google::Protobuf::Value.new string_value: obj.to_s
            elsif Array === obj
              Google::Protobuf::Value.new list_value:
                Google::Protobuf::ListValue.new(values:
                  obj.map { |o| raw_to_value(o) })
            # elsif Hash === obj
            #   Google::Protobuf::Value.new struct_value:
            #     Google::Protobuf::Struct.new(fields:
            #       Hash[obj.map { |k, v| [String(k), raw_to_value(v)] }])
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              obj.rewind
              content = obj.read.force_encoding("ASCII-8BIT")
              encoded_content = Base64.strict_encode64(content)
              Google::Protobuf::Value.new(string_value: encoded_content)
            else
              raise ArgumentError,
                    "A value of type #{obj.class} is not supported."
            end
          end

          def row_to_pairs row_types, row
            row_types.zip(row).map do |field, value|
              [field.name.to_sym, value_to_raw(value, field.type)]
            end
          end

          def row_to_raw row_types, row
            Hash[row_to_pairs(row_types, row)]
          end

          def value_to_raw value, type
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
                value_to_raw v, type.array_element_type
              end
            when :STRUCT
              Data.from_grpc value.list_value.values, type.struct_type.fields
            end
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
              start_closed: raw_to_value(Array(range.begin)).list_value,
              end_closed: raw_to_value(Array(range.end)).list_value }

            if range.respond_to?(:exclude_begin?) && range.exclude_begin?
              range_opts[:start_open] = range_opts[:start_closed]
              range_opts.delete :start_closed
            end
            if range.exclude_end?
              range_opts[:end_open] = range_opts[:end_closed]
              range_opts.delete :end_closed
            end

            Google::Spanner::V1::KeyRange.new range_opts
          end

          def to_key_set keys
            return Google::Spanner::V1::KeySet.new(all: true) if keys.nil?
            keys = [keys] unless keys.is_a? Array
            return Google::Spanner::V1::KeySet.new(all: true) if keys.empty?

            if keys_are_ranges? keys
              key_ranges = keys.map { |r| to_key_range(r) }
              return Google::Spanner::V1::KeySet.new(ranges: key_ranges)
            end

            key_list = keys.map do |key|
              key = [key] unless key.is_a? Array
              raw_to_value(key).list_value
            end
            Google::Spanner::V1::KeySet.new keys: key_list
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
        end

        # rubocop:enable all

        extend ClassMethods
      end
    end
  end
end
