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
require "gcloud/datastore/property"
require "gcloud/proto/datastore_v1.pb"

module Gcloud
  module Datastore
    ##
    # Datastore Entity
    #
    # Represents the Datastore record.
    # Every Datastore record has an identifying key, and a list of properties.
    class Entity
      attr_accessor :key
      def initialize
        @_entity = Proto::Entity.new
        @_entity.key = Proto::Key.new
        @_entity.property = []
        @key = Key.from_proto @_entity.key
      end

      def [] prop_name
        prop = Array(@_entity.property).find { |p| p.name == prop_name }
        Property.decode prop.value
      rescue
        nil
      end

      def []= prop_name, prop_value
        prop = @_entity.property.find { |p| p.name == prop_name }
        prop ||= Proto::Property.new.tap do |p|
          p.name = prop_name
          @_entity.property << p
        end
        prop.value = Property.encode prop_value
        prop_value
      end

      def properties
        Array(@_entity.property).map { |p| [p.name, Property.decode(p.value)] }
      end

      def to_proto #:nodoc:
        @_entity.key = @key.to_proto
        @_entity
      end

      def self.from_proto proto #:nodoc:
        key    = Key.new
        key.instance_variable_set :@_key, proto.key
        entity = Entity.new
        entity.instance_variable_set :@_entity, proto
        entity.instance_variable_set :@key, key
        entity
      end
    end
  end
end
