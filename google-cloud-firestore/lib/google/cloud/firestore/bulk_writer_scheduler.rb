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
require "google/cloud/firestore/errors"
require "google/cloud/firestore/bulk_writer_operation"
require "google/cloud/firestore/rate_limiter"
require "google/cloud/firestore/bulk_commit_batch"
require "google/cloud/firestore/bulk_writer_exception"
require "google/cloud/firestore/bulk_writer_scheduler"


module Google
  module Cloud
    module Firestore
      ##
      # @private
      class BulkWriterScheduler

        MAX_BATCH_SIZE = 20

        ##
        # Initialize the attributes and start the schedule_operations job
        #
        def initialize client, service, batch_threads
          @client = client
          @service = service
          @rate_limiter = RateLimiter.new
          @buffered_operations = []
          @batch_threads = (batch_threads || 4).to_i
          @batch_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @batch_threads, max_queue: 0
          @retry_operations = Containers::MinHeap.new
          @pending_batch_count = 0
          @doc_refs = Set.new
          @mutex = Mutex.new
          start_scheduling_operations
        end

        def start_scheduling_operations
          Concurrent::Promises.future_on @batch_thread_pool do
            begin
              schedule_operations
            rescue StandardError => e
              # TODO: Log the error when logging is available
              retry
            end
          end
        end

        def add_operation operation
          @mutex.synchronize { @buffered_operations << operation }
        end

        ##
        # @private Checks if all the operations are completed.
        #
        def operations_remaining?
          # pp @retry_operations.length
          # pp @buffered_operations.length
          # pp @pending_batch_count
          @mutex.synchronize { (@retry_operations.length + @buffered_operations.length + @pending_batch_count).positive? }
        end

        ##
        # Closes the scheduler object.
        # Won't wait for the existing complete before the completion.
        #
        # @return [nil]
        def close
          @mutex.synchronize { @batch_thread_pool.shutdown }
        end

        private

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
            @pending_batch_count -= 1
          end
        end

        ##
        # @private Commits a batch of scheduled operations.
        # Batch size <= 20 to match the constraint of request size < 9.8 MB
        #
        # @return [nil]
        def commit_batch bulk_commit_batch
          begin
            Concurrent::Promises.future_on @batch_thread_pool, bulk_commit_batch do |batch|
              begin
                batch.commit
              rescue StandardError => e
                # TODO: Log the errors while committing a batch
              ensure
                post_commit_batch bulk_commit_batch
              end
            end
          rescue StandardError => e
            post_commit_batch bulk_commit_batch
            raise BulkWriterSchedulerError, e.message
          end
        end

        ##
        # @private Schedule the enqueued operations in batches.
        #
        # @return [nil]
        def schedule_operations
          loop do
            dequeue_retry_operations
            batch_size = [MAX_BATCH_SIZE, @buffered_operations.length].min
            if batch_size.zero? || @batch_thread_pool.remaining_capacity.zero?
              sleep 0.1
              next
            end
            @rate_limiter.get_tokens batch_size
            @mutex.synchronize do
              operations = dequeue_buffered_operations batch_size
              @pending_batch_count += 1
              commit_batch BulkCommitBatch.new(@service, operations)
            end
          end
        end

        ##
        # @private Removes BulkWriterOperations from the buffered queue to scheduled in
        # the current batch
        #
        def dequeue_buffered_operations size
          @buffered_operations.shift size
        end

        ##
        # @private Removes BulkWriterOperations from the retry queue to scheduled in
        # the current batch
        #
        def dequeue_retry_operations
          @mutex.synchronize do
            while @retry_operations.size.positive? && @retry_operations.min.retry_time <= Time.now
              @buffered_operations << @retry_operations.min!
            end
          end
        end
      end
    end
  end
end
