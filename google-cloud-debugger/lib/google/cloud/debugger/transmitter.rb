# Copyright 2017 Google Inc. All rights reserved.
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
    module Debugger
      ##
      # # Transmitter
      #
      # Responsible for submit evaluated breakpoints back to Stackdriver
      # Debugger service asynchronously. It has it's own dedicated child thread,
      # so it doesn't interfere with main Ruby application threads or the
      # debugger agent's thread.
      #
      # The transmitter is controlled by the debugger agent it belongs to.
      # Debugger agent submits evaluated breakpoint into a thread safe queue,
      # and the transmitter operates directly on the queue along with minimal
      # interaction with the rest debugger agent components
      #
      class Transmitter
        include Stackdriver::Core::AsyncActor

        ##
        # @private Default maximum backlog size for the job queue
        DEFAULT_MAX_QUEUE_SIZE = 1000

        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # The debugger agent this transmiter belongs to
        # @return [Google::Cloud::Debugger::Agent]
        attr_accessor :agent

        ##
        # Maxium backlog size for this transmitter's queue
        attr_accessor :max_queue_size

        ##
        # @private Construct a new instance of Tramsnitter
        def initialize agent, service, max_queue_size = DEFAULT_MAX_QUEUE_SIZE
          super()
          @service = service
          @agent = agent
          @max_queue_size = max_queue_size
          @queue = []
          @queue_resource = new_cond
        end

        ##
        # Starts the transmitter and its worker thread
        def start
          async_start
        end

        ##
        # Stops the transmitter and its worker thread. Once stopped, cannot be
        # started again.
        def stop
          async_stop
        end

        ##
        # Enqueue an evaluated breakpoints to be submitted by the transmitter.
        #
        # @param [Google::Cloud::Debugger::Breakpoint] breakpoint The evaluated
        #   breakpoint to be submitted
        def submit breakpoint
          synchronize do
            @queue.push breakpoint
            @queue_resource.broadcast
            # Discard old entries if queue gets too large
            @queue.pop while @queue.size > @max_queue_size
          end
        end

        ##
        # @private Callback fucntion for AsyncActor module to run the async
        # job in a loop
        def run_backgrounder
          breakpoint = wait_next_item
          return if breakpoint.nil?
          begin
            service.update_active_breakpoint agent.debuggee.id, breakpoint
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

        private

        ##
        # @private The the next item from the transmitter queue. If there are
        # no more item, it blocks the transmitter thread until an item is
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
