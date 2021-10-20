# Copyright 2014 Google LLC
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


require "google-cloud-datastore"
require "google/cloud/datastore/errors"
require "google/cloud/datastore/dataset"
require "google/cloud/datastore/transaction"
require "google/cloud/datastore/credentials"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Datastore
    #
    # Google Cloud Datastore is a fully managed, schemaless database for storing
    # non-relational data. You should feel at home if you are familiar with
    # relational databases, but there are some key differences to be aware of to
    # make the most of using Datastore.
    #
    # See {file:OVERVIEW.md Datastore Overview}.
    #
    # @example
    #   require "google/cloud/datastore"
    #
    #   datastore = Google::Cloud::Datastore.new(
    #     project_id: "my-todo-project",
    #     credentials: "/path/to/keyfile.json"
    #   )
    #
    #   task = datastore.find "Task", "sampleTask"
    #   task["priority"] = 5
    #   datastore.save task
    #
    module Datastore
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength

      ##
      # Creates a new object for connecting to the Datastore service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Identifier for a Datastore project. If not
      #   present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Datastore::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/datastore`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] emulator_host Datastore emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Datastore::Dataset]
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new(
      #     project_id: "my-todo-project",
      #     credentials: "/path/to/keyfile.json"
      #   )
      #
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   datastore.save task
      #
      def self.new project_id: nil,
                   credentials: nil,
                   scope: nil,
                   timeout: nil,
                   endpoint: nil,
                   emulator_host: nil,
                   project: nil,
                   keyfile: nil
        project_id    ||= (project || default_project_id)
        scope         ||= configure.scope
        timeout       ||= configure.timeout
        endpoint      ||= configure.endpoint
        emulator_host ||= configure.emulator_host

        if emulator_host
          project_id = project_id.to_s # Always cast to a string
          raise ArgumentError, "project_id is missing" if project_id.empty?

          return Datastore::Dataset.new(
            Datastore::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host, timeout: timeout
            )
          )
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Datastore::Credentials.new credentials, scope: scope
        end

        if credentials.respond_to? :project_id
          project_id ||= credentials.project_id
        end
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        Datastore::Dataset.new(
          Datastore::Service.new(
            project_id, credentials,
            host: endpoint, timeout: timeout
          )
        )
      end

      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      ##
      # Configure the Google Cloud Datastore library.
      #
      # The following Datastore configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Datastore project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Datastore::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["DATASTORE_EMULATOR_HOST"]`
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Datastore library uses.
      #
      def self.configure
        yield Google::Cloud.configure.datastore if block_given?

        Google::Cloud.configure.datastore
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.datastore.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.datastore.credentials ||
          Google::Cloud.configure.credentials ||
          Datastore::Credentials.default(scope: scope)
      end
    end
  end
  ## Legacy generated client namespace
  Datastore = Cloud::Datastore unless const_defined? :Datastore
end
