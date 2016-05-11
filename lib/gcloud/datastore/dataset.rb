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


require "gcloud/gce"
require "gcloud/datastore/grpc_utils"
require "gcloud/datastore/credentials"
require "gcloud/datastore/service"
require "gcloud/datastore/commit"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"
require "gcloud/datastore/query"
require "gcloud/datastore/gql_query"
require "gcloud/datastore/cursor"
require "gcloud/datastore/dataset/lookup_results"
require "gcloud/datastore/dataset/query_results"

module Gcloud
  module Datastore
    ##
    # # Dataset
    #
    # Dataset is the data saved in a project's Datastore.
    # Dataset is analogous to a database in relational database world.
    #
    # Gcloud::Datastore::Dataset is the main object for interacting with
    # Google Datastore. {Gcloud::Datastore::Entity} objects are created,
    # read, updated, and deleted by Gcloud::Datastore::Dataset.
    #
    # See {Gcloud#datastore}
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   datastore = gcloud.datastore
    #
    #   query = datastore.query("Task").
    #     where("done", "=", false)
    #
    #   tasks = datastore.run query
    #
    class Dataset
      ##
      # @private The gRPC Service object.
      attr_accessor :service

      ##
      # @private Creates a new Dataset instance.
      #
      # See {Gcloud#datastore}
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @service = Service.new project, credentials
      end

      ##
      # The Datastore project connected to.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #
      #   datastore = gcloud.datastore
      #   datastore.project #=> "my-todo-project"
      #
      def project
        service.project
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["DATASTORE_DATASET"] ||
          ENV["DATASTORE_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Generate IDs for a Key before creating an entity.
      #
      # @param [Key] incomplete_key A Key without `id` or `name` set.
      # @param [String] count The number of new key IDs to create.
      #
      # @return [Array<Gcloud::Datastore::Key>]
      #
      # @example
      #   task_key = datastore.key "Task"
      #   task_keys = datastore.allocate_ids task_key, 5
      #
      def allocate_ids incomplete_key, count = 1
        if incomplete_key.complete?
          fail Gcloud::Datastore::Error, "An incomplete key must be provided."
        end

        ensure_service!
        incomplete_keys = count.times.map { incomplete_key.to_grpc }
        allocate_res = service.allocate_ids(*incomplete_keys)
        allocate_res.keys.map { |key| Key.from_grpc key }
      rescue GRPC::BadStatus => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Persist one or more entities to the Datastore.
      #
      # @param [Entity] entities One or more entity objects to be saved.
      #
      # @return [Array<Gcloud::Datastore::Entity>]
      #
      # @example Insert a new entity:
      #   task = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #   task.key.id #=> nil
      #   datastore.save task
      #   task.key.id #=> 123456
      #
      # @example Insert multiple new entities in a batch:
      #   task1 = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   task2 = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 5
      #     t["description"] = "Integrate Cloud Datastore"
      #   end
      #
      #   task_key1, task_key2 = datastore.save(task1, task2).map(&:key)
      #
      # @example Update an existing entity:
      #   task = datastore.find "Task", "sampleTask"
      #   task["priority"] = 5
      #   datastore.save task
      #
      def save *entities
        commit { |c| c.save(*entities) }
      end
      alias_method :upsert, :save

      ##
      # Insert one or more entities to the Datastore. An InvalidArgumentError
      # will raised if the entities cannot be inserted.
      #
      # @param [Entity] entities One or more entity objects to be inserted.
      #
      # @return [Array<Gcloud::Datastore::Entity>]
      #
      # @example Insert a new entity:
      #   task = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #   task.key.id #=> nil
      #   datastore.insert task
      #   task.key.id #=> 123456
      #
      # @example Insert multiple new entities in a batch:
      #   task1 = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   task2 = datastore.entity "Task" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 5
      #     t["description"] = "Integrate Cloud Datastore"
      #   end
      #
      #   task_key1, task_key2 = datastore.insert(task1, task2).map(&:key)
      #
      def insert *entities
        commit { |c| c.insert(*entities) }
      end

      ##
      # Update one or more entities to the Datastore. An InvalidArgumentError
      # will raised if the entities cannot be updated.
      #
      # @param [Entity] entities One or more entity objects to be updated.
      #
      # @return [Array<Gcloud::Datastore::Entity>]
      #
      # @example Update an existing entity:
      #   task = datastore.find "Task", "sampleTask"
      #   task["done"] = true
      #   datastore.save task
      #
      # @example update multiple new entities in a batch:
      #   query = datastore.query("Task").where("done", "=", false)
      #   tasks = datastore.run query
      #   tasks.each { |t| t["done"] = true }
      #   datastore.update tasks
      #
      def update *entities
        commit { |c| c.update(*entities) }
      end

      ##
      # Remove entities from the Datastore.
      #
      # @param [Entity, Key] entities_or_keys One or more Entity or Key objects
      #   to remove.
      #
      # @return [Boolean] Returns `true` if successful
      #
      # @example
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #   datastore.delete task1, task2
      #
      def delete *entities_or_keys
        commit { |c| c.delete(*entities_or_keys) }
        true
      end

      ##
      # Make multiple changes in a single commit.
      #
      # @yield [commit] a block for making changes
      # @yieldparam [Commit] commit The object that changes are made on
      #
      # @return [Array<Gcloud::Datastore::Entity>] The entities that were
      #   persisted.
      #
      # @example
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #   datastore.commit do |c|
      #     c.save task3, task4
      #     c.delete task1, task2
      #   end
      #
      def commit
        return unless block_given?
        c = Commit.new
        yield c

        ensure_service!
        commit_res = service.commit c.mutations
        entities = c.entities
        returned_keys = commit_res.mutation_results.map(&:key)
        returned_keys.each_with_index do |key, index|
          next if entities[index].nil?
          entities[index].key = Key.from_grpc(key) unless key.nil?
        end
        entities.each { |e| e.key.freeze unless e.persisted? }
        entities
      rescue GRPC::BadStatus => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieve an entity by key.
      #
      # @param [Key, String] key_or_kind A Key object or `kind` string value.
      # @param [Integer, String, nil] id_or_name The Key's `id` or `name` value
      #   if a `kind` was provided in the first parameter.
      # @param [Symbol] consistency The non-transactional read consistency to
      #   use. Cannot be set to `:strong` for global queries. Accepted values
      #   are `:eventual` and `:strong`.
      #
      #   The default consistency depends on the type of lookup used. See
      #   [Eventual Consistency in Google Cloud
      #   Datastore](https://cloud.google.com/datastore/docs/articles/balancing-strong-and-eventual-consistency-with-google-cloud-datastore/#h.tf76fya5nqk8)
      #   for more information.
      #
      # @return [Gcloud::Datastore::Entity, nil]
      #
      # @example Finding an entity with a key:
      #   task_key = datastore.key "Task", "sampleTask"
      #   task = datastore.find task_key
      #
      # @example Finding an entity with a `kind` and `id`/`name`:
      #   task = datastore.find "Task", "sampleTask"
      #
      def find key_or_kind, id_or_name = nil, consistency: nil
        key = key_or_kind
        unless key.is_a? Gcloud::Datastore::Key
          key = Key.new key_or_kind, id_or_name
        end
        find_all(key, consistency: consistency).first
      end
      alias_method :get, :find

      ##
      # Retrieve the entities for the provided keys. The order of results is
      # undefined and has no relation to the order of `keys` arguments.
      #
      # @param [Key] keys One or more Key objects to find records for.
      # @param [Symbol] consistency The non-transactional read consistency to
      #   use. Cannot be set to `:strong` for global queries. Accepted values
      #   are `:eventual` and `:strong`.
      #
      #   The default consistency depends on the type of lookup used. See
      #   [Eventual Consistency in Google Cloud
      #   Datastore](https://cloud.google.com/datastore/docs/articles/balancing-strong-and-eventual-consistency-with-google-cloud-datastore/#h.tf76fya5nqk8)
      #   for more information.
      #
      # @return [Gcloud::Datastore::Dataset::LookupResults]
      #
      # @example
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #
      #   task_key1 = datastore.key "Task", "sampleTask1"
      #   task_key2 = datastore.key "Task", "sampleTask2"
      #   tasks = datastore.find_all task_key1, task_key2
      #
      def find_all *keys, consistency: nil
        ensure_service!
        check_consistency! consistency
        lookup_res = service.lookup(*keys.map(&:to_grpc),
                                    consistency: consistency)
        entities = to_gcloud_entities lookup_res.found
        deferred = to_gcloud_keys lookup_res.deferred
        missing  = to_gcloud_entities lookup_res.missing
        LookupResults.new entities, deferred, missing
      rescue GRPC::BadStatus => e
        raise Gcloud::Error.from_error(e)
      end
      alias_method :lookup, :find_all

      ##
      # Retrieve entities specified by a Query.
      #
      # @param [Query, GqlQuery] query The object with the search criteria.
      # @param [String] namespace The namespace the query is to run within.
      # @param [Symbol] consistency The non-transactional read consistency to
      #   use. Cannot be set to `:strong` for global queries. Accepted values
      #   are `:eventual` and `:strong`.
      #
      #   The default consistency depends on the type of query used. See
      #   [Eventual Consistency in Google Cloud
      #   Datastore](https://cloud.google.com/datastore/docs/articles/balancing-strong-and-eventual-consistency-with-google-cloud-datastore/#h.tf76fya5nqk8)
      #   for more information.
      #
      # @return [Gcloud::Datastore::Dataset::QueryResults]
      #
      # @example
      #   query = datastore.query("Task").
      #     where("done", "=", false)
      #   tasks = datastore.run query
      #
      # @example Run the query within a namespace with the `namespace` option:
      #   query = datastore.query("Task").
      #     where("done", "=", false)
      #   tasks = datastore.run query, namespace: "ns~todo-project"
      #
      # @example Run the query with a GQL string.
      #   gql_query = datastore.gql "SELECT * FROM Task WHERE done = @done",
      #                             done: false
      #   tasks = datastore.run gql_query
      #
      # @example Run the GQL query within a namespace with `namespace` option:
      #   gql_query = datastore.gql "SELECT * FROM Task WHERE done = @done",
      #                             done: false
      #   tasks = datastore.run gql_query, namespace: "ns~todo-project"
      #
      def run query, namespace: nil, consistency: nil
        ensure_service!
        unless query.is_a?(Query) || query.is_a?(GqlQuery)
          fail ArgumentError, "Cannot run a #{query.class} object."
        end
        check_consistency! consistency
        query_res = service.run_query query.to_grpc, namespace,
                                      consistency: consistency
        QueryResults.from_grpc query_res, service, namespace, query.to_grpc.dup
      rescue GRPC::BadStatus => e
        raise Gcloud::Error.from_error(e)
      end
      alias_method :run_query, :run

      ##
      # Creates a Datastore Transaction.
      #
      # @yield [tx] a block yielding a new transaction
      # @yieldparam [Transaction] tx the transaction object
      #
      # @example Runs the given block in a database transaction:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   datastore.transaction do |tx|
      #     if tx.find(task.key).nil?
      #       tx.save task
      #     end
      #   end
      #
      # @example If no block is given, a Transaction object is returned:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   tx = datastore.transaction
      #   begin
      #     if tx.find(task.key).nil?
      #       tx.save task
      #     end
      #     tx.commit
      #   rescue
      #     tx.rollback
      #   end
      #
      def transaction
        tx = Transaction.new service
        return tx unless block_given?

        begin
          yield tx
          tx.commit
        rescue => e
          begin
            tx.rollback
          rescue => re
            msg = "Transaction failed to commit and rollback."
            raise TransactionError.new(msg, commit_error: e, rollback_error: re)
          end
          raise TransactionError.new("Transaction failed to commit.",
                                     commit_error: e)
        end
      end

      ##
      # Create a new Query instance. This is a convenience method to make the
      # creation of Query objects easier.
      #
      # @param [String] kinds The kind of entities to query. This is optional.
      #
      # @return [Gcloud::Datastore::Query]
      #
      # @example
      #   query = datastore.query("Task").
      #     where("done", "=", false)
      #   tasks = datastore.run query
      #
      # @example The previous example is equivalent to:
      #   query = Gcloud::Datastore::Query.new.
      #     kind("Task").
      #     where("done", "=", false)
      #   tasks = datastore.run query
      #
      def query *kinds
        query = Query.new
        query.kind(*kinds) unless kinds.empty?
        query
      end

      ##
      # Create a new GqlQuery instance. This is a convenience method to make the
      # creation of GqlQuery objects easier.
      #
      # @param [String] query The GQL query string.
      # @param [Hash] bindings Named bindings for the GQL query string, each
      #   key must match regex `[A-Za-z_$][A-Za-z_$0-9]*`, must not match regex
      #   `__.*__`, and must not be `""`. The value must be an `Object` that can
      #   be stored as an Entity property value, or a `Cursor`.
      #
      # @return [Gcloud::Datastore::GqlQuery]
      #
      # @example
      #   gql_query = datastore.gql "SELECT * FROM Task WHERE done = @done",
      #                             done: false
      #   tasks = datastore.run gql_query
      #
      # @example The previous example is equivalent to:
      #   gql_query = Gcloud::Datastore::GqlQuery.new
      #   gql_query.query_string = "SELECT * FROM Task WHERE done = @done"
      #   gql_query.named_bindings = {done: false}
      #   tasks = datastore.run gql_query
      #
      def gql query, bindings = {}
        gql = GqlQuery.new
        gql.query_string = query
        gql.named_bindings = bindings unless bindings.empty?
        gql
      end

      ##
      # Create a new Key instance. This is a convenience method to make the
      # creation of Key objects easier.
      #
      # @param [Array<Array(String,(String|Integer|nil))>] path An optional list
      #   of pairs for the key's path. Each pair may include the key's kind
      #   (String) and an id (Integer) or name (String). This is optional.
      # @param [String] project The project of the Key. This is optional.
      # @param [String] namespace namespace kind of the Key. This is optional.
      #
      # @return [Gcloud::Datastore::Key]
      #
      # @example
      #   task_key = datastore.key "Task", "sampleTask"
      #
      # @example The previous example is equivalent to:
      #   task_key = Gcloud::Datastore::Key.new "Task", "sampleTask"
      #
      # @example Create an empty key:
      #   key = datastore.key
      #
      # @example Create an incomplete key:
      #   key = datastore.key "User"
      #
      # @example Create a key with a parent:
      #   key = datastore.key [["TaskList", "default"], ["Task", "sampleTask"]]
      #   key.path #=> [["TaskList", "default"], ["Task", "sampleTask"]]
      #
      # @example Create a key with multi-level ancestry:
      #   key = datastore.key([
      #     ["User", "alice"],
      #     ["TaskList", "default"],
      #     ["Task", "sampleTask"]
      #   ])
      #   key.path #=> [["User", "alice"], ["TaskList", "default"], [ ... ]]
      #
      # @example Create an incomplete key with a parent:
      #   key = datastore.key "TaskList", "default", "Task"
      #   key.path #=> [["TaskList", "default"], ["Task", nil]]
      #
      # @example Create a key with a project and namespace:
      #   key = datastore.key ["TaskList", "default"], ["Task", "sampleTask"],
      #                       project: "my-todo-project",
      #                       namespace: "ns~todo-project"
      #   key.path #=> [["TaskList", "default"], ["Task", "sampleTask"]]
      #   key.project #=> "my-todo-project",
      #   key.namespace #=> "ns~todo-project"
      #
      def key *path, project: nil, namespace: nil
        path = path.flatten.each_slice(2).to_a # group in pairs
        kind, id_or_name = path.pop
        Key.new(kind, id_or_name).tap do |k|
          k.project = project
          k.namespace = namespace
          unless path.empty?
            k.parent = key path, project: project, namespace: namespace
          end
        end
      end

      ##
      # Create a new empty Entity instance. This is a convenience method to make
      # the creation of Entity objects easier.
      #
      # @param [Key, Array<Array(String,(String|Integer|nil))>] key_or_path An
      #   optional list of pairs for the key's path. Each pair may include the #
      #   key's kind (String) and an id (Integer) or name (String). This is #
      #   optional.
      # @param [String] project The project of the Key. This is optional.
      # @param [String] namespace namespace kind of the Key. This is optional.
      # @yield [entity] a block yielding a new entity
      # @yieldparam [Entity] entity the newly created entity object
      #
      # @return [Gcloud::Datastore::Entity]
      #
      # @example
      #   task = datastore.entity
      #
      # @example The previous example is equivalent to:
      #   task = Gcloud::Datastore::Entity.new
      #
      # @example The key can also be passed in as an object:
      #   task_key = datastore.key "Task", "sampleTask"
      #   task = datastore.entity task_key
      #
      # @example Or the key values can be passed in as parameters:
      #   task = datastore.entity "Task", "sampleTask"
      #
      # @example The previous example is equivalent to:
      #   task_key = Gcloud::Datastore::Key.new "Task", "sampleTask"
      #   task = Gcloud::Datastore::Entity.new
      #   task.key = task_key
      #
      # @example The newly created entity can also be configured using a block:
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      # @example The previous example is equivalent to:
      #   task_key = Gcloud::Datastore::Key.new "Task", "sampleTask"
      #   task = Gcloud::Datastore::Entity.new
      #   task.key = task_key
      #   task["type"] = "Personal"
      #   task["done"] = false
      #   task["priority"] = 4
      #   task["description"] = "Learn Cloud Datastore"
      #
      def entity *key_or_path, project: nil, namespace: nil
        entity = Entity.new

        # Set the key
        if key_or_path.flatten.first.is_a? Gcloud::Datastore::Key
          entity.key = key_or_path.flatten.first
        else
          entity.key = key key_or_path, project: project, namespace: namespace
        end

        yield entity if block_given?

        entity
      end

      protected

      ##
      # @private Raise an error unless an active connection to the service is
      # available.
      def ensure_service!
        fail "Must have active connection to service" unless service
      end

      ##
      # Convenience method to convert GRPC entities to Gcloud entities.
      def to_gcloud_entities grpc_entity_results
        # Entities are nested in an object.
        Array(grpc_entity_results).map do |result|
          # TODO: Make this return an EntityResult with cursor...
          Entity.from_grpc result.entity
        end
      end

      ##
      # Convenience method to convert GRPC keys to Gcloud keys.
      def to_gcloud_keys grpc_keys
        # Keys are not nested in an object like entities are.
        Array(grpc_keys).map { |key| Key.from_grpc key }
      end

      def check_consistency! consistency
        fail(ArgumentError,
             format("Consistency must be :eventual or :strong, not %s.",
                    consistency.inspect)
            ) unless [:eventual, :strong, nil].include? consistency
      end
    end
  end
end
