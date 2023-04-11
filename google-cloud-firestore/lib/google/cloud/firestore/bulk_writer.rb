# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License")
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


require "algorithms"
require "concurrent"
require "google/cloud/firestore/rate_limiter"
require "google/cloud/firestore/bulk_commit_batch"
require "google/cloud/firestore/concurrent/promises"
require "google/cloud/firestore/bulk_writer_operation"
require "google/cloud/firestore/bulk_writer_exception"
require "google/cloud/firestore/bulk_writer_scheduler"


module Google
  module Cloud
    module Firestore
      class BulkWriter
        MAX_RETRY_ATTEMPTS = 15

        ##
        # Initialize the attributes and start the schedule_operations job
        #
        def initialize client, service,
                       request_threads: nil,
                       batch_threads: nil,
                       retries: MAX_RETRY_ATTEMPTS
          @client = client
          @service = service
          @closed = false
          @flush = false
          @request_threads = (request_threads || 2).to_i
          @write_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @request_threads,
                                                                  max_queue: 0
          @mutex = Mutex.new
          @scheduler = BulkWriterScheduler.new client, service, batch_threads
          @doc_refs = Set.new
          @retries = [retries || MAX_RETRY_ATTEMPTS, MAX_RETRY_ATTEMPTS].min
        end

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
        #   bw = firestore.bulk_writer
        #
        #   bw.create("cities/NYC", { name: "New York City" })
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   bw.create(nyc_ref, { name: "New York City" })
        #
        # @example Create a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   bw.create(nyc_ref, { name: "New York City",
        #                          updated_at: firestore.field_server_time })
        #
        def create doc, data
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_create doc_path, data

          create_and_enqueue_operation write
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
        #   bw = firestore.bulk_writer
        #
        #   # Update a document
        #   bw.set("cities/NYC", { name: "New York City" })
        #
        # @example Create a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Update a document
        #   bw.set(nyc_ref, { name: "New York City" })
        #
        # @example Set a document and merge all data:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   bw.set("cities/NYC", { name: "New York City" }, merge: true)
        #
        # @example Set a document and merge only name:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #     bw.set("cities/NYC", { name: "New York City" }, merge: :name)
        #
        # @example Set a document and deleting a field using merge:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                trash: firestore.field_delete }
        #
        #   bw.set(nyc_ref, nyc_data, merge: true)
        #
        # @example Set a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                updated_at: firestore.field_server_time }
        #
        #   bw.set(nyc_ref, nyc_data, merge: true)
        #
        def set doc, data, merge: nil
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_set doc_path, data, merge: merge

          create_and_enqueue_operation write
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
        #   bw = firestore.bulk_writer
        #
        #   bw.update("cities/NYC", { name: "New York City" })
        #
        # @example Directly update a deeply-nested field with a `FieldPath`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   nested_field_path = firestore.field_path :favorites, :food
        #
        #   bw.update("users/frank", { nested_field_path => "Pasta" })
        #
        # @example Update a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   bw.update(nyc_ref, { name: "New York City" })
        #
        # @example Update a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   bw.update("cities/NYC", { name: "New York City" },
        #              update_time: last_updated_at)
        #
        # @example Update a document and deleting a field:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                trash: firestore.field_delete }
        #
        #   bw.update(nyc_ref, nyc_data)
        #
        # @example Update a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_data = { name: "New York City",
        #                updated_at: firestore.field_server_time }
        #
        #   bw.update(nyc_ref, nyc_data)
        #
        def update doc, data, update_time: nil
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_update doc_path, data, update_time: update_time

          create_and_enqueue_operation write
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
        #   bw = firestore.bulk_writer
        #
        #   # Delete a document
        #   bw.delete "cities/NYC"
        #
        # @example Delete a document using a document reference:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Delete a document
        #   bw.delete nyc_ref
        #
        # @example Delete a document using `exists`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Delete a document
        #   bw.delete "cities/NYC", exists: true
        #
        # @example Delete a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   # Delete a document
        #   bw.delete "cities/NYC", update_time: last_updated_at
        #
        def delete doc, exists: nil, update_time: nil
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_delete doc_path, exists: exists, update_time: update_time

          create_and_enqueue_operation write
        end

        ##
        # Flushes all the current operation before enqueuing new operations.
        #
        # @return [nil]
        def flush
          @mutex.synchronize { @flush = true }
          sleep 0.1 while @scheduler.operations_remaining?
          @mutex.synchronize do
            @doc_refs = Set.new
            @flush = false
          end
        end

        ##
        # Closes the BulkWriter object for new operations.
        # Existing operations will be flushed and the threadpool will shutdown.
        #
        # @return [nil]
        def close
          @mutex.synchronize { @closed = true }
          flush
          @mutex.synchronize do
            @write_thread_pool.shutdown
            @scheduler.close
          end
        end

        private

        ##
        # @private The client the Cloud Firestore BulkWriter belongs to.
        #
        # @return [Client] firestore client.
        def firestore
          @client
        end
        alias client firestore

        ##
        # @private Checks if the BulkWriter is accepting write requests
        def accepting_request
          @mutex.synchronize do
            unless @closed || @flush
              return true
            end
            false
          end
        end

        ##
        # @private Sanity checks before adding a write request in the BulkWriter
        def pre_add_operation doc_path
          unless accepting_request
            raise StandardError, "BulkWriter not accepting responses for now. Either closed or in flush state"
          end
          if @doc_refs.include? doc_path
            raise StandardError, "BulkWriter already contains mutations for this document"
          end
          @doc_refs.add doc_path
        end

        ##
        # @private Creates a BulkWriterOperation
        #
        def create_operation write
          BulkWriterOperation.new write, @retries
        end

        ##
        # @private Adds a BulkWriterOperation to the scheduler.
        def enqueue_operation operation
          @mutex.synchronize { @scheduler.add_operation operation }
        end

        ##
        # @private Creates a BulkWriterOperation and adds it in the scheduler.
        #
        def create_and_enqueue_operation write
          operation = create_operation write
          enqueue_operation operation
          future = Concurrent::Promises.future_on @write_thread_pool, operation do |bulk_writer_operation|
            bulk_writer_operation.completion_event.wait
            raise bulk_writer_operation.result if bulk_writer_operation.result.is_a? BulkWriterException
            bulk_writer_operation.result
          end
          Promise::Future.new future
        end

        ##
        # @private
        def coalesce_doc_path_argument doc_path
          return doc_path.path if doc_path.respond_to? :path

          client.doc(doc_path).path
        end
      end
    end
  end
end
