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
    # Special Connection instance for running transactions.
    #
    # See Gcloud::Datastore::Dataset.transaction
    class Transaction < Dataset
      attr_reader :id

      ##
      # Creates a new Transaction instance.
      # Takes a Connection instead of project and Credentials.
      def initialize connection #:nodoc:
        @connection = connection
        reset!
        start
      end

      def save *entities
        save_entities_to_mutation entities, shared_mutation
        # Do not save or assign auto_ids yet
        entities
      end

      def delete *entities
        shared_mutation.tap do |m|
          m.delete = entities.map { |entity| entity.key.to_proto }
        end
        # Do not delete yet
        true
      end

      def start
        fail "Transaction already opened" unless @id.nil?

        response = connection.begin_transaction
        @id = response.transaction
      end

      def commit
        fail "Cannot commit when not in a transaction" if @id.nil?

        response = connection.commit shared_mutation, @id
        auto_id_assign_ids response.mutation_result.insert_auto_id_key
        true
      end

      def rollback
        fail "Cannot rollback when not in a transaction" if @id.nil?

        connection.rollback @id
        true
      end

      ##
      # Reset the transaction.
      # Transaction#start must be called afterwards.
      def reset!
        @shared_mutation = nil
        @id  = nil
        @_auto_id_entities = []
      end

      protected

      def shared_mutation #:nodoc:
        # Work on a shared mutation object
        @shared_mutation ||= Proto.new_mutation
      end
    end
  end
end
