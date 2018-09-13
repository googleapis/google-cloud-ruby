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
    # Creates a new object for connecting to the Bigtable service.
    #
    # For more information on connecting to Google Cloud see the
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
    # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
    #   Provides the means for authenticating requests made by the client. This parameter can
    #   be many types.
    #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
    #   authenticating requests made by this client.
    #   A `String` will be treated as the path to the keyfile to be used for the construction of
    #   credentials for this client.
    #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
    #   credentials for this client.
    #   A `GRPC::Core::Channel` will be used to make calls through.
    #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
    #   should already be composed with a `GRPC::Core::CallCredentials` object.
    #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
    #   metadata for requests, generally, to give OAuth credentials.
    # @param client_config [Hash]
    #   A Hash for call options for each method.
    #   See Google::Gax#construct_settings for the structure of
    #   this data. Falls back to the default config if not specified
    #   or the specified config is missing data points.
    # @return [Google::Cloud::Bigtable::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #
    #   bigtable = gcloud.bigtable
    #

    def bigtable scope: nil, timeout: nil, credentials: nil, client_config: nil
      Google::Cloud.bigtable(
        project_id: @project,
        credentials: (credentials || @keyfile),
        scope: scope,
        timeout: (timeout || @timeout),
        client_config: client_config
      )
    end

    # Create bigtable client instance for data, table admin and instance admin
    # operartions.
    #
    # @param project_id [String]
    #   Project identifier for the Bigtable service you
    #   are connecting to. If not present, the default project for the
    #   credentials is used.
    # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
    #   Provides the means for authenticating requests made by the client. This parameter can
    #   be many types.
    #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
    #   authenticating requests made by this client.
    #   A `String` will be treated as the path to the keyfile to be used for the construction of
    #   credentials for this client.
    #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
    #   credentials for this client.
    #   A `GRPC::Core::Channel` will be used to make calls through.
    #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
    #   should already be composed with a `GRPC::Core::CallCredentials` object.
    #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
    #   metadata for requests, generally, to give OAuth credentials.
    # @param scope [Array<String>]
    #   The OAuth 2.0 scopes controlling the set of resources and operations
    #   that the connection can access. See [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #   The OAuth scopes for this service. This parameter is ignored if an
    #   updater_proc is supplied.
    # @param timeout [Integer]
    #   The default timeout, in seconds, for calls made through this client.
    # @param client_config [Hash]
    #   A Hash for call options for each method.
    #   See Google::Gax#construct_settings for the structure of
    #   this data. Falls back to the default config if not specified
    #   or the specified config is missing data points. Optional.
    # @return [Google::Cloud::Bigtable::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   bigtable = Google::Cloud.bigtable

    def self.bigtable \
        project_id: nil,
        credentials: nil,
        scope: nil,
        timeout: nil,
        client_config: nil
      require "google/cloud/bigtable"
      Google::Cloud::Bigtable.new(
        project_id: project_id,
        credentials: credentials,
        scope: scope,
        timeout: timeout,
        client_config: client_config
      )
    end
  end
end

# Set the default BIGTABLE configuration
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

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [
                      String,
                      Hash,
                      Google::Auth::Credentials,
                      GRPC::Core::Channel,
                      GRPC::Core::ChannelCredentials,
                      Proc
                    ],
                    allow_nil: true
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
end
