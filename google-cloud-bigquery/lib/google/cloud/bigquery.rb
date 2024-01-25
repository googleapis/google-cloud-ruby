# Copyright 2015 Google LLC
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


require "google-cloud-bigquery"
require "google/cloud/bigquery/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud BigQuery
    #
    # Google BigQuery enables super-fast, SQL-like queries against massive
    # datasets, using the processing power of Google's infrastructure.
    #
    # See {file:OVERVIEW.md BigQuery Overview}.
    #
    module Bigquery
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
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See # [Using OAuth 2.0 to Access Google #
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/bigquery`
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `5`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Bigquery::Project]
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, endpoint: nil,
                   project: nil, keyfile: nil, universe_domain: nil
        scope       ||= configure.scope
        retries     ||= configure.retries
        timeout     ||= configure.timeout
        endpoint    ||= configure.endpoint
        credentials ||= (keyfile || default_credentials(scope: scope))
        universe_domain ||= configure.universe_domain

        unless credentials.is_a? Google::Auth::Credentials
          credentials = Bigquery::Credentials.new credentials, scope: scope
        end

        project_id = resolve_project_id(project_id || project, credentials)
        raise ArgumentError, "project_id is missing" if project_id.empty?

        Bigquery::Project.new(
          Bigquery::Service.new(
            project_id, credentials,
            retries: retries, timeout: timeout, host: endpoint,
            quota_project: configure.quota_project, universe_domain: universe_domain
          )
        )
      end

      ##
      # Configure the Google Cloud BigQuery library.
      #
      # The following BigQuery configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a BigQuery project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Bigquery::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Bigquery library uses.
      #
      def self.configure
        yield Google::Cloud.configure.bigquery if block_given?

        Google::Cloud.configure.bigquery
      end

      ##
      # @private Resolve project.
      def self.resolve_project_id given_project, credentials
        project_id = given_project || default_project_id
        project_id ||= credentials.project_id if credentials.respond_to? :project_id
        project_id.to_s # Always cast to a string
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.bigquery.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.bigquery.credentials ||
          Google::Cloud.configure.credentials ||
          Bigquery::Credentials.default(scope: scope)
      end
    end
  end
end
