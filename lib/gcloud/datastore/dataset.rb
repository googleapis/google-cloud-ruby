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

require "gcloud/datastore/connection"
require "gcloud/datastore/credentials"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"
require "gcloud/datastore/query"
require "gcloud/datastore/list"

module Gcloud
  module Datastore
    ##
    # Datastore Entity
    #
    # See Gcloud::Datastore.dataset
    class Dataset
      attr_accessor :connection # :nodoc:

      ##
      # Creates a new Dataset instance.
      # See Gcloud::Datastore.dataset
      def initialize project, credentials #:nodoc:
        @connection = Connection.new project, credentials
      end

      def dataset_id
        connection.dataset_id
      end

      ##
      # Generate IDs for a Key before creating an entity.
      #
      #   conn = Gcloud::Datastore.connection
      #   empty_key = Gcloud::Datastore::Key.new "Task"
      #   task_keys = conn.allocate_ids empty_key, 5
      def allocate_ids incomplete_key, count = 1
        if incomplete_key.complete?
          fail Gcloud::Datastore::Error, "An incomplete key must be provided."
        end

        incomplete_keys = count.times.map { incomplete_key.to_proto }
        response = connection.allocate_ids(*incomplete_keys)
        Array(response.key).map do |key|
          Key.from_proto key
        end
      end

      def save *entities
        mutation = Proto.new_mutation
        save_entities_to_mutation entities, mutation
        response = connection.commit mutation
        auto_id_assign_ids response.mutation_result.insert_auto_id_key
        entities
      end

      def find key_or_kind, id_or_name = nil
        key = key_or_kind
        key = Key.new key_or_kind, id_or_name unless key_or_kind.is_a? Key
        find_all(key).first
      end

      def find_all *keys
        response = connection.lookup(*keys.map(&:to_proto))
        Array(response.found).map do |found|
          Entity.from_proto found.entity
        end
      end
      alias_method :lookup, :find_all

      def delete *entities
        mutation = Proto.new_mutation.tap do |m|
          m.delete = entities.map { |entity| entity.key.to_proto }
        end
        connection.commit mutation
        true
      end

      def run query
        response = connection.run_query query.to_proto
        results = Array(response.batch.entity_result).map do |result|
          Entity.from_proto result.entity
        end
        cursor = Proto.encode_cursor(response.batch.end_cursor)
        List.new results, cursor
      end
      alias_method :run_query, :run

      ##
      # Runs the given block in a database transaction.
      # If no block is given the transaction object is returned.
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = Gcloud::Datastore::Key.new "User", "username"
      #   user["name"] = "Test"
      #   user["email"] = "test@example.net"
      #
      #   dataset.transaction do |tx|
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #   end
      #
      # Alternatively, you can manually commit or rollback by
      # using the returned transaction object.
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = Gcloud::Datastore::Key.new "User", "username"
      #   user["name"] = "Test"
      #   user["email"] = "test@example.net"
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
      def transaction
        tx = Transaction.new connection
        return tx unless block_given?

        begin
          yield tx
          tx.commit
        rescue => e
          tx.rollback
          raise TransactionError.new("Transaction failed to commit.", e)
        end
      end

      protected

      def auto_id_register entity #:nodoc:
        @_auto_id_entities ||= []
        @_auto_id_entities << entity
      end

      def auto_id_assign_ids auto_ids #:nodoc:
        @_auto_id_entities ||= []
        Array(auto_ids).each_with_index do |key, index|
          entity = @_auto_id_entities[index]
          entity.key = Key.from_proto key
        end
        @_auto_id_entities = []
      end

      def save_entities_to_mutation entities, mutation #:nodoc:
        entities.each do |entity|
          if entity.key.id.nil? && entity.key.name.nil?
            mutation.insert_auto_id << entity.to_proto
            auto_id_register entity
          else
            mutation.upsert << entity.to_proto
          end
        end
      end
    end
  end
end
