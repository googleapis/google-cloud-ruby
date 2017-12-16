# Copyright 2014 Google LLC
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
        # @private Creates a new ReadOnlyTransaction instance.
        # Takes a Service instead of project and Credentials.
        #
        def initialize service
          @service = service
          reset!
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
        alias_method :get, :find

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
        alias_method :lookup, :find_all

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
        #   query = datastore.query("Task").
        #     where("done", "=", false)
        #   datastore.read_only_transaction do |tx|
        #     tasks = tx.run query
        #   end
        #
        def run query, namespace: nil
          ensure_service!
          unless query.is_a?(Query) || query.is_a?(GqlQuery)
            fail ArgumentError, "Cannot run a #{query.class} object."
          end
          query_res = service.run_query query.to_grpc, namespace,
                                        transaction: @id
          Dataset::QueryResults.from_grpc query_res, service, namespace,
                                          query.to_grpc.dup
        end
        alias_method :run_query, :run

        ##
        # Begins a transaction.
        # This method is run when a new ReadOnlyTransaction is created.
        #
        def start
          fail TransactionError, "Transaction already opened." unless @id.nil?

          ensure_service!
          tx_res = service.begin_transaction read_only: true
          @id = tx_res.transaction
        end
        alias_method :begin_transaction, :start

        ##
        # Commits the transaction.
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
        #   tx = datastore.transaction
        #   task_list = tx.find task_list_key
        #   if task_list
        #     tasks = tx.run query
        #   end
        #   tx.commit
        #
        def commit
          fail TransactionError,
               "Cannot commit when not in a transaction." if @id.nil?

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
        #   query = datastore.query("Task").
        #     ancestor(task_list_key)
        #
        #   tx = datastore.transaction
        #   task_list = tx.find task_list_key
        #   if task_list
        #     tasks = tx.run query
        #   end
        #   tx.rollback
        #
        def rollback
          if @id.nil?
            fail TransactionError, "Cannot rollback when not in a transaction."
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

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
