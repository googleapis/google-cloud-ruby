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
    # # Entity
    #
    # Entity represents a Datastore record.
    # Every Entity has a {Key}, and a list of properties.
    #
    # @example
    #   entity = Gcloud::Datastore::Entity.new
    #   entity.key = Gcloud::Datastore::Key.new "User", "heidi@example.com"
    #   entity["name"] = "Heidi Henderson"
    #
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
      # Property values are converted from the Datastore value type
      # automatically. Blob properties are returned as StringIO objects.
      #
      # @param [String, Symbol] prop_name The name of the property.
      #
      # @return [Object, nil] Returns `nil` if the property doesn't exist
      #
      # @example Properties can be retrieved with a string name:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user["name"] #=> "Heidi Henderson"
      #
      # @example Or with a symbol name:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user[:name] #=> "Heidi Henderson"
      #
      # @example Getting a blob value returns a StringIO object:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user["avatar"] #=> StringIO("\x89PNG\r\n\x1A...")
      #
      def [] prop_name
        @properties[prop_name]
      end

      ##
      # Set a property value by name.
      #
      # Property values are converted to use the proper Datastore value type
      # automatically. Use an IO-compatible object (File, StringIO, Tempfile) to
      # indicate the property value should be stored as a Datastore `blob`.
      # IO-compatible objects are converted to StringIO objects when they are
      # set.
      #
      # @param [String, Symbol] prop_name The name of the property.
      # @param [Object] prop_value The value of the property.
      #
      # @example Properties can be set with a string name:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user["name"] = "Heidi H. Henderson"
      #
      # @example Or with a symbol name:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user[:name] = "Heidi H. Henderson"
      #
      # @example Setting a blob value using an IO:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   user = dataset.find "User", "heidi@example.com"
      #   user["avatar"] = File.open "/avatars/heidi.png"
      #   user["avatar"] #=> StringIO("\x89PNG\r\n\x1A...")
      #
      def []= prop_name, prop_value
        @properties[prop_name] = prop_value
      end

      ##
      # Retrieve properties in a hash-like structure.
      # Properties can be accessed or set by string or symbol.
      #
      # @return [Gcloud::Datastore::Properties]
      #
      # @example
      #   entity.properties[:name] = "Heidi H. Henderson"
      #   entity.properties["name"] #=> "Heidi H. Henderson"
      #
      #   entity.properties.each do |name, value|
      #     puts "property #{name} has a value of #{value}"
      #   end
      #
      # @example A property's existence can be determined by calling `exist?`:
      #   entity.properties.exist? :name #=> true
      #   entity.properties.exist? "name" #=> true
      #   entity.properties.exist? :expiration #=> false
      #
      # @example A property can be removed from the entity:
      #   entity.properties.delete :name
      #   entity.save
      #
      # @example The properties can be converted to a hash:
      #   prop_hash = entity.properties.to_h
      #
      attr_reader :properties

      ##
      # Sets the Key that identifies the entity.
      #
      # Once the entity is saved, the key is frozen and immutable. Trying to set
      # a key when immutable will raise a `RuntimeError`.
      #
      # @example The Key can be set before the entity is saved:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   entity = Gcloud::Datastore::Entity.new
      #   entity.key = Gcloud::Datastore::Key.new "User"
      #   dataset.save entity
      #
      # @example Once the entity is saved, the key is frozen and immutable:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   entity = dataset.find "User", "heidi@example.com"
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
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   new_entity = Gcloud::Datastore::Entity.new
      #   new_entity.persisted? #=> false
      #
      #   found_entity = dataset.find "User", "heidi@example.com"
      #   found_entity.persisted? #=> true
      #
      def persisted?
        @key && @key.frozen?
      end

      ##
      # Indicates if a property is flagged to be excluded from the
      # Datastore indexes. The default value is `false`. This is another way of
      # saying that values are indexed by default.
      #
      # If the property is multi-valued, each value in the list can be managed
      # separately for exclusion from indexing. Calling this method for a
      # multi-valued property will return an array that contains the `excluded`
      # boolean value for each corresponding value in the property. For example,
      # if a multi-valued property contains `["a", "b"]`, and only the value
      # `"b"` is indexed (meaning that `"a"`' is excluded), the return value for
      # this method will be `[true, false]`.
      #
      # @see https://cloud.google.com/datastore/docs/concepts/indexes#Datastore_Unindexed_properties
      #   Unindexed properties
      #
      # @example Single property values will return a single flag setting:
      #   entity["age"] = 21
      #   entity.exclude_from_indexes? "age" #=> false
      #
      # @example A multi-valued property will return an array of flag settings:
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes! "tags", [true, false]
      #
      #   entity.exclude_from_indexes? "tags" #=> [true, false]
      #
      def exclude_from_indexes? name
        value = self[name]
        flag = @_exclude_indexes[name.to_s]
        map_exclude_flag_to_value flag, value
      end

      ##
      # Sets whether a property should be excluded from the Datastore indexes.
      # Setting `true` will exclude the property from the indexes.
      # Setting `false` will include the property on any applicable indexes.
      # The default value is `false`. This is another way of saying that values
      # are indexed by default.
      #
      # If the property is multi-valued, each value in the list can be managed
      # separately for exclusion from indexing. When you call this method for a
      # multi-valued property, you can pass either a single boolean argument to
      # be applied to all of the values, or an array that contains the boolean
      # argument for each corresponding value in the property. For example,
      # if a multi-valued property contains `["a", "b"]`, and only the value
      # `"b"` should be indexed (meaning that `"a"`' should be excluded), you
      # should pass the array: `[true, false]`.
      #
      # @param [String] name the property name
      # @param [Boolean, Array<Boolean>, nil] flag whether the value or values
      #   should be excluded from indexing
      # @yield [value] a block yielding each value of the property
      # @yieldparam [Object] value a value of the property
      # @yieldreturn [Boolean] `true` if the value should be excluded from
      #   indexing
      #
      # @see https://cloud.google.com/datastore/docs/concepts/indexes#Datastore_Unindexed_properties
      #   Unindexed properties
      #
      # @example
      #   entity["age"] = 21
      #   entity.exclude_from_indexes! "age", true
      #
      # @example Multi-valued properties can be given multiple exclude flags:
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes! "tags", [true, false]
      #
      # @example Or, a single flag can be applied to all values in a property:
      #   entity["tags"] = ["ruby", "code"]
      #   entity.exclude_from_indexes! "tags", true
      #
      # @example Flags can also be set with a block:
      #   entity["age"] = 21
      #   entity.exclude_from_indexes! "age" do |age|
      #     age > 18
      #   end
      #
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
      # @private Convert the Entity to a protocol buffer object.
      def to_proto
        entity = Proto::Entity.new.tap do |e|
          e.key = @key.to_proto
          e.property = Proto.to_proto_properties @properties.to_h
        end
        update_properties_indexed! entity
        entity
      end

      ##
      # @private Create a new Entity from a protocol buffer object.
      def self.from_proto proto
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
      # @private Map the exclude flag object to value.
      # The flag object can be a boolean, Proc, or Array.
      # Procs will be called and passed in the value.
      # This will return an array of flags for an array value.
      def map_exclude_flag_to_value flag, value
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
      # @private Update the exclude data after a new object is created.
      def update_exclude_indexes! entity
        @_exclude_indexes = {}
        Array(entity.property).each do |property|
          @_exclude_indexes[property.name] = !property.value.indexed
          unless property.value.list_value.nil?
            exclude = Array(property.value.list_value).map{|v| !v.indexed}
            @_exclude_indexes[property.name] = exclude
          end
        end
      end

      ##
      # @private Update the indexed values before the object is saved.
      def update_properties_indexed! entity
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
