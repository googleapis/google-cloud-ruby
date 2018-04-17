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
require "google/cloud/firestore/service"
require "google/cloud/firestore/field_path"
require "google/cloud/firestore/field_value"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/batch"
require "google/cloud/firestore/transaction"

module Google
  module Cloud
    module Firestore
      ##
      # # Client
      #
      # The Cloud Firestore Client used is to access and manipulate the
      # collections and documents in the Firestore database.
      #
      # @example
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
      class Client
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Firestore Database instance.
        def initialize service
          @service = service
        end

        ##
        # The project identifier for the Cloud Firestore database.
        #
        # @return [String] project identifier.
        def project_id
          service.project
        end

        ##
        # The database identifier for the Cloud Firestore database.
        #
        # @return [String] database identifier.
        def database_id
          "(default)"
        end

        ##
        # @private The full Database path for the Cloud Firestore database.
        #
        # @return [String] database resource path.
        def path
          service.database_path
        end

        # @!group Access

        ##
        # Retrieves a list of collections.
        #
        # @yield [collections] The block for accessing the collections.
        # @yieldparam [CollectionReference] collection A collection.
        #
        # @return [Enumerator<CollectionReference>] collection list.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get the root collections
        #   firestore.cols.each do |col|
        #     puts col.collection_id
        #   end
        #
        def cols
          ensure_service!

          return enum_for(:cols) unless block_given?

          collection_ids = service.list_collections "#{path}/documents"
          collection_ids.each { |collection_id| yield col(collection_id) }
        end
        alias collections cols

        ##
        # Retrieves a collection.
        #
        # @param [String] collection_path A string representing the path of the
        #   collection, relative to the document root of the database.
        #
        # @return [CollectionReference] A collection.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get the cities collection
        #   cities_col = firestore.col "cities"
        #
        #   # Get the document for NYC
        #   nyc_ref = cities_col.doc "NYC"
        #
        def col collection_path
          if collection_path.to_s.split("/").count.even?
            raise ArgumentError, "collection_path must refer to a collection."
          end

          CollectionReference.from_path \
            "#{path}/documents/#{collection_path}", self
        end
        alias collection col

        ##
        # Retrieves a document reference.
        #
        # @param [String] document_path A string representing the path of the
        #   document, relative to the document root of the database.
        #
        # @return [DocumentReference] A document.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   puts nyc_ref.document_id
        #
        def doc document_path
          if document_path.to_s.split("/").count.odd?
            raise ArgumentError, "document_path must refer to a document."
          end

          doc_path = "#{path}/documents/#{document_path}"

          DocumentReference.from_path doc_path, self
        end
        alias document doc

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
        #   # Get and print city documents
        #   cities = ["cities/NYC", "cities/SF", "cities/LA"]
        #   firestore.get_all(cities).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def get_all *docs
          ensure_service!

          return enum_for(:get_all, docs) unless block_given?

          doc_paths = Array(docs).flatten.map do |doc_path|
            coalesce_doc_path_argument doc_path
          end

          results = service.get_documents doc_paths
          results.each do |result|
            next if result.result.nil?
            yield DocumentSnapshot.from_batch_result(result, self)
          end
        end
        alias get_docs get_all
        alias get_documents get_all
        alias find get_all

        ##
        # Creates a field path object representing the sentinel ID of a
        # document. It can be used in queries to sort or filter by the document
        # ID. See {Client#document_id}.
        #
        # @return [FieldPath] The field path object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.start_at("NYC").order(
        #     Google::Cloud::Firestore::FieldPath.document_id
        #   )
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def document_id
          FieldPath.document_id
        end

        ##
        # Creates a field path object representing a nested field for
        # document data.
        #
        # @param [String, Symbol] fields One or more strings representing the
        #   path of the data to select. Each field must be provided separately.
        #
        # @return [FieldPath] The field path object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   nested_field_path = firestore.field_path :favorites, :food
        #   user_snap.get(nested_field_path) #=> "Pizza"
        #
        def field_path *fields
          FieldPath.new(*fields)
        end

        ##
        # Creates a field value object representing the deletion of a field in
        # document data.
        #
        # @return [FieldValue] The delete field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.update({ name: "New York City",
        #                    trash: firestore.field_delete })
        #
        def field_delete
          FieldValue.delete
        end

        ##
        # Creates a field value object representing set a field's value to
        # the server timestamp when accessing the document data.
        #
        # @return [FieldValue] The server time field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.update({ name: "New York City",
        #                    updated_at: firestore.field_server_time })
        #
        def field_server_time
          FieldValue.server_time
        end

        # @!endgroup

        # @!group Operations

        ##
        # Perform multiple changes at the same time.
        #
        # All changes are accumulated in memory until the block completes.
        # Unlike transactions, batches don't lock on document reads, should only
        # fail if users provide preconditions, and are not automatically
        # retried. See {Batch}.
        #
        # @see https://firebase.google.com/docs/firestore/manage-data/transactions
        #   Transactions and Batched Writes
        #
        # @yield [batch] The block for reading data and making changes.
        # @yieldparam [Batch] batch The write batch object for making changes.
        #
        # @return [CommitResponse] The response from committing the changes.
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
        def batch
          batch = Batch.from_client self
          yield batch
          batch.commit
        end

        ##
        # Create a transaction to perform multiple reads and writes that are
        # executed atomically at a single logical point in time in a database.
        #
        # All changes are accumulated in memory until the block completes.
        # Transactions will be automatically retried when documents change
        # before the transaction is committed. See {Transaction}.
        #
        # @see https://firebase.google.com/docs/firestore/manage-data/transactions
        #   Transactions and Batched Writes
        #
        # @param [Integer] max_retries The maximum number of retries for
        #   transactions failed due to errors. Default is 5. Optional.
        #
        # @yield [transaction] The block for reading data and making changes.
        # @yieldparam [Transaction] transaction The transaction object for
        #   making changes.
        #
        # @return [CommitResponse] The response from committing the changes.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Set the data for NYC
        #     tx.set("cities/NYC", { name: "New York City" })
        #
        #     # Update the population for SF
        #     tx.update("cities/SF", { population: 1000000 })
        #
        #     # Delete LA
        #     tx.delete("cities/LA")
        #   end
        #
        def transaction max_retries: nil
          max_retries = 5 unless max_retries.is_a? Integer
          retries = 0
          backoff = 1.0

          transaction = Transaction.from_client self
          begin
            yield transaction
            transaction.commit
          rescue Google::Cloud::UnavailableError => err
            # Re-raise if deadline has passed
            raise err if retries >= max_retries
            # Sleep with incremental backoff
            sleep(backoff *= 1.3)
            # Create new transaction and retry
            transaction = Transaction.from_client \
              self, previous_transaction: transaction.transaction_id
            retries += 1
            retry
          rescue Google::Cloud::InvalidArgumentError => err
            # Return if a previous call has succeeded
            return nil if retries > 0
            # Re-raise error.
            raise err
          rescue StandardError => err
            # Rollback transaction when handling unexpected error
            transaction.rollback rescue nil
            # Re-raise error.
            raise err
          end
        end

        # @!endgroup

        protected

        ##
        # @private
        def coalesce_get_argument obj
          return obj.ref if obj.is_a? DocumentSnapshot

          return obj unless obj.is_a?(String) || obj.is_a?(Symbol)

          return doc obj if obj.to_s.split("/").count.even?

          col obj # Convert to CollectionReference
        end

        ##
        # @private
        def coalesce_doc_path_argument doc_path
          return doc_path.path if doc_path.respond_to? :path

          doc(doc_path).path
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
