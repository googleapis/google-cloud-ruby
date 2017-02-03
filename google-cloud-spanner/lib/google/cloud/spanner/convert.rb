# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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

module Google
  module Cloud
    module Spanner
      ##
      # @private Helper module for converting Spanner values.
      module Convert
        # rubocop:disable all

        module ClassMethods
          def raw_to_params input_params
            formatted_params = input_params.map do |key, obj|
              [String(key), raw_to_param_and_type(obj)]
            end
            Hash[formatted_params]
          end

          def raw_to_param_and_type obj
            if NilClass === obj
              [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
               Google::Spanner::V1::Type.new(code: :INT64)]
            elsif String === obj
              [raw_to_value(obj), Google::Spanner::V1::Type.new(code: :STRING)]
            elsif Symbol === obj
              [raw_to_value(obj.to_s),
               Google::Spanner::V1::Type.new(code: :STRING)]
            elsif TrueClass === obj
              [raw_to_value(obj), Google::Spanner::V1::Type.new(code: :BOOL)]
            elsif FalseClass === obj
              [raw_to_value(obj), Google::Spanner::V1::Type.new(code: :BOOL)]
            elsif Integer === obj
              [raw_to_value(obj.to_s),
               Google::Spanner::V1::Type.new(code: :INT64)]
            elsif Numeric === obj # Any number not an integer gets to be a float
              [raw_to_value(obj),
               Google::Spanner::V1::Type.new(code: :FLOAT64)]
            elsif Time === obj
              [raw_to_value(obj.utc.strftime('%FT%TZ')),
               Google::Spanner::V1::Type.new(code: :TIMESTAMP)]
            elsif DateTime === obj
              [raw_to_value(obj.to_time.utc.strftime('%FT%TZ')),
               Google::Spanner::V1::Type.new(code: :TIMESTAMP)]
            elsif Date === obj
              [raw_to_value(obj.to_s),
               Google::Spanner::V1::Type.new(code: :DATE)]
            elsif Array === obj
              # Use recursion to get the param type for the first item the list
              nested_param_type = raw_to_param_and_type(obj.first).last
              [raw_to_value(obj),
               Google::Spanner::V1::Type.new(
                code: :ARRAY, array_element_type: nested_param_type)]
            elsif Hash === obj
              field_pairs = obj.map do |key, value|
                [key, raw_to_param_and_type(value).last]
              end
              formatted_fields = field_pairs.map do |name, param_type|
                Google::Spanner::V1::StructType::Field.new(
                  name: String(name), type: param_type
                )
              end
              [raw_to_value(obj),
               Google::Spanner::V1::Type.new(
                code: :STRUCT,
                struct_type: Google::Spanner::V1::StructType.new(
                  fields: formatted_fields
                ))]
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              obj.rewind
              [raw_to_value(obj.read.force_encoding("ASCII-8BIT")),
               Google::Spanner::V1::Type.new(code: :BYTES)]
            else
              raise ArgumentError,
                    "A parameter of type #{obj.class} is not supported."
            end
          end

          def raw_to_value obj
            if NilClass === obj
              Google::Protobuf::Value.new null_value: :NULL_VALUE
            elsif String === obj
              Google::Protobuf::Value.new string_value: obj
            elsif Symbol === obj
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
                obj.to_time.utc.strftime('%FT%TZ'))
            elsif Date === obj
              Google::Protobuf::Value.new string_value: obj.to_s
            elsif Array === obj
              Google::Protobuf::Value.new list_value:
                Google::Protobuf::ListValue.new(values:
                  obj.map { |o| raw_to_value(o) })
            elsif Hash === obj
              Google::Protobuf::Value.new struct_value:
                Google::Protobuf::Struct.new(fields:
                  Hash[obj.map { |k, v| [String(k), raw_to_value(v)] }])
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              obj.rewind
              content = obj.read.force_encoding("ASCII-8BIT")
              encoded_content = Base64.strict_encode64(content)
              [Google::Protobuf::Value.new(string_value: encoded_content),
               Google::Spanner::V1::Type.new(code: :BYTES)]
            else
              raise ArgumentError,
                    "A value of type #{obj.class} is not supported."
            end
          end

          def row_to_raw row_types, row
            # this calls to_ruby on the value objects.
            Hash[row_types.zip(row).map do |field, value|
              [field.name.to_sym, value_to_raw(value, field.type)]
            end]
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
              # Unsupported query shape: A struct value cannot be returned as a
              # column value. Rewrite the query to flatten the struct fields in
              # the result.
              fail "STRUCT not implemented yet"
            end
          end

          ##
          # @private Convert an Object to a Google::Protobuf::Value.
          def object_to_value obj
            case obj
            when NilClass then Google::Protobuf::Value.new null_value:
              :NULL_VALUE
            when Numeric then Google::Protobuf::Value.new number_value: obj
            when String then Google::Protobuf::Value.new string_value: obj
            when TrueClass then Google::Protobuf::Value.new bool_value: true
            when FalseClass then Google::Protobuf::Value.new bool_value: false
            when Hash then Google::Protobuf::Value.new struct_value:
              hash_to_struct(obj)
            when Array then Google::Protobuf::Value.new list_value:
              Google::Protobuf::ListValue.new(values:
                obj.map { |o| object_to_value(o) })
            else
              # TODO: Could raise ArgumentError here, or convert to a string
              Google::Protobuf::Value.new string_value: obj.to_s
            end
          end

          ##
          # @private Convert a Google::Protobuf::Value to an Object.
          def value_to_object value
            # TODO: ArgumentError if struct is not a Google::Protobuf::Value
            if value.kind == :null_value
              nil
            elsif value.kind == :number_value
              value.number_value
            elsif value.kind == :string_value
              value.string_value
            elsif value.kind == :bool_value
              value.bool_value
            elsif value.kind == :struct_value
              struct_to_hash value.struct_value
            elsif value.kind == :list_value
              value.list_value.values.map { |v| value_to_object(v) }
            else
              nil # just in case
            end
          end
        end

        # rubocop:enable all

        extend ClassMethods
      end
    end
  end
end
