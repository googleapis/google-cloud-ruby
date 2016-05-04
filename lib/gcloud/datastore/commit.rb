# Copyright 2016 Google Inc. All rights reserved.
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
    # # Commit
    #
    # Object yielded from `commit` methods to allow multiple changes to be made
    # in a single commit.
    #
    # @example
    #   dataset.commit do |c|
    #     c.save task1, task2
    #     c.delete entity1, entity2
    #   end
    #
    # See {Gcloud::Datastore::Dataset#commit} and
    # {Gcloud::Datastore::Transaction#commit}.
    #
    class Commit
      ##
      # @private Create a new Commit object.
      def initialize
        @shared_entities = []
        @shared_auto_ids = []
        @shared_deletes  = []
      end

      ##
      # Saves entities to the Datastore.
      #
      # @param [Entity] entities One or more Entity objects to save.
      #
      # @example
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   dataset.commit do |c|
      #     c.save task1, task2
      #   end
      #
      def save *entities
        entities.each do |entity|
          shared_auto_ids << entity if entity.key.incomplete?
          shared_entities << entity
        end
        # Do not save yet
        entities
      end

      ##
      # Remove entities from the Datastore.
      #
      # @param [Entity, Key] entities_or_keys One or more Entity or Key
      #   objects to remove.
      #
      # @example
      #   gcloud = Gcloud.new
      #   dataset = gcloud.datastore
      #   dataset.commit do |c|
      #     c.delete entity1, entity2
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

      # @private Mutation object to be committed.
      def mutation
        Proto.new_mutation.tap do |m|
          m.insert_auto_id = shared_auto_ids.map(&:to_proto)
          m.upsert = shared_upserts.map(&:to_proto)
          m.delete = shared_deletes.map(&:to_proto)
        end
      end

      # @private Entities that need key ids assigned.
      def auto_id_entities
        shared_auto_ids
      end

      # @private All entities saved in the commit.
      def entities
        shared_entities
      end

      protected

      ##
      # @private List of Entity objects to be saved.
      def shared_entities
        @shared_entities
      end

      ##
      # @private List of Entity objects that need auto_ids
      def shared_auto_ids
        @shared_auto_ids
      end

      ##
      # @private List of Entity objects to be saved.
      def shared_upserts
        shared_entities - shared_auto_ids
      end

      ##
      # @private List of Key objects to be deleted.
      def shared_deletes
        @shared_deletes
      end
    end
  end
end
