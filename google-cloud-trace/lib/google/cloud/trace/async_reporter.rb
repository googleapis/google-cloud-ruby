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


require "stackdriver/core/async_actor"

module Google
  module Cloud
    module Trace
      ##
      # # AsyncReporter
      #
      # @private Used by the {Google::Cloud::Trace::Middleware} to
      # asynchronously update traces to Stackdriver Trace service when used in
      # a Rack-based application.
      class AsyncReporter
        include Stackdriver::Core::AsyncActor

        ##
        # @private Default Maximum blacklog size for the job queue
        DEFAULT_MAX_QUEUE_SIZE = 1000

        ##
        # The {Google::Cloud::Trace::Service} object to patch traces
        attr_accessor :service

        ##
        # The max number of items the queue holds
        attr_accessor :max_queue_size

        ##
        # @private Construct a new instance of AsyncReporter
        def initialize service, max_queue_size = DEFAULT_MAX_QUEUE_SIZE
          super()

          @service = service
          @max_queue_size = max_queue_size
          @queue = []
          @queue_resource = new_cond
        end

        ##
        # Add the traces to the queue to be reported to Stackdriver Trace
        # asynchronously. Signal the child thread to start processing the queue.
        def patch_traces traces
          ensure_thread

          synchronize do
            @queue.push traces
            @queue_resource.broadcast

            while @max_queue_size && @queue.size > max_queue_size
              @queue_resource.wait 1

              @queue.pop while @queue.size > max_queue_size
            end
          end
        end

        ##
        # @private Callback function for AsyncActor module to process the queue
        # in a loop
        def run_backgrounder
          traces = wait_next_item
          return if traces.nil?

          begin
            service.patch_traces traces
          rescue => e
            warn ["#{e.class}: #{e.message}", e.backtrace].join("\n\t")
            @last_exception = e
          end
        end

        ##
        # @private Callback function when the async actor thread state changes
        def on_async_state_change
          synchronize do
            @queue_resource.broadcast
          end
        end

        ##
        # Get the project id from underlying service object.
        def project
          service.project
        end

        private

        ##
        # @private Wait for the next item from the reporter queue. If there are
        # no more items, it blocks the child thread until an item is enqueued.
        def wait_next_item
          synchronize do
            @queue_resource.wait_while do
              async_suspended? || (async_running? && @queue.empty?)
            end
            @queue.pop
          end
        end

        ##
        # @private Override the #backgrounder_stoppable? method from AsyncActor
        # module. The actor can be gracefully stopped when queue is empty.
        def backgrounder_stoppable?
          synchronize do
            @queue.empty?
          end
        end
      end
    end
  end
end
