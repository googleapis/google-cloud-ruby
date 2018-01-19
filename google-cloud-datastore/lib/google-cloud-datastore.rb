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
# Google::Cloud.datastore and Google::Cloud#datastore methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Datastore service.
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
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. See Google::Gax::CallSettings. Optional.
    #
    # @return [Google::Cloud::Datastore::Dataset]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   datastore = gcloud.datastore
    #
    #   task = datastore.entity "Task" do |t|
    #     t["type"] = "Personal"
    #     t["done"] = false
    #     t["priority"] = 4
    #     t["description"] = "Learn Cloud Datastore"
    #   end
    #
    #   datastore.save task
    #
    # @example You shouldn't need to override the default scope, but you can:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   datastore = gcloud.datastore scope: platform_scope
    #
    def datastore scope: nil, timeout: nil, client_config: nil
      Google::Cloud.datastore @project, @keyfile,
                              scope: scope, timeout: (timeout || @timeout),
                              client_config: client_config
    end

    ##
    # Creates a new object for connecting to the Datastore service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Identifier for a Datastore project. If not
    #   present, the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Datastore::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    # @param [Hash] client_config A hash of values to override the default
    #   behavior of the API client. See Google::Gax::CallSettings. Optional.
    #
    # @return [Google::Cloud::Datastore::Dataset]
    #
    # @example
    #   require "google/cloud"
    #
    #   datastore = Google::Cloud.datastore "my-todo-project",
    #                                       "/path/to/keyfile.json"
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
    def self.datastore project_id = nil, credentials = nil, scope: nil,
                       timeout: nil, client_config: nil
      require "google/cloud/datastore"
      Google::Cloud::Datastore.new project_id: project_id,
                                   credentials: credentials,
                                   scope: scope, timeout: timeout,
                                   client_config: client_config
    end
  end
end

# Set the default bigquery configuration
Google::Cloud.configure.add_config! :datastore do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["DATASTORE_DATASET"] || ENV["DATASTORE_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "DATASTORE_CREDENTIALS", "DATASTORE_CREDENTIALS_JSON",
      "DATASTORE_KEYFILE", "DATASTORE_KEYFILE_JSON"
    )
  end
  default_emulator = Google::Cloud::Config.deferred do
    ENV["DATASTORE_EMULATOR_HOST"]
  end

  config.add_field! :project_id, default_project, match: String
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials]
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
  config.add_field! :emulator_host, default_emulator, match: String
end
