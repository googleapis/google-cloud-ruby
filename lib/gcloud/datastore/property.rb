# Copyright 2014 Google Inc. All rights reserved.
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

require "gcloud/proto/datastore_v1.pb"
require "gcloud/datastore/key"

module Gcloud
  module Datastore
    ##
    # Property is a helper for converting primitive types
    # to the Protocol Buffer Value objects, and vice versa.
    #
    # This module is an implementation detail and as such
    # should not be relied on. It is not part of the public
    # API that gcloud intends to expose. The implementation,
    # and the module's existance, may change without warning.
    module Property #:nodoc:
      # rubocop:disable all
      def self.decode proto_value
        if !proto_value.timestamp_microseconds_value.nil?
          microseconds = proto_value.timestamp_microseconds_value
          self.time_from_microseconds microseconds
        elsif !proto_value.key_value.nil?
          Key.from_proto(proto_value.key_value)
        elsif !proto_value.boolean_value.nil?
          proto_value.boolean_value
        elsif !proto_value.double_value.nil?
          proto_value.double_value
        elsif !proto_value.integer_value.nil?
          proto_value.integer_value
        elsif !proto_value.string_value.nil?
          return proto_value.string_value
        else
          nil
        end # TODO: blob? Entity?
      end

      def self.encode value
        v = Proto::Value.new
        if Time === value
          v.timestamp_microseconds_value = self.microseconds_from_time value
        elsif Key === value
          v.key_value = value.to_proto
        elsif TrueClass === value
          v.boolean_value = true
        elsif FalseClass === value
          v.boolean_value = false
        elsif Float === value
          v.double_value = value
        elsif defined?(BigDecimal) && BigDecimal === value
          v.double_value = value
        elsif Integer === value
          v.integer_value = value
        elsif String === value
          v.string_value = value
        end # TODO: entity, blob_value, blob_key_value, list_value
        v
      end
      # rubocop:enable all

      def self.microseconds_from_time time
        (time.utc.to_f * 1000000).to_i
      end

      def self.time_from_microseconds microseconds
        Time.at(microseconds / 1000000, microseconds % 1000000).utc
      end
    end
  end
end
