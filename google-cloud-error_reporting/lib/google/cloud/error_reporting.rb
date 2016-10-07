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

module Google
  module Cloud
    ##
    # # Stackdriver ErrorReporting
    #
    # Stackdriver Error Reporting counts, analyzes and aggregates the crashes in
    # your running cloud services. The Stackdriver Error Reporting API provides:
    # * [A simple endpoint to report errors from your running service](#report-error).
    #
    # For general information about Stackdriver Error Reporting, read
    # [Stackdriver Error Reporting Documentation]
    # (https://cloud.google.com/error-reporting/docs/).
    #
    # The goal of google-cloud-ruby is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by Google::Cloud#error_reporting.
    # You can provide the project and credential information to connect to the
    # Stackdriver Error Reporting service, or if you are running on Google Compute
    # Engine this configuration is taken care of for you. You can read more
    # about the options for connecting in the [Authentication
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
    #   gcloud = Google::Cloud.new "GCP_Project_ID", "/path/to/gcp/secretkey.json"
    #   error_reporting = gcloud.error_reporting
    #
    #   error_event = error_reporting.error_event "Error Message with Backtrace",
    #                                             timestamp: Time.now,
    #                                             service_name: "my_app_name",
    #                                             service_version: "v8",
    #                                             user: "johndoh",
    #                                             http_method: "GET",
    #                                             http_url: "http://mysite.com/index.html",
    #                                             http_status: 500,
    #                                             http_remote_ip: "127.0.0.1",
    #                                             file_path: "app/controllers/MyController.rb",
    #                                             line_number: 123,
    #                                             function_name: "index"
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
    #   error_event = error_reporting.error_event "Error Message with Backtrace",
    #                                              timestamp: Time.now,
    #                                              user: "johndoh",
    #                                              http_method: "GET",
    #                                              http_url: "http://mysite.com/index.html",
    #                                              http_status: 500,
    #                                              http_remote_ip: "127.0.0.1",
    #                                              file_path: "app/controllers/MyController.rb",
    #                                              line_number: 123,
    #                                              function_name: "index"
    #   error_reporting.report error_event
    # ```
    #
    # ## Configuring retries and timeout
    #
    # You can configure how many times API requests may be automatically
    # retried. When an API request fails, the response will be inspected to see
    # if the request meets criteria indicating that it may succeed on retry,
    # such as `500` and `503` status codes or a specific internal error code
    # such as `rateLimitExceeded`. If it meets the criteria, the request will be
    # retried after a delay. If another error occurs, the delay will be
    # increased before a subsequent attempt, until the `retries` limit is
    # reached.
    #
    # You can also set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/error_reporting"
    #
    # gcloud = Google::Cloud.new
    # error_reporting = gcloud.error_reporting retries: 10, timeout: 120
    # ```
    #
    module ErrorReporting
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
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      #
      # @return [Google::Cloud::ErrorReporting::Project]
      #
      # @example
      #   require "google/cloud/error_reporting"
      #
      #   error_reporting = Google::Cloud::ErrorReporting.new
      #   # ...
      #
      def self.new project: nil, keyfile: nil, scope: nil, retries: nil,
                   timeout: nil
        project ||= Google::Cloud::ErrorReporting::Project.default_project
        project = project.to_s
        raise ArgumentError, "project is missing" if project.empty?

        credentials =
          if keyfile.nil?
            Google::Cloud::ErrorReporting::Credentials.default scope: scope
          else
            Google::Cloud::ErrorReporting::Credentials.new keyfile, scope: scope
          end

        Google::Cloud::ErrorReporting::Project.new(
          Google::Cloud::ErrorReporting::Service.new(
            project, credentials, retries: retries, timeout: timeout
          )
        )
      end
    end
  end
end
