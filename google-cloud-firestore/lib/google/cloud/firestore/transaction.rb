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


require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/commit_response"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # Transaction
      #
      # A transaction in Cloud Firestore is a set of reads and writes that
      # execute atomically at a single logical point in time.
      #
      # All changes are accumulated in memory until the block passed to
      # {Database#transaction} completes. Transactions will be automatically
      # retried when documents change before the transaction is committed. See
      # {Database#transaction}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   city = firestore.col("cities").doc("SF")
      #   city.set({ name: "San Francisco",
      #              state: "CA",
      #              country: "USA",
      #              capital: false,
      #              population: 860000 })
      #
      #   firestore.transaction do |tx|
      #     new_population = tx.get(city).data[:population] + 1
      #     tx.update(city, { population: new_population })
      #   end
      #
      class Transaction
        ##
        # @private New Transaction object.
        def initialize
          @writes = []
          @transaction_id = nil
          @previous_transaction = nil
        end

        ##
        # The transaction identifier.
        #
        # @return [String] transaction identifier.
        def transaction_id
          @transaction_id
        end

        ##
        # The client the Cloud Firestore transaction belongs to.
        #
        # @return [Client] firestore client.
        def firestore
          @client
        end
        alias client firestore

        # @!group Access

        ##
        # Retrieves a list of document snapshots.
        #
        # @param [String, DocumentReference] docs One or more strings
        #   representing the path of the document, or document reference
        #   objects.
        #
        # @yield [documents] The block for accessing the document snapshots.
        # @yieldparam [DocumentSnapshot] document A document snapshot.
        #
        # @return [Enumerator<DocumentSnapshot>] document snapshots list.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Get and print city documents
        #     tx.get_all("cities/NYC", "cities/SF", "cities/LA").each do |city|
        #       puts "#{city.document_id} has #{city[:population]} residents."
        #     end
        #   end
        #
        def get_all *docs
          ensure_not_closed!
          ensure_service!

          return enum_for(:get_all, docs) unless block_given?

          doc_paths = Array(docs).flatten.map do |doc_path|
            coalesce_doc_path_argument doc_path
          end

          results = service.get_documents \
            doc_paths, transaction: transaction_or_create
          results.each do |result|
            extract_transaction_from_result! result
            next if result.result.nil?
            yield DocumentSnapshot.from_batch_result(result, self)
          end
        end
        alias get_docs get_all
        alias get_documents get_all
        alias find get_all

        ##
        # Retrieves document snapshots for the given value. Valid values can be
        # a string representing either a document or a collection of documents,
        # a document reference object, a collection reference object, or a query
        # to be run.
        #
        # @param [String, DocumentReference, CollectionReference, Query] obj
        #   A string representing the path of a document or collection, a
        #   document reference object, a collection reference object, or a query
        #   to run.
        #
        # @yield [documents] The block for accessing the document snapshots.
        # @yieldparam [DocumentReference] document A document snapshot.
        #
        # @return [DocumentSnapshot, Enumerator<DocumentSnapshot>] A
        #   single document snapshot when passed a document path or a document
        #   reference object, or a list of document snapshots when passed other
        #   valid values.
        #
        # @example Get a document snapshot given a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Get a document snapshot
        #     nyc_snap = tx.get "cities/NYC"
        #   end
        #
        # @example Get a document snapshot given a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   firestore.transaction do |tx|
        #     # Get a document snapshot
        #     nyc_snap = tx.get nyc_ref
        #   end
        #
        # @example Get document snapshots given a collection path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Get documents for a collection path
        #     tx.get("cities").each do |city|
        #       # Update the city population by 1
        #       tx.update(city, { population: city[:population] + 1})
        #     end
        #   end
        #
        # @example Get document snapshots given a collection reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col :cities
        #
        #   firestore.transaction do |tx|
        #     # Get documents for a collection
        #     tx.get(cities_col).each do |city|
        #       # Update the city population by 1
        #       tx.update(city, { population: city[:population] + 1})
        #     end
        #   end
        #
        # @example Get document snapshots given a query:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).select(:population)
        #
        #   firestore.transaction do |tx|
        #     # Get/run a query
        #     tx.get(query).each do |city|
        #       # Update the city population by 1
        #       tx.update(city, { population: city[:population] + 1})
        #     end
        #   end
        #
        def get obj
          ensure_not_closed!
          ensure_service!

          obj = coalesce_get_argument obj

          if obj.is_a?(DocumentReference)
            doc = get_all([obj]).first
            yield doc if block_given?
            return doc
          end

          return enum_for(:get, obj) unless block_given?

          results = service.run_query obj.parent_path, obj.query,
                                      transaction: transaction_or_create
          results.each do |result|
            extract_transaction_from_result! result
            next if result.document.nil?
            yield DocumentSnapshot.from_query_result(result, self)
          end
        end
        alias run get

        # @!endgroup

        # @!group Modifications

        ##
        # Creates a document with the provided data (fields and values).
        #
        # The operation will fail if the document already exists.
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
        #   firestore.transaction do |tx|
        #     tx.create("cities/NYC", { name: "New York City" })
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
        #   firestore.transaction do |tx|
        #     tx.create(nyc_ref, { name: "New York City" })
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
        #   firestore.transaction do |tx|
        #     tx.create(nyc_ref, { name: "New York City",
        #                          updated_at: firestore.field_server_time })
        #   end
        #
        def create doc, data
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.writes_for_create(doc_path, data)

          nil
        end

        ##
        # Writes the provided data (fields and values) to the provided document.
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
        #   firestore.transaction do |tx|
        #     # Update a document
        #     tx.set("cities/NYC", { name: "New York City" })
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
        #   firestore.transaction do |tx|
        #     # Update a document
        #     tx.set(nyc_ref, { name: "New York City" })
        #   end
        #
        # @example Set a document and merge all data:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     tx.set("cities/NYC", { name: "New York City" }, merge: true)
        #   end
        #
        # @example Set a document and merge only name:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     tx.set("cities/NYC", { name: "New York City" }, merge: :name)
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
        #   firestore.transaction do |tx|
        #     tx.set(nyc_ref, nyc_data, merge: true)
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
        #   firestore.transaction do |tx|
        #     tx.set(nyc_ref, nyc_data, merge: true)
        #   end
        #
        def set doc, data, merge: nil
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.writes_for_set(doc_path, data, merge: merge)

          nil
        end

        ##
        # Updates the document with the provided data (fields and values). The
        # provided data is merged into the existing document data.
        #
        # The operation will fail if the document does not exist.
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
        #   firestore.transaction do |tx|
        #     tx.update("cities/NYC", { name: "New York City" })
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
        #   firestore.transaction do |tx|
        #     tx.update("users/frank", { nested_field_path => "Pasta" })
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
        #   firestore.transaction do |tx|
        #     tx.update(nyc_ref, { name: "New York City" })
        #   end
        #
        # @example Update a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   firestore.transaction do |tx|
        #     tx.update("cities/NYC", { name: "New York City" },
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
        #   firestore.transaction do |tx|
        #     tx.update(nyc_ref, nyc_data)
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
        #   firestore.transaction do |tx|
        #     tx.update(nyc_ref, nyc_data)
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
        #   firestore.transaction do |tx|
        #     # Delete a document
        #     tx.delete "cities/NYC"
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
        #   firestore.transaction do |tx|
        #     # Delete a document
        #     tx.delete nyc_ref
        #   end
        #
        # @example Delete a document using `exists`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Delete a document
        #     tx.delete "cities/NYC", exists: true
        #   end
        #
        # @example Delete a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   firestore.transaction do |tx|
        #     # Delete a document
        #     tx.delete "cities/NYC", update_time: last_updated_at
        #   end
        #
        def delete doc, exists: nil, update_time: nil
          ensure_not_closed!

          doc_path = coalesce_doc_path_argument doc

          @writes << Convert.write_for_delete(
            doc_path, exists: exists, update_time: update_time
          )

          nil
        end

        # @!endgroup

        ##
        # @private commit the transaction
        def commit
          ensure_not_closed!

          if @transaction_id.nil? && @writes.empty?
            @closed = true
            return CommitResponse.from_grpc nil, @writes
          end

          ensure_transaction_id!

          resp = service.commit @writes.flatten, transaction: transaction_id
          @closed = true
          CommitResponse.from_grpc resp, @writes
        end

        ##
        # @private rollback and close the transaction
        def rollback
          ensure_not_closed!

          if @transaction_id.nil? && @writes.empty?
            @closed = true
            return
          end

          service.rollback @transaction_id
          @closed = true
          nil
        end

        ##
        # @private the transaction is complete and closed
        def closed?
          @closed
        end

        ##
        # @private New Transaction reference object from a path.
        def self.from_client client, previous_transaction: nil
          new.tap do |s|
            s.instance_variable_set :@client, client
            s.instance_variable_set :@previous_transaction, previous_transaction
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
        # @private The full Database path for the Cloud Firestore transaction.
        #
        # @return [String] database resource path.
        def path
          @client.path
        end

        ##
        # @private
        def coalesce_get_argument obj
          return obj.ref if obj.is_a? DocumentSnapshot

          return obj unless obj.is_a?(String) || obj.is_a?(Symbol)

          return client.doc obj if obj.to_s.split("/").count.even?

          client.col obj # Convert to CollectionReference
        end

        ##
        # @private
        def coalesce_doc_path_argument doc_path
          return doc_path.path if doc_path.respond_to? :path

          client.doc(doc_path).path
        end

        ##
        # @private
        def transaction_or_create
          return @transaction_id if @transaction_id

          transaction_opt
        end

        ##
        # @private
        def transaction_opt
          read_write = \
            Google::Firestore::V1beta1::TransactionOptions::ReadWrite.new

          if @previous_transaction
            read_write.retry_transaction = @previous_transaction
            @previous_transaction = nil
          end

          Google::Firestore::V1beta1::TransactionOptions.new(
            read_write: read_write
          )
        end

        ##
        # @private
        def extract_transaction_from_result! result
          return if @transaction_id
          return if result.transaction.nil?
          return if result.transaction.empty?

          @transaction_id = result.transaction
        end

        ##
        # @private
        def ensure_not_closed!
          raise "transaction is closed" if closed?
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_transaction_id!
          ensure_service!

          return unless @transaction_id.nil?
          resp = service.begin_transaction transaction_opt
          @transaction_id = resp.transaction
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_client!
          raise "Must have active connection to service" unless firestore
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
