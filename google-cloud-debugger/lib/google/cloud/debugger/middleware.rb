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


require "set"

require "google/cloud/logging/logger"
require "google/cloud/debugger/request_quota_manager"

module Google
  module Cloud
    module Debugger
      ##
      # Rack Middleware implementation that supports Stackdriver Debugger Agent
      # in Rack-based Ruby frameworks. It instantiates a new debugger agent if
      # one isn't given already. It helps optimize Debugger Agent Tracer
      # performance by suspending and resuming the tracer between each request.
      #
      # To use this middleware, simply install it in your Rack configuration.
      # The middleware will take care of registering itself with the
      # Stackdriver Debugger and activating the debugger agent. The location
      # of the middleware in the middleware stack matters: breakpoints will be
      # detected in middleware appearing after but not before this middleware.
      #
      # For best results, you should also call {Middleware.start_agents}
      # during application initialization. See its documentation for details.
      #
      class Middleware
        ##
        # Reset deferred start mechanism.
        # @private
        #
        def self.reset_deferred_start
          @debuggers_to_start = Set.new
        end

        reset_deferred_start

        ##
        # Start the debugger. Either adds it to the deferred list, or, if the
        # deferred list has already been started, starts immediately.
        #
        # @param [Google::Cloud::Debugger::Project] debugger
        #
        # @private
        #
        def self.deferred_start debugger
          if @debuggers_to_start
            @debuggers_to_start << debugger
          else
            debugger.start
          end
        end

        ##
        # This should be called once the application determines that it is safe
        # to start background threads and open gRPC connections. It informs
        # the middleware system that it can start debugger agents.
        #
        # Generally, this matters if the application forks worker processes;
        # this method should be called only after workers are forked, since
        # threads and network connections interact badly with fork. For
        # example, when running Puma in
        # [clustered mode](https://github.com/puma/puma#clustered-mode), this
        # method should be called in an `on_worker_boot` block.
        #
        # If the application does no forking, this method can be called any
        # time early in the application initialization process.
        #
        # If {Middleware.start_agents} is never called, the debugger agent will
        # be started when the first request is received. This should be safe,
        # but it will probably mean breakpoints will not be recognized during
        # that first request. For best results, an application should call this
        # method at the appropriate time.
        #
        def self.start_agents
          return unless @debuggers_to_start
          @debuggers_to_start.each(&:start)
          @debuggers_to_start = nil
        end

        ##
        # Create a new Debugger Middleware.
        #
        # @param [Rack Application] app Rack application
        # @param [Google::Cloud::Debugger::Project] debugger A debugger to be
        #   used by this middleware. If not given, will construct a new one
        #   using the other parameters.
        # @param [Hash] kwargs Hash of configuration settings. Used for backward
        #   API compatibility. See the [Configuration
        #   Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION)
        #   for the prefered way to set configuration parameters.
        #
        # @return [Google::Cloud::Debugger::Middleware] A new
        #   Google::Cloud::Debugger::Middleware instance
        #
        def initialize app, debugger: nil, **kwargs
          @app = app

          load_config kwargs

          if debugger
            @debugger = debugger
          else
            @debugger =
              Debugger.new(project_id: configuration.project_id,
                           credentials: configuration.credentials,
                           service_name: configuration.service_name,
                           service_version: configuration.service_version)

            @debugger.agent.quota_manager =
              Google::Cloud::Debugger::RequestQuotaManager.new
          end

          Middleware.deferred_start(@debugger)
        end

        ##
        # Rack middleware entry point. In most Rack based frameworks, a request
        # is served by one thread. It enables/resume the debugger breakpoints
        # tracing and stops/pauses the tracing afterwards to help improve
        # debugger performance.
        #
        # @param [Hash] env Rack environment hash
        #
        # @return [Rack::Response] The response from downstream Rack app
        #
        def call env
          # Ensure the agent is running. (Note the start method is idempotent.)
          @debugger.start

          # Enable/resume breakpoints tracing
          @debugger.agent.tracer.start

          # Use Stackdriver Logger for debugger if available
          if env["rack.logger"].is_a? Google::Cloud::Logging::Logger
            @debugger.agent.logger = env["rack.logger"]
          end

          @app.call env
        ensure
          # Stop breakpoints tracing beyond this point
          @debugger.agent.tracer.disable_traces_for_thread

          # Reset quotas after each request finishes.
          @debugger.agent.quota_manager.reset if @debugger.agent.quota_manager
        end

        private

        ##
        # Consolidate configurations from various sources. Also set
        # instrumentation config parameters to default values if not set
        # already.
        #
        def load_config **kwargs
          project_id = kwargs[:project] || kwargs[:project_id]
          configuration.project_id = project_id unless project_id.nil?

          creds = kwargs[:credentials] || kwargs[:keyfile]
          configuration.credentials = creds unless creds.nil?

          service_name = kwargs[:service_name]
          configuration.service_name = service_name unless service_name.nil?

          service_vers = kwargs[:service_version]
          configuration.service_version = service_vers unless service_vers.nil?

          init_default_config
        end

        ##
        # Fallback to default configuration values if not defined already
        def init_default_config
          configuration.project_id ||= Debugger.default_project_id
          configuration.credentials ||= Debugger.default_credentials
          configuration.service_name ||= Debugger.default_service_name
          configuration.service_version ||= Debugger.default_service_version
        end

        ##
        # @private Get Google::Cloud::Debugger.configure
        def configuration
          Google::Cloud::Debugger.configure
        end
      end
    end
  end
end
