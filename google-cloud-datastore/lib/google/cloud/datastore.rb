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
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. See Google::Gax::CallSettings. Optional.
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
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, emulator_host: nil, project: nil,
                   keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        emulator_host ||= configure.emulator_host
        if emulator_host
          return Datastore::Dataset.new(
            Datastore::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host, client_config: client_config
            )
          )
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Datastore::Credentials.new credentials, scope: scope
        end

        Datastore::Dataset.new(
          Datastore::Service.new(
            project_id, credentials,
            timeout: timeout, client_config: client_config
          )
        )
      end

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
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
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
end
