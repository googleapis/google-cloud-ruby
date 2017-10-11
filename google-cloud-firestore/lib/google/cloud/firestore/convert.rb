# Copyright 2017, Google Inc. All rights reserved.
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
require "stringio"

module Google
  module Cloud
    module Firestore
      ##
      # @private Helper module for converting Protobuf values.
      module Convert
        module ClassMethods
          # rubocop:disable all

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

          def fields_to_hash fields, context
            Hash[fields.map do |key, value|
              [key.to_sym, value_to_raw(value, context)]
            end]
          end

          def hash_to_fields hash
            Hash[hash.map do |key, value|
              [String(key), raw_to_value(value)]
            end]
          end

          def value_to_raw value, context
            case value.value_type
            when :null_value
              nil
            when :boolean_value
              value.boolean_value
            when :integer_value
              Integer value.integer_value
            when :double_value
              value.double_value
            when :timestamp_value
              timestamp_to_time value.timestamp_value
            when :string_value
              value.string_value
            when :bytes_value
              StringIO.new Base64.decode64 value.bytes_value
            when :reference_value
              Google::Cloud::Firestore::Document.from_path \
                value.reference_value, context
            when :geo_point_value
              value.geo_point_value.to_hash
            when :array_value
              value.array_value.values.map { |v| value_to_raw v, context }
            when :map_value
              fields_to_hash value.map_value.fields, context
            end
          end

          def raw_to_value obj
            if NilClass === obj
              Google::Firestore::V1beta1::Value.new null_value: :NULL_VALUE
            elsif TrueClass === obj || FalseClass === obj
              Google::Firestore::V1beta1::Value.new boolean_value: obj
            elsif Integer === obj
              Google::Firestore::V1beta1::Value.new integer_value: obj
            elsif Numeric === obj # Any number not an integer is a double
              Google::Firestore::V1beta1::Value.new double_value: obj.to_f
            elsif Time === obj || DateTime === obj || Date === obj
              Google::Firestore::V1beta1::Value.new \
                timestamp_value: time_to_timestamp(obj.to_time)
            elsif String === obj || Symbol === obj
              Google::Firestore::V1beta1::Value.new string_value: obj.to_s
            elsif Google::Cloud::Firestore::Document::Reference === obj
              Google::Firestore::V1beta1::Value.new reference_value: obj.path
            elsif Array === obj
              values = obj.map { |o| raw_to_value(o) }
              Google::Firestore::V1beta1::Value.new(array_value:
                Google::Firestore::V1beta1::ArrayValue.new(values: values))
            elsif Hash === obj
              if obj.keys.sort == [:latitude, :longitude]
                Google::Firestore::V1beta1::Value.new(geo_point_value:
                  Google::Type::LatLng.new(obj))
              else
                fields = hash_to_fields obj
                Google::Firestore::V1beta1::Value.new(map_value:
                  Google::Firestore::V1beta1::MapValue.new(fields: fields))
              end
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              obj.rewind
              content = obj.read.force_encoding "ASCII-8BIT"
              encoded_content = Base64.strict_encode64 content
              Google::Firestore::V1beta1::Value.new bytes_value: encoded_content
            else
              fail ArgumentError,
                   "A value of type #{obj.class} is not supported."
            end
          end

          # rubocop:enable all
        end

        extend ClassMethods
      end
    end
  end
end
