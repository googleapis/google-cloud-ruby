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


module Google
  module Cloud
    module Datastore
      ##
      # # Key
      #
      # Every Datastore record has an identifying key, which includes the
      # record's entity kind and a unique identifier. The identifier may be
      # either a key name string, assigned explicitly by the application, or an
      # integer numeric ID, assigned automatically by Datastore.
      #
      # @see https://cloud.google.com/datastore/docs/concepts/entities Entities,
      #   Properties, and Keys
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
      #
      class Key
        ##
        # The kind of the Key.
        #
        # @return [String]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   key = Google::Cloud::Datastore::Key.new "TaskList"
        #   key.kind #=> "TaskList"
        #   key.kind = "Task"
        #
        attr_accessor :kind

        ##
        # The project of the Key.
        #
        # @return [String]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new(
        #     project: "my-todo-project",
        #     keyfile: "/path/to/keyfile.json"
        #   )
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task.key.project #=> "my-todo-project"
        #
        attr_accessor :project
        alias_method :project_id,  :project
        alias_method :project_id=, :project=
        alias_method :dataset_id,  :project
        alias_method :dataset_id=, :project=

        ##
        # The namespace of the Key.
        #
        # @return [String, nil]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new(
        #     project: "my-todo-project",
        #     keyfile: "/path/to/keyfile.json"
        #   )
        #
        #   task = datastore.find "Task", "sampleTask"
        #   task.key.namespace #=> "example-ns"
        #
        attr_accessor :namespace

        ##
        # Create a new Key instance.
        #
        # @param [String] kind The kind of the Key. This is optional.
        # @param [Integer, String] id_or_name The id or name of the Key. This is
        #   optional.
        #
        # @return [Google::Cloud::Datastore::Dataset::Key]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
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
        #   require "google/cloud/datastore"
        #
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   task_key.id #=> nil
        #   task_key.name #=> "sampleTask"
        #   task_key.id = 654321
        #   task_key.id #=> 654321
        #   task_key.name #=> nil
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
        #   require "google/cloud/datastore"
        #
        #   task_key = Google::Cloud::Datastore::Key.new "Task", 123456
        #   task_key.id #=> 123456
        #
        attr_reader :id

        ##
        # @private Set the name of the Key.
        # If an id is already present it will be removed.
        #
        # @return [String, nil]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   task_key = Google::Cloud::Datastore::Key.new "Task", 123456
        #   task_key.id #=> 123456
        #   task_key.name #=> nil
        #   task_key.name = "sampleTask"
        #   task_key.id #=> nil
        #   task_key.name #=> "sampleTask"
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
        #   require "google/cloud/datastore"
        #
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   task_key.name #=> "sampleTask"
        #
        attr_reader :name

        ##
        # Set the parent of the Key.
        #
        # @return [Key, nil]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   parent_key = Google::Cloud::Datastore::Key.new "TaskList", "default"
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   task_key.parent = parent_key
        #
        # @example With multiple levels:
        #   require "google/cloud/datastore"
        #
        #   user_key = Google::Cloud::Datastore::Key.new "User", "alice"
        #   list_key = Google::Cloud::Datastore::Key.new "TaskList", "default"
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   list_key.parent = user_key
        #   task_key.parent = list_key
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
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_list = datastore.find "TaskList", "default"
        #   query = datastore.query("Task").
        #     ancestor(task_list)
        #   lists = datastore.run query
        #   lists.first.key.parent # Key("TaskList", "default")
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
        #   require "google/cloud/datastore"
        #
        #   parent_key = Google::Cloud::Datastore::Key.new "TaskList", "default"
        #   task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   task_key.parent = parent_key
        #   task_key.path #=> [["TaskList", "default"], ["Task", "sampleTask"]]
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
        # The number of bytes the Key will take to serialize during API calls.
        def serialized_size
          to_grpc.to_proto.length
        end

        ##
        # @private Convert the Key to a Google::Datastore::V1::Key object.
        def to_grpc
          grpc_path = path.map do |pe_kind, pe_id_or_name|
            path_args = { kind: pe_kind }
            if pe_id_or_name.is_a? Integer
              path_args[:id] = pe_id_or_name
            elsif pe_id_or_name.is_a? String
              path_args[:name] = pe_id_or_name unless pe_id_or_name.empty?
            end
            Google::Datastore::V1::Key::PathElement.new(path_args)
          end
          grpc = Google::Datastore::V1::Key.new(path: grpc_path)
          if project || namespace
            grpc.partition_id = Google::Datastore::V1::PartitionId.new(
              project_id: project.to_s, namespace_id: namespace.to_s)
          end
          grpc
        end

        ##
        # @private Create a new Key from a Google::Datastore::V1::Key
        # object.
        def self.from_grpc grpc
          return nil if grpc.nil?
          key_grpc = grpc.dup
          key = Key.new
          path_grpc = key_grpc.path.pop
          if path_grpc
            id_or_name =
              (path_grpc.id_type == :id ? path_grpc.id : path_grpc.name)
            key = Key.new path_grpc.kind, id_or_name
          end
          if key_grpc.partition_id
            key.project = key_grpc.partition_id.project_id
            key.namespace = key_grpc.partition_id.namespace_id
          end
          key.parent = Key.from_grpc(key_grpc) if key_grpc.path.count > 0
          # Freeze the key to make it immutable.
          key.freeze
          key
        end
      end
    end
  end
end
