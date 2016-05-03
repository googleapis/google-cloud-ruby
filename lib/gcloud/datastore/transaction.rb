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


module Gcloud
  module Datastore
    ##
    # # Transaction
    #
    # Special Connection instance for running transactions.
    #
    # See {Gcloud::Datastore::Dataset#transaction}
    class Transaction < Dataset
      attr_reader :id

      ##
      # @private Creates a new Transaction instance.
      # Takes a Connection instead of project and Credentials.
      def initialize connection
        @connection = connection
        reset!
        start
      end

      ##
      # Persist entities in a transaction.
      #
      # @example
      #   dataset.transaction do |tx|
      #     if tx.find(user.key).nil?
      #       tx.save task1, task2
      #     end
      #   end
      #
      def save *entities
        @commit.save(*entities)
        # Do not save or assign auto_ids yet
        entities
      end

      ##
      # Remove entities in a transaction.
      #
      # @example
      #   dataset.transaction do |tx|
      #     if tx.find(user.key).nil?
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
      # @return [Gcloud::Datastore::Entity, nil]
      #
      # @example Finding an entity with a key:
      #   key = dataset.key "Task", 123456
      #   task = dataset.find key
      #
      # @example Finding an entity with a `kind` and `id`/`name`:
      #   task = dataset.find "Task", 123456
      #
      def find key_or_kind, id_or_name = nil
        key = key_or_kind
        unless key.is_a? Gcloud::Datastore::Key
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
      # @return [Gcloud::Datastore::Dataset::LookupResults]
      #
      # @example
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   key1 = dataset.key "Task", 123456
      #   key2 = dataset.key "Task", 987654
      #   tasks = dataset.find_all key1, key2
      #
      def find_all *keys
        response = connection.lookup(*keys.map(&:to_proto),
                                     transaction: @id)
        entities = to_gcloud_entities response.found
        deferred = to_gcloud_keys response.deferred
        missing  = to_gcloud_entities response.missing
        LookupResults.new entities, deferred, missing
      end
      alias_method :lookup, :find_all

      ##
      # Retrieve entities specified by a Query. The query is run within the
      # transaction.
      #
      # @param [Query] query The Query object with the search criteria.
      # @param [String] namespace The namespace the query is to run within.
      #
      # @return [Gcloud::Datastore::Dataset::QueryResults]
      #
      # @example
      #   query = dataset.query("Task").
      #     where("completed", "=", true)
      #   dataset.transaction do |tx|
      #     tasks = tx.run query
      #   end
      #
      # @example Run the query within a namespace with the `namespace` option:
      #   query = Gcloud::Datastore::Query.new.kind("Task").
      #     where("completed", "=", true)
      #   dataset.transaction do |tx|
      #     tasks = tx.run query, namespace: "ns~todo-project"
      #   end
      #
      def run query, namespace: nil
        partition = optional_partition_id namespace
        response = connection.run_query query.to_proto, partition,
                                        transaction: @id
        entities = to_gcloud_entities response.batch.entity_result
        cursor = Proto.encode_cursor response.batch.end_cursor
        more_results = Proto.to_more_results_string response.batch.more_results
        QueryResults.new entities, cursor, more_results
      end
      alias_method :run_query, :run

      ##
      # Begins a transaction.
      # This method is run when a new Transaction is created.
      def start
        fail TransactionError, "Transaction already opened." unless @id.nil?

        response = connection.begin_transaction
        @id = response.transaction
      end
      alias_method :begin_transaction, :start

      ##
      # Commits a transaction.
      #
      # @yield [commit] an optional block for making changes
      # @yieldparam [Commit] commit The object that changes are made on
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   user = dataset.entity "User", "heidi" do |u|
      #     u["name"] = "Heidi Henderson"
      #     u["email"] = "heidi@example.net"
      #   end
      #
      #   tx = dataset.transaction
      #   begin
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #     tx.commit
      #   rescue
      #     tx.rollback
      #   end
      #
      # @example Commit can be passed a block, same as {Dataset#commit}:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   tx = dataset.transaction
      #   begin
      #     tx.commit do |c|
      #       c.save task1, task2
      #       c.delete entity1, entity2
      #     end
      #   rescue
      #     tx.rollback
      #   end
      #
      def commit
        if @id.nil?
          fail TransactionError, "Cannot commit when not in a transaction."
        end

        yield @commit if block_given?
        response = connection.commit @commit.mutation, @id
        auto_id_assign_ids @commit.auto_id_entities,
                           response.mutation_result.insert_auto_id_key
        # Make sure all entity keys are frozen so all show as persisted
        @commit.entities.each { |e| e.key.freeze unless e.persisted? }
        true
      end

      ##
      # Rolls a transaction back.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   user = dataset.entity "User", "heidi" do |u|
      #     u["name"] = "Heidi Henderson"
      #     u["email"] = "heidi@example.net"
      #   end
      #
      #   tx = dataset.transaction
      #   begin
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #     tx.commit
      #   rescue
      #     tx.rollback
      #   end
      def rollback
        if @id.nil?
          fail TransactionError, "Cannot rollback when not in a transaction."
        end

        connection.rollback @id
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
