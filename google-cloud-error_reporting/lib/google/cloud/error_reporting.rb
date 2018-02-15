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


require "google-cloud-error_reporting"
require "google/cloud/error_reporting/async_error_reporter"
require "google/cloud/error_reporting/project"
require "google/cloud/error_reporting/middleware"
require "google/cloud/config"
require "google/cloud/env"
require "stackdriver/core"

module Google
  module Cloud
    ##
    # # ErrorReporting
    #
    # Stackdriver Error Reporting counts, analyzes and aggregates the crashes in
    # your running cloud services. The Stackdriver Error Reporting
    # Instrumentation client provides
    # [a simple way to report errors](#how-to-report-errors) from your
    # application.
    #
    # For general information about Stackdriver Error Reporting, read
    # [Stackdriver Error Reporting
    # Documentation](https://cloud.google.com/error-reporting/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Your authentication credentials are detected automatically in
    # Google Cloud Platform environments such as Google Compute Engine, Google
    # App Engine and Google Kubernetes Engine. In other environments you can
    # configure authentication easily, either directly in your code or via
    # environment variables. Read more about the options for connecting in the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ## How to report errors
    #
    # You can easily report exceptions from your applications to Stackdriver
    # Error Reporting service:
    #
    # ```ruby
    # require "google/cloud/error_reporting"
    #
    # # Configure Stackdriver ErrorReporting instrumentation
    # Google::Cloud::ErrorReporting.configure do |config|
    #   config.project_id = "my-project"
    #   config.keyfile = "/path/to/keyfile.json"
    # end
    #
    # # Insert a Rack Middleware to report unhanded exceptions
    # use Google::Cloud::ErrorReporting::Middleware
    #
    # # Or explicitly submit exceptions
    # begin
    #   fail "Boom!"
    # rescue => exception
    #   Google::Cloud::ErrorReporting.report exception
    # end
    # ```
    #
    # See the [Instrumentation
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/instrumentation)
    # for more examples.
    #
    module ErrorReporting
      ##
      # @private The default Google::Cloud::ErrorReporting::Project client used
      # for the Google::Cloud::ErrorReporting.report API.
      @@default_client = nil

      ##
      # Creates a new object for connecting to the Stackdriver Error Reporting
      # service. Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Google Cloud Platform project identifier for
      #   the Stackdriver Error Reporting service you are connecting to. If not
      #   present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {ErrorReporting::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      #
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::ErrorReporting::Project]
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #   # ...
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || ErrorReporting::Project.default_project_id)
        project_id = project_id.to_s
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = ErrorReporting::Credentials.new credentials,
                                                        scope: scope
        end

        ErrorReporting::Project.new(
          ErrorReporting::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Configure the default {Google::Cloud::ErrorReporting::Project}
      # client, allows the {.report} public method to reuse these
      # configured parameters.
      #
      # The following Stackdriver ErrorReporting configuration parameters are
      # supported:
      #
      # * `project_id` - (String)  Google Cloud Platform project identifier for
      #   the Stackdriver Error Reporting service you are connecting to. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {ErrorReporting::Credentials})
      #   (The parameter `keyfile` is considered deprecated, but may also be
      #   used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `service_name` - (String) Name for the application.
      # * `service_version` - (String) Version identifier for the application.
      # * `ignore_classes` - (Array<Exception>) Array of exception types that
      #   should not be reported.
      #
      # See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
      # for full configuration parameters.
      #
      # @example
      #   # in app.rb
      #   require "google/cloud/error_reporting"
      #
      #   Google::Cloud::ErrorReporting.configure do |config|
      #     config.project_id = "my-project"
      #     config.credentials = "/path/to/keyfile.json"
      #     config.service_name = "my-service"
      #     config.service_version = "v8"
      #   end
      #
      #   begin
      #     fail "boom"
      #   rescue => exception
      #     # Report exception using configuration parameters provided above
      #     Google::Cloud::ErrorReporting.report exception
      #   end
      #
      # @return [Google::Cloud::Config] The configuration object
      #   the Google::Cloud::ErrorReporting module uses.
      #
      def self.configure
        yield Google::Cloud.configure.error_reporting if block_given?

        Google::Cloud.configure.error_reporting
      end

      ##
      # Provides an easy-to-use interface to Report a Ruby exception object to
      # Stackdriver ErrorReporting service. This method helps users to
      # transform the Ruby exception into an Stackdriver ErrorReporting
      # ErrorEvent gRPC structure, so users don't need to. This should be the
      # prefered method to use when users wish to report captured exception in
      # applications.
      #
      # This public method creates a default Stackdriver ErrorReporting client
      # and reuse that between calls. The default client is initialized with
      # parameters defined in {.configure}.
      #
      # The error event can be customized before reporting. See the example
      # below and {Google::Cloud::ErrorReporting::ErrorEvent} class for avaiable
      # error event fields.
      #
      # @example Basic usage
      #   # in app.rb
      #   require "google/cloud/error_reporting"
      #
      #   begin
      #     fail "boom"
      #   rescue => exception
      #     # Report exception using configuration parameters provided above
      #     Google::Cloud::ErrorReporting.report exception
      #   end
      #
      # @example The error event can be customized if needed
      #   require "google/cloud/error_reporting"
      #
      #   begin
      #     fail "boom"
      #   rescue => exception
      #     Google::Cloud::ErrorReporting.report exception do |error_event|
      #       error_event.user = "johndoh@example.com"
      #       error_event.http_status = "502"
      #     end
      #   end
      #
      # @param [Exception] exception The captured Ruby Exception object
      # @param [String] service_name An identifier for running service.
      #   Optional.
      # @param [String] service_version A version identifier for running
      #   service.
      #
      def self.report exception, service_name: nil, service_version: nil
        return if Google::Cloud.configure.use_error_reporting == false

        service_name ||= Project.default_service_name
        service_version ||= Project.default_service_version

        error_event = ErrorEvent.from_exception(exception).tap do |event|
          event.service_name = service_name
          event.service_version = service_version
        end

        yield error_event if block_given?

        default_client.report error_event
      end

      ##
      # @private Create a private client to
      def self.default_client
        unless @@default_client
          project_id = Project.default_project_id
          credentials = default_credentials

          @@default_client = AsyncErrorReporter.new(
            new(project_id: project_id, credentials: credentials)
          )
        end

        @@default_client
      end

      private_class_method :default_client

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.error_reporting.credentials ||
          Google::Cloud.configure.credentials ||
          ErrorReporting::Credentials.default(scope: scope)
      end

      private_class_method :default_credentials
    end
  end
end
