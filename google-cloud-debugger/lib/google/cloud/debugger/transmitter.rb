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


require "google/cloud/debugger/async_actor"

module Google
  module Cloud
    module Debugger
      class Transmitter
        include AsyncActor

        DEFAULT_MAX_QUEUE_SIZE = 1000

        attr_accessor :service

        attr_accessor :agent

        attr_accessor :max_queue_size


        def initialize service, agent, max_queue_size = DEFAULT_MAX_QUEUE_SIZE
          super()
          @service = service
          @agent = agent
          @max_queue_size = max_queue_size
          @queue = Thread::Queue.new
        end

        def submit breakpoint
          synchronize do
            @queue.push breakpoint
            @lock_cond.broadcast
            # Discard old entries if queue gets too large
            @queue.pop while @queue.size > @max_queue_size
          end
        end

        def run_backgrounder
          breakpoint = wait_next_item
          return if breakpoint.nil?
          begin
            service.update_active_breakpoint agent.debuggee.id, breakpoint
          rescue => e
            @last_exception = e
          end
        end

        def wait_next_item
          synchronize do
            @lock_cond.wait_while do
              async_state == :suspended ||
                (async_state == :running && @queue.empty?)
            end
            queue_item = nil
            if @queue.empty?
              @async_state = :stopped
            else
              queue_item = @queue.pop
            end
            @lock_cond.broadcast
            queue_item
          end
        end
      end
    end
  end
end
