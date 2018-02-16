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

require "google-cloud-bigtable"
require "google/cloud/env"
require "google/cloud/config"
require "google/cloud/errors"

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Cloud Bigtable API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Cloud Bigtable API][Product Documentation]:
    # API for reading and writing the contents of Bigtables associated with a
    # cloud project.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
    # 3. [Enable the Cloud Bigtable API.](https://console.cloud.google.com/apis/api/bigtable)
    # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Next Steps
    # - Read the [Cloud Bigtable API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/bigtable
    #
    #
    module Bigtable
      # rubocop:enable LineLength

      # Service for managing bigtable instance, tables and reading from and writing to existing Bigtable tables.
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
      # @return [Google::Cloud::InstanceAdminClient | Google::Cloud::TableAdminClient | Google::Cloud::DataClient]
      #
      # @example Create instance admin client
      #   require "google/cloud/bigtable"
      #
      #   client = Google::Cloud::Bigtable.new(client_type: :instance)
      #
      # @example Create table admin client
      #   require "google/cloud/bigtable"
      #
      #   client = Google::Cloud::Bigtable.new(
      #     client_type: :table
      #     instance_id: "instance-id"
      #   )
      #
      # @example Create table data operations client
      #   require "google/cloud/bigtable"
      #
      #   client = Google::Cloud::Bigtable.new(instance_id: "instance-id")

      def self.new \
          project_id: nil,
          client_type: :data,
          instance_id: nil,
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
          require "google/cloud/bigtable/v2/bigtable_client"
          Bigtable::V2::BigtableClient.new(options)
        else
          raise InvalidArgumentError, "invalid client type. Valid types are \
  :instance, :table, :data"
        end
      end

      # Configure the Google Cloud Bigtable library.
      #
      # The following Bigtable configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Bigtable project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials,
      #    GRPC::Core::Channel, GRPC::Core::ChannelCredentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Bigtable::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Bigtable library uses.
      #
      def self.configure
        yield Google::Cloud.configure.bigtable if block_given?

        Google::Cloud.configure.bigtable
      end

     # @private Default project.
     def self.default_project_id
       Google::Cloud.configure.bigtable.project_id ||
         Google::Cloud.configure.project_id ||
         Google::Cloud.env.project_id
     end

     # @private Default credentials.
     def self.default_credentials scope: nil
       Google::Cloud.configure.bigtable.credentials ||
         Google::Cloud.configure.credentials ||
         Bigtable::Credentials.default(scope: scope)
     end
    end
  end
end
