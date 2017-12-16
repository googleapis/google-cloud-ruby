# Copyright 2016 Google LLC
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
      # # Commit
      #
      # Object yielded from `commit` methods to allow multiple changes to be
      # made in a single commit.
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   datastore.commit do |c|
      #     c.save task3, task4
      #     c.delete task1, task2
      #   end
      #
      # See {Google::Cloud::Datastore::Dataset#commit} and
      # {Google::Cloud::Datastore::Transaction#commit}.
      class Commit
        ##
        # @private Create a new Commit object.
        def initialize
          @shared_upserts = []
          @shared_inserts = []
          @shared_updates = []
          @shared_deletes = []
        end

        ##
        # Saves entities to the Datastore.
        #
        # @param [Entity] entities One or more Entity objects to save.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.commit do |c|
        #     c.save task1, task2
        #   end
        #
        def save *entities
          entities = Array(entities).flatten
          @shared_upserts += entities unless entities.empty?
          # Do not save yet
          entities
        end
        alias_method :upsert, :save

        ##
        # Inserts entities to the Datastore.
        #
        # @param [Entity] entities One or more Entity objects to insert.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.commit do |c|
        #     c.insert task1, task2
        #   end
        #
        def insert *entities
          entities = Array(entities).flatten
          @shared_inserts += entities unless entities.empty?
          # Do not insert yet
          entities
        end

        ##
        # Updates entities to the Datastore.
        #
        # @param [Entity] entities One or more Entity objects to update.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.commit do |c|
        #     c.update task1, task2
        #   end
        #
        def update *entities
          entities = Array(entities).flatten
          @shared_updates += entities unless entities.empty?
          # Do not update yet
          entities
        end

        ##
        # Remove entities from the Datastore.
        #
        # @param [Entity, Key] entities_or_keys One or more Entity or Key
        #   objects to remove.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   datastore.commit do |c|
        #     c.delete task1, task2
        #   end
        #
        def delete *entities_or_keys
          keys = Array(entities_or_keys).flatten.map do |e_or_k|
            e_or_k.respond_to?(:key) ? e_or_k.key : e_or_k
          end
          @shared_deletes += keys unless keys.empty?
          # Do not delete yet
          true
        end

        # @private Mutations object to be committed.
        def mutations
          mutations = []
          mutations += @shared_upserts.map do |entity|
            Google::Datastore::V1::Mutation.new upsert: entity.to_grpc
          end
          mutations += @shared_inserts.map do |entity|
            Google::Datastore::V1::Mutation.new insert: entity.to_grpc
          end
          mutations += @shared_updates.map do |entity|
            Google::Datastore::V1::Mutation.new update: entity.to_grpc
          end
          mutations += @shared_deletes.map do |key|
            Google::Datastore::V1::Mutation.new delete: key.to_grpc
          end
          mutations
        end

        # @private All entities saved in the commit.
        def entities
          @shared_upserts + @shared_inserts + @shared_updates
        end
      end
    end
  end
end
