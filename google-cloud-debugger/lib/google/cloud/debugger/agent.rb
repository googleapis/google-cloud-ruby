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


require "google/cloud/debugger/breakpoint_manager"
require "google/cloud/debugger/debuggee"
require "google/cloud/debugger/debugger_c"
require "google/cloud/debugger/tracer"
require "google/cloud/debugger/transmitter"
require "google/cloud/logging"
require "stackdriver/core/async_actor"

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
        # Name of the logpoints log file.
        DEFAULT_LOG_NAME = "debugger_logpoints"

        ##
        # @private Debugger Agent is an asynchronous actor
        include Stackdriver::Core::AsyncActor

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
        # The logger used to write the results of Logpoints.
        attr_accessor :logger

        ##
        # A quota tracking object helps tracking resource consumption during
        # evaluations.
        attr_accessor :quota_manager

        ##
        # Absolute path to the debuggee Ruby application root directory. The
        # Stackdriver Debugger service creates canonical breakpoints with only
        # relative path. So the debugger agent combines the relative path to
        # the application directory to trace and evaluate breakpoints.
        # @return [String]
        attr_accessor :app_root

        ##
        # @private The last exception captured in the agent child thread
        attr_reader :last_exception

        ##
        # Create a new Debugger Agent instance.
        #
        # @param [Google::Cloud::Debugger::Service] service The gRPC Service
        #   object
        # @param [Google::Cloud::Logging::Logger] logger The logger used
        #   to write the results of Logpoints.
        # @param [String] service_name Name for the debuggee application.
        # @param [String] service_version Version identifier for the debuggee
        #   application.
        # @param [String] app_root Absolute path to the root directory of
        #   the debuggee application. Default to Rack root.
        #
        def initialize service, logger: nil, service_name:, service_version:,
                       app_root: nil
          super()

          @service = service
          @debuggee = Debuggee.new service, service_name: service_name,
                                            service_version: service_version
          @tracer = Debugger::Tracer.new self
          @breakpoint_manager = BreakpointManager.new self, service
          @breakpoint_manager.on_breakpoints_change =
            method :breakpoints_change_callback

          @transmitter = Transmitter.new self, service

          @logger = logger || default_logger

          init_app_root app_root

          # Agent actor thread needs to force exit immediately.
          set_cleanup_options timeout: 0
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
          transmitter.stop
          async_stop
        end

        ##
        # Stops the tracer regardless of whether any active breakpoints are
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
          warn ["#{e.class}: #{e.message}", e.backtrace].join("\n\t")
          @last_exception = e
        end

        ##
        # @private Callback function when the async actor thread state changes
        def on_async_state_change
          if async_running?
            tracer.start
          else
            tracer.stop
          end
        end

        private

        ##
        # @private Initialize `@app_root` instance variable.
        def init_app_root app_root = nil
          app_root ||= Google::Cloud::Debugger.configure.app_root
          app_root ||= Rack::Directory.new("").root if defined? Rack::Directory
          app_root ||= Dir.pwd

          @app_root = app_root
        end

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
        # @private Create a default logger
        def default_logger
          project_id = @service.project
          credentials = @service.credentials
          logging = Google::Cloud::Logging::Project.new(
            Google::Cloud::Logging::Service.new(
              project_id, credentials))
          resource =
            Google::Cloud::Logging::Middleware.build_monitored_resource

          logging.logger DEFAULT_LOG_NAME, resource
        end
      end
    end
  end
end
