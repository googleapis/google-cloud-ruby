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


module Google
  module Cloud
    module Logging
      ##
      # @private Conversion to/from Logging GRPC objects.
      module Convert
        ##
        # @private Convert a Hash to a Google::Protobuf::Struct.
        def self.hash_to_struct hash
          # TODO: ArgumentError if hash is not a Hash
          Google::Protobuf::Struct.new \
            fields: hash.to_h { |k, v| [String(k), object_to_value(v)] }
        end

        ##
        # @private Convert an Array to a Google::Protobuf::ListValue.
        def self.array_to_list array
          # TODO: ArgumentError if array is not an Array
          Google::Protobuf::ListValue.new \
            values: array.map { |o| object_to_value o }
        end

        ##
        # @private Convert an Object to a Google::Protobuf::Value.
        def self.object_to_value obj
          case obj
          when NilClass
            Google::Protobuf::Value.new null_value: :NULL_VALUE
          when Numeric
            Google::Protobuf::Value.new number_value: obj
          when String
            Google::Protobuf::Value.new string_value: obj
          when TrueClass
            Google::Protobuf::Value.new bool_value: true
          when FalseClass
            Google::Protobuf::Value.new bool_value: false
          when Hash
            Google::Protobuf::Value.new struct_value: hash_to_struct(obj)
          when Array
            Google::Protobuf::Value.new list_value: array_to_list(obj)
          else
            # TODO: Could raise ArgumentError here, or convert to a string
            Google::Protobuf::Value.new string_value: obj.to_s
          end
        end

        ##
        # @private Convert a Google::Protobuf::Map to a Hash
        def self.map_to_hash map
          if map.respond_to? :to_h
            map.to_h
          else
            map.to_a.to_h
          end
        end
      end
    end
  end
end
