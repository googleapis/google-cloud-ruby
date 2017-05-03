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


require "google-cloud-error_reporting"
require "google/cloud/error_reporting/project"
require "google/cloud/error_reporting/middleware"
require "stackdriver/core"

module Google
  module Cloud
    ##
    # # Stackdriver ErrorReporting
    #
    # Stackdriver Error Reporting counts, analyzes and aggregates the crashes in
    # your running cloud services. The Stackdriver Error Reporting API provides:
    # * [A simple endpoint to report errors from your application](
    # #report-error).
    #
    # For general information about Stackdriver Error Reporting, read
    # [Stackdriver Error Reporting Documentation]
    # (https://cloud.google.com/error-reporting/docs/).
    #
    # The goal of google-cloud-ruby is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by Google::Cloud#error_reporting.
    # You can provide the project and credential information to connect to the
    # Stackdriver Error Reporting service, or if you are running on Google
    # Compute Engine this configuration is taken care of for you. You can read
    # more about the options for connecting in the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ## Report Error
    #
    # Create a Google::Cloud object and a
    # {Google::Cloud::ErrorReporting::Project} object help provide
    # authentication and GCP project context information. Then A
    # {Google::Cloud::ErrorReporting::ErrorEvent} can be instantiated on top of
    # the Google::Cloud::ErrorReporting::Project object, which represents an
    # error event and describes the error's content and context.
    # ```ruby
    #   require "google/cloud/error_reporting"
    #
    #   error_reporting = Google::Cloud::ErrorReporting.new
    #
    #   error_event =
    #     error_reporting.error_event "Error with Backtrace",
    #                                 timestamp: Time.now,
    #                                 service_name: "my_app_name",
    #                                 service_version: "v8",
    #                                 user: "johndoh",
    #                                 file_path: "controllers/MyController.rb",
    #                                 line_number: 123,
    #                                 function_name: "index"
    #   error_reporting.report error_event
    # ```
    #
    # If running from withint Google Compute Engine, or have corresponding
    # environment variables (see {Google::Cloud::ErrorReporting::Project})
    # defined, the instantiation process can be simplified to:
    # ```ruby
    #   require "google/cloud/error_reporting"
    #
    #   error_reporting = Google::Cloud.error_reporting
    #
    #   error_event =
    #     error_reporting.error_event "Error with Backtrace",
    #                                 timestamp: Time.now,
    #                                 service_name: "my_app_name",
    #                                 service_version: "v8",
    #                                 user: "johndoh",
    #                                 file_path: "controllers/MyController.rb",
    #                                 line_number: 123,
    #                                 function_name: "index"
    #   error_reporting.report error_event
    # ```
    #
    # ## Configuring timeout
    #
    # You can set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/error_reporting"
    #
    # gcloud = Google::Cloud.new
    # error_reporting = gcloud.error_reporting timeout: 120
    # ```
    #
    module ErrorReporting
      ##
      # @private Instrumentation library configuration options
      CONFIG_OPTIONS = %I{
        project_id
        keyfile
        service_name
        service_version
      }

      ##
      # Creates a new object for connecting to the Stackdriver Error Reporting
      # service. Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project Project identifier for the Stackdriver Error
      #   Reporting service.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
      #   file path the file must be readable.
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
      #
      # @return [Google::Cloud::ErrorReporting::Project]
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #   # ...
      #
      def self.new project: nil, keyfile: nil, scope: nil, timeout: nil,
                   client_config: nil
        project ||= Google::Cloud::ErrorReporting::Project.default_project
        project = project.to_s
        fail ArgumentError, "project is missing" if project.empty?

        credentials =
          Google::Cloud::ErrorReporting::Credentials.credentials_with_scope(
            keyfile, scope)

        Google::Cloud::ErrorReporting::Project.new(
          Google::Cloud::ErrorReporting::Service.new(
            project, credentials, timeout: timeout, client_config: client_config
          )
        )
      end

      ##
      # Configure the default Google::Cloud::ErrorReporting client, allow the
      # Google::Cloud::ErrorReporting.report public method to reuse these
      # configured parameters.
      #
      # Possible configuration parameters:
      #   * project_id: The Google Cloud Project ID. Automatically discovered
      #                 when running from GCP environments.
      #   * keyfile: The service account JSON file path. Automatically
      #              discovered when running from GCP environments.
      #   * service_name: An identifier for the running service. Optional,
      #              automatically discovered when running from Google App
      #              Engine Flex. Otherwise default to "ruby".
      #   * service_version: A version identifier for the running service.
      #                      Optional, automatically discovered when running
      #                      from Google App Engine Flex.
      #
      # Note the project_id and keyfile configuration changes won't be picked up
      # after the first Google::Cloud::ErrorReporting.report call.
      #
      # @example
      #   # in app.rb
      #   Google::Cloud::ErrorReporting.configure do |config|
      #     config.project_id = "my-project-id"
      #     config.keyfile = "/path/to/keyfile.json"
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
      # @return [Stackdriver::Core::Configuration] The configuration object
      #   the Google::Cloud::ErrorReporting module uses.
      #
      def self.configure
        # Initialize :error_reporting as a nested Configuration under
        # Google::Cloud if haven't already
        unless Google::Cloud.configure.option? :error_reporting
          Google::Cloud.configure.add_options [{
            error_reporting: CONFIG_OPTIONS
          }]
        end

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
      # parameters defined in {Google::Cloud::ErrorReporting.configure}.
      #
      # The error event can be customized before reporting. See the example
      # below and {Google::Cloud::ErrorReporting::ErrorEvent} class for avaiable
      # error event fields.
      #
      # @example Basic usage
      #   # in app.rb
      #   Google::Cloud::ErrorReporting.configure do |config|
      #     config.project_id = "my-project-id"
      #     config.keyfile = "/path/to/keyfile.json"
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
      # @example The error event can be customized if needed
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
      def self.report exception, service_name: nil, service_version: nil, &block
        return if Google::Cloud.configure.use_error_reporting == false

        unless defined? @@default_client
          project_id = configure.project_id
          keyfile = configure.keyfile

          @@default_client = new project: project_id, keyfile: keyfile
        end

        service_name ||= configure.service_name
        service_version ||= configure.service_version

        @@default_client.report_exception exception,
                                          service_name: service_name,
                                          service_version: service_version,
                                          &block
      end
    end
  end
end
