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

#
# This file is here to be autorequired by bundler, so that the
# Google::Cloud#bigtable method can be available,
# but the library and all dependencies won't be loaded until required and used.

require "google/cloud"
require "google/cloud/errors"

module Google
  module Cloud
    # Create bigtable client instance for data, table admin and instance admin
    # operartions.
    #
    # @param instance_id [String]
    #   Bigtable instance identifier
    # @param client_type [Symbol]
    #   Client type are
    #   `:data` - data operartions(read rows, update cells etc)
    #   `:table` - table admin operartions(create, delete, update, list etc)
    #   `:instance` - instance admin operartions(create, delete, update, list etc)
    #   Default client type is `:data`.
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
    # @return [InstanceAdminClient | TableAdminClient | DataClient]
    #
    # @example Create instance admin client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new("project-id")
    #
    #   # With keyfile
    #   gcloud  = Google::Cloud.new("project-id", "keyfile.json")
    #
    #   instance_admin_client = gcloud.bigtable(client_type: :instance)
    #
    # @example Create table admin client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new("project-id")
    #
    #   # With keyfile
    #   gcloud  = Google::Cloud.new("project-id", "keyfile.json")
    #
    #   table_admin_client = gcloud.bigtable(
    #     instance_id: "instance-id",
    #     client_type: :table
    #   )
    #
    # @example Create table data operations client
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new("project-id")
    #
    #   # With keyfile
    #   gcloud  = Google::Cloud.new("project-id", "keyfile.json")
    #
    #   data_client = gcloud.bigtable(
    #     instance_id: "instance-id",
    #     client_type: :data
    #   )

    def bigtable \
        instance_id: nil,
        credentials: nil,
        client_type: :data,
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
    # @param instance_id [String]
    #   Bigtable instance identifier
    # @param client_type [Symbol]
    #   Client type are
    #   `:data` - data operartions(read rows, update cells etc)
    #   `:table` - table admin operartions(create, delete, update, list etc)
    #   `:instance` - instance admin operartions(create, delete, update, list etc)
    #   Default client type is `:data`.
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
    # @return [InstanceAdminClient | TableAdminClient | DataClient]
    # @example Create instance admin client
    #   require "google/cloud/bigtable"
    #
    #   client = Google::Cloud.bigtable(
    #     project_id: "project-id",
    #     client_type: :instance
    #   )
    #
    # @example Create table admin client
    #   require "google/cloud/bigtable"
    #
    #   client = Google::Cloud.bigtable(
    #     project_id: "project-id",
    #     instance_id: "instance_id"
    #     client_type: :table
    #   )
    #
    # @example Create table data operations client
    #   require "google/cloud/bigtable"
    #
    #   client = Google::Cloud.bigtable(
    #     project_id: "project-id",
    #     instance_id: "instance_id",
    #     client_type: :data
    #   )

    def self.bigtable \
        project_id: nil,
        instance_id: nil,
        client_type: :data,
        credentials: nil,
        scopes: nil,
        client_config: nil,
        timeout: nil
      gem_spec = Gem.loaded_specs["google-cloud-bigtable"]
      options = {
        credentials: credentials,
        scopes: scopes,
        client_config: client_config,
        timeout: timeout,
        lib_name: gem_spec.name,
        lib_version: gem_spec.version.to_s
      }

      raise InvalidArgumentError, "project_id is required" unless project_id

      if client_type == :instance
        require "google/cloud/bigtable/instance_admin_client"
        return Bigtable::InstanceAdminClient.new(project_id, options)
      end

      # Instance id is required for data and table clients
      raise InvalidArgumentError, "instance_id is required" unless instance_id

      if client_type == :table
        require "google/cloud/bigtable/table_admin_client"
        Bigtable::TableAdminClient.new(project_id, instance_id, options)
      elsif client_type == :data
        raise UnimplementedError, "Data client api wrapper not implemented yet.\
Use underline apis from 'google/cloud/bigtable/v2/bigtable_client.rb'"
      else
        raise InvalidArgumentError, "invalid client type. Valid types are \
:instance, :table, :data"
      end
    end
  end
end
