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
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
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
    #   error_event = error_reporting.error_event "Error Message with Backtrace",
    #                                             timestamp: Time.now,
    #                                             service_name: "my_app_name",
    #                                             service_version: "v8"
    #   error_reporting.report error_event
    #
    def error_reporting scope: nil, retries: nil, timeout: nil
      Google::Cloud.error_reporting @project, @keyfile,
                                    scope: scope,
                                    retries: (retries || @retries),
                                    timeout: (timeout || @timeout)
    end


    ##
    # Create a new object for connecting to the Stackdriver Error Reporting
    # service. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication)
    #
    # @param [String] project Google Cloud Platform project id.
    #   Use Project.default_project if not given.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
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
    #   gcloud = Google::Cloud.error_reporting "GCP_Project_ID",
    #                                          "/path/to/gcp/secretkey.json"
    #
    #   error_event = error_reporting.error_event "Error Message with Backtrace",
    #                                             timestamp: Time.now,
    #                                             service_name: "my_app_name",
    #                                             service_version: "v8"
    #   error_reporting.report error_event
    #
    def self.error_reporting project = nil, keyfile = nil, scope: nil,
                             retries: nil, timeout: nil
      require "google/cloud/error_reporting"
      Google::Cloud::ErrorReporting.new project: project, keyfile: keyfile,
                                        scope: scope, retries: retries,
                                        timeout: timeout
    end
  end
end
