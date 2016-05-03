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
