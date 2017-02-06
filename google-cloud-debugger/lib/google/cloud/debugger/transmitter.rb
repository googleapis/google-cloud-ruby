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
          @queue.push breakpoint
          # Discard old entries if queue gets too large
          @queue.pop while @queue.size > @max_queue_size
        end

        def run_backgrounder
          loop do
            breakpoint = wait_next_item
            puts breakpoint
            next if breakpoint.nil?
            begin
              agent.breakpoint_manager.mark_off breakpoint
              service.update_active_breakpoint breakpoint
            rescue => e
              @last_exception = e
            end
          end
        ensure
          @state = :stopped
        end

        def wait_next_item
          synchronize do
            sleep 0.1 while state == :suspended || (state == :running && @queue.empty?)
            queue_item = nil
            if @queue.empty?
              @state = :stopped
            else
              queue_item = @queue.pop
            end
            queue_item
          end
        end
      end
    end
  end
end

