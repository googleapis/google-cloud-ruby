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
require "google/cloud/debugger/breakpoint_manager"
require "google/cloud/debugger/debuggee"
require "google/cloud/debugger/debugger_c"
require "google/cloud/debugger/tracer"
require "google/cloud/debugger/transmitter"

module Google
  module Cloud
    module Debugger
      ##
      # # Agent
      #
      # The Stackdriver Debugger Agent runs on the same system where a debuggee
      # application is running. The agent is responsible for sending state data,
      # such as the value of program variables and the call stack, to
      # Stackdriver Debugger when the code at a breakpoint location is executed.
      #
      # The Debugger Agent runs in its own child thread when started. It ensures
      # the instrumented application is registered properly and constantly
      # monitors for any active breakpoints. Once the agent gets updated with
      # active breakpoints from Stackdriver Debugger service, it facilitates
      # the breakpoints in application requests thread, then transport the
      # result snapshot back to Stackdriver Debugger service asynchronously.
      #
      # @example
      #   require "google/cloud/debugger"
      #
      #   debugger = Google::Cloud::Debugger.new
      #   agent = debugger.agent
      #   agent.start
      #
      class Agent
        ##
        # @private Debugger Agent is an asynchronous actor
        include AsyncActor

        ##
        # @private The gRPC Service object.
        attr_reader :service

        ##
        # The gRPC Debuggee representation of the debuggee application. It
        # contains identification information to match running application to
        # specific Cloud Source Repository code base, and correctly group
        # same versions of the debuggee application together through a generated
        # unique identifier.
        # @return [Google::Cloud::Debugger::Debuggee]
        attr_reader :debuggee

        ##
        # It manages syncing breakpoints between the Debugger Agent and
        # Stackdriver Debugger service
        # @return [Google::Cloud::Debugger::BreakpointManager]
        attr_reader :breakpoint_manager

        ##
        # It monitors the debuggee application and triggers breakpoint
        # evaluation when breakpoints are set.
        # @return [Google::Cloud::Debugger::Tracer]
        attr_reader :tracer

        ##
        # It sends evaluated breakpoints snapshot back to Stackdriver Debugger
        # Service.
        # @return [Google::Cloud::Debugger::Transmiter]
        attr_reader :transmitter

        ##
        # @private The last exception captured in the agent child thread
        attr_reader :last_exception

        ##
        # Create a new Debugger Agent instance.
        #
        # @param [Google::Cloud::Debugger::Service] service The gRPC Service
        #   object
        # @param [String] module_name Name for the debuggee application.
        #   Optional.
        # @param [String] module_version Version identifier for the debuggee
        #   application. Optional.
        #
        def initialize service, module_name:, module_version:
          super()

          @service = service
          @debuggee = Debuggee.new service, module_name: module_name,
                                            module_version: module_version
          @tracer = Debugger::Tracer.new self
          @breakpoint_manager = BreakpointManager.new service
          @breakpoint_manager.on_breakpoints_change =
            method :breakpoints_change_callback

          @transmitter = Transmitter.new service, self
        end

        ##
        # Starts the Debugger Agent in a child thread, where debuggee
        # application registration and breakpoints querying will take place.
        # It also starts the transmitter in another child thread.
        #
        def start
          transmitter.start
          async_start
        end

        ##
        # Stops and terminates the Debugger Agent. It also properly shuts down
        # transmitter and tracer.
        #
        # Once Debugger Agent is stopped, it cannot be started again.
        #
        def stop
          tracer.stop
          transmitter.stop
          async_stop
        end

        ##
        # Stops the tracer regardless whether any active breakpoints are
        # present. Once the tracer stops monitoring the debuggee application,
        # the application can return to normal performance.
        def stop_tracer
          tracer.stop
        end

        ##
        # @private Callback function for AsyncActor module that kicks off
        # the asynchronous job in a loop.
        def run_backgrounder
          sync_breakpoints = ensure_debuggee_registration

          if sync_breakpoints
            sync_result =
              breakpoint_manager.sync_active_breakpoints debuggee.id
            debuggee.revoke_registration unless sync_result
          end
        rescue => e
          @last_exception = e
        end

        private

        ##
        # @private Callback function for breakpoint manager when any updates
        # happens to the list of active breakpoints
        def breakpoints_change_callback active_breakpoints
          if active_breakpoints.empty?
            tracer.stop
          else
            tracer.start
          end
        end

        ##
        # @private Helper method to register the debuggee application if not
        # registered already.
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

        ##
        # @private Override AsyncActor#async_stop to immediately kill the child
        # thread instead of waiting for it to return, because the breakpoints
        # are queried with a hanging long poll mechanism.
        def async_stop
          @startup_lock.synchronize do
            unless @thread.nil?
              tracer.stop

              @async_state = :stopped
              @thread.kill
              @thread.join
            end
          end
        end
      end
    end
  end
end
