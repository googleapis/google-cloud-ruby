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

require "gcloud/datastore/proto"

module Gcloud
  module Datastore
    ##
    # # Key
    #
    # Every Datastore record has an identifying key, which includes the record's
    # entity kind and a unique identifier. The identifier may be either a key
    # name string, assigned explicitly by the application, or an integer numeric
    # ID, assigned automatically by Datastore.
    #
    # @example
    #   key = Gcloud::Datastore::Key.new "User", "heidi@example.com"
    #
    class Key
      ##
      # The kind of the Key.
      #
      # @return [String]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User"
      #   key.kind #=> "User"
      #   key.kind = "Task"
      #
      attr_accessor :kind

      ##
      # The dataset_id of the Key.
      #
      # @return [String]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #
      #   dataset = gcloud.datastore
      #   entity = dataset.find "User", "heidi@example.com"
      #   entity.key.dataset_id #=> "my-todo-project"
      #
      attr_accessor :dataset_id

      ##
      # The namespace of the Key.
      #
      # @return [String, nil]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #
      #   dataset = gcloud.datastore
      #   entity = dataset.find "User", "heidi@example.com"
      #   entity.key.namespace #=> "ns~todo-project"
      #
      attr_accessor :namespace

      ##
      # Create a new Key instance.
      #
      # @param [String] kind The kind of the Key. This is optional.
      # @param [Integer, String] id_or_name The id or name of the Key. This is
      #   optional.
      #
      # @return [Gcloud::Datastore::Dataset::Key]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User", "heidi@example.com"
      #
      def initialize kind = nil, id_or_name = nil
        @kind = kind
        if id_or_name.is_a? Integer
          @id = id_or_name
        else
          @name = id_or_name
        end
      end

      ##
      # @private Set the id of the Key.
      # If a name is already present it will be removed.
      #
      # @return [Integer, nil]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User", "heidi@example.com"
      #   key.id #=> nil
      #   key.name #=> "heidi@example.com"
      #   key.id = 654321
      #   key.id #=> 654321
      #   key.name #=> nil
      #
      def id= new_id
        @name = nil if new_id
        @id = new_id
      end

      ##
      # The id of the Key.
      #
      # @return [Integer, nil]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User", 123456
      #   key.id #=> 123456
      #
      attr_reader :id

      ##
      # @private Set the name of the Key.
      # If an id is already present it will be removed.
      #
      # @return [String, nil]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User", 123456
      #   key.id #=> 123456
      #   key.name #=> nil
      #   key.name = "heidi@example.com"
      #   key.id #=> nil
      #   key.name #=> "heidi@example.com"
      #
      def name= new_name
        @id = nil if new_name
        @name = new_name
      end

      ##
      # The name of the Key.
      #
      # @return [String, nil]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "User", "heidi@example.com"
      #   key.name #=> "heidi@example.com"
      #
      attr_reader :name

      ##
      # @private Set the parent of the Key.
      #
      # @return [Key, nil]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "List", "todos"
      #   key.parent = Gcloud::Datastore::Key.new "User", "heidi@example.com"
      #
      def parent= new_parent
        # store key if given an entity
        new_parent = new_parent.key if new_parent.respond_to? :key
        @parent = new_parent
      end

      ##
      # The parent of the Key.
      #
      # @return [Key, nil]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   user = dataset.find "User", "heidi@example.com"
      #   query = dataset.query("List").
      #     ancestor(user.key)
      #   lists = dataset.run query
      #   lists.first.key.parent #=> Key("User", "heidi@example.com")
      #
      attr_reader :parent

      ##
      # Represent the Key's path (including parent) as an array of arrays.
      # Each inner array contains two values, the kind and the id or name.
      # If neither an id or name exist then nil will be returned.
      #
      # @return [Array<Array<(String, String)>>]
      #
      # @example
      #   key = Gcloud::Datastore::Key.new "List", "todos"
      #   key.parent = Gcloud::Datastore::Key.new "User", "heidi@example.com"
      #   key.path #=> [["User", "heidi@example.com"], ["List", "todos"]]
      #
      def path
        new_path = parent ? parent.path : []
        new_path << [kind, (id || name)]
      end

      ##
      # Determine if the key is complete.
      # A complete key has either an id or a name.
      #
      # Inverse of {#incomplete?}
      def complete?
        !incomplete?
      end

      ##
      # Determine if the key is incomplete.
      # An incomplete key has neither an id nor a name.
      #
      # Inverse of {#complete?}
      def incomplete?
        kind.nil? || (id.nil? && (name.nil? || name.empty?))
      end

      ##
      # @private Convert the Key to a protocol buffer object.
      def to_proto
        Proto::Key.new.tap do |k|
          k.path_element = path.map do |pe_kind, pe_id_or_name|
            Proto.new_path_element pe_kind, pe_id_or_name
          end
          k.partition_id = Proto.new_partition_id dataset_id, namespace
        end
      end

      # rubocop:disable all

      ##
      # @private Create a new Key from a protocol buffer object.
      def self.from_proto proto
        # Disable rules because the complexity here is neccessary.
        key_proto = proto.dup
        key = Key.new
        proto_path_element = Array(key_proto.path_element).pop
        if proto_path_element
          key = Key.new proto_path_element.kind,
                        proto_path_element.id || proto_path_element.name
        end
        if key_proto.partition_id
          key.dataset_id = key_proto.partition_id.dataset_id
          key.namespace  = key_proto.partition_id.namespace
        end
        if Array(key_proto.path_element).count > 0
          key.parent = Key.from_proto(key_proto)
        end
        # Freeze the key to make it immutable.
        key.freeze
        key
      end
      # rubocop:enable all
    end
  end
end
