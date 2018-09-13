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
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Create a new object for connecting to the Stackdriver Error Reporting
    # service. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
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
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
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

# Add error reporting to top-level configuration
Google::Cloud.configure do |config|
  unless config.field? :use_error_reporting
    config.add_field! :use_error_reporting, nil, enum: [true, false]
  end
  unless config.field? :service_name
    config.add_field! :service_name, nil, match: String
  end
  unless config.field? :service_version
    config.add_field! :service_version, nil, match: String
  end
end

# Set the default error reporting configuration
Google::Cloud.configure.add_config! :error_reporting do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["ERROR_REPORTING_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "ERROR_REPORTING_CREDENTIALS", "ERROR_REPORTING_CREDENTIALS_JSON",
      "ERROR_REPORTING_KEYFILE", "ERROR_REPORTING_KEYFILE_JSON"
    )
  end
  default_service = Google::Cloud::Config.deferred do
    ENV["ERROR_REPORTING_SERVICE"]
  end
  default_version = Google::Cloud::Config.deferred do
    ENV["ERROR_REPORTING_VERSION"]
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
  config.add_field! :service_name, default_service,
                    match: String, allow_nil: true
  config.add_field! :service_version, default_version,
                    match: String, allow_nil: true
  config.add_field! :ignore_classes, nil, match: Array
end
