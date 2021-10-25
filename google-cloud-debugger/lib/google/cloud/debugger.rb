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


require "google-cloud-debugger"
require "google/cloud/debugger/project"
require "google/cloud/config"
require "google/cloud/env"
require "stackdriver/core"

module Google
  module Cloud
    ##
    # # Stackdriver Debugger
    #
    # Stackdriver Debugger is a feature of the Google Cloud Platform that lets
    # you inspect the state of an application at any code location without using
    # logging statements and without stopping or slowing down your applications.
    # Your users are not impacted during debugging. Using the production
    # debugger you can capture the local variables and call stack and link it
    # back to a specific line location in your source code. You can use this to
    # analyze the production state of your application and understand the
    # behavior of your code in production.
    #
    # See {file:OVERVIEW.md Debugger Overview}.
    #
    module Debugger
      # rubocop:disable all

      ##
      # Creates a new debugger object for instrumenting Stackdriver Debugger for
      # an application. Each call creates a new debugger agent with independent
      # connection service.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Stackdriver
      #   Debugger service you are connecting to. If not present, the default
      #   project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Debugger::Credentials})
      # @param [String] service_name Name for the debuggee application.
      #   Optional.
      # @param [String] service_version Version identifier for the debuggee
      #   application. Optional.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud_debugger`
      #   * `https://www.googleapis.com/auth/logging.admin`
      #
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] project Project identifier for the Stackdriver Debugger
      #   service.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud:
      #   either the JSON data or the path to a readable file.
      #
      # @return [Google::Cloud::Debugger::Project]
      #
      # @example
      #   require "google/cloud/debugger"
      #
      #   debugger = Google::Cloud::Debugger.new
      #   debugger.start
      #
      def self.new project_id: nil,
                   credentials: nil,
                   service_name: nil,
                   service_version: nil,
                   scope: nil,
                   timeout: nil,
                   endpoint: nil,
                   project: nil,
                   keyfile: nil
        project_id      ||= (project || default_project_id)
        service_name    ||= default_service_name
        service_version ||= default_service_version
        scope           ||= configure.scope
        timeout         ||= configure.timeout
        endpoint        ||= configure.endpoint

        service_name = service_name.to_s
        raise ArgumentError, "service_name is missing" if service_name.empty?

        service_version = service_version.to_s
        if service_version.nil?
          raise ArgumentError, "service_version is missing"
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Debugger::Credentials.new credentials, scope: scope
        end

        if credentials.respond_to? :project_id
          project_id ||= credentials.project_id
        end
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        service = Debugger::Service.new project_id, credentials, host: endpoint, timeout: timeout
        Debugger::Project.new service, service_name: service_name, service_version: service_version
      end

      # rubocop:enable all

      ##
      # Configure the Stackdriver Debugger agent.
      #
      # The following Stackdriver Debugger configuration parameters are
      # supported:
      #
      # * `project_id` - (String) Project identifier for the Stackdriver
      #   Debugger service you are connecting to. (The parameter `project` is
      #   considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Debugger::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `service_name` - (String) Name for the debuggee application.
      # * `service_version` - (String) Version identifier for the debuggee
      #   application.
      # * `root` - (String) The root directory of the debuggee application as an
      #   absolute file path.
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `allow_mutating_methods` - (boolean) Whether expressions and
      #   conditional breakpoints can call methods that could modify program
      #   state. Defaults to false.
      # * `evaluation_time_limit` - (Numeric) Time limit in seconds for
      #   expression evaluation. Defaults to 0.05.
      # * `on_error` - (Proc) A Proc to be run when an error is encountered
      #   on a background thread. The Proc must take the error object as the
      #   single argument.
      #
      # See the [Configuration
      # Guide](https://googleapis.dev/ruby/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION.html)
      # for full configuration parameters.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Debugger module uses.
      #
      def self.configure
        yield Google::Cloud.configure.debugger if block_given?

        Google::Cloud.configure.debugger
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.debugger.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default service name identifier.
      def self.default_service_name
        Google::Cloud.configure.debugger.service_name ||
          Google::Cloud.configure.service_name ||
          Google::Cloud.env.app_engine_service_id ||
          "ruby-app"
      end

      ##
      # @private Default service version identifier.
      def self.default_service_version
        Google::Cloud.configure.debugger.service_version ||
          Google::Cloud.configure.service_version ||
          Google::Cloud.env.app_engine_service_version ||
          ""
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.debugger.credentials ||
          Google::Cloud.configure.credentials ||
          Debugger::Credentials.default(scope: scope)
      end

      ##
      # Allow calling of potentially state-changing methods even if mutation
      # detection is configured to be active.
      #
      # Generally it is unwise to run code that may change the program state
      # (e.g. modifying instance variables or causing other side effects) in a
      # breakpoint expression, because it could change the behavior of your
      # program. However, the checks are currently quite conservative, and may
      # block code that is actually safe to run. If you are certain your
      # expression is safe to evaluate, you may use this method to disable
      # side effect checks.
      #
      # This method may be called with a block, in which case checks are
      # disabled within the block. It may also be called without a block to
      # disable side effect checks for the rest of the current expression; the
      # default setting will be restored for the next expression.
      #
      # This method may be called only from a debugger condition or expression
      # evaluation, and will throw an exception if you call it from normal
      # application code. Set the `allow_mutating_methods` configuration if you
      # want to disable the side effect checker globally for your app.
      #
      # @example Disabling side effect detection in a block
      #   # This is an expression evaluated in a debugger snapshot
      #   Google::Cloud::Debugger.allow_mutating_methods! do
      #     obj1.method_with_potential_side_effects
      #   end
      #
      # @example Disabling side effect detection for the rest of the expression
      #   # This is an expression evaluated in a debugger snapshot
      #   Google::Cloud::Debugger.allow_mutating_methods!
      #   obj1.method_with_potential_side_effects
      #   obj2.another_method_with_potential_side_effects
      #
      # @example Globally disabling side effect detection at app initialization
      #   require "google/cloud/debugger"
      #   Google::Cloud::Debugger.configure.allow_mutating_methods = true
      #
      def self.allow_mutating_methods! &block
        evaluator = Breakpoint::Evaluator.current
        if evaluator.nil?
          raise "allow_mutating_methods can be called only during evaluation"
        end
        evaluator.allow_mutating_methods!(&block)
      end
    end
  end

  # Aliases for compatibility with older spellings.
  # @private
  module Devtools
    # @private
    Clouddebugger = ::Google::Cloud::Debugger unless const_defined? :Clouddebugger
  end
end
