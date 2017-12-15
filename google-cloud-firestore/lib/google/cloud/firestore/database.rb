# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/collection"
require "google/cloud/firestore/document"
require "google/cloud/firestore/query"
require "google/cloud/firestore/batch"
require "google/cloud/firestore/read_only_transaction"
require "google/cloud/firestore/transaction"

module Google
  module Cloud
    module Firestore
      ##
      # # Database
      #
      class Database
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Firestore Database instance.
        def initialize service
          @service = service
        end

        ##
        # The project resource the Cloud Firestore database belongs to.
        #
        # @return [Project] project resource
        def project
          @project ||= Project.new service
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
        # The full Database path for the Cloud Firestore database.
        #
        # @return [String] database resource path.
        def path
          service.database_path
        end

        ##
        # Retrieves a list of collections.
        #
        # @yield [collections] The block for accessing the collections.
        # @yieldparam [Collection::Reference] collection A collection.
        #
        # @return [Enumerator<Collection::Reference>] collection list.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get the root collections
        #   firestore.cols.each do |col|
        #     # Print the collection
        #     puts col.collection_id
        #   end
        #
        def cols
          ensure_service!

          return enum_for(:cols) unless block_given?

          collection_ids = service.list_collections "#{path}/documents"
          collection_ids.each { |collection_id| yield col(collection_id) }
        end
        alias_method :collections, :cols

        ##
        # Retrieves a collection.
        #
        # @param [String] collection_path A string representing the path of the
        #   collection, relative to the document root of the database.
        #
        # @return [Collection::Reference] A collection.
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
        #   # Set the name for NYC
        #   firestore.set(nyc_ref, { name: "New York City" })
        #
        def col collection_path
          if collection_path.to_s.split("/").count.even?
            fail ArgumentError, "collection_path must refer to a collection."
          end

          Collection.from_path "#{path}/documents/#{collection_path}", self
        end
        alias_method :collection, :col

        ##
        # Retrieves a list of documents.
        #
        # @param [String] collection_path A string representing the path of the
        #   collection, relative to the document root of the database.
        #
        # @yield [documents] The block for accessing the documents with data.
        # @yieldparam [Document::Snapshot] document A document with data.
        #
        # @return [Enumerator<Document::Snapshot>] documents with data list.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get and print all city documents
        #   firestore.docs("cities").each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def docs collection_path, &block
          col(collection_path).docs(&block)
        end
        alias_method :documents, :docs

        ##
        # Retrieves a document.
        #
        # @param [String] document_path A string representing the path of the
        #   document, relative to the document root of the database.
        #
        # @return [Document::Reference] A document.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Print the document ID
        #   puts nyc_ref.document_id
        #
        def doc document_path
          if document_path.to_s.split("/").count.odd?
            fail ArgumentError, "document_path must refer to a document."
          end

          doc_path = "#{path}/documents/#{document_path}"

          Document.from_path doc_path, self
        end
        alias_method :document, :doc

        ##
        # Retrieves a list of documents with data.
        #
        # @param [String, Document::Reference] docs One or more strings
        #   representing the path of the document, or document reference
        #   objects.
        # @param [Array<String|Symbol>, String|Symbol] mask A list of field
        #   paths to filter the returned document data by.
        #
        # @yield [documents] The block for accessing the documents with data.
        # @yieldparam [Document::Snapshot] document A document with data.
        #
        # @return [Enumerator<Document::Snapshot>] documents with data list.
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
        def get_all *docs, mask: nil
          ensure_service!

          return enum_for(:get_all, docs, mask: mask) unless block_given?

          doc_paths = Array(docs).flatten.map do |doc_path|
            coalesce_doc_path_argument doc_path
          end

          results = service.get_documents doc_paths, mask: mask
          results.each do |result|
            next if result.result.nil?
            yield Document.from_batch_result(result, self)
          end
        end
        alias_method :get_docs, :get_all
        alias_method :get_documents, :get_all
        alias_method :find, :get_all

        ##
        # Perform multiple changes at the same time.
        #
        # All changes are accumulated in memory until the block completes.
        # Unlike `transaction`, batches are not automatically retried. See
        # {Batch}.
        #
        # Batched writes have fewer failure cases than transactions and use
        # simpler code. They are not affected by contention issues, because they
        # don't depend on consistently reading any documents.
        #
        # @see https://firebase.google.com/docs/firestore/manage-data/transactions
        #   Transactions and Batched Writes
        #
        # @yield [batch] The block for reading data and making changes.
        # @yieldparam [Batch] batch The write batch object for making changes.
        #
        # @return [Time] The time the changes were committed
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.batch do |b|
        #     # Set the data for NYC
        #     b.col("cities").doc("NYC").set({ name: "New York City" })
        #
        #     # Update the population for SF
        #     b.col("cities").doc("SF").update({ population: 1000000 })
        #
        #     # Delete LA
        #     b.col("cities").doc("LA").delete
        #   end
        #
        def batch
          batch = Batch.from_database self
          yield batch
          batch.commit
        end

        ##
        # Create a document with the provided object values.
        #
        # The operation will fail if the document already exists.
        #
        # @param [String, Document::Reference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash] data The document's fields and values.
        #
        # @return [Time] The time the changes were committed
        #
        # @example Create a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a document
        #   firestore.create("cities/NYC", { name: "New York City" })
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Create a document
        #   firestore.create(nyc_ref, { name: "New York City" })
        #
        def create doc, data
          batch { |b| b.create doc, data }
        end

        ##
        # Write to document with the provided object values. If the document
        # does not exist, it will be created. By default, the provided data
        # overwrites existing data, but the provided data can be merged into the
        # existing document using the `merge` argument.
        #
        # If you're not sure whether the document exists, pass the option to
        # merge the new data with any existing document to avoid overwriting
        # entire documents.
        #
        # @param [String, Document::Reference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash] data The document's fields and values.
        # @param [true, String|Symbol, Array<String|Symbol>] merge When provided
        #   and `true` all data is merged with the existing document data. When
        #   provided only the specified as a list of field paths are merged with
        #   the existing document data. The default is to overwrite the existing
        #   document data.
        #
        # @return [Time] The time the changes were committed
        #
        # @example Set a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Set a document
        #   firestore.set("cities/NYC", { name: "New York City" })
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set a document
        #   firestore.set(nyc_ref, { name: "New York City" })
        #
        # @example Set a document and merge all data:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Set a document
        #   firestore.set("cities/NYC", { name: "New York City" }, merge: true)
        #
        # @example Set a document and merge only name:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Set a document
        #   firestore.set("cities/NYC", { name: "New York City" },
        #                 merge: [:name])
        #
        def set doc, data, merge: nil
          batch { |b| b.set doc, data, merge: merge }
        end

        ##
        # Write to document with the provided object values. If the document
        # does not exist, it will be created. By default, the provided data
        # overwrites existing data, but the provided data can be merged into the
        # existing document using the `merge` argument.
        #
        # The batch will fail if the document does not exist.
        #
        # @param [String, Document::Reference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Hash] data The document's fields and values.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @return [Time] The time the changes were committed
        #
        # @example Update a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Update a document
        #   firestore.update("cities/NYC", { name: "New York City" })
        #
        # @example Update a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Update a document
        #   firestore.update(nyc_ref, { name: "New York City" })
        #
        # @example Update a document using `update_time`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   # Update a document
        #   firestore.update("cities/NYC", { name: "New York City" },
        #                    update_time: last_updated_at)
        #
        def update doc, data, update_time: nil
          batch { |b| b.update doc, data, update_time: update_time }
        end

        ##
        # Deletes a document from the database.
        #
        # @param [String, Document::Reference] doc A string representing the
        #   path of the document, or a document reference object.
        # @param [Boolean] exists Whether the document must exist. When `true,
        #   the document must exist or an error is raised. Default is `false`.
        #   Optional.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @return [Time] The time the changes were committed
        #
        # @example Delete a document using a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Delete a document
        #   firestore.delete "cities/NYC"
        #
        # @example Delete a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Delete a document
        #   firestore.delete nyc_ref
        #
        # @example Delete a document using `exists`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Delete a document
        #   firestore.delete "cities/NYC", exists: true
        #
        # @example Delete a document using `update_time`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   # Delete a document
        #   firestore.delete "cities/NYC", update_time: last_updated_at
        #
        def delete doc, exists: nil, update_time: nil
          batch { |b| b.delete doc, exists: exists, update_time: update_time }
        end

        ##
        # Create a transaction to perform multiple reads and changes that are
        # executed atomically at a single logical point in time in a database.
        #
        # All changes are accumulated in memory until the block completes.
        # Transactions will be automatically retried when possible. See
        # {Transaction}.
        #
        # @see https://firebase.google.com/docs/firestore/manage-data/transactions
        #   Transactions and Batched Writes
        #
        # @param [String] previous_transaction The transaction identifier of a
        #   transaction that is being retried. Read-write transactions may fail
        #   due to contention. A read-write transaction can be retried by
        #   specifying `previous_transaction` when creating the new transaction.
        #
        #   Specifying `previous_transaction` provides information that can be
        #   used to improve throughput. In particular, if transactional
        #   operations A and B conflict, specifying the `previous_transaction`
        #   can help to prevent livelock. (See {Transaction#transaction_id})
        #
        # @yield [transaction] The block for reading data and making changes.
        # @yieldparam [Transaction] transaction The transaction object for
        #   making changes.
        #
        # @return [Time] The time the changes were committed
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.transaction do |tx|
        #     # Set the data for NYC
        #     tx.col("cities").doc("NYC").set({ name: "New York City" })
        #
        #     # Update the population for SF
        #     tx.col("cities").doc("SF").update({ population: 1000000 })
        #
        #     # Delete LA
        #     tx.col("cities").doc("LA").delete
        #   end
        #
        def transaction previous_transaction: nil
          retries = 0
          backoff = 1.0
          deadline = 60
          start_time = Time.now

          transaction = Transaction.from_database \
            self, previous_transaction: previous_transaction
          begin
            yield transaction
            transaction.commit
          rescue Google::Cloud::UnavailableError => err
            # Re-raise if deadline has passed
            raise err if Time.now - start_time > deadline
            # Sleep with incremental backoff
            sleep(backoff *= 1.3)
            # Create new transaction and retry
            transaction = Transaction.from_database \
              self, previous_transaction: transaction.transaction_id
            retries += 1
            retry
          rescue Google::Cloud::InvalidArgumentError => err
            # Return if a previous call has succeeded
            return nil if retries > 0
            # Re-raise error.
            raise err
          rescue => err
            # Rollback transaction when handling unexpected error
            transaction.rollback! rescue nil
            # Re-raise error.
            raise err
          end
        end

        ##
        # Create a read-only transaction to perform multiple reads that are
        # executed at a single logical point in time in a database.
        #
        # Changes to data are not supported. See {ReadOnlyTransaction}.
        #
        # @param [Time] read_time The time to read the documents at. This may
        #   not be older than 60 seconds. Optional.
        #
        # @yield [read_transaction] The block for reading data.
        # @yieldparam [ReadOnlyTransaction] read_transaction The read-only
        #   transaction object for reading data.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.read_only_transaction do |rtx|
        #     # Create a query
        #     query = rtx.query.select(:population).from(:cities)
        #
        #     # Get/run a query
        #     rtx.get(query).each do |city|
        #       puts "#{city.document_id} has #{city[:population]} residents."
        #     end
        #   end
        #
        def read_only_transaction read_time: nil
          read_tx = ReadOnlyTransaction.from_database self, read_time: read_time
          yield read_tx
          read_tx.rollback
        end
        alias_method :read_transaction, :read_only_transaction
        alias_method :snapshot, :read_only_transaction

        ##
        # Creates a query object.
        #
        # @return [Query] A query.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.query.select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def query
          Query.start "#{path}/documents", self
        end
        alias_method :q, :query

        ##
        # Creates a query object with method `select` called on it. (See
        # {Query#select}.)
        #
        # @param [String, Symbol] fields A field mask to filter results with and
        #   return only the specified fields. One or more field paths can be
        #   specified.
        #
        # @return [Query] A query with `select` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def select *fields
          query.select fields
        end

        ##
        # Creates a query object with method `from` called on it. (See
        # {Query#from}.)
        #
        # @param [String] collection_path A string representing the path of the
        #   collection, relative to the document root of the database, to query
        #   results from.
        #
        # @return [Query] A query with `from` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.from(:cities).select(:population)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def from collection_path
          query.from collection_path
        end

        ##
        # Creates a query object with method `where` called on it. (See
        # {Query#where}.)
        #
        # @param [String, Symbol] field A field mask to filter results with and
        #   return only the specified fields. One or more field paths can be
        #   specified.
        # @param [String, Symbol] operator The operation to compare the field
        #   to. Acceptable values include:
        #
        #   * less than: `<`, `lt`
        #   * less than or equal: `<=`, `lte`
        #   * greater than: `>`, `gt`
        #   * greater than or equal: `>=`, `gte`
        #   * equal: `=`, `==`, `eq`, `eql`, `is`
        # @param [Object] value A value the field is compared to.
        #
        # @return [Query] A query with `where` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.where(:population, :>=, 1000000).
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def where field, operator, value
          query.where field, operator, value
        end

        ##
        # Creates a query object with method `order` called on it. (See
        # {Query#order}.)
        #
        # @param [String, Symbol] field A field mask to order results with.
        # @param [String, Symbol] direction The direction to order the results
        #   by. Optional. Default is ascending.
        #
        # @return [Query] A query with `order` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.order(:name).
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def order field, direction = :asc
          query.order field, direction
        end

        ##
        # Creates a query object with method `offset` called on it. (See
        # {Query#offset}.)
        #
        # @param [Integer] num The number of results to skip.
        #
        # @return [Query] A query with `offset` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.limit(5).offset(10).
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def offset num
          query.offset num
        end

        ##
        # Creates a query object with method `limit` called on it. (See
        # {Query#limit}.)
        #
        # @param [Integer] num The maximum number of results to return.
        #
        # @return [Query] A query with `limit` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.offset(10).limit(5).
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def limit num
          query.limit num
        end

        ##
        # Creates a query object with method `start_at` called on it. (See
        # {Query#start_at}.)
        #
        # @param [Object] values The field value to start the query at.
        #
        # @return [Query] A query with `start_at` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.start_at("NYC").
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_at *values
          query.start_at values
        end

        ##
        # Creates a query object with method `start_after` called on it. (See
        # {Query#start_after}.)
        #
        # @param [Object] values The field value to start the query after.
        #
        # @return [Query] A query with `start_after` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.start_after("NYC").
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_after *values
          query.start_after values
        end

        ##
        # Creates a query object with method `end_before` called on it. (See
        # {Query#end_before}.)
        #
        # @param [Object] values The field value to end the query before.
        #
        # @return [Query] A query with `end_before` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.end_before("NYC").
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_before *values
          query.end_before values
        end

        ##
        # Creates a query object with method `end_at` called on it. (See
        # {Query#end_at}.)
        #
        # @param [Object] values The field value to end the query at.
        #
        # @return [Query] A query with `end_at` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.end_at("NYC").
        #                     select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_at *values
          query.end_at values
        end

        ##
        # Retrieves documents with data for the given value. Valid values can be
        # a string representing either a document or a collection of documents,
        # a document refernce object, a collection reference object, or a query
        # to be run.
        #
        # @param [String, Document::Reference, Collection::Reference, query] obj
        #   A string representing the path of a document or collection, a
        #   document reference object, a collection reference object, or a query
        #   to run.
        #
        # @yield [documents] The block for accessing the documents with data.
        # @yieldparam [Document::Reference] document A document with data.
        #
        # @return [Document::Reference, Enumerator<Document::Reference>] A
        #   single document with data when passed a document path a document
        #   refernce, or a list of documents with data when passed other valid
        #   values.
        #
        # @example Get a document with data given a document path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document with data
        #   nyc_snap = firestore.get "cities/NYC"
        #
        # @example Get a document with data given a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Get a document with data
        #   nyc_snap = firestore.get nyc_ref
        #
        # @example Get documents with data given a collection path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get documents for a collection path
        #   firestore.get("cities").each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Get documents with data given a collection reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col :cities
        #
        #   # Get documents for a collection
        #   firestore.get(cities_col).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Get documents with data given a query:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.select(:population).from(:cities)
        #
        #   # Get/run a query
        #   firestore.get(query).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def get obj
          ensure_service!

          obj = coalesce_get_argument obj

          if obj.is_a?(Document::Reference)
            doc = get_all([obj]).first
            yield doc if block_given?
            return doc
          end

          return enum_for(:get, obj) unless block_given?

          results = service.run_query obj.parent_path, obj.grpc
          results.each do |result|
            next if result.document.nil?
            yield Document.from_query_result(result, self)
          end
        end
        alias_method :run, :get

        protected

        ##
        # @private
        def coalesce_get_argument obj
          if obj.is_a?(String) || obj.is_a?(Symbol)
            if obj.to_s.split("/").count.even?
              return doc obj # Convert a Document::Reference
            else
              return col(obj).query # Convert to Query
            end
          end

          return obj.ref if obj.is_a?(Document::Snapshot)

          return obj.query if obj.is_a? Collection::Reference

          obj
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
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
