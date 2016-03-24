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

module Gcloud
  ##
  # @private Conversion to/from Datastore GRPC objects.
  # This file adds Datastore methods to GRPCUtils.
  module GRPCUtils
    ##
    # Gets an object from a Google::Datastore::V1beta3::Value.
    def self.from_value grpc_value
      return nil if grpc_value.nil?
      if !grpc_value.timestamp_value.nil?
        Time.at grpc_value.timestamp_value.seconds,
                grpc_value.timestamp_value.nanos/1000.0
      elsif !grpc_value.key_value.nil?
        Gcloud::Datastore::Key.from_grpc(grpc_value.key_value)
      elsif !grpc_value.entity_value.nil?
        Gcloud::Datastore::Entity.from_grpc(grpc_value.entity_value)
      elsif !grpc_value.boolean_value.nil?
        grpc_value.boolean_value
      elsif !grpc_value.double_value.nil?
        grpc_value.double_value
      elsif !grpc_value.integer_value.nil?
        grpc_value.integer_value
      elsif !grpc_value.string_value.nil?
        return grpc_value.string_value
      elsif !grpc_value.array_value.nil?
        return Array(grpc_value.array_value.values).map { |v| from_value v }
      else
        nil
      end
    end

    ##
    # Stores an object into a Google::Datastore::V1beta3::Value.
    def self.to_value value
      v = Google::Datastore::V1beta3::Value.new
      if NilClass === value
        v = nil
        # v.null_value = Google::Protobuf::NullValue
        # The correct behavior is to not set a value property
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
      elsif Time === value
        v.timestamp_value = Google::Protobuf::Timestamp.new(
          seconds: value.to_i, nanos: value.nsec)
      elsif Gcloud::Datastore::Key === value
        v.key_value = value.to_grpc
      elsif Gcloud::Datastore::Entity === value
        v.entity_value = value.to_grpc
      elsif String === value
        v.string_value = value
      elsif Array === value
        v.array_value = Google::Datastore::V1beta3::ArrayValue.new(
          values: value.map { |v| to_value v }
        )
      else
        fail PropertyError, "A property of type #{value.class} is not supported."
      end
      v
    end
  end
end
