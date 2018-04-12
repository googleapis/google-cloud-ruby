# frozen_string_literal: true

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

require "google/cloud"
require "google/cloud/config"

module Google
  module Cloud
    # Create bigtable client instance for data, table admin and instance admin
    # operartions.
    #
    # @param client_type [Symbol]
    #   Client type are
    #   `:data` - data operartions(read rows, update cells etc)
    #   `:table` - table admin operartions(create, delete, update, list etc)
    #   `:instance` - instance admin operartions(create, delete, update, list etc)
    #   Default client type is `:data`.
    # @param instance_id [String]
    #   Bigtable instance identifier
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
    # @param scopes [Array<String>]
    #   The OAuth scopes for this service. This parameter is ignored if an
    #   updater_proc is supplied.
    # @param client_config [Hash]
    #   A Hash for call options for each method.
    #   See Google::Gax#construct_settings for the structure of
    #   this data. Falls back to the default config if not specified
    #   or the specified config is missing data points.
    # @param timeout [Integer]
    #   The default timeout, in seconds, for calls made through this client.
    # @return [Google::Cloud::Bigtable::InstanceAdminClient | Google::Cloud::Bigtable::TableAdminClient | Google::Cloud::Bigtable::DataClient]
    #
    # @example Create instance admin client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   instance_admin_client = gcloud.bigtable(client_type: :instance)
    #
    # @example Create table admin client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #
    #   table_admin_client = gcloud.bigtable(
    #     client_type: :table,
    #     instance_id: "instance-id"
    #   )
    #
    # @example Create table data operations client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #
    #   data_client = gcloud.bigtable(
    #     client_type: :data,
    #     instance_id: "instance-id"
    #   )

    def bigtable \
        client_type: :data,
        instance_id: nil,
        credentials: nil,
        scopes: nil,
        client_config: nil,
        timeout: nil
      Google::Cloud.bigtable(
        project_id: @project,
        instance_id: instance_id,
        client_type: client_type,
        credentials: (credentials || @keyfile),
        scopes: scopes,
        client_config: client_config,
        timeout: (timeout || @timeout)
      )
    end

    # Create bigtable client instance for data, table admin and instance admin
    # operartions.
    #
    # @param project_id [String]
    #   Project identifier for bigtable
    # @param client_type [Symbol]
    #   Client type are
    #   `:data` - data operartions(read rows, update cells etc)
    #   `:table` - table admin operartions(create, delete, update, list etc)
    #   `:instance` - instance admin operartions(create, delete, update, list etc)
    #   Default client type is `:data`.
    # @param instance_id [String]
    #   Bigtable instance identifier
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
    # @param scopes [Array<String>]
    #   The OAuth scopes for this service. This parameter is ignored if an
    #   updater_proc is supplied.
    # @param client_config [Hash]
    #   A Hash for call options for each method.
    #   See Google::Gax#construct_settings for the structure of
    #   this data. Falls back to the default config if not specified
    #   or the specified config is missing data points.
    # @param timeout [Integer]
    #   The default timeout, in seconds, for calls made through this client.
    # @return [Google::Cloud::Bigtable::InstanceAdminClient | Google::Cloud::Bigtable::TableAdminClient | Google::Cloud::Bigtable::DataClient]
    #
    # @example Create instance admin client
    #   require "google/cloud"
    #
    #   instance_admin_client = Google::Cloud.bigtable(client_type: :instance)
    #
    # @example Create table admin client
    #   require "google/cloud"
    #
    #   table_admin_client = Google::Cloud.bigtable(
    #     client_type: :table,
    #     instance_id: "instance-id"
    #   )
    #
    # @example Create table data operations client
    #   require "google/cloud"
    #
    #   data_client = Google::Cloud.bigtable(instance_id: "instance-id")

    def self.bigtable \
        project_id: nil,
        client_type: :data,
        instance_id: nil,
        credentials: nil,
        scopes: nil,
        client_config: nil,
        timeout: nil
      require "google/cloud/bigtable"
      Google::Cloud::Bigtable.new(
        project_id: project_id,
        client_type: client_type,
        instance_id: instance_id,
        credentials: credentials,
        scopes: scopes,
        client_config: client_config,
        timeout: timeout
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
  config.add_field! :scopes, nil, match: [String, Array]
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :client_config, nil, match: Hash
end
