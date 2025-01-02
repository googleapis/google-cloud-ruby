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


require "google/cloud/datastore/dataset/lookup_results"
require "google/cloud/datastore/dataset/query_results"

module Google
  module Cloud
    module Datastore
      ##
      # # ReadOnlyTransaction
      #
      # Represents a read-only Datastore transaction that only allows reads.
      #
      # A read-only transaction cannot modify entities; in return they do not
      # contend with other read-write or read-only transactions. Using a
      # read-only transaction for transactions that only read data will
      # potentially improve throughput.
      #
      # See {Google::Cloud::Datastore::Dataset#transaction}
      #
      # @see https://cloud.google.com/datastore/docs/concepts/transactions
      #   Transactions
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   task_list_key = datastore.key "TaskList", "default"
      #   query = datastore.query("Task").
      #     ancestor(task_list_key)
      #
      #   tasks = nil
      #
      #   datastore.read_only_transaction do |tx|
      #     task_list = tx.find task_list_key
      #     if task_list
      #       tasks = tx.run query
      #     end
      #   end
      #
      class ReadOnlyTransaction
        attr_reader :id

        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # Reads entities at the given time.
        # This may not be older than 60 seconds.
        attr_reader :read_time

        ##
        # @private Creates a new ReadOnlyTransaction instance.
        # Takes a Service instead of project and Credentials.
        #
        # @param [Time] read_time Reads documents as they were at the given time.
        #   This may not be older than 270 seconds. Optional
        #
        def initialize service, read_time: nil
          @service = service
          reset!
          @read_time = read_time
          start
        end

        ##
        # Retrieve an entity by providing key information. The lookup is run
        # within the transaction.
        #
        # @param [Key, String] key_or_kind A Key object or `kind` string value.
        #
        # @return [Google::Cloud::Datastore::Entity, nil]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_list_key = datastore.key "TaskList", "default"
        #
        #   datastore.read_only_transaction do |tx|
        #     task_list = tx.find task_list_key
        #   end
        #
        def find key_or_kind, id_or_name = nil
          key = key_or_kind
          unless key.is_a? Google::Cloud::Datastore::Key
            key = Key.new key_or_kind, id_or_name
          end
          find_all(key).first
        end
        alias get find

        ##
        # Retrieve the entities for the provided keys. The lookup is run within
        # the transaction.
        #
        # @param [Key] keys One or more Key objects to find records for.
        #
        # @return [Google::Cloud::Datastore::Dataset::LookupResults]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_key1 = datastore.key "Task", 123456
        #   task_key2 = datastore.key "Task", 987654
        #
        #   datastore.read_only_transaction do |tx|
        #     tasks = tx.find_all task_key1, task_key2
        #   end
        #
        def find_all *keys
          ensure_service!
          lookup_res = service.lookup(*Array(keys).flatten.map(&:to_grpc),
                                      transaction: @id)
          Dataset::LookupResults.from_grpc lookup_res, service, nil, @id
        end
        alias lookup find_all

        ##
        # Retrieve entities specified by a Query. The query is run within the
        # transaction.
        #
        # @param [Query] query The Query object with the search criteria.
        # @param [String] namespace The namespace the query is to run within.
        #
        # @return [Google::Cloud::Datastore::Dataset::QueryResults]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     query = tx.query("Task").
        #       where("done", "=", false)
        #     tasks = tx.run query
        #   end
        #
        def run query, namespace: nil
          ensure_service!
          unless query.is_a?(Query) || query.is_a?(GqlQuery)
            raise ArgumentError, "Cannot run a #{query.class} object."
          end
          query_res = service.run_query query.to_grpc, namespace,
                                        transaction: @id
          Dataset::QueryResults.from_grpc query_res, service, namespace,
                                          query.to_grpc.dup
        end
        alias run_query run

        ##
        # Retrieve aggregate query results specified by an AggregateQuery. The query is run within the
        # transaction.
        #
        # @param [AggregateQuery, GqlQuery] aggregate_query The Query object
        #   with the search criteria.
        # @param [String] namespace The namespace the query is to run within.
        #
        # @return [Google::Cloud::Datastore::Dataset::AggregateQueryResults]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     query = tx.query("Task")
        #               .where("done", "=", false)
        #     aggregate_query = query.aggregate_query
        #                            .add_count
        #     res = tx.run_aggregation aggregate_query
        #   end
        #
        def run_aggregation aggregate_query, namespace: nil
          ensure_service!
          unless aggregate_query.is_a?(AggregateQuery) || aggregate_query.is_a?(GqlQuery)
            raise ArgumentError, "Cannot run a #{aggregate_query.class} object."
          end
          aggregate_query_results = service.run_aggregation_query aggregate_query.to_grpc, namespace, transaction: @id
          Dataset::AggregateQueryResults.from_grpc aggregate_query_results
        end

        ##
        # Begins a transaction.
        # This method is run when a new ReadOnlyTransaction is created.
        #
        def start
          raise TransactionError, "Transaction already opened." unless @id.nil?
          ensure_service!
          tx_res = service.begin_transaction read_only: true, read_time: @read_time
          @id = tx_res.transaction
        end
        alias begin_transaction start

        ##
        # Commits the transaction.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_list_key = datastore.key "TaskList", "default"
        #
        #   tx = datastore.transaction
        #   task_list = tx.find task_list_key
        #   if task_list
        #     query = tx.query("Task").
        #       ancestor(task_list_key)
        #     tasks = tx.run query
        #   end
        #   tx.commit
        #
        def commit
          if @id.nil?
            raise TransactionError, "Cannot commit when not in a transaction."
          end

          ensure_service!

          service.commit [], transaction: @id
          true
        end

        ##
        # Rolls back the transaction.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_list_key = datastore.key "TaskList", "default"
        #
        #   tx = datastore.transaction
        #   task_list = tx.find task_list_key
        #   if task_list
        #     query = tx.query("Task").
        #       ancestor(task_list_key)
        #     tasks = tx.run query
        #   end
        #   tx.rollback
        #
        def rollback
          if @id.nil?
            raise TransactionError, "Cannot rollback when not in a transaction."
          end

          ensure_service!
          service.rollback @id
          true
        end

        ##
        # Reset the transaction.
        # {ReadOnlyTransaction#start} must be called afterwards.
        def reset!
          @id = nil
        end

        ##
        # Create a new Query instance. This is a convenience method to make the
        # creation of Query objects easier.
        #
        # @param [String] kinds The kind of entities to query. This is optional.
        #
        # @return [Google::Cloud::Datastore::Query]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     query = tx.query("Task").
        #       where("done", "=", false)
        #     tasks = tx.run query
        #   end
        #
        def query *kinds
          query = Query.new
          query.kind(*kinds) unless kinds.empty?
          query
        end

        ##
        # Create a new GqlQuery instance. This is a convenience method to make
        # the creation of GqlQuery objects easier.
        #
        # @param [String] query The GQL query string.
        # @param [Hash] bindings Named bindings for the GQL query string, each
        #   key must match regex `[A-Za-z_$][A-Za-z_$0-9]*`, must not match
        #   regex `__.*__`, and must not be `""`. The value must be an `Object`
        #   that can be stored as an Entity property value, or a `Cursor`.
        #
        # @return [Google::Cloud::Datastore::GqlQuery]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     gql_query = tx.gql "SELECT * FROM Task WHERE done = @done",
        #                        done: false
        #     tasks = tx.run gql_query
        #   end
        #
        # @example The previous example is equivalent to:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     gql_query = Google::Cloud::Datastore::GqlQuery.new
        #     gql_query.query_string = "SELECT * FROM Task WHERE done = @done"
        #     gql_query.named_bindings = {done: false}
        #     tasks = tx.run gql_query
        #   end
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
        # @param [Array<Array(String,(String|Integer|nil))>] path An optional
        #   list of pairs for the key's path. Each pair may include the key's
        #   kind (String) and an id (Integer) or name (String). This is
        #   optional.
        # @param [String] project The project of the Key. This is optional.
        # @param [String] namespace namespace kind of the Key. This is optional.
        #
        # @return [Google::Cloud::Datastore::Key]
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     task_key = tx.key "Task", "sampleTask"
        #   end
        #
        # @example The previous example is equivalent to:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     task_key = Google::Cloud::Datastore::Key.new "Task", "sampleTask"
        #   end
        #
        # @example Create a key with a parent:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     key = tx.key [["TaskList", "default"], ["Task", "sampleTask"]]
        #     results = tx.find_all key
        #   end
        #
        # @example Create a key with multi-level ancestry:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     key = tx.key([
        #       ["User", "alice"],
        #       ["TaskList", "default"],
        #       ["Task", "sampleTask"]
        #     ])
        #     results = tx.find_all key
        #   end
        #
        # @example Create a key with a project and namespace:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.read_only_transaction do |tx|
        #     key = tx.key ["TaskList", "default"], ["Task", "sampleTask"],
        #                  project: "my-todo-project",
        #                  namespace: "example-ns"
        #     results = tx.find_all key
        #   end
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

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
