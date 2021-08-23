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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/service"
require "google/cloud/firestore/field_path"
require "google/cloud/firestore/field_value"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/collection_group"
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
        # Retrieves an enumerator for the root collections.
        #
        # @yield [collections] The block for accessing the collections.
        # @yieldparam [CollectionReference] collection A collection reference object.
        #
        # @return [Enumerator<CollectionReference>] An enumerator of collection references. If a block is provided,
        #  this is the same enumerator that is accessed through the block.
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
        def cols &block
          ensure_service!
          grpc = service.list_collections "#{path}/documents"
          cols_enum = CollectionReferenceList.from_grpc(grpc, self, "#{path}/documents").all
          cols_enum.each(&block) if block_given?
          cols_enum
        end
        alias collections cols
        alias list_collections cols

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

          CollectionReference.from_path "#{path}/documents/#{collection_path}", self
        end
        alias collection col

        ##
        # Creates and returns a new collection group that includes all documents in the
        # database that are contained in a collection or subcollection with the
        # given collection_id.
        #
        # @param [String] collection_id Identifies the collections to query
        #   over. Every collection or subcollection with this ID as the last
        #   segment of its path will be included. Cannot contain a slash (`/`).
        #
        # @return [CollectionGroup] The created collection group.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get the cities collection group query
        #   col_group = firestore.col_group "cities"
        #
        #   col_group.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def col_group collection_id
          if collection_id.include? "/"
            raise ArgumentError, "Invalid collection_id: '#{collection_id}', " \
              "must not contain '/'."
          end

          CollectionGroup.from_collection_id service.documents_path, collection_id, self
        end
        alias collection_group col_group

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
        # @param [String, DocumentReference, Array<String|DocumentReference>]
        #   docs One or more strings representing the path of the document, or
        #   document reference objects.
        # @param [Array<String|FieldPath>] field_mask One or more field path
        #   values, representing the fields of the document to be returned. If a
        #   document has a field that is not present in this mask, that field
        #   will not be returned in the response. All fields are returned when
        #   the mask is not set.
        #
        #   A field path can either be a {FieldPath} object, or a dotted string
        #   representing the nested fields. In other words the string represents
        #   individual fields joined by ".". Fields containing `~`, `*`, `/`,
        #   `[`, `]`, and `.` cannot be in a dotted string, and should provided
        #   using a {FieldPath} object instead. (See {#field_path}.)
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
        # @example Get docs using a field mask:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get and print city documents
        #   cities = ["cities/NYC", "cities/SF", "cities/LA"]
        #   firestore.get_all(cities, field_mask: [:population]).each do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def get_all *docs, field_mask: nil
          ensure_service!

          unless block_given?
            return enum_for :get_all, *docs, field_mask: field_mask
          end

          doc_paths = Array(docs).flatten.map do |doc_path|
            coalesce_doc_path_argument doc_path
          end
          mask = Array(field_mask).map do |field_path|
            if field_path.is_a? FieldPath
              field_path.formatted_string
            else
              FieldPath.parse(field_path).formatted_string
            end
          end
          mask = nil if mask.empty?

          results = service.get_documents doc_paths, mask: mask
          results.each do |result|
            next if result.result.nil?
            yield DocumentSnapshot.from_batch_result result, self
          end
        end
        alias get_docs get_all
        alias get_documents get_all
        alias find get_all

        ##
        # Creates a field path object representing the sentinel ID of a
        # document. It can be used in queries to sort or filter by the document
        # ID. See {FieldPath#document_id}.
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
        #   query = cities_col.order(firestore.document_id)
        #                     .start_at("NYC")
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
        # @param [String, Symbol, Array<String|Symbol>] fields One or more
        #   strings representing the path of the data to select. Each field must
        #   be provided separately.
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

        ##
        # Creates a sentinel value to indicate the union of the given values
        # with an array.
        #
        # @param [Object] values The values to add to the array. Required.
        #
        # @return [FieldValue] The array union field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   array_union = firestore.field_array_union 1, 2, 3
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_union })
        #
        def field_array_union *values
          FieldValue.array_union(*values)
        end

        ##
        # Creates a sentinel value to indicate the removal of the given values
        # with an array.
        #
        # @param [Object] values The values to remove from the array. Required.
        #
        # @return [FieldValue] The array delete field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   array_delete = firestore.field_array_delete 7, 8, 9
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_delete })
        #
        def field_array_delete *values
          FieldValue.array_delete(*values)
        end

        ##
        # Creates a sentinel value to indicate the addition the given value to
        # the field's current value.
        #
        # If the field's current value is not an integer or a double value
        # (Numeric), or if the field does not yet exist, the transformation will
        # set the field to the given value. If either of the given value or the
        # current field value are doubles, both values will be interpreted as
        # doubles. Double arithmetic and representation of double values follow
        # IEEE 754 semantics. If there is positive/negative integer overflow,
        # the field is resolved to the largest magnitude positive/negative
        # integer.
        #
        # @param [Numeric] value The value to add to the given value. Required.
        #
        # @return [FieldValue] The increment field value object.
        #
        # @raise [ArgumentError] if the value is not a Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to increment by 1.
        #   increment_value = firestore.field_increment 1
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: increment_value })
        #
        def field_increment value
          FieldValue.increment value
        end

        ##
        # Creates a sentinel value to indicate the setting the field to the
        # maximum of its current value and the given value.
        #
        # If the field is not an integer or double (Numeric), or if the field
        # does not yet exist, the transformation will set the field to the given
        # value. If a maximum operation is applied where the field and the input
        # value are of mixed types (that is - one is an integer and one is a
        # double) the field takes on the type of the larger operand. If the
        # operands are equivalent (e.g. 3 and 3.0), the field does not change.
        # 0, 0.0, and -0.0 are all zero. The maximum of a zero stored value and
        # zero input value is always the stored value. The maximum of any
        # numeric value x and NaN is NaN.
        #
        # @param [Numeric] value The value to compare against the given value to
        #   calculate the maximum value to set. Required.
        #
        # @return [FieldValue] The maximum field value object.
        #
        # @raise [ArgumentError] if the value is not a Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to be at maximum 4,000,000.
        #   maximum_value = firestore.field_maximum 4000000
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: maximum_value })
        #
        def field_maximum value
          FieldValue.maximum value
        end

        ##
        # Creates a sentinel value to indicate the setting the field to the
        # minimum of its current value and the given value.
        #
        # If the field is not an integer or double (Numeric), or if the field
        # does not yet exist, the transformation will set the field to the input
        # value. If a minimum operation is applied where the field and the input
        # value are of mixed types (that is - one is an integer and one is a
        # double) the field takes on the type of the smaller operand. If the
        # operands are equivalent (e.g. 3 and 3.0), the field does not change.
        # 0, 0.0, and -0.0 are all zero. The minimum of a zero stored value and
        # zero input value is always the stored value. The minimum of any
        # numeric value x and NaN is NaN.
        #
        # @param [Numeric] value The value to compare against the given value to
        #   calculate the minimum value to set. Required.
        #
        # @return [FieldValue] The minimum field value object.
        #
        # @raise [ArgumentError] if the value is not a Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to be at minimum 1,000,000.
        #   minimum_value = firestore.field_minimum 1000000
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: minimum_value })
        #
        def field_minimum value
          FieldValue.minimum value
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
        # @param [Boolean] commit_response When `true`, the return value from
        #   this method will be a `Google::Cloud::Firestore::CommitResponse`
        #   object with a `commit_time` attribute. Otherwise, the return
        #   value from this method will be the return value of the provided
        #   yield block. Default is `false`. Optional.
        #
        # @yield [transaction] The block for reading data and making changes.
        # @yieldparam [Transaction] transaction The transaction object for
        #   making changes.
        #
        # @return [Object, CommitResponse] The return value of the provided
        #   yield block, or if `commit_response` is provided and true, the
        #   `CommitResponse` object from the commit operation.
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
        def transaction max_retries: nil, commit_response: nil
          max_retries = 5 unless max_retries.is_a? Integer
          backoff = { current: 0, delay: 1.0, max: max_retries, mod: 1.3 }

          transaction = Transaction.from_client self
          begin
            transaction_return = yield transaction
            commit_return = transaction.commit
            # Conditional return value, depending on truthy commit_response
            commit_response ? commit_return : transaction_return
          rescue Google::Cloud::AbortedError,
                 Google::Cloud::CanceledError,
                 Google::Cloud::UnknownError,
                 Google::Cloud::DeadlineExceededError,
                 Google::Cloud::InternalError,
                 Google::Cloud::UnauthenticatedError,
                 Google::Cloud::ResourceExhaustedError,
                 Google::Cloud::UnavailableError,
                 Google::Cloud::InvalidArgumentError => e

            if e.instance_of? Google::Cloud::InvalidArgumentError
              # Return if a previous call was retried but ultimately succeeded
              return nil if backoff[:current].positive?
              # The Firestore backend uses "INVALID_ARGUMENT" for transaction IDs that have expired.
              # While INVALID_ARGUMENT is generally not retryable, we retry this specific case.
              raise e unless e.message =~ /transaction has expired/
            end

            # Re-raise if retried more than the max
            raise e if backoff[:current] > backoff[:max]

            # Sleep with incremental backoff before restarting
            sleep backoff[:delay]

            # Update increment backoff delay and retry counter
            backoff[:delay] *= backoff[:mod]
            backoff[:current] += 1

            # Create new transaction and retry
            transaction = Transaction.from_client \
              self, previous_transaction: transaction.transaction_id
            retry
          rescue StandardError => e
            # Rollback transaction when handling unexpected error
            transaction.rollback rescue nil

            # Re-raise error.
            raise e
          end
        end

        # @!endgroup

        # @private
        def list_documents parent, collection_id, token: nil, max: nil
          ensure_service!
          grpc = service.list_documents parent, collection_id, token: token, max: max
          DocumentReference::List.from_grpc grpc, self, parent, collection_id
        end

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
