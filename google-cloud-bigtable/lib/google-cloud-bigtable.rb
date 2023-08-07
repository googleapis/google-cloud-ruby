# Copyright 2018 Google LLC
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


# This file is here to be autorequired by bundler, so that the
# Google::Cloud#bigtable method can be available,
# but the library and all dependencies won't be loaded until required and used.

gem "google-cloud-core"

require "googleauth"
require "grpc"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Cloud Bigtable service.
    #
    # For more information on connecting to Google Cloud Platform, see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param scope [Array<String>]
    #   The OAuth 2.0 scopes controlling the set of resources and operations
    #   that the connection can access. See [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #   The OAuth scopes for this service. This parameter is ignored if an
    #   updater_proc is supplied.
    # @param timeout [Integer]
    #   The default timeout, in seconds, for calls made through this client.
    # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel,
    #   GRPC::Core::ChannelCredentials, Proc]
    #   Provides the means for authenticating requests made by the client. This parameter can
    #   be one of the following types.
    #   `Google::Auth::Credentials` uses the properties of its represented keyfile for
    #   authenticating requests made by this client.
    #   `String` will be treated as the path to the keyfile to use to construct
    #   credentials for this client.
    #   `Hash` will be treated as the contents of a keyfile to use to construct
    #   credentials for this client.
    #   `GRPC::Core::Channel` will be used to make calls through.
    #   `GRPC::Core::ChannelCredentials` will be used to set up the gRPC client. The channel credentials
    #   should already be composed with a `GRPC::Core::CallCredentials` object.
    #   `Proc` will be used as an updater_proc for the gRPC channel. The proc transforms the
    #   metadata for requests, generally, to give OAuth credentials.
    # @return [Google::Cloud::Bigtable::Project]
    #
    # @example
    #   require "google/cloud/bigtable"
    #
    #   gcloud  = Google::Cloud.new
    #
    #   bigtable = gcloud.bigtable
    #
    def bigtable scope: nil, timeout: nil, credentials: nil
      Google::Cloud.bigtable(
        project_id:  @project,
        credentials: (credentials || @keyfile),
        scope:       scope,
        timeout:     (timeout || @timeout)
      )
    end

    ##
    # Creates a Cloud Bigtable client instance for data, table admin and instance admin
    # operations.
    #
    # @param project_id [String]
    #   Project identifier for the Bigtable service you
    #   are connecting to. If not present, the default project for the
    #   credentials is used.
    # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel,
    #   GRPC::Core::ChannelCredentials, Proc]
    #   The means for authenticating requests made by the client. This parameter can
    #   be one of the following types.
    #   `Google::Auth::Credentials` uses the properties of its represented keyfile for
    #   authenticating requests made by this client.
    #   `String` will be treated as the path to the keyfile to use to construct
    #   credentials for this client.
    #   `Hash` will be treated as the contents of a keyfile to use to construct
    #   credentials for this client.
    #   `GRPC::Core::Channel` will be used to make calls through.
    #   `GRPC::Core::ChannelCredentials` will be used to set up the gRPC client. The channel credentials
    #   should already be composed with a `GRPC::Core::CallCredentials` object.
    #   `Proc` will be used as an updater_proc for the gRPC channel. The proc transforms the
    #   metadata for requests, generally, to give OAuth credentials.
    # @param scope [Array<String>]
    #   The OAuth 2.0 scopes controlling the set of resources and operations
    #   that the connection can access. See [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #   The OAuth scopes for this service. This parameter is ignored if an
    #   updater_proc is supplied.
    # @param timeout [Integer]
    #   The default timeout, in seconds, for calls made through this client.
    # @return [Google::Cloud::Bigtable::Project]
    #
    # @example
    #   require "google/cloud/bigtable"
    #
    #   bigtable = Google::Cloud.bigtable
    #
    def self.bigtable project_id: nil, credentials: nil, scope: nil, timeout: nil
      require "google/cloud/bigtable"
      Google::Cloud::Bigtable.new(
        project_id:  project_id,
        credentials: credentials,
        scope:       scope,
        timeout:     timeout
      )
    end
  end
end

# Sets the default Bigtable configuration
Google::Cloud.configure.add_config! :bigtable do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["BIGTABLE_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "BIGTABLE_CREDENTIALS", "BIGTABLE_CREDENTIALS_JSON",
      "BIGTABLE_KEYFILE", "BIGTABLE_KEYFILE_JSON"
    )
  end
  default_emulator = Google::Cloud::Config.deferred do
    ENV["BIGTABLE_EMULATOR_HOST"]
  end
  default_scopes = [
    "https://www.googleapis.com/auth/bigtable.admin",
    "https://www.googleapis.com/auth/bigtable.admin.cluster",
    "https://www.googleapis.com/auth/bigtable.admin.instance",
    "https://www.googleapis.com/auth/bigtable.admin.table",
    "https://www.googleapis.com/auth/bigtable.data",
    "https://www.googleapis.com/auth/bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-bigtable.admin",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.table",
    "https://www.googleapis.com/auth/cloud-bigtable.data",
    "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/cloud-platform.read-only"
  ]

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match:     [
                      String,
                      Hash,
                      Google::Auth::Credentials,
                      GRPC::Core::Channel,
                      GRPC::Core::ChannelCredentials,
                      Proc
                    ],
                    allow_nil: true
  config.add_field! :scope, default_scopes, match: [String, Array]
  config.add_field! :quota_project, nil, match: String
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :emulator_host, default_emulator, match: String, allow_nil: true
  config.add_field! :endpoint, "bigtable.googleapis.com", match: String
  config.add_field! :endpoint_admin, "bigtableadmin.googleapis.com", match: String
  config.add_field! :channel_selection, :least_loaded, match: Symbol
  config.add_field! :channel_count, 1, match: Integer
end
