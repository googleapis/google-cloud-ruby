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
    # For general information about Stackdriver Debugger, read [Stackdriver
    # Debugger Documentation](https://cloud.google.com/debugger/docs/).
    #
    # The Stackdriver Debugger Ruby library, `google-cloud-debugger`, provides:
    #
    # *   Easy-to-use debugger instrumentation that reports state data, such as
    #     value of program variables and the call stack, to Stackdriver Debugger
    #     when the code at a breakpoint location is executed in your Ruby
    #     application. See the [instrumenting your app](#instrumenting-your-app)
    #     section for how to debug your application, in both development and
    #     production.
    # *   An idiomatic Ruby API for registerying debuggee application, and
    #     querying or manipulating breakpoints in registered Ruby debuggee
    #     application. See [Debugger API](#stackdriver-debugger-api) section for
    #     an introduction to Stackdriver Debugger API.
    #
    # ## Instrumenting Your App
    #
    # This instrumentation library provides the following features to help you
    # debug your applications in production:
    #
    # *   Automatic application registration. It facilitates multiple running
    #     instances of same version of application when hosted in production.
    # *   A background debugger agent that runs side-by-side with your
    #     application that automatically collects state data when code is
    #     executed at breakpoint locations.
    # *   A Rack middleware and Railtie that automatically manages the debugger
    #     agent for Ruby on Rails and other Rack-based Ruby applications.
    #
    # When this library is configured in your running application, and the
    # source code and breakpoints are setup through the Google Cloud Console,
    # You'll be able to
    # [interact](https://cloud.google.com/debugger/docs/debugging) with your
    # application in real time through the [Stackdriver Debugger
    # UI](https://console.cloud.google.com/debug?_ga=1.84295834.280814654.1476313407).
    # This library also integrates with Google App Engine Flexible to make
    # debuggee application configuration more seemless.
    #
    # Note that when no breakpoints are created, the debugger agent consumes
    # very little resource and has no interference with the running application.
    # Once breakpoints are created and depends on where the breakpoints are
    # located, the debugger agent may add a little latency onto each request.
    # The application performance will be back to normal after all breakpoints
    # are finished being evaluated. Be aware the more breakpoints are created,
    # or the harder to reach the breakpoints, the more resource the debugger
    # agent would need to consume.
    #
    # ### Using instrumentation with Ruby on Rails
    #
    # To install application instrumentation in your Ruby on Rails app, add this
    # gem, `google-cloud-debugger`, to your Gemfile and update your bundle. Then
    # add the following line to your `config/application.rb` file:
    #
    # ```ruby
    # require "google/cloud/debugger/rails"
    # ```
    #
    # This will load a Railtie that automatically integrates with the Rails
    # framework by injecting a Rack middleware. The Railtie also takes in the
    # following Rails configuration as parameter of the debugger agent
    # initialization:
    #
    # ```ruby
    # # Explicitly enable or disable Stackdriver Debugger Agent
    # config.google_cloud.use_debugger = true
    # # Shared Google Cloud Platform project identifier
    # config.google_cloud.project_id = "gcloud-project"
    # # Google Cloud Platform project identifier for Stackdriver Debugger only
    # config.google_cloud.debugger.project_id = "debugger-project"
    # # Shared Google Cloud authentication json file
    # config.google_cloud.keyfile = "/path/to/keyfile.json"
    # # Google Cloud authentication json file for Stackdriver Debugger only
    # config.google_cloud.debugger.keyfile = "/path/to/debugger/keyfile.json"
    # # Stackdriver Debugger Agent service name identifier
    # config.google_cloud.debugger.service_name = "my-ruby-app"
    # # Stackdriver Debugger Agent service version identifier
    # config.google_cloud.debugger.service_version = "v1"
    # ```
    #
    # See the {Google::Cloud::Debugger::Railtie} class for more information.
    #
    # ### Using instrumentation with Sinatra
    #
    # To install application instrumentation in your Sinatra app, add this gem,
    # `google-cloud-debugger`, to your Gemfile and update your bundle. Then add
    # the following lines to your main application Ruby file:
    #
    # ```ruby
    # require "google/cloud/debugger"
    # use Google::Cloud::Debugger::Middleware
    # ```
    #
    # This will install the debugger middleware in your application.
    #
    # Configuration parameters may also be passed in as arguments to Middleware.
    # ```ruby
    # require "google/cloud/debugger"
    # use Google::Cloud::Debugger::Middleware project: "debugger-project-id",
    #                                         keyfile: "/path/to/keyfile.json",
    #                                         service_name: "my-ruby-app",
    #                                         service_version: "v1"
    # ```
    #
    # ### Using instrumentation with other Rack-based frameworks
    #
    # To install application instrumentation in an app using another Rack-based
    # web framework, add this gem, `google-cloud-debugger`, to your Gemfile and
    # update your bundle. Then add install the debugger middleware in your
    # middleware stack. In most cases, this means adding these lines to your
    # `config.ru` Rack configuration file:
    #
    # ```ruby
    # require "google/cloud/debugger"
    # use Google::Cloud::Debugger::Middleware
    # ```
    #
    # Some web frameworks have an alternate mechanism for modifying the
    # middleware stack. Consult your web framework's documentation for more
    # information.
    #
    # ### The Stackdriver diagnostics suite
    #
    # The debugger library is part of the Stackdriver diagnostics suite, which
    # also includes error reporting, log analysis, and tracing analysis. If you
    # include the `stackdriver` gem in your Gemfile, this debugger library will
    # be included automatically. In addition, if you include the `stackdriver`
    # gem in an application using Ruby On Rails, the Railties will be installed
    # automatically. See the documentation for the "stackdriver" gem
    # for more details.
    #
    # ## Stackdriver Debugger API
    #
    # This library also includes an easy to use Ruby client for the
    # Stackdriver Debugger API. This API provides calls to register debuggee
    # application, as well as creating or modifying breakpoints.
    #
    # For further information on the Debugger API, see
    # {Google::Cloud::Debugger::Project}
    #
    # ### Registering debuggee application
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Controller2Client = Google::Cloud::Debugger::V2::Controller2Client
    # Debuggee = Google::Devtools::Clouddebugger::V2::Debuggee
    #
    # controller2_client = Controller2Client.new
    # debuggee = Debuggee.new
    # response = controller2_client.register_debuggee(debuggee)
    # debuggee_id = response.debuggee.id
    # ```
    # See [Stackdriver Debugger Debuggee
    # doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Debuggee)
    # on fields necessary for registerying a debuggee.
    #
    # Upon successful registration, the response debuggee object will contain
    # a debuggee_id that's later needed to interact with the other Stackdriver
    # Debugger API.
    #
    # See {Google::Cloud::Debugger::V2::Controller2Client} for details.
    #
    # ### List Active Breakpoints
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Controller2Client = Google::Cloud::Debugger::V2::Controller2Client
    # controller2_client = Controller2Client.new
    #
    # debuggee_id = ''
    # response = controller2_client.list_active_breakpoints(debuggee_id)
    # breakpoints = response.breakpoints
    # ```
    #
    # See {Google::Cloud::Debugger::V2::Controller2Client} for details.
    #
    # ### Update Active Breakpoint
    #
    # Users can send custom snapshots for active breakpoints using this API.
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Breakpoint = Google::Devtools::Clouddebugger::V2::Breakpoint
    # Controller2Client = Google::Cloud::Debugger::V2::Controller2Client
    #
    # controller2_client = Controller2Client.new
    # debuggee_id = ''
    # breakpoint = Breakpoint.new
    # response =
    #   controller2_client.update_active_breakpoint(debuggee_id, breakpoint)
    # ```
    #
    # See [Stackdriver Debugger Breakpoint
    # doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Breakpoint)
    # for all available fields for breakpoint.
    #
    # See {Google::Cloud::Debugger::V2::Controller2Client} for details.
    #
    # ### Set Breakpoint
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Breakpoint = Google::Devtools::Clouddebugger::V2::Breakpoint
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # debugger2_client = Debugger2Client.new
    # debuggee_id = ''
    # breakpoint = Breakpoint.new
    # client_version = ''
    # response = debugger2_client.set_breakpoint(
    #              debuggee_id, breakpoint, client_version)
    # ```
    #
    # See [Stackdriver Debugger Breakpoint
    # doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Breakpoint)
    # for fields needed to specify breakpoint location.
    #
    # See {Google::Cloud::Debugger::V2::Debugger2Client} for details.
    #
    # ### Get Breakpoint
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # debugger2_client = Debugger2Client.new
    # debuggee_id = ''
    # breakpoint_id = ''
    # client_version = ''
    # response = debugger2_client.get_breakpoint(
    #              debuggee_id, breakpoint_id, client_version)
    # ```
    #
    # See {Google::Cloud::Debugger::V2::Debugger2Client} for details.
    #
    # ### Delete Breakpoint
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # debugger2_client = Debugger2Client.new
    # debuggee_id = ''
    # breakpoint_id = ''
    # client_version = ''
    # debugger2_client.delete_breakpoint(
    #   debuggee_id, breakpoint_id, client_version)
    # ```
    #
    # See {Google::Cloud::Debugger::V2::Debugger2Client} for details.
    #
    # ### List Breakpoints
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # debugger2_client = Debugger2Client.new
    # debuggee_id = ''
    # client_version = ''
    # response = debugger2_client.list_breakpoints(debuggee_id, client_version)
    # ```
    #
    # See {Google::Cloud::Debugger::V2::Debugger2Client} for details.
    #
    # ### List Debuggees
    #
    # ```ruby
    # require "google/cloud/debugger/v2"
    #
    # Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client
    #
    # debugger2_client = Debugger2Client.new
    # project = ''
    # client_version = ''
    # response = debugger2_client.list_debuggees(project, client_version)
    # ```
    #
    # See {Google::Cloud::Debugger::V2::Debugger2Client} for details.
    #
    module Debugger
      # rubocop:disable all

      ##
      # Creates a new debugger object for instrumenting Stackdriver Debugger for
      # an application. Each call creates a new debugger agent with independent
      # connection service.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
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
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
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
      def self.new project_id: nil, credentials: nil, service_name: nil,
                   service_version: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string

        service_name ||= default_service_name
        service_name = service_name.to_s

        service_version ||= default_service_version
        service_version = service_version.to_s

        raise ArgumentError, "project_id is missing" if project_id.empty?
        raise ArgumentError, "service_name is missing" if service_name.empty?
        if service_version.nil?
          raise ArgumentError, "service_version is missing"
        end

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Debugger::Credentials.new credentials, scope: scope
        end

        Debugger::Project.new(
          Debugger::Service.new(project_id, credentials,
                                timeout: timeout, client_config: client_config),
          service_name: service_name,
          service_version: service_version
        )
      end

      # rubocop:enable all

      ##
      # Reload debugger configuration from defaults. For testing.
      # @private
      #
      def self.reload_configuration!
        default_creds = Google::Cloud.credentials_from_env(
          "DEBUGGER_CREDENTIALS", "DEBUGGER_CREDENTIALS_JSON",
          "DEBUGGER_KEYFILE", "DEBUGGER_KEYFILE_JSON"
        )

        Google::Cloud.configure.delete! :debugger
        Google::Cloud.configure.add_config! :debugger do |config|
          config.add_field! :project_id, ENV["DEBUGGER_PROJECT"], match: String
          config.add_alias! :project, :project_id
          config.add_field! :credentials, default_creds,
                            match: [String, Hash, Google::Auth::Credentials]
          config.add_alias! :keyfile, :credentials
          config.add_field! :service_name, ENV["DEBUGGER_SERVICE_NAME"],
                            match: String
          config.add_field! :service_version, ENV["DEBUGGER_SERVICE_VERSION"],
                            match: String
          config.add_field! :app_root, nil, match: String
          config.add_field! :root, nil, match: String
          config.add_field! :scope, nil, match: [String, Array]
          config.add_field! :timeout, nil, match: Integer
          config.add_field! :client_config, nil, match: Hash
          config.add_field! :allow_mutating_methods, false
          config.add_field! :evaluation_time_limit, 0.05, match: Numeric
        end
      end

      reload_configuration! unless Google::Cloud.configure.subconfig? :debugger

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
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `allow_mutating_methods` - (boolean) Whether expressions and
      #   conditional breakpoints can call methods that could modify program
      #   state. Defaults to false.
      # * `evaluation_time_limit` - (Numeric) Time limit in seconds for
      #   expression evaluation. Defaults to 0.05.
      #
      # See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
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
          Google::Cloud.env.app_engine_service_id ||
          "ruby-app"
      end

      ##
      # @private Default service version identifier.
      def self.default_service_version
        Google::Cloud.configure.debugger.service_version ||
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
end
