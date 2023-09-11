# Copyright 2016 Google LLC
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
# This file is here to be autorequired by bundler, so that the
# Google::Cloud.bigquery and Google::Cloud#bigquery methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the BigQuery service.
    # Each call creates a new connection.
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
    #   * `https://www.googleapis.com/auth/bigquery`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `5`. Optional.
    # @param [Integer] timeout Default request timeout in seconds. Optional.
    #
    # @return [Google::Cloud::Bigquery::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   bigquery = gcloud.bigquery
    #   dataset = bigquery.dataset "my_dataset"
    #   table = dataset.table "my_table"
    #
    #   data = table.data
    #
    #   # Iterate over the first page of results
    #   data.each do |row|
    #     puts row[:name]
    #   end
    #   # Retrieve the next page of results
    #   data = data.next if data.next?
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   bigquery = gcloud.bigquery scope: platform_scope
    #
    def bigquery scope: nil, retries: nil, timeout: nil
      Google::Cloud.bigquery @project, @keyfile, scope:   scope,
                                                 retries: (retries || @retries),
                                                 timeout: (timeout || @timeout)
    end

    ##
    # Creates a new `Project` instance connected to the BigQuery service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String] project_id Identifier for a BigQuery project. If not
    #   present, the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Bigquery::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/bigquery`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `5`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Bigquery::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   bigquery = Google::Cloud.bigquery
    #   dataset = bigquery.dataset "my_dataset"
    #   table = dataset.table "my_table"
    #
    def self.bigquery project_id = nil, credentials = nil, scope: nil, retries: nil, timeout: nil
      require "google/cloud/bigquery"
      Google::Cloud::Bigquery.new project_id: project_id, credentials: credentials,
                                  scope: scope, retries: retries, timeout: timeout
    end
  end
end

# Set the default bigquery configuration
Google::Cloud.configure.add_config! :bigquery do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["BIGQUERY_PROJECT"]
  end
  default_endpoint = Google::Cloud::Config.deferred do
    ENV["BIGQUERY_EMULATOR_HOST"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "BIGQUERY_CREDENTIALS", "BIGQUERY_CREDENTIALS_JSON", "BIGQUERY_KEYFILE", "BIGQUERY_KEYFILE_JSON"
    )
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds, match: [String, Hash, Google::Auth::Credentials], allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :quota_project, nil, match: String
  config.add_field! :retries, nil, match: Integer
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :endpoint, default_endpoint, match: String, allow_nil: true
end
