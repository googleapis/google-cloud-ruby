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
      attr_reader :key

      ##
      # Create a new Entity object.
      def initialize
        @_entity = Proto::Entity.new
        @_entity.property = []
        @key = Key.new
        @_exclude_indexes = {}
      end

      ##
      # Retrieve a property value.
      #
      #   puts entity["name"]
      def [] prop_name
        prop_name = prop_name.to_s
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
        prop = Array(@_entity.property).find { |p| p.name == prop_name }
        prop ||= Proto::Property.new.tap do |p|
          p.name = prop_name
          @_entity.property ||= []
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
      # Sets the Key that identifies the entity.
      # This can only be set before the entity is saved.
      # Once the entity is saved, the key is frozen and immutable.
      #
      # Trying to set a key when immutable will raise a RuntimeError.
      #
      #   task = dataset.find "Task", 123456
      #   task.persisted? #=> true
      #   task.key = Gcloud::Datastore::Key.new "Task", 456789 #=> RuntimeError
      #   task.key.frozen? #=> true
      #   task.key.id = 456789 #=> RuntimeError
      def key= new_key
        fail "This entity's key is immutable." if persisted?
        @key = new_key
      end

      ##
      # Returns true if the record is persisted to the datastore.
      # Otherwise returns false.
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
      #   entity.exclude_from_indexes? "tags" #=> true [false, false]
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
        update_properties_indexed!
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
        entity.send :update_exclude_indexes!
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
      def update_exclude_indexes! #:nodoc:
        @_exclude_indexes = {}
        Array(@_entity.property).each do |property|
          @_exclude_indexes[property.name] = property.value.indexed
          unless property.value.list_value.nil?
            exclude = Array(property.value.list_value).map(&:indexed)
            @_exclude_indexes[property.name] = exclude
          end
        end
      end

      ##
      # Update the indexed values before the object is saved.
      def update_properties_indexed! #:nodoc:
        Array(@_entity.property).each do |property|
          excluded = exclude_from_indexes? property.name
          if excluded.is_a? Array
            # Lists are never indexed
            property.value.indexed = false
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
