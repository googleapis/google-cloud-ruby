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
require "google/cloud/debugger/breakpoint_manager"
require "google/cloud/debugger/debuggee"
require "google/cloud/debugger/debugger_c"
require "google/cloud/debugger/tracer"
require "google/cloud/debugger/transmitter"

module Google
  module Cloud
    module Debugger
      class Agent
        include AsyncActor

        attr_reader :debuggee

        attr_reader :breakpoint_manager

        attr_reader :tracer

        attr_reader :transmitter

        attr_reader :last_exception

        def initialize service, module_name: , module_version:
          super()

          @service = service
          @debuggee = Debuggee.new service, module_name: module_name,
                                            module_version: module_version
          @tracer = Debugger::Tracer.new self
          @breakpoint_manager = BreakpointManager.new service
          @breakpoint_manager.on_breakpoints_change = method :breakpoints_change_callback

          @transmitter = Transmitter.new service, self
        end

        def start
          transmitter.async_start
          async_start
        end

        def stop
          breakpoint_manager.stop
          transmitter.async_stop
          async_stop
        end

        def stop_tracer
          tracer.stop
        end

        def submit_breakpoint breakpoint
          transmitter.submit breakpoint
        end

        def run_backgrounder
          while running?
            begin
              sync_breakpoints = ensure_debuggee_registration

              if sync_breakpoints
                sync_result = breakpoint_manager.sync_active_breakpoints debuggee.id
                unless sync_result
                  debuggee.revoke_registration
                end
              end
            rescue => e
              @last_exception = e
              delay = @sync_backoff.failed
              puts e
              puts e.backtrace
              # break
            end
          end
        end

        private

        def breakpoints_change_callback active_breakpoints
          if active_breakpoints.empty?
            puts "*********** Agent: tracer stopped"
            tracer.stop
          else
            puts "*********** Agent: tracer started"
            tracer.start
          end
        end

        def ensure_debuggee_registration
          if debuggee.registered?
            registration_result = true
          else
            registration_result = debuggee.register
            if registration_result
              puts "Debuggee #{debuggee.id} successfully registered"
            end
          end

          registration_result
        end

        def async_stop
          @startup_lock.synchronize do
            unless @thread.nil?
              tracer.stop

              @state = :stopped
              @thread.kill
              @thread.join
            end
          end
        end

      end
    end
  end
end
