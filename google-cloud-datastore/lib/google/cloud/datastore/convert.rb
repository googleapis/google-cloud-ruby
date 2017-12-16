# Copyright 2017 Google LLC
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


require "google/cloud/datastore/errors"
require "stringio"
require "base64"

module Google
  module Cloud
    module Datastore
      # rubocop:disable all

      ##
      # @private Conversion to/from Datastore GRPC objects.
      module Convert
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

        PROP_FILTER_OPS = { "<"            => :LESS_THAN,
                            "lt"           => :LESS_THAN,
                            "<="           => :LESS_THAN_OR_EQUAL,
                            "lte"          => :LESS_THAN_OR_EQUAL,
                            ">"            => :GREATER_THAN,
                            "gt"           => :GREATER_THAN,
                            ">="           => :GREATER_THAN_OR_EQUAL,
                            "gte"          => :GREATER_THAN_OR_EQUAL,
                            "="            => :EQUAL,
                            "eq"           => :EQUAL,
                            "eql"          => :EQUAL,
                            "~"            => :HAS_ANCESTOR,
                            "~>"           => :HAS_ANCESTOR,
                            "ancestor"     => :HAS_ANCESTOR,
                            "has_ancestor" => :HAS_ANCESTOR,
                            "has ancestor" => :HAS_ANCESTOR }

        ##
        # Get a property filter operator from op
        def self.to_prop_filter_op op
          PROP_FILTER_OPS[op.to_s.downcase] || :EQUAL
        end

        ##
        # Gets an object from a Google::Datastore::V1::Value.
        def self.from_value grpc_value
          if grpc_value.value_type == :null_value
            return nil
          elsif grpc_value.value_type == :key_value
            return Google::Cloud::Datastore::Key.from_grpc(grpc_value.key_value)
          elsif grpc_value.value_type == :entity_value
            return Google::Cloud::Datastore::Entity.from_grpc(
              grpc_value.entity_value)
          elsif grpc_value.value_type == :boolean_value
            return grpc_value.boolean_value
          elsif grpc_value.value_type == :double_value
            return grpc_value.double_value
          elsif grpc_value.value_type == :integer_value
            return grpc_value.integer_value
          elsif grpc_value.value_type == :string_value
            return grpc_value.string_value
          elsif grpc_value.value_type == :array_value
            return Array(grpc_value.array_value.values).map { |v| from_value v }
          elsif grpc_value.value_type == :timestamp_value
            return Time.at grpc_value.timestamp_value.seconds,
                           grpc_value.timestamp_value.nanos/1000.0
          elsif grpc_value.value_type == :geo_point_value
            return grpc_value.geo_point_value.to_hash
          elsif grpc_value.value_type == :blob_value
            return StringIO.new(
              grpc_value.blob_value.dup.force_encoding("ASCII-8BIT"))
          else
            nil
          end
        end

        ##
        # Stores an object into a Google::Datastore::V1::Value.
        def self.to_value value
          v = Google::Datastore::V1::Value.new
          if NilClass === value
            v.null_value = :NULL_VALUE
          elsif TrueClass === value
            v.boolean_value = true
          elsif FalseClass === value
            v.boolean_value = false
          elsif Integer === value
            v.integer_value = value
          elsif Float === value
            v.double_value = value
          elsif defined?(BigDecimal) && BigDecimal === value
            v.double_value = value
          elsif Google::Cloud::Datastore::Key === value
            v.key_value = value.to_grpc
          elsif Google::Cloud::Datastore::Entity === value
            value.key = nil # Embedded entities can't have keys
            v.entity_value = value.to_grpc
          elsif String === value
            v.string_value = value
          elsif Array === value
            v.array_value = Google::Datastore::V1::ArrayValue.new(
              values: value.map { |val| to_value val }
            )
          elsif value.respond_to? :to_time
            v.timestamp_value = Google::Protobuf::Timestamp.new(
              seconds: value.to_time.to_i, nanos: value.to_time.nsec)
          elsif value.respond_to?(:to_hash) &&
                value.keys.sort == [:latitude, :longitude]
            v.geo_point_value = Google::Type::LatLng.new(value)
          elsif value.respond_to?(:read) && value.respond_to?(:rewind)
            value.rewind
            v.blob_value = value.read.force_encoding("ASCII-8BIT")
          else
            fail Google::Cloud::Datastore::PropertyError,
                 "A property of type #{value.class} is not supported."
          end
          v
        end

        def self.encode_bytes bytes
          Base64.strict_encode64(bytes.to_s).encode("ASCII-8BIT")
        end

        def self.decode_bytes bytes
          Base64.decode64(bytes.to_s).force_encoding Encoding::ASCII_8BIT
        end
      end

      # rubocop:enable all
    end
  end
end
