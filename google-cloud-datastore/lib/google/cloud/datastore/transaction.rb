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


module Google
  module Cloud
    module Datastore
      ##
      # # Transaction
      #
      # Special Connection instance for running transactions.
      #
      # See {Google::Cloud::Datastore::Dataset#transaction}
      #
      # @see https://cloud.google.com/datastore/docs/concepts/transactions
      #   Transactions
      #
      # @example Transactional update:
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   def transfer_funds from_key, to_key, amount
      #     datastore.transaction do |tx|
      #       from = tx.find from_key
      #       from["balance"] -= amount
      #       to = tx.find to_key
      #       to["balance"] += amount
      #       tx.save from, to
      #     end
      #   end
      #
      # @example Transactional read:
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   task_list_key = datastore.key "TaskList", "default"
      #   datastore.transaction do |tx|
      #     task_list = tx.find task_list_key
      #     query = tx.query("Task").ancestor(task_list)
      #     tasks_in_list = tx.run query
      #   end
      #
      class Transaction < Dataset
        attr_reader :id

        ##
        # @private Creates a new Transaction instance.
        # Takes a Service instead of project and Credentials.
        #
        # @param [Boolean] read_only Whether the transaction should only allow
        #   reads. A read-only transaction cannot modify entities; in return
        #   they do not contend with other read-write or read-only transactions.
        #   Using a read-only transaction for transactions that only read data
        #   will potentially improve throughput.
        #
        def initialize service, read_only: nil
          @service = service
          @read_only = read_only
          reset!
          start
        end

        ##
        # Whether the transaction only allows reads. A read-only transaction
        # cannot modify entities; in return they do not contend with other
        # read-write or read-only transactions. Using a read-only transaction
        # for transactions that only read data will potentially improve
        # throughput.
        #
        # @return [Boolean] Returns `true` if the transaction is a read-only
        #   transaction, or `false` if it is a read-write transaction.
        #
        def read_only?
          !read_write?
        end

        ##
        # Whether the transaction allows both reads and writes.
        #
        # @return [Boolean] Returns `true` if the transaction is a read-write
        #   transaction, or `false` if it is a read-only transaction.
        #
        def read_write?
          @read_only.nil?
        end

        ##
        # Persist entities in a transaction.
        #
        # @example Transactional get or create:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_key = datastore.key "Task", "sampleTask"
        #
        #   task = nil
        #   datastore.transaction do |tx|
        #     task = tx.find task_key
        #     if task.nil?
        #       task = datastore.entity task_key do |t|
        #         t["type"] = "Personal"
        #         t["done"] = false
        #         t["priority"] = 4
        #         t["description"] = "Learn Cloud Datastore"
        #       end
        #       tx.save task
        #     end
        #   end
        #
        def save *entities
          @commit.save(*entities)
          # Do not save yet
          entities
        end
        alias_method :upsert, :save

        ##
        # Insert entities in a transaction. An InvalidArgumentError will raised
        # if the entities cannot be inserted.
        #
        # @example Transactional insert:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_key = datastore.key "Task", "sampleTask"
        #
        #   task = nil
        #   datastore.transaction do |tx|
        #     task = tx.find task_key
        #     if task.nil?
        #       task = datastore.entity task_key do |t|
        #         t["type"] = "Personal"
        #         t["done"] = false
        #         t["priority"] = 4
        #         t["description"] = "Learn Cloud Datastore"
        #       end
        #       tx.insert task
        #     end
        #   end
        #
        def insert *entities
          @commit.insert(*entities)
          # Do not insert yet
          entities
        end

        ##
        # Update entities in a transaction. An InvalidArgumentError will raised
        # if the entities cannot be updated.
        #
        # @example Transactional update:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_key = datastore.key "Task", "sampleTask"
        #
        #   task = nil
        #   datastore.transaction do |tx|
        #     task = tx.find task_key
        #     if task
        #       task["done"] = true
        #       tx.update task
        #     end
        #   end
        #
        def update *entities
          @commit.update(*entities)
          # Do not update yet
          entities
        end

        ##
        # Remove entities in a transaction.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.transaction do |tx|
        #     if tx.find(task_list.key).nil?
        #       tx.delete task1, task2
        #     end
        #   end
        #
        def delete *entities_or_keys
          @commit.delete(*entities_or_keys)
          # Do not delete yet
          true
        end

        ##
        # Retrieve an entity by providing key information. The lookup is run
        # within the transaction.
        #
        # @param [Key, String] key_or_kind A Key object or `kind` string value.
        #
        # @return [Google::Cloud::Datastore::Entity, nil]
        #
        # @example Finding an entity with a key:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_key = datastore.key "Task", "sampleTask"
        #   task = datastore.find task_key
        #
        # @example Finding an entity with a `kind` and `id`/`name`:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.find "Task", "sampleTask"
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
        #   tasks = datastore.find_all task_key1, task_key2
        #
        def find_all *keys
          ensure_service!
          lookup_res = service.lookup(*Array(keys).flatten.map(&:to_grpc),
                                      transaction: @id)
          LookupResults.from_grpc lookup_res, service, nil, @id
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
        #   datastore.transaction do |tx|
        #     tasks = tx.run query
        #   end
        #
        # @example Run the query within a namespace with the `namespace` option:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new.kind("Task").
        #     where("done", "=", false)
        #   datastore.transaction do |tx|
        #     tasks = tx.run query, namespace: "example-ns"
        #   end
        #
        def run query, namespace: nil
          ensure_service!
          unless query.is_a?(Query) || query.is_a?(GqlQuery)
            fail ArgumentError, "Cannot run a #{query.class} object."
          end
          query_res = service.run_query query.to_grpc, namespace,
                                        transaction: @id
          QueryResults.from_grpc query_res, service, namespace,
                                 query.to_grpc.dup
        end
        alias_method :run_query, :run

        ##
        # Begins a transaction.
        # This method is run when a new Transaction is created.
        def start
          fail TransactionError, "Transaction already opened." unless @id.nil?

          ensure_service!
          tx_res = service.begin_transaction read_only: @read_only
          @id = tx_res.transaction
        end
        alias_method :begin_transaction, :start

        ##
        # Commits a transaction.
        #
        # @yield [commit] an optional block for making changes
        # @yieldparam [Commit] commit The object that changes are made on
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.entity "Task" do |t|
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
        # @example Commit can be passed a block, same as {Dataset#commit}:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   tx = datastore.transaction
        #   begin
        #     tx.commit do |c|
        #     c.save task3, task4
        #     c.delete task1, task2
        #     end
        #   rescue
        #     tx.rollback
        #   end
        #
        def commit
          fail TransactionError,
               "Cannot commit when not in a transaction." if @id.nil?

          yield @commit if block_given?

          ensure_service!

          commit_res = service.commit @commit.mutations, transaction: @id
          entities = @commit.entities
          returned_keys = commit_res.mutation_results.map(&:key)
          returned_keys.each_with_index do |key, index|
            next if entities[index].nil?
            entities[index].key = Key.from_grpc(key) unless key.nil?
          end
          # Make sure all entity keys are frozen so all show as persisted
          entities.each { |e| e.key.freeze unless e.persisted? }
          true
        end

        ##
        # Rolls a transaction back.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task = datastore.entity "Task" do |t|
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
        # {Transaction#start} must be called afterwards.
        def reset!
          @id = nil
          @commit = Commit.new
        end
      end
    end
  end
end
