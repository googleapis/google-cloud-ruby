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


require "google-cloud-debugger"
require "google/cloud/debugger/project"

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
    # Other Stackdriver Debugger service features not covered by this
    # application instrumentation:
    #
    # *   Source code context generation. The Stackdriver Debugger service
    #     console is able to display your application source code from a source
    #     of your choice if a source context JSON file exists. See
    #     [Debugger Doc](https://cloud.google.com/debugger/docs/source-context)
    #     on how to select source code on Stackdriver Debugger UI.
    # *   Breakpoints creation and manipulation. See the [Debugger
    #     Doc](https://cloud.google.com/debugger/docs/debugging) on how to
    #     manage breakpoints on Cloud Console, or see the [#Debugger
    #     API](#stackdriver-debugger-api) section on how to manage breakpoints
    #     using the Ruby API client.
    #
    # When this library is installed and configured in your running application,
    # you can view your applications breakpoint snapshots in real time by
    # opening the Google Cloud Console in your web browser and navigating to the
    # "Debug" section. It also integrates with Google App Engine Flexible to
    # make application registration more seemless, and helps Stackdriver
    # Debugger Console to select correct version of source code from Cloud
    # Source Repository.
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
    # # Share Google Cloud authentication json file
    # config.google_cloud.keyfile = "/path/to/keyfile.json"
    # # Google Cloud authentication json file for Stackdriver Debugger only
    # config.google_cloud.debugger.keyfile = "/path/to/debugger/keyfile.json"
    # # Stackdriver Debugger Agent module name identifier
    # config.google_cloud.debugger.module_name = "my-ruby-app"
    # # Stackdriver Debugger Agent module version identifier
    # config.google_cloud.debugger.module_version = "v1"
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
    # See [Stackdriver Debuggee Debuggee
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
      ##
      # Creates a new debugger object for instrumenting Stackdriver Debugger for
      # an application. Each call creates a new debugger agent with independent
      # connection service.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project Project identifier for the Stackdriver Debugger
      #   service.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud:
      #   either the JSON data or the path to a readable file.
      # @param [String] module_name Name for the debuggee application. Optional.
      # @param [String] module_version Version identifier for the debuggee
      #   application. Optional.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #   The default scope is `https://www.googleapis.com/auth/cloud-platform`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      #
      # @return [Google::Cloud::Debugger::Project]
      #
      # @example
      #   require "google/cloud/debugger"
      #
      #   debugger = Google::Cloud::Debugger.new
      #   debugger.start
      #
      def self.new project: nil, keyfile: nil, module_name: nil,
                   module_version: nil, scope: nil, timeout: nil,
                   client_config: nil
        project ||= Debugger::Project.default_project
        project = project.to_s # Always cast to a string
        module_name ||= Debugger::Project.default_module_name
        module_name = module_name.to_s
        module_version ||= Debugger::Project.default_module_version
        module_version = module_version.to_s

        fail ArgumentError, "project is missing" if project.empty?
        fail ArgumentError, "module_name is missing" if module_name.empty?
        fail ArgumentError, "module_version is missing" if module_version.nil?

        credentials = Credentials.credentials_with_scope keyfile, scope

        Google::Cloud::Debugger::Project.new(
          Google::Cloud::Debugger::Service.new(
            project, credentials, timeout: timeout,
                                  client_config: client_config),
          module_name: module_name,
          module_version: module_version
        )
      end
    end
  end
end
