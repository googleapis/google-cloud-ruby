# Copyright 2016 Google Inc. All rights reserved.
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


require "google/cloud"
require "google/protobuf/struct"

module Google
  module Cloud
    ##
    # @private Conversion to/from GRPC objects.
    module GRPCUtils
      ##
      # @private Convert a Hash to a Google::Protobuf::Struct.
      def self.hash_to_struct hash
        # TODO: ArgumentError if hash is not a Hash
        Google::Protobuf::Struct.new fields:
          Hash[hash.map { |k, v| [String(k), object_to_value(v)] }]
      end

      ##
      # @private Convert a Google::Protobuf::Struct to a Hash.
      def self.struct_to_hash struct
        # TODO: ArgumentError if struct is not a Google::Protobuf::Struct
        Hash[struct.fields.map { |k, v| [k, value_to_object(v)] }]
      end

      ##
      # @private Convert a Google::Protobuf::Value to an Object.
      def self.value_to_object value
        # TODO: ArgumentError if struct is not a Google::Protobuf::Value
        if value.null_value
          nil
        elsif value.number_value
          value.number_value
        elsif value.struct_value
          struct_to_hash value.struct_value
        elsif value.list_value
          value.list_value.values.map { |v| value_to_object(v) }
        elsif !value.bool_value.nil? # Make sure its a bool, not nil
          value.bool_value
        else
          nil # just in case
        end
      end

      ##
      # @private Convert an Object to a Google::Protobuf::Value.
      def self.object_to_value obj
        case obj
        when String then Google::Protobuf::Value.new string_value: obj
        when Array then Google::Protobuf::ListValue.new(values:
          obj.map { |o| object_to_value(o) })
        when Hash then Google::Protobuf::Value.new struct_value:
          hash_to_struct(obj)
        when Numeric then Google::Protobuf::Value.new number_value: obj
        when TrueClass then Google::Protobuf::Value.new bool_value: true
        when FalseClass then Google::Protobuf::Value.new bool_value: false
        when NilClass then Google::Protobuf::Value.new null_value: :NULL_VALUE
        else
          # We could raise ArgumentError here, or we could convert to a string.
          Google::Protobuf::Value.new string_value: obj.to_s
        end
      end

      ##
      # @private Convert a Google::Protobuf::Map to a Hash
      def self.map_to_hash map
        if map.respond_to? :to_h
          map.to_h
        else
          # Enumerable doesn't have to_h on ruby 2.0...
          Hash[map.to_a]
        end
      end
    end
  end
end
