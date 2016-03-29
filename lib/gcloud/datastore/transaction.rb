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
      # Takes a Connection and Service instead of project and Credentials.
      def initialize service
        @service = service
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
        create_save_mutations(entities).each { |m| shared_mutations << m }
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
      def delete *entities
        create_delete_mutations(entities).each { |m| shared_mutations << m }
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
        commit_res = service.commit shared_mutations, transaction: @id
        returned_keys = commit_res.mutation_results.map(&:key)
        update_incomplete_keys_on_saved_entities returned_keys
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
        @shared_mutations = []
        @id = nil
        @_auto_id_entities = []
      end

      protected

      ##
      # @private Mutation to be shared across save, delete, and commit calls.
      # This enables updates to happen when commit is called.
      def shared_mutations
        # @shared_mutations = Array(@shared_mutations).flatten
        @shared_mutations
      end
    end
  end
end
