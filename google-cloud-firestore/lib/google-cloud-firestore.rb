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
# This file is here to be autorequired by bundler, so that the .firestore and
# #firestore methods can be available, but the library and all dependencies
# won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Firestore service.
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
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [String] database_id Identifier for a Firestore database. If not
    #   present, the default database of the project is used.
    # @param [:grpc,:rest] transport Which transport to use to communicate
    #   with the server. Defaults to `:grpc`.
    #
    # @return [Google::Cloud::Firestore::Client]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   firestore = gcloud.firestore
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   firestore = gcloud.firestore scope: platform_scope
    #
    # @example The default database can be overridden with the `database_id` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   database_id = "my-todo-database"
    #   firestore = gcloud.firestore database_id: database_id
    #
    def firestore scope: nil,
                  timeout: nil,
                  database_id: nil,
                  transport: nil
      transport ||= Google::Cloud.configure.firestore.transport
      timeout ||= @timeout
      Google::Cloud.firestore @project, @keyfile,
                              scope: scope,
                              timeout: timeout,
                              database_id: database_id,
                              transport: transport
    end

    ##
    # Creates a new object for connecting to the Firestore service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String] project_id Identifier for a Firestore project. If not
    #   present, the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Firestore::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [String] database_id Identifier for a Firestore database. If not
    #   present, the default database of the project is used.
    # @param [:grpc,:rest] transport Which transport to use to communicate
    #   with the server. Defaults to `:grpc`.
    #
    # @return [Google::Cloud::Firestore::Client]
    #
    # @example
    #   require "google/cloud"
    #
    #   firestore = Google::Cloud.firestore
    #
    def self.firestore project_id = nil,
                       credentials = nil,
                       scope: nil,
                       timeout: nil,
                       database_id: nil,
                       transport: nil
      require "google/cloud/firestore"
      transport ||= Google::Cloud.configure.firestore.transport
      Google::Cloud::Firestore.new project_id: project_id,
                                   credentials: credentials,
                                   scope: scope,
                                   timeout: timeout,
                                   database_id: database_id,
                                   transport: transport
    end
  end
end

# rubocop:disable Metrics/BlockLength

# Set the default firestore configuration
Google::Cloud.configure.add_config! :firestore do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["FIRESTORE_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "FIRESTORE_CREDENTIALS", "FIRESTORE_CREDENTIALS_JSON",
      "FIRESTORE_KEYFILE", "FIRESTORE_KEYFILE_JSON"
    )
  end
  default_emulator = Google::Cloud::Config.deferred do
    ENV["FIRESTORE_EMULATOR_HOST"]
  end
  default_scopes = [
    "https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/datastore"
  ]

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds, match: [String, Hash, Google::Auth::Credentials], allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, default_scopes, match: [String, Array]
  config.add_field! :quota_project, nil, match: String
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :emulator_host, default_emulator, match: String, allow_nil: true
  config.add_field! :endpoint, "firestore.googleapis.com", match: String
  config.add_field! :database_id, "(default)", match: String
  config.add_field! :transport, :grpc, match: Symbol
end

# rubocop:enable Metrics/BlockLength
