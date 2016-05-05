# Copyright 2015 Google Inc. All rights reserved.
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


require "stringio"

module Gcloud
  module Datastore
    ##
    # # Properties
    #
    # Hash-like data structure for Datastore properties.
    #
    # See {Entity#properties}
    class Properties
      def initialize properties = {}
        @hash = {}
        properties.each do |key, value|
          key   = ensure_key_type key
          value = ensure_value_type value
          @hash[key] = value
        end
      end

      def [] key
        key = ensure_key_type key
        @hash[key]
      end
      alias_method :read, :[]

      def []= key, value
        key   = ensure_key_type key
        value = ensure_value_type value
        @hash[key] = value
      end
      alias_method :write, :[]=

      def exist? key
        key = ensure_key_type key
        @hash.key? key
      end

      def fetch key, &_block
        key = ensure_key_type key
        @hash[key] = yield unless exist? key
        @hash[key]
      end

      def each &block
        @hash.each(&block)
      end

      def delete key, &block
        key = ensure_key_type key
        @hash.delete key, &block
      end

      def to_h
        @hash.dup
      end
      alias_method :to_hash, :to_h

      def to_grpc
        Hash[@hash.map { |(k, v)| [k.to_s, GRPCUtils.to_value(v)] }]
      end

      def self.from_grpc grpc_map
        # For some reason Google::Protobuf::Map#map isn't returning the value.
        # It returns nil every time. COnvert to Hash to get actual objects.
        grpc_hash = GRPCUtils.map_to_hash grpc_map
        new Hash[grpc_hash.map { |(k, v)| [k.to_s, GRPCUtils.from_value(v)] }]
      end

      protected

      ##
      # Ensures the key is the proper type,
      # otherwise a PropertyError is raised.
      def ensure_key_type key
        return key.to_str if key.respond_to? :to_str
        fail "Property key #{key} must be a String."
      end

      # rubocop:disable all
      # Disabled rubocop because this needs to match GRPCUtils.to_value

      ##
      # Ensures the value is a type that can be persisted,
      # otherwise a PropertyError is raised.
      def ensure_value_type value
        if Gcloud::Datastore::Key    === value ||
           Gcloud::Datastore::Entity === value ||
           NilClass                  === value ||
           TrueClass                 === value ||
           FalseClass                === value ||
           Float                     === value ||
           Integer                   === value ||
           String                    === value ||
           Array                     === value
          return value
        elsif value.respond_to?(:to_time)
          return value
        elsif value.respond_to?(:to_hash) && value.keys.sort == [:latitude, :longitude]
          return value
        elsif value.respond_to?(:read) && value.respond_to?(:rewind)
          # Always convert an IO object to a StringIO when storing.
          value.rewind
          return StringIO.new(value.read.force_encoding("ASCII-8BIT"))
        elsif defined?(BigDecimal) && BigDecimal === value
          return value
        end
        fail PropertyError, "A property of type #{value.class} is not supported."
      end
      # rubocop:enable all
    end
  end
end
