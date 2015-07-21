#--
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
require "gcloud/datastore/properties"
require "gcloud/datastore/proto"

module Gcloud
  module Datastore
    ##
    # = Entity
    #
    # Entity represents a Datastore record.
    # Every Entity has a Key, and a list of properties.
    #
    #   entity = Gcloud::Datastore::Entity.new
    #   entity.key = Gcloud::Datastore::Key.new "User", "username"
    #   entity["name"] = "User McUser"
    #   entity["email"] = "user@example.net"
    class Entity
      ##
      # The Key that identifies the entity.
      attr_reader :key

      ##
      # Create a new Entity object.
      def initialize
        @properties = Properties.new
        @key = Key.new
        @_exclude_indexes = {}
      end

      ##
      # Retrieve a property value by providing the name.
      #
      # === Parameters
      #
      # +prop_name+::
      #   The name of the property. (+String+ or +Symbol+)
      #
      # === Returns
      #
      # Object if the property exists, +nil+ if the property doesn't exist
      #
      # === Example
      #
      # Properties can be retrieved with a string name:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = datastore.find "User", "heidi"
      #   user["name"] #=> "Heidi Henderson"
      #
      # Or with a symbol name:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = datastore.find "User", "heidi"
      #   user[:name] #=> "Heidi Henderson"
      #
      def [] prop_name
        @properties[prop_name]
      end

      ##
      # Set a property value by name.
      #
      # === Parameters
      #
      # +prop_name+::
      #   The name of the property. (+String+ or +Symbol+)
      # +prop_value+::
      #   The value of the property. (+Object+)
      #
      # === Example
      #
      # Properties can be set with a string name:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = datastore.find "User", "heidi"
      #   user["name"] = "Heidi H. Henderson"
      #
      # Or with a symbol name:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = datastore.find "User", "heidi"
      #   user[:name] = "Heidi H. Henderson"
      #
      def []= prop_name, prop_value
        @properties[prop_name] = prop_value
      end

      ##
      # Retrieve properties in a hash-like structure.
      # Properties can be accessed or set by string or symbol.
      #
      # === Returns
      #
      # Gcloud::Datastore::Properties
      #
      # === Example
      #
      #   entity.properties[:name] = "User McUser"
      #   entity.properties["name"] #=> "User McUser"
      #
      #   entity.properties.each do |name, value|
      #     puts "property #{name} has a value of #{value}"
      #   end
      #
      # A property's existance can be determined by calling exist?
      #
      #   entity.properties.exist? :name #=> true
      #   entity.properties.exist? "name" #=> true
      #   entity.properties.exist? :expiration #=> false
      #
      # A property can be removed from the entity.
      #
      #   entity.properties.delete :name
      #   entity.save
      #
      # The properties can be converted to a hash:
      #
      #   prop_hash = entity.properties.to_h
      #
      attr_reader :properties

      ##
      # Sets the Key that identifies the entity.
      #
      # === Example
      #
      # The Key can be set before the entity is saved.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   entity = Gcloud::Datastore::Entity.new
      #   entity.key = Gcloud::Datastore::Key.new "User"
      #   dataset.save entity
      #
      # Once the entity is saved, the key is frozen and immutable.
      # Trying to set a key when immutable will raise a +RuntimeError+.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   entity = dataset.find "User", "heidi"
      #   entity.persisted? #=> true
      #   entity.key = Gcloud::Datastore::Key.new "User" #=> RuntimeError
      #   entity.key.frozen? #=> true
      #   entity.key.id = 9876543221 #=> RuntimeError
      #
      def key= new_key
        fail "This entity's key is immutable." if persisted?
        @key = new_key
      end

      ##
      # Indicates if the record is persisted. Default is false.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   new_entity = Gcloud::Datastore::Entity.new
      #   new_entity.persisted? #=> false
      #
      #   found_entity = dataset.find "User", "heidi"
      #   found_entity.persisted? #=> true
      #
      def persisted?
        @key && @key.frozen?
      end

      ##
      # Indicates if a property is flagged to be excluded from the
      # Datastore indexes. The default value is false.
      #
      # Single property values will return a single flag setting.
      #
      #   entity["age"] = 21
      #   entity.exclude_from_indexes? "age" #=> false
      #
      # Array property values will return an array of flag settings.
      #
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes? "tags" #=> [false, false]
      def exclude_from_indexes? name
        value = self[name]
        flag = @_exclude_indexes[name.to_s]
        map_exclude_flag_to_value flag, value
      end

      ##
      # Flag a property to be excluded from the Datastore indexes.
      # Setting true will exclude the property from the indexes.
      # Setting false will include the property on any applicable indexes.
      # The default value for the flag is false.
      #
      #   entity["age"] = 21
      #   entity.exclude_from_indexes! "age", true
      #
      # Properties that are arrays can be given multiple exclude flags.
      #
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes! "tags", [true, false]
      #
      # Or, array properties can be given a single flag that will be applied
      # to each item in the array.
      #
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes! "tags", true
      #
      # Flags can also be set with a block for either single and array values.
      #
      #   entity["age"] = 21
      #   entity.exclude_from_indexes! "age" do |age|
      #     age > 18
      #   end
      def exclude_from_indexes! name, flag = nil, &block
        name = name.to_s
        flag = block if block_given?
        if flag.nil?
          @_exclude_indexes.delete name
        else
          @_exclude_indexes[name] = flag
        end
      end

      ##
      # Convert the Entity to a protocol buffer object.
      # This is not part of the public API.
      def to_proto #:nodoc:
        entity = Proto::Entity.new.tap do |e|
          e.key = @key.to_proto
          e.property = Proto.to_proto_properties @properties.to_h
        end
        update_properties_indexed! entity
        entity
      end

      ##
      # Create a new Entity from a protocol buffer object.
      # This is not part of the public API.
      def self.from_proto proto #:nodoc:
        entity = Entity.new
        entity.key = Key.from_proto proto.key
        Array(proto.property).each do |p|
          entity[p.name] = Proto.from_proto_value p.value
        end
        entity.send :update_exclude_indexes!, proto
        entity
      end

      protected

      # rubocop:disable all
      # Disabled rubocop because this is intentionally complex.

      ##
      # Map the exclude flag object to value.
      # The flag object can be a boolean, Proc, or Array.
      # Procs will be called and passed in the value.
      # This will return an array of flags for an array value.
      def map_exclude_flag_to_value flag, value #:nodoc:
        if value.is_a? Array
          if flag.is_a? Proc
            value.map { |v| !!flag.call(v) }
          elsif flag.is_a? Array
            (flag + Array.new(value.size)).slice(0, value.size).map { |v| !!v }
          else
            value.map { |_| !!flag }
          end
        else
          if flag.is_a? Proc
            !!flag.call(value)
          elsif flag.is_a? Array
            !!flag.first
          else
            !!flag
          end
        end
      end

      ##
      # Update the exclude data after a new object is created.
      def update_exclude_indexes! entity #:nodoc:
        @_exclude_indexes = {}
        Array(entity.property).each do |property|
          @_exclude_indexes[property.name] = property.value.indexed
          unless property.value.list_value.nil?
            exclude = Array(property.value.list_value).map(&:indexed)
            @_exclude_indexes[property.name] = exclude
          end
        end
      end

      ##
      # Update the indexed values before the object is saved.
      def update_properties_indexed! entity #:nodoc:
        Array(entity.property).each do |property|
          excluded = exclude_from_indexes? property.name
          if excluded.is_a? Array
            # Lists must not set indexed, or this error will happen:
            # "A Value containing a list_value cannot specify indexed."
            property.value.indexed = nil
            property.value.list_value.each_with_index do |value, index|
              value.indexed = !excluded[index]
            end
          else
            property.value.indexed = !excluded
          end
        end
      end

      # rubocop:enable all
    end
  end
end
