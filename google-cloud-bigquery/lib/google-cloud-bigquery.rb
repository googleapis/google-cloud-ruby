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
# This file is here to be autorequired by bundler, so that the .bigquery and
# #bigquery methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the BigQuery service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
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
    #   table.data.each do |row|
    #     puts row
    #   end
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   bigquery = gcloud.bigquery scope: platform_scope
    #
    def bigquery scope: nil, retries: nil, timeout: nil
      Google::Cloud.bigquery @project, @keyfile, scope: scope,
                                                 retries: (retries || @retries),
                                                 timeout: (timeout || @timeout)
    end

    ##
    # Creates a new `Project` instance connected to the BigQuery service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project Identifier for a BigQuery project. If not present,
    #   the default project for the credentials is used.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
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
    def self.bigquery project = nil, keyfile = nil, scope: nil, retries: nil,
                      timeout: nil
      require "google/cloud/bigquery"
      Google::Cloud::Bigquery.new project: project, keyfile: keyfile,
                                  scope: scope, retries: retries,
                                  timeout: timeout
    end
  end
end
