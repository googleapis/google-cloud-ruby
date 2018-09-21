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
require "google/cloud/errors"
require "google/cloud/bigtable/credentials"
require "google/cloud/bigtable/project"

module Google
  module Cloud
    # Cloud Bigtable
    #
    # See {file:OVERVIEW.md Bigtable Overview}.
    #
    module Bigtable
      # Service for managing Bigtable instance, tables and reading from and
      # writing to existing Bigtable tables.
      #
      # @param project_id [String]
      #   Project identifier for the Bigtable service you are connecting to.
      #   If not present, the default project for the credentials is used.
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
      # @param [String] emulator_host Bigtable emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param scope [Array<String>]
      #   The OAuth 2.0 scopes controlling the set of resources and operations
      #   that the connection can access. See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #   The OAuth scopes for this service. This parameter is ignored if an
      #   updater_proc is supplied.
      # @param client_config [Hash]
      #   A Hash for call options for each method.
      #   See Google::Gax#construct_settings for the structure of
      #   this data. Falls back to the default config if not specified
      #   or the specified config is missing data points.
      # @param timeout [Integer]
      #   The default timeout, in seconds, for calls made through this client. Optional.
      # @return [Google::Cloud::Bigtable::Project]
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   client = Google::Cloud::Bigtable.new

      def self.new \
          project_id: nil,
          credentials: nil,
          emulator_host: nil,
          scope: nil,
          client_config: nil,
          timeout: nil
        project_id = (project_id || default_project_id).to_s
        raise ArgumentError, "project_id is required" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        emulator_host ||= configure.emulator_host
        if emulator_host
          return Bigtable::Project.new(
            Bigtable::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host, timeout: timeout,
              client_config: client_config
            )
          )
        end

        credentials ||= default_credentials(scope: scope)
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Bigtable::Credentials.new credentials, scope: scope
        end

        service = Bigtable::Service.new(
          project_id,
          credentials,
          timeout: timeout,
          client_config: client_config
        )
        Bigtable::Project.new(service)
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

      def self.configure
        yield Google::Cloud.configure.bigtable if block_given?

        Google::Cloud.configure.bigtable
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

      def self.configure
        yield Google::Cloud.configure.bigtable if block_given?

        Google::Cloud.configure.bigtable
      end

     # @private
     # Default project.

     def self.default_project_id
       Google::Cloud.configure.bigtable.project_id ||
         Google::Cloud.configure.project_id ||
         Google::Cloud.env.project_id
     end

     # @private
     # Default credentials.

     def self.default_credentials scope: nil
       Google::Cloud.configure.bigtable.credentials ||
         Google::Cloud.configure.credentials ||
         Bigtable::Credentials.default(scope: scope)
     end
    end
  end
end
