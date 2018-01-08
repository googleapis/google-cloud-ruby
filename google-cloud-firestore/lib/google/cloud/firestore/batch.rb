# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/commit_response"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # Batch
      #
      # A batch in Cloud Firestore is a set of writes that execute
      # atomically at a single logical point in time in a database.
      #
      # All changes are accumulated in memory until the block passed to
      # {Database#batch} completes. Unlike transactions, batches don't lock on
      # document reads, should only fail if users provide preconditions, and are
      # not automatically retried.
      #
      # @see https://firebase.google.com/docs/firestore/manage-data/transactions
      #   Transactions and Batched Writes
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   firestore.batch do |b|
      #     # Set the data for NYC
      #     b.set("cities/NYC", { name: "New York City" })
      #
      #     # Update the population for SF
      #     b.update("cities/SF", { population: 1000000 })
      #
      #     # Delete LA
      #     b.delete("cities/LA")
      #   end
      #
      class Batch
        ##
        # @private New Batch object.
        def initialize
          @writes = []
        end

        ##
        # The client the Cloud Firestore batch belongs to.
        #
        # @return [Client] firestore client.
        def firestore
          @client
        end
        alias_method :client, :firestore

        # @!group Modifications

        ##
        # Create a document with the provided data (fields and values).
        #
        # The batch will fail if the document already exists.
        #
        # @param [String, DocumentReference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash] data The document's fields and values.
        #
        # @example Create a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.create("cities/NYC", { name: "New York City" })
        #   end
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.batch do |b|
        #     b.create(nyc_ref, { name: "New York City" })
        #   end
        #
        # @example Create a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.batch do |b|
        #     b.create(nyc_ref, { name: "New York City",
        #                         updated_at: firestore.field_server_time })
        #   end
        #
        def create doc, data
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.writes_for_create(doc_path, data)

          nil
        end

        ##
        # Write the provided data (fields and values) to the provided document.
        # If the document does not exist, it will be created. By default, the
        # provided data overwrites existing data, but the provided data can be
        # merged into the existing document using the `merge` argument.
        #
        # If you're not sure whether the document exists, use the `merge`
        # argument to merge the new data with any existing document data to
        # avoid overwriting entire documents.
        #
        # @param [String, DocumentReference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash] data The document's fields and values.
        # @param [Boolean, FieldPath, String, Symbol] merge When
        #   `true`, all provided data is merged with the existing document data.
        #   When the argument is one or more field path, only the data for
        #   fields in this argument is merged with the existing document data.
        #   The default is to not merge, but to instead overwrite the existing
        #   document data.
        #
        # @example Set a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.set("cities/NYC", { name: "New York City" })
        #   end
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.batch do |b|
        #     b.set(nyc_ref, { name: "New York City" })
        #   end
        #
        # @example Set a document and merge all data:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.set("cities/NYC", { name: "New York City" }, merge: true)
        #   end
        #
        # @example Set a document and merge only name:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.set("cities/NYC", { name: "New York City" }, merge: :name)
        #   end
        #
        # @example Set a document and deleting a field using merge:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                trash: firestore.field_delete }
        #
        #   firestore.batch do |b|
        #     b.set(nyc_ref, nyc_data, merge: true)
        #   end
        #
        # @example Set a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                updated_at: firestore.field_server_time }
        #
        #   firestore.batch do |b|
        #     b.set(nyc_ref, nyc_data, merge: true)
        #   end
        #
        def set doc, data, merge: nil
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.writes_for_set(doc_path, data, merge: merge)

          nil
        end

        ##
        # Update the document with the provided data (fields and values). The
        # provided data is merged into the existing document data.
        #
        # The batch will fail if the document does not exist.
        #
        # @param [String, DocumentReference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash<FieldPath|String|Symbol, Object>] data The document's
        #   fields and values.
        #
        #   The top-level keys in the data hash are considered field paths, and
        #   can either be a FieldPath object, or a string representing the
        #   nested fields. In other words the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @example Update a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.update("cities/NYC", { name: "New York City" })
        #   end
        #
        # @example Directly update a deeply-nested field with a `FieldPath`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   nested_field_path = Google::Cloud::Firestore::FieldPath.new(
        #     :favorites, :food
        #   )
        #
        #   firestore.batch do |b|
        #     b.update("users/frank", { nested_field_path: "Pasta" })
        #   end
        #
        # @example Update a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.batch do |b|
        #     b.update(nyc_ref, { name: "New York City" })
        #   end
        #
        # @example Update a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   firestore.batch do |b|
        #     b.update("cities/NYC", { name: "New York City" },
        #              update_time: last_updated_at)
        #   end
        #
        # @example Update a document and deleting a field:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                trash: firestore.field_delete }
        #
        #   firestore.batch do |b|
        #     b.update(nyc_ref, nyc_data)
        #   end
        #
        # @example Update a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                updated_at: firestore.field_server_time }
        #
        #   firestore.batch do |b|
        #     b.update(nyc_ref, nyc_data)
        #   end
        #
        def update doc, data, update_time: nil
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.writes_for_update(doc_path, data,
                                               update_time: update_time)

          nil
        end

        ##
        # Deletes a document from the database.
        #
        # @param [String, DocumentReference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Boolean] exists Whether the document must exist. When `true`,
        #   the document must exist or an error is raised. Default is `false`.
        #   Optional.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @example Delete a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.delete "cities/NYC"
        #   end
        #
        # @example Delete a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.batch do |b|
        #     b.delete nyc_ref
        #   end
        #
        # @example Delete a document using `exists`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     b.delete "cities/NYC", exists: true
        #   end
        #
        # @example Delete a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   firestore.batch do |b|
        #     b.delete "cities/NYC", update_time: last_updated_at
        #   end
        #
        def delete doc, exists: nil, update_time: nil
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.write_for_delete(
            doc_path, exists: exists, update_time: update_time)

          nil
        end

        # @!endgroup

        ##
        # @private commit the batch
        def commit
          ensure_not_closed!
          @closed = true
          return nil if @writes.empty?
          resp = service.commit @writes.flatten
          return nil if resp.nil?
          CommitResponse.from_grpc resp, @writes
        end

        ##
        # @private the batch is complete and closed
        def closed?
          @closed
        end

        ##
        # @private New Batch reference object from a path.
        def self.from_client client
          new.tap do |b|
            b.instance_variable_set :@client, client
          end
        end

        ##
        # @private The Service object.
        def service
          ensure_client!

          firestore.service
        end

        protected

        ##
        # @private
        def coalesce_doc_path_argument doc_path
          return doc_path.path if doc_path.respond_to? :path

          client.doc(doc_path).path
        end

        ##
        # @private
        def ensure_not_closed!
          fail "batch is closed" if closed?
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_client!
          fail "Must have active connection to service" unless firestore
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
