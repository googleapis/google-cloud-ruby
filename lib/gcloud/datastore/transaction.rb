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
        @commit.save(*entities)
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
        @commit.delete(*entities_or_keys)
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

        ensure_service!

        commit_res = service.commit @commit.mutations, transaction: @id
        entities = @commit.entities
        returned_keys = commit_res.mutation_results.map(&:key)
        returned_keys.each_with_index do |key, index|
          entity = entities[index]
          next if entity.nil?
          entity.key = Key.from_grpc(key) unless key.nil?
        end
        # Make sure all entity keys are frozen so all show as persisted
        entities.each { |e| e.key.freeze unless e.persisted? }
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
