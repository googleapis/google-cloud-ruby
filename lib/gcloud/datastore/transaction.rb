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
    #
    # @see https://cloud.google.com/datastore/docs/concepts/transactions
    #   Transactions
    #
    # @example Transactional update:
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
    # @example Retry logic using the transactional update example above:
    #   (1..5).each do |i|
    #     begin
    #       transfer_funds from_key, to_key, 10
    #       break
    #     rescue Gcloud::Error => e
    #       raise e if i == 5
    #     end
    #   end
    #
    # @example Transactional read:
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
      # Takes a Connection and Service instead of project and Credentials.
      def initialize service
        @service = service
        reset!
        start
      end

      ##
      # Persist entities in a transaction.
      #
      # @example Transactional get or create:
      #   task_key = datastore.key "Task", "sampleTask"
      #
      #   datastore.transaction do |tx|
      #     task = tx.find task_key
      #     if task.nil?
      #       task = datastore.entity task_key do |task|
      #         task["type"] = "Personal"
      #         task["done"] = false
      #         task["priority"] = 4
      #         task["description"] = "Learn Cloud Datastore"
      #       end
      #       tx.save task
      #     end
      #   end
      #
      def save *entities
        entities.each { |e| shared_upserts << e }
        # Do not save yet
        entities
      end

      ##
      # Remove entities in a transaction.
      #
      # @example
      #   datastore.transaction do |tx|
      #     if tx.find(task_list.key).nil?
      #       tx.delete task1, task2
      #     end
      #   end
      #
      def delete *entities_or_keys
        keys = entities_or_keys.map do |e_or_k|
          e_or_k.respond_to?(:key) ? e_or_k.key : e_or_k
        end
        keys.each { |k| shared_deletes << k }
        # Do not delete yet
        true
      end

      ##
      # Begins a transaction.
      # This method is run when a new Transaction is created.
      def start
        fail TransactionError, "Transaction already opened." unless @id.nil?

        ensure_service!
        tx_res = service.begin_transaction
        @id = tx_res.transaction
      end
      alias_method :begin_transaction, :start

      ##
      # Commits a transaction.
      def commit
        if @id.nil?
          fail TransactionError, "Cannot commit when not in a transaction."
        end

        ensure_service!

        mutations = shared_mutations

        commit_res = service.commit mutations, transaction: @id
        returned_keys = commit_res.mutation_results.map(&:key)
        returned_keys.each_with_index do |key, index|
          entity = shared_upserts[index]
          next if entity.nil?
          # assign returned key if entity and key are present
          entity.key = Key.from_grpc key unless key.nil?
        end
        # Make sure all entity keys are frozen so all show as persisted
        shared_upserts.each { |e| e.key.freeze unless e.persisted? }
        true
      end

      ##
      # Rolls a transaction back.
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
        @shared_upserts = []
        @shared_deletes = []
        @id = nil
      end

      protected

      ##
      # @private List of Entity objects to be saved.
      def shared_upserts
        @shared_upserts
      end

      ##
      # @private List of Key objects to be deleted.
      def shared_deletes
        @shared_deletes
      end

      ##
      # @private List of Mutation objects to be committed.
      def shared_mutations
        mutations = []
        # shared upserts always go in first, so the keys can be assigned
        shared_upserts.each do |e|
          m = Google::Datastore::V1beta3::Mutation.new upsert: e.to_grpc
          mutations << m
        end
        shared_deletes.each do |k|
          m = Google::Datastore::V1beta3::Mutation.new delete: k.to_grpc
          mutations << m
        end
        mutations
      end
    end
  end
end
