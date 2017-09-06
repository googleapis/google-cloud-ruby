# Copyright 2016 Google Inc. All rights reserved.
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


require "stackdriver/core/async_actor"


module Google
  module Cloud
    module ErrorReporting
      ##
      # # AsyncErrorReporter
      #
      # @private Used by {Google::Cloud::ErrorReporting} and
      # {Google::Cloud::ErrorReporting::Middleware} to asynchronously submit
      # error events to Stackdriver Error Reporting service when used in
      # Ruby applications.
      class AsyncErrorReporter
        include Stackdriver::Core::AsyncActor

        ##
        # @private Default maximum backlog size for the job queue
        DEFAULT_MAX_QUEUE_SIZE = 1000

        ##
        # The {Google::Cloud::ErrorReporting::Project} object to submit events
        # with.
        attr_accessor :error_reporting

        ##
        # The max number of items the queue holds
        attr_accessor :max_queue_size

        ##
        # @private Construct a new instance of AsyncErrorReporter
        def initialize error_reporting, max_queue_size = DEFAULT_MAX_QUEUE_SIZE
          super()
          @error_reporting = error_reporting
          @max_queue_size = max_queue_size
          @queue = []
          @queue_resource = new_cond
        end

        ##
        # Add the error event to the queue. Signal the child thread an item
        # has been added.
        def report error_event
          async_start

          synchronize do
            @queue.push error_event
            @queue_resource.broadcast

            retries = 0
            while @max_queue_size && @queue.size > @max_queue_size
              retries += 1
              @queue_resource.wait 1

              # Drop early queue entries when have waited long enough.
              @queue.pop while @queue.size > @max_queue_size && retries > 3
            end
          end
        end

        ##
        # @private Callback fucntion for AsyncActor module to run the async
        # job in a loop
        def run_backgrounder
          error_event = wait_next_item
          return if error_event.nil?
          begin
            error_reporting.report error_event
          rescue => e
            warn error_event.message if error_event.message
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

        private

        ##
        # @private The the next item from the reporter queue. If there are
        # no more item, it blocks the reporter thread until an item is
        # enqueued
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
        # module. The actor can be gracefully stopped when queue is
        # empty.
        def backgrounder_stoppable?
          synchronize do
            @queue.empty?
          end
        end
      end
    end
  end
end
