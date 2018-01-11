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

##
# This file is here to be autorequired by bundler


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Create a new object for connecting to the Stackdriver Error Reporting
    # service. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication)
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::ErrorReporting::Project]
    #
    # @example
    #   require "google/cloud/error_reporting"
    #
    #   gcloud = Google::Cloud.new "GCP_Project_ID",
    #                              "/path/to/gcp/secretkey.json"
    #   error_reporting = gcloud.error_reporting
    #
    #   error_event = error_reporting.error_event "Error with Backtrace",
    #                                             event_time: Time.now,
    #                                             service_name: "my_app_name",
    #                                             service_version: "v8"
    #   error_reporting.report error_event
    #
    def error_reporting scope: nil, timeout: nil, client_config: nil
      Google::Cloud.error_reporting @project, @keyfile,
                                    scope: scope,
                                    timeout: (timeout || @timeout),
                                    client_config: client_config
    end

    ##
    # Create a new object for connecting to the Stackdriver Error Reporting
    # service. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication)
    #
    # @param [String] project_id Google Cloud Platform project identifier for
    #   the Stackdriver Error Reporting service you are connecting to. If not
    #   present, the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {ErrorReporting::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection  can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. Optional.
    #
    # @return [Google::Cloud::ErrorReporting::Project]
    #
    # @example
    #   require "google/cloud/error_reporting"
    #
    #   error_reporting =
    #     Google::Cloud.error_reporting "GCP_Project_ID",
    #                                   "/path/to/gcp/secretkey.json"
    #
    #   error_event = error_reporting.error_event "Error with Backtrace",
    #                                             event_time: Time.now,
    #                                             service_name: "my_app_name",
    #                                             service_version: "v8"
    #   error_reporting.report error_event
    #
    def self.error_reporting project_id = nil, credentials = nil, scope: nil,
                             timeout: nil, client_config: nil
      require "google/cloud/error_reporting"
      Google::Cloud::ErrorReporting.new project_id: project_id,
                                        credentials: credentials,
                                        scope: scope, timeout: timeout,
                                        client_config: client_config
    end
  end
end
