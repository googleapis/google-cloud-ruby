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
require "google/cloud/firestore/concurrent/promises"
require "concurrent/atomics"
require "concurrent"
require "algorithms"
require "google/cloud/firestore/bulk_writer_operation"
require "google/cloud/firestore/rate_limiter"
require "google/cloud/firestore/bulk_commit_batch"
require "google/cloud/firestore/bulk_writer_exception"



module Google
  module Cloud
    module Firestore
      class BulkWriter

        MAX_BATCH_SIZE = 20

        ##
        # Initialize the attributes and start the schedule_operations job
        #
        def initialize client, service, request_threads: nil, batch_threads: nil
          @client = client
          @service = service
          @closed = false
          @flush = false
          @rate_limiter = RateLimiter.new
          @buffered_operations = []
          @request_threads = (request_threads || 2).to_i
          @batch_threads = (batch_threads || 4).to_i
          @write_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @request_threads,
                                                                  max_queue: 0
          @batch_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @batch_threads,
                                                                  max_queue: @batch_threads * (@rate_limiter.bandwidth/MAX_BATCH_SIZE)
          @schedule_thread_pool = Concurrent::ThreadPoolExecutor.new max_thread: 1, min_thread: 1
          @mutex = Mutex.new
          @retry_operations = Containers::MinHeap.new
          @pending_batch_count = 0
          @doc_refs = Set.new
          Concurrent::Promises.future_on @schedule_thread_pool do
            begin
              schedule_operations
            rescue StandardError => e
              raise e
            end
          end
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
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_create doc_path, data

          # @service.batch_write [write]

          create_and_enqueue_operation write, doc_path
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
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_set doc_path, data, merge: merge

          create_and_enqueue_operation write, doc_path
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
        #   nested_field_path = firestore.field_path :favorites, :food
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
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_update doc_path, data, update_time: update_time

          create_and_enqueue_operation write, doc_path
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
          doc_path = coalesce_doc_path_argument doc
          pre_add_operation doc_path

          write = Convert.write_for_delete doc_path, exists: exists, update_time: update_time

          create_and_enqueue_operation write, doc_path
        end

        ##
        # Flushes all the current operation before enqueuing new operations.
        #
        # @return [nil]
        def flush
          @mutex.synchronize { @flush = true }
          loop do
            break if operations_completed?
            sleep 0.1
          end
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
            @batch_thread_pool.shutdown
          end
        end

        private

        ##
        # @private Checks if all the operations are completed.
        #
        def operations_completed?
          @mutex.synchronize {
 (@retry_operations.length + @buffered_operations.length + @batch_thread_pool.scheduled_task_count - @batch_thread_pool.completed_task_count).zero? }
        end

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
          unless @closed || @flush
            return true
          end
          false
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
        # @private Adds failed operations in the retry heap.
        #
        def post_commit_batch bulk_commit_batch
          @mutex.synchronize do
            bulk_commit_batch.operations.each do |operation|
              unless operation.completion_event.set?
                @retry_operations.push operation.retry_time, operation
              end
            end
          end
        end

        ##
        # @private Commits a batch of scheduled operations.
        # Batch size = 20 to match the constraint of request size < 9.8 MB
        #
        # @return [nil]
        def commit_batch bulk_commit_batch
          Concurrent::Promises.future_on @batch_thread_pool, bulk_commit_batch do |batch|
            begin
              batch.commit
            rescue StandardError => e
              puts "BulkCommitBatchError : #{e}"
            ensure
              post_commit_batch bulk_commit_batch
            end
          end
        end

        ##
        # @private Schedule the enqueued operations in batches.
        #
        # @return [nil]
        def schedule_operations
          loop do
            batch_size = [MAX_BATCH_SIZE, (@retry_operations.length + @buffered_operations.length)].min
            if batch_size.zero? || @batch_thread_pool.remaining_capacity.zero?
              # puts "Batch tasks added - #{@batch_thread_pool.scheduled_task_count} processed - #{@batch_thread_pool.completed_task_count} left - #{@batch_thread_pool.queue_length} "
              # puts "Write tasks added - #{@write_thread_pool.scheduled_task_count} processed - #{@write_thread_pool.completed_task_count} left - #{@write_thread_pool.queue_length} "
              # puts "Thread count - #{Thread.list.count}"
              sleep 1
              next
            end
            @rate_limiter.get_tokens batch_size
            bulk_commit_batch = nil
            @mutex.synchronize do
              operations = dequeue_operations batch_size
              bulk_commit_batch = BulkCommitBatch.new @service, operations
            end
            commit_batch bulk_commit_batch
          end
        end

        ##
        # @private Creates a BulkWriterOperation
        #
        def create_operation write, doc_path
          BulkWriterOperation.new write, doc_path
        end

        ##
        # @private Adds a BulkWriterOperation in the buffered queue to be scheduled in the
        # future batches
        def enqueue_operation operation
          @mutex.synchronize { @buffered_operations << operation }
          future = Concurrent::Promises.future_on @write_thread_pool do
            operation.completion_event.wait
            raise Concurrent::Promises.rejected_future(operation.result) if operation.result.is_a?(BulkWriterException)
            operation.result
          end
          Promise::Future.new future
        end

        ##
        # @private Creates a BulkWriterOperation and adds it to the
        # buffered queue.
        #
        def create_and_enqueue_operation write, doc_path
          enqueue_operation create_operation(write, doc_path)
        end

        ##
        # @private Removes BulkWriterOperations from the buffered queue to scheduled in
        # the current batch
        #
        def dequeue_operations size
          operations = []
          while operations.length < size && @retry_operations.size.positive?
            break unless @retry_operations.min.retry_time <= Time.now
            operations << @retry_operations.min!
          end
          operations << @buffered_operations.shift while operations.length < size
          operations
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
