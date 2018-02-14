# Copyright 2014 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/datastore/key"
require "google/cloud/datastore/properties"

module Google
  module Cloud
    module Datastore
      ##
      # # Entity
      #
      # Entity represents a Datastore record.
      # Every Entity has a {Key}, and a list of properties.
      #
      # Entities in Datastore form a hierarchically structured space similar to
      # the directory structure of a file system. When you create an entity, you
      # can optionally designate another entity as its parent; the new entity is
      # a child of the parent entity.
      #
      # @see https://cloud.google.com/datastore/docs/concepts/entities Entities,
      #   Properties, and Keys
      #
      # @example Create a new entity using a block:
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["created"] = Time.now
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["percent_complete"] = 10.0
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      # @example Create a new entity belonging to an existing parent entity:
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   task_key = datastore.key "Task", "sampleTask"
      #   task_key.parent = datastore.key "TaskList", "default"
      #
      #   task = Google::Cloud::Datastore::Entity.new
      #   task.key = task_key
      #
      #   task["type"] = "Personal"
      #   task["done"] = false
      #   task["priority"] = 4
      #   task["description"] = "Learn Cloud Datastore"
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
        # Location properties are returned as a Hash with `:longitude` and
        # `:latitude` keys.
        #
        # @param [String, Symbol] prop_name The name of the property.
        #
        # @return [Object, nil] Returns `nil` if the property doesn't exist
        #
        # @example Properties can be retrieved with a string name:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task["description"] #=> "Learn Cloud Datastore"
        #
        # @example Or with a symbol name:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task[:description] #=> "Learn Cloud Datastore"
        #
        # @example Getting a blob value returns a StringIO object:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["avatar"].class #=> StringIO
        #
        # @example Getting a geo point value returns a Hash:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["location"].keys #=> [:latitude, :longitude]
        #
        # @example Getting a blob value returns a StringIO object:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["avatar"].class #=> StringIO
        #
        def [] prop_name
          properties[prop_name]
        end

        ##
        # Set a property value by name.
        #
        # Property values are converted to use the proper Datastore value type
        # automatically. Use an IO-compatible object (File, StringIO, Tempfile)
        # to indicate the property value should be stored as a Datastore `blob`.
        # IO-compatible objects are converted to StringIO objects when they are
        # set. Use a Hash with `:longitude` and `:latitude` keys to indicate the
        # property value should be stored as a Geo Point/LatLng.
        #
        # @param [String, Symbol] prop_name The name of the property.
        # @param [Object] prop_value The value of the property.
        #
        # @example Properties can be set with a string name:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task["description"] = "Learn Cloud Datastore"
        #   task["tags"] = ["fun", "programming"]
        #
        # @example Or with a symbol name:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task[:description] = "Learn Cloud Datastore"
        #   task[:tags] = ["fun", "programming"]
        #
        # @example Setting a blob value using an IO:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["avatar"] = File.open "/avatars/alice.png"
        #   user["avatar"].class #=> StringIO
        #
        # @example Setting a geo point value using a Hash:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["location"] = { longitude: -122.0862462, latitude: 37.4220041 }
        #
        # @example Setting a blob value using an IO:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   user = datastore.find "User", "alice"
        #   user["avatar"] = File.open "/avatars/alice.png"
        #   user["avatar"].class #=> StringIO
        #
        def []= prop_name, prop_value
          properties[prop_name] = prop_value
        end

        ##
        # Retrieve properties in a hash-like structure.
        # Properties can be accessed or set by string or symbol.
        #
        # @return [Google::Cloud::Datastore::Properties]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   task.properties[:description] = "Learn Cloud Datastore"
        #   task.properties["description"] #=> "Learn Cloud Datastore"
        #
        #   task.properties.each do |name, value|
        #     puts "property #{name} has a value of #{value}"
        #   end
        #
        # @example A property's existence can be determined by calling `exist?`:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   task.properties.exist? :description #=> true
        #   task.properties.exist? "description" #=> true
        #   task.properties.exist? :expiration #=> false
        #
        # @example A property can be removed from the entity:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   task.properties.delete :description
        #   datastore.update task
        #
        # @example The properties can be converted to a hash:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   prop_hash = task.properties.to_h
        #
        attr_reader :properties

        ##
        # Sets the {Google::Cloud::Datastore::Key} that identifies the entity.
        #
        # Once the entity is saved, the key is frozen and immutable. Trying to
        # set a key when immutable will raise a `RuntimeError`.
        #
        # @example The key can be set before the entity is saved:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = Google::Cloud::Datastore::Entity.new
        #   task.key = datastore.key "Task"
        #   datastore.save task
        #
        # @example Once the entity is saved, the key is frozen and immutable:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task.persisted? #=> true
        #   # Because the entity is persisted, the following would raise
        #   # task.key = datastore.key "Task"
        #   task.key.frozen? #=> true
        #   # Because the key is frozen, the following would raise
        #   # task.key.id = 9876543221
        #
        def key= new_key
          raise "This entity's key is immutable." if persisted?
          @key = new_key
        end

        ##
        # Indicates if the record is persisted. Default is false.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = Google::Cloud::Datastore::Entity.new
        #   task.persisted? #=> false
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task.persisted? #=> true
        #
        def persisted?
          @key && @key.frozen?
        end

        ##
        # Indicates if a property is flagged to be excluded from the Datastore
        # indexes. The default value is `false`. This is another way of saying
        # that values are indexed by default.
        #
        # If the property is multi-valued, each value in the list can be managed
        # separately for exclusion from indexing. Calling this method for a
        # multi-valued property will return an array that contains the
        # `excluded` boolean value for each corresponding value in the property.
        # For example, if a multi-valued property contains `["a", "b"]`, and
        # only the value `"b"` is indexed (meaning that `"a"`' is excluded), the
        # return value for this method will be `[true, false]`.
        #
        # @see https://cloud.google.com/datastore/docs/concepts/indexes#Datastore_Unindexed_properties
        #   Unindexed properties
        #
        # @example Single property values will return a single flag setting:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   task["priority"] = 4
        #   task.exclude_from_indexes? "priority" #=> false
        #
        # @example A multi-valued property will return array of flag settings:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
        #
        #   task["tags"] = ["fun", "programming"]
        #   task.exclude_from_indexes! "tags", [true, false]
        #
        #   task.exclude_from_indexes? "tags" #=> [true, false]
        #
        def exclude_from_indexes? name
          value = self[name]
          flag = @_exclude_indexes[name.to_s]
          map_exclude_flag_to_value flag, value
        end

        ##
        # Sets whether a property should be excluded from the Datastore indexes.
        # Setting `true` will exclude the property from the indexes. Setting
        # `false` will include the property on any applicable indexes. The
        # default value is `false`. This is another way of saying that values
        # are indexed by default.
        #
        # If the property is multi-valued, each value in the list can be managed
        # separately for exclusion from indexing. When you call this method for
        # a multi-valued property, you can pass either a single boolean argument
        # to be applied to all of the values, or an array that contains the
        # boolean argument for each corresponding value in the property. For
        # example, if a multi-valued property contains `["a", "b"]`, and only
        # the value `"b"` should be indexed (meaning that `"a"`' should be
        # excluded), you should pass the array: `[true, false]`.
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
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   entity = datastore.find "Task", "sampleTask"
        #
        #   entity["priority"] = 4
        #   entity.exclude_from_indexes! "priority", true
        #
        # @example Multi-valued properties can be given multiple exclude flags:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   entity = datastore.find "Task", "sampleTask"
        #
        #   entity["tags"] = ["fun", "programming"]
        #   entity.exclude_from_indexes! "tags", [true, false]
        #
        # @example Or, a single flag can be applied to all values in a property:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   entity = datastore.find "Task", "sampleTask"
        #
        #   entity["tags"] = ["fun", "programming"]
        #   entity.exclude_from_indexes! "tags", true
        #
        # @example Flags can also be set with a block:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   entity = datastore.find "Task", "sampleTask"
        #
        #   entity["priority"] = 4
        #   entity.exclude_from_indexes! "priority" do |priority|
        #     priority > 4
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
        # The number of bytes the Entity will take to serialize during API
        # calls.
        def serialized_size
          to_grpc.to_proto.length
        end

        ##
        # @private Convert the Entity to a Google::Datastore::V1::Entity
        # object.
        def to_grpc
          grpc = Google::Datastore::V1::Entity.new(
            properties: @properties.to_grpc
          )
          grpc.key = @key.to_grpc unless @key.nil?
          update_properties_indexed! grpc.properties
          grpc
        end

        ##
        # @private Create a new Entity from a Google::Datastore::V1::Key
        # object.
        def self.from_grpc grpc
          entity = Entity.new
          entity.key = Key.from_grpc grpc.key
          entity.send :properties=, Properties.from_grpc(grpc.properties)
          entity.send :update_exclude_indexes!, grpc.properties
          entity
        end

        protected

        ##
        # @private Allow friendly objects to set Properties object.
        attr_writer :properties

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
              (flag + Array.new(value.size)).slice(0, value.size).map do |v|
                !!v
              end
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
        def update_exclude_indexes! grpc_map
          @_exclude_indexes = {}
          grpc_map.each do |name, value|
            next if value.nil?
            @_exclude_indexes[name] = value.exclude_from_indexes
            unless value.array_value.nil?
              exclude = value.array_value.values.map(&:exclude_from_indexes)
              @_exclude_indexes[name] = exclude
            end
          end
        end

        ##
        # @private Update the indexed values before the object is saved.
        def update_properties_indexed! grpc_map
          grpc_map.each do |name, value|
            next if value.nil?
            excluded = exclude_from_indexes? name
            if excluded.is_a? Array
              value.array_value.values.each_with_index do |v, i|
                v.exclude_from_indexes = excluded[i]
              end
            else
              value.exclude_from_indexes = excluded
            end
          end
        end

        # rubocop:enable all
      end
    end
  end
end
