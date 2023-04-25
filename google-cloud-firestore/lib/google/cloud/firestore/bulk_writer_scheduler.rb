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


require "concurrent"
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
      #
      # @private Accumulate BulkWriterOperations from the BulkWriter, schedules them
      # in accordance with 555 rule and retry the failed operations from the BulkCommitBatch.
      #
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
          @retry_operations = []
          @mutex = Mutex.new
          start_scheduling_operations
        end

        def start_scheduling_operations
          Concurrent::Promises.future_on @batch_thread_pool do
            begin
              schedule_operations
            rescue StandardError
              # TODO: Log the error when logging is available
              retry
            end
          end
        end

        def add_operation operation
          @mutex.synchronize { @buffered_operations << operation }
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
                @retry_operations << operation
              end
            end
            @retry_operations.sort_by!(&:retry_time)
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
              rescue StandardError
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
            if batch_size.zero?
              sleep 0.001
              next
            end
            @rate_limiter.wait_for_tokens batch_size
            operations = dequeue_buffered_operations batch_size
            commit_batch BulkCommitBatch.new(@service, operations)
          end
        end

        ##
        # @private Removes BulkWriterOperations from the buffered queue to scheduled in
        # the current batch
        #
        def dequeue_buffered_operations size
          @mutex.synchronize do
            @buffered_operations.shift size
          end
        end

        ##
        # @private Removes BulkWriterOperations from the retry queue to scheduled in
        # the current batch
        #
        def dequeue_retry_operations
          @mutex.synchronize do
            while @retry_operations.length.positive? && @retry_operations.first.retry_time <= Time.now
              @buffered_operations << @retry_operations.shift
            end
          end
        end
      end
    end
  end
end
