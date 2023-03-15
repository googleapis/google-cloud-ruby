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
require "concurrent/atomics"

module Google
  module Cloud
    module Firestore
      class BulkWriter

        MAX_BATCH_SIZE = 20

        ##
        # Initialize the object attributes and start the schedule_operations job
        def initialize service
          @service = service
          @thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: 4
          @mutex = Mutex.new
          @closed = false
          @flush = false
          @buffered_operations = []
          @retry_operations = MinHeap.new
          @pending_batch_count = 0
          @rate_limiter = RateLimiter.new
          @doc_refs = Set
          Google::Cloud::Firestore::Concurrent::Promises.future_on @thread_pool do
            schedule_operations
          end
        end

        def accepting_request
          unless @closed || @flush
            return true
          end
          false
        end

        def pre_add_operation doc_ref
          unless accepting_request
            raise StandardError "BulkWriter not accepting responses for now. Either closed or in flush state"
          end
          if @doc_refs.include? doc_ref
            raise StandardError "BulkWriter already contains mutations for the document"
          end
          @doc_refs.add doc_ref
        end


        ##
        # Add a new operation/request in the BulkwWriter operations queue.
        # x can be a create, delete, set or update based on the operation type.
        #
        # @params will depend on the operation type.
        # Will be same as the current implementation in transaction.rb
        #
        # @return [Google::Cloud::Firestore::Concurrent::Promises::Future] future
        def add_x_operation doc_ref, data
          pre_add_operation doc_ref
          write = Convert.write_for_x(doc_ref, data)
          operation = BulkWriterOperation.new write, doc_ref, operation_type
          enqueue_operation operation
        end

        ##
        # Flushes all the current operation before enqueuing new operations.
        #
        # @return [nil]
        def flush
          @flush = true
          loop do
            if (@retry_operations.length + @buffered_operations.length + @pending_batch_count).zero?
              break
            end
            sleep 100
          end
          @flush = false
        end

        ##
        # Closes the BulkWriter object for new operations.
        # Existing operations will be flushed and the threadpool will shutdown.
        #
        # @return [nil]
        def close
          @closed = true
          flush
          @thread_pool.shutdown
        end

        def pre_commit_batch
          @mutex.lock
          @pending_batch_count += 1
          @mutex.unlock
        end

        def post_commit_batch failed_operations
          @mutex.lock
          failed_operations.each do |operation|
            @retry_operations.push operation.retry_time, operation
          end
          @pending_batch_count -= 1
          @mutex.unlock
        end

        ##
        # @private Commits a batch of scheduled operations.
        # Batch size = 20 to match the constraint - request size < 9.8 MB
        #
        # @return [nil]
        def commit_batch operations
          Google::Cloud::Firestore::Concurrent::Promises.future_on @thread_pool do
            pre_commit_batch
            bulk_commit_batch = BulkCommitBatch.new operations, @service
            failed_operations = bulk_commit_batch.commit
            post_commit_batch failed_operations
          end
        end

        ##
        # @private Schedule the enqueued operations in batches.
        #
        # @return [nil]
        def schedule_operations
          loop do
            batch_size = min MAX_BATCH_SIZE, @retry_operations.length + @buffered_operations.length
            if batch_size.zero?
              sleep 100
              next
            end
            @rate_limiter.get_tokens batch_size
            operations = dequeue_operations batch_size
            commit_batch operations
          end
        end

        def enqueue_operation operation
          @mutex.lock
          @buffered_operations << operation
          @mutex.unlock
          Google::Cloud::Firestore::Concurrent::Promises.future_on @thread_pool do
            operation.completion_event.wait
            # based on the status of operation either raise an error or return the result
          end
        end

        def dequeue_operations batch_size
          @mutex.lock
          # Dequeue `batch_size` operations from the retry_operations (first) and
          # buffered_operations
          @mutex.unlock
        end
      end
    end
  end
end