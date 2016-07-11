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


require "gcloud/grpc_utils"
require "gcloud/datastore/errors"
require "stringio"

module Gcloud
  ##
  # @private Conversion to/from Datastore GRPC objects.
  # This file adds Datastore methods to GRPCUtils.
  module GRPCUtils
    # rubocop:disable all

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
    # Gets an object from a Google::Datastore::V1beta3::Value.
    def self.from_value grpc_value
      if grpc_value.value_type == :null_value
        return nil
      elsif grpc_value.value_type == :key_value
        return Gcloud::Datastore::Key.from_grpc(grpc_value.key_value)
      elsif grpc_value.value_type == :entity_value
        return Gcloud::Datastore::Entity.from_grpc(grpc_value.entity_value)
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
        return StringIO.new(grpc_value.blob_value.force_encoding("ASCII-8BIT"))
      else
        nil
      end
    end

    ##
    # Stores an object into a Google::Datastore::V1beta3::Value.
    def self.to_value value
      v = Google::Datastore::V1beta3::Value.new
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
      elsif Gcloud::Datastore::Key === value
        v.key_value = value.to_grpc
      elsif Gcloud::Datastore::Entity === value
        v.entity_value = value.to_grpc
      elsif String === value
        v.string_value = value
      elsif Array === value
        v.array_value = Google::Datastore::V1beta3::ArrayValue.new(
          values: value.map { |val| to_value val }
        )
      elsif value.respond_to? :to_time
        v.timestamp_value = Google::Protobuf::Timestamp.new(
          seconds: value.to_time.to_i, nanos: value.to_time.nsec)
      elsif value.respond_to?(:to_hash) && value.keys.sort == [:latitude, :longitude]
        v.geo_point_value = Google::Type::LatLng.new(value)
      elsif value.respond_to?(:read) && value.respond_to?(:rewind)
        value.rewind
        v.blob_value = value.read.force_encoding("ASCII-8BIT")
      else
        fail Gcloud::Datastore::PropertyError,
             "A property of type #{value.class} is not supported."
      end
      v
    end

    def self.encode_bytes bytes
      Array(bytes.to_s).pack("m").chomp.encode("ASCII-8BIT")
    end

    def self.decode_bytes bytes
      bytes.to_s.unpack("m").first.force_encoding Encoding::ASCII_8BIT
    end
    # rubocop:enable all
  end
end
