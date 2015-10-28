#--
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

require "gcloud/gce"
require "gcloud/datastore/connection"
require "gcloud/datastore/credentials"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"
require "gcloud/datastore/query"
require "gcloud/datastore/dataset/lookup_results"
require "gcloud/datastore/dataset/query_results"

module Gcloud
  module Datastore
    ##
    # = Dataset
    #
    # Dataset is the data saved in a project's Datastore.
    # Dataset is analogous to a database in relational database world.
    #
    # Gcloud::Datastore::Dataset is the main object for interacting with
    # Google Datastore. Gcloud::Datastore::Entity objects are created,
    # read, updated, and deleted by Gcloud::Datastore::Dataset.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dataset = gcloud.datastore
    #
    #   query = Gcloud::Datastore::Query.new.kind("Task").
    #     where("completed", "=", true)
    #
    #   tasks = dataset.run query
    #
    # See Gcloud#datastore
    class Dataset
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Dataset instance.
      #
      # See Gcloud#datastore
      def initialize project, credentials #:nodoc:
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      ##
      # The Datastore project connected to.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #
      #   dataset = gcloud.datastore
      #   dataset.project #=> "my-todo-project"
      #
      def project
        connection.dataset_id
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["DATASTORE_DATASET"] ||
          ENV["DATASTORE_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Generate IDs for a Key before creating an entity.
      #
      # === Parameters
      #
      # +incomplete_key+::
      #   A Key without +id+ or +name+ set. (+Key+)
      # +count+::
      #   The number of new key IDs to create. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Datastore::Key
      #
      # === Example
      #
      #   empty_key = Gcloud::Datastore::Key.new "Task"
      #   task_keys = dataset.allocate_ids empty_key, 5
      #
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

      ##
      # Persist one or more entities to the Datastore.
      #
      # === Parameters
      #
      # +entities+::
      #   One or more entity objects to be saved without +id+ or +name+ set.
      #   (+Entity+)
      #
      # === Returns
      #
      # Array of Gcloud::Datastore::Entity
      #
      # === Example
      #
      #   dataset.save task1, task2
      #
      def save *entities
        mutation = Proto.new_mutation
        save_entities_to_mutation entities, mutation
        response = connection.commit mutation
        auto_id_assign_ids response.mutation_result.insert_auto_id_key
        entities
      end

      ##
      # Retrieve an entity by providing key information.
      #
      # === Parameters
      #
      # +key_or_kind+::
      #   A Key object or +kind+ string value. (+Key+ or +String+)
      # +id_or_name+::
      #   The Key's +id+ or +name+ value if a +kind+ was provided in the first
      #   parameter. (+Integer+ or +String+ or +nil+)
      #
      # === Returns
      #
      # Gcloud::Datastore::Entity or +nil+
      #
      # === Example
      #
      # Finding an entity with a key:
      #
      #   key = Gcloud::Datastore::Key.new "Task", 123456
      #   task = dataset.find key
      #
      # Finding an entity with a +kind+ and +id+/+name+:
      #
      #   task = dataset.find "Task", 123456
      #
      def find key_or_kind, id_or_name = nil
        key = key_or_kind
        key = Key.new key_or_kind, id_or_name unless key_or_kind.is_a? Key
        find_all(key).first
      end
      alias_method :get, :find

      ##
      # Retrieve the entities for the provided keys.
      #
      # === Parameters
      #
      # +keys+::
      #   One or more Key objects to find records for. (+Key+)
      #
      # === Returns
      #
      # Gcloud::Datastore::Dataset::LookupResults
      #
      # === Example
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   key1 = Gcloud::Datastore::Key.new "Task", 123456
      #   key2 = Gcloud::Datastore::Key.new "Task", 987654
      #   tasks = dataset.find_all key1, key2
      #
      def find_all *keys
        response = connection.lookup(*keys.map(&:to_proto))
        entities = to_gcloud_entities response.found
        deferred = to_gcloud_keys response.deferred
        missing  = to_gcloud_entities response.missing
        LookupResults.new entities, deferred, missing
      end
      alias_method :lookup, :find_all

      ##
      # Remove entities from the Datastore.
      #
      # === Parameters
      #
      # +entities_or_keys+::
      #   One or more Entity or Key objects to remove. (+Entity+ or +Key+)
      #
      # === Returns
      #
      # +true+ if successful
      #
      # === Example
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   dataset.delete entity1, entity2
      #
      def delete *entities_or_keys
        keys = entities_or_keys.map do |e_or_k|
          e_or_k.respond_to?(:key) ? e_or_k.key.to_proto : e_or_k.to_proto
        end
        mutation = Proto.new_mutation.tap do |m|
          m.delete = keys
        end
        connection.commit mutation
        true
      end

      # rubocop:disable Metrics/AbcSize
      # Disabled rubocop because the level of abstraction is not violated here

      ##
      # Retrieve entities specified by a Query.
      #
      # === Parameters
      #
      # +query+::
      #   The Query object with the search criteria. (+Query+)
      #
      # === Returns
      #
      # Gcloud::Datastore::Dataset::QueryResults
      #
      # === Example
      #
      #   query = Gcloud::Datastore::Query.new.kind("Task").
      #     where("completed", "=", true)
      #   tasks = dataset.run query
      #
      def run query, options = {}
        partition = optional_partition_id options[:namespace]
        response = connection.run_query query.to_proto, partition
        entities = to_gcloud_entities response.batch.entity_result
        cursor = Proto.encode_cursor response.batch.end_cursor
        more_results = Proto.to_more_results_string response.batch.more_results
        QueryResults.new entities, cursor, more_results
      end
      alias_method :run_query, :run

      # rubocop:enable Metrics/AbcSize

      ##
      # Creates a Datastore Transaction.
      #
      # === Example
      #
      # Runs the given block in a database transaction:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   key = Gcloud::Datastore::Key.new "User", "heidi"
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = key
      #   user["name"] = "Heidi Henderson"
      #   user["email"] = "heidi@example.net"
      #
      #   dataset.transaction do |tx|
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #   end
      #
      # Alternatively, if no block is given a Transaction object is returned:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #
      #   key = Gcloud::Datastore::Key.new "User", "heidi"
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = key
      #   user["name"] = "Heidi Henderson"
      #   user["email"] = "heidi@example.net"
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

      ##
      # Convenince method to convert proto entities to Gcloud entities.
      def to_gcloud_entities proto_results
        # Entities are nested in an object.
        Array(proto_results).map do |result|
          Entity.from_proto result.entity
        end
      end

      ##
      # Convenince method to convert proto keys to Gcloud keys.
      def to_gcloud_keys proto_results
        # Keys are not nested in an object like entities are.
        Array(proto_results).map do |key|
          Key.from_proto key
        end
      end

      ##
      # Save a key to be given an ID when comitted.
      def auto_id_register entity #:nodoc:
        @_auto_id_entities ||= []
        @_auto_id_entities << entity
      end

      ##
      # Update saved keys with new IDs post-commit.
      def auto_id_assign_ids auto_ids #:nodoc:
        @_auto_id_entities ||= []
        Array(auto_ids).each_with_index do |key, index|
          entity = @_auto_id_entities[index]
          entity.key = Key.from_proto key
        end
        @_auto_id_entities = []
      end

      ##
      # Add entities to a Mutation, and register they key to be
      # updated with an auto ID if needed.
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

      def optional_partition_id namespace = nil
        return nil if namespace.nil?
        Proto::PartitionId.new.tap do |p|
          p.namespace = namespace
          p.datasetId = project
        end
      end
    end
  end
end
