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

require "gcloud/datastore/key"
require "gcloud/datastore/proto"

module Gcloud
  module Datastore
    ##
    # Entity represents the Datastore record.
    # Every Entity has a Key, and a list of properties.
    #
    #   entity = Gcloud::Datastore::Entity.new
    #   entity.key = Gcloud::Datastore::Key.new "User", "username"
    #   entity["name"] = "User McUser"
    #   entity["email"] = "user@example.net"
    class Entity
      ##
      # The Key that identifies the entity.
      attr_accessor :key

      ##
      # Create a new Entity object.
      def initialize
        @_entity = Proto::Entity.new
        @_entity.key = Proto::Key.new
        @_entity.property = []
        @key = Key.from_proto @_entity.key
      end

      ##
      # Retrieve a property value.
      #
      #   puts entity["name"]
      def [] prop_name
        prop = Array(@_entity.property).find { |p| p.name == prop_name }
        Proto.from_proto_value prop.value
      rescue
        nil
      end

      ##
      # Set a property value.
      #
      #   entity["name"] = "User McUser"
      def []= prop_name, prop_value
        prop = @_entity.property.find { |p| p.name == prop_name }
        prop ||= Proto::Property.new.tap do |p|
          p.name = prop_name
          @_entity.property << p
        end
        prop.value = Proto.to_proto_value prop_value
        prop_value
      end

      ##
      # Retrieve all properties as an array of arrays.
      # The inner arrays hold the property name and value.
      #
      #   entity.properties.each do |name, value|
      #     puts "#{name} has a value of #{value}"
      #   end
      #
      # The properties can easilly be converted to a hash:
      #
      #   prop_hash = Hash[entity.properties]
      #   prop_hash = entity.properties.to_h
      def properties
        Array(@_entity.property).map do |p|
          [p.name, Proto.from_proto_value(p.value)]
        end
      end

      ##
      # Convert the Entity to a protocol buffer object.
      # This is not part of the public API.
      def to_proto #:nodoc:
        @_entity.key = @key.to_proto
        @_entity
      end

      ##
      # Create a new Entity from a protocol buffer object.
      # This is not part of the public API.
      def self.from_proto proto #:nodoc:
        key    = Key.from_proto proto.key
        entity = Entity.new
        entity.instance_variable_set :@_entity, proto
        entity.instance_variable_set :@key, key
        entity
      end
    end
  end
end
