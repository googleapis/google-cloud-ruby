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
        # @param [String] project Project identifier for the Stackdriver
        #   Debugger service. Optional if a debugger is given.
        # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud:
        #   either the JSON data or the path to a readable file. Optional if
        #   a debugger is given.
        # @param [String] module_name Name for the debuggee application.
        #   Optional if a debugger is given.
        # @param [String] module_version Version identifier for the debuggee
        #   application. Optiona if a debugger is given.
        #
        # @return [Google::Cloud::Debugger::Middleware] A new
        #   Google::Cloud::Debugger::Middleware instance
        #
        def initialize app, debugger: nil, module_name:nil, module_version: nil,
                       project: nil, keyfile: nil
          @app = app
          @debugger = debugger || Debugger.new(project: project,
                                               keyfile: keyfile,
                                               module_name: module_name,
                                               module_version: module_version)
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

          response = @app.call env

          # Stop breakpoints tracing beyond this point
          @debugger.agent.tracer.disable_traces_for_thread

          response
        end
      end
    end
  end
end
