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
require "google/cloud/debugger/backoff"
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

        def initialize service, module_name: nil, module_version: nil
          super()

          @service = service
          @debuggee = Debuggee.new service, module_name: module_name,
                                   module_version: module_version
          @tracer = Debugger::Tracer.new self
          @breakpoint_manager = BreakpointManager.new service
          @breakpoint_manager.on_breakpoints_change = method :breakpoints_change_callback

          @transmitter = Transmitter.new service, self

          @register_backoff = Backoff.new
          @sync_backoff = Backoff.new
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

        def breakpoints_change_callback active_breakpoints
          if active_breakpoints.empty?
            tracer.stop
          else
            tracer.start
          end
        end

        def run_backgrounder
          while running?
            delay = 0
            sync_breakpoints = false
            begin
              if debuggee.registered?
                sync_breakpoints = true
              else
                sync_breakpoints = debuggee.register
                if sync_breakpoints
                  puts "Debuggee #{debuggee.id} successfully registered"
                  # STDOUT.flush
                  @register_backoff.succeeded
                  delay = 0
                else
                  @register_backoff.failed
                end
              end
            rescue => e
              @last_exception = e
              delay = @register_backoff.failed
              puts e
              puts e.backtrace
              # break
            end

            begin
              if sync_breakpoints
                sync_result = breakpoint_manager.sync_active_breakpoints debuggee.id
                if sync_result
                  delay = 0
                  @sync_backoff.succeeded
                else
                  debuggee.revoke_registration
                  delay = @sync_backoff.failed
                end
              end
            rescue => e
              @last_exception = e
              delay = @sync_backoff.failed
              puts e
              puts e.backtrace
              # break
            end

            sleep delay
            # sleep 3
          end
        ensure
          @state = :stopped
        end

      end
    end
  end
end
