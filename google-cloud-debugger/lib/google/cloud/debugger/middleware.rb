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


module Google
  module Cloud
    module Debugger
      ##
      # Rack Middleware implementation that supports Stackdriver Debugger Agent
      # in Rack-based Ruby frameworks. It instantiates a new debugger agent if
      # one isn't given already. It helps optimize Debugger Agent Tracer
      # performance by suspend and resume tracer between each request.
      class Middleware
        ##
        # Create a new Debugger Middleware.
        #
        # @param [Rack Application] app Rack application
        # @param [Google::Cloud::Debugger::Project] debugger A debugger to be
        #   used by this middleware. If not given, will construct a new one
        #   using the other parameters.
        # @param [String] project_id Project identifier for the Stackdriver
        #   Debugger service. Optional if a debugger is given.
        # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud:
        #   either the JSON data or the path to a readable file. Optional if
        #   a debugger is given.
        #
        # @return [Google::Cloud::Debugger::Middleware] A new
        #   Google::Cloud::Debugger::Middleware instance
        #
        def initialize app, debugger: nil, project_id: nil, keyfile: nil
          @app = app
          load_config project_id: project_id, keyfile: keyfile

          @debugger = debugger ||
                      Debugger.new(project: @project_id,
                                   keyfile: @keyfile,
                                   module_name: configuration.module_name,
                                   module_version: configuration.module_version)
          # Immediately start the debugger agent
          @debugger.start
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
          # Enable/resume breakpoints tracing
          @debugger.agent.tracer.start

          @app.call env
        ensure
          # Stop breakpoints tracing beyond this point
          @debugger.agent.tracer.disable_traces_for_thread
        end

        private

        ##
        # Consolidate configurations from various sources. Also set
        # instrumentation config parameters to default values if not set
        # already.
        #
        def load_config project_id: nil, keyfile: nil
          @project_id = project_id ||
                        configuration.project_id ||
                        Cloud.configure.project_id ||
                        Debugger::Project.default_project
          @keyfile = keyfile || configuration.keyfile || Cloud.configure.keyfile

          # Set defaults
          configuration.module_name ||=
            Debugger::Project.default_module_name
          configuration.module_version ||=
            Debugger::Project.default_module_version

          # Ensure instrumentation configurations are aligned
          configuration.project_id = @project_id
          configuration.keyfile = @keyfile
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
