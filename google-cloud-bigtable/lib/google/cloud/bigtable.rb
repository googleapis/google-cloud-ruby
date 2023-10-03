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
    ##
    # Cloud Bigtable
    #
    # See {file:OVERVIEW.md Bigtable Overview}.
    #
    module Bigtable
      ##
      # Service for managing Cloud Bigtable instances and tables and for reading from and
      # writing to Bigtable tables.
      #
      # @param project_id [String]
      #   Project identifier for the Bigtable service you are connecting to.
      #   If not present, the default project for the credentials is used.
      # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel,
      #   GRPC::Core::ChannelCredentials, Proc]
      #   Provides the means for authenticating requests made by the client. This parameter can
      #   be one of the following types:
      #   `Google::Auth::Credentials` uses the properties of its represented keyfile for
      #   authenticating requests made by this client.
      #   `String` will be treated as the path to the keyfile to use to construct
      #   credentials for this client.
      #   `Hash` will be treated as the contents of a keyfile to use to construct
      #   credentials for this client.
      #   `GRPC::Core::Channel` will be used to make calls through.
      #   `GRPC::Core::ChannelCredentials` for the setting up the gRPC client. The channel credentials
      #   should already be composed with a `GRPC::Core::CallCredentials` object.
      #   `Proc` will be used as an updater_proc for the gRPC channel. The proc transforms the
      #   metadata for requests, generally, to give OAuth credentials.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] endpoint_admin Override of the admin service endpoint host name. Optional.
      #   If the param is nil, uses the default admin endpoint.
      # @param [String] emulator_host Bigtable emulator host. Optional.
      #   If the parameter is nil, uses the value of the `emulator_host` config.
      # @param scope [Array<String>]
      #   The OAuth 2.0 scopes controlling the set of resources and operations
      #   that the connection can access. See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #   The OAuth scopes for this service. This parameter is ignored if an
      #   updater_proc is supplied.
      # @param timeout [Integer]
      #   The default timeout, in seconds, for calls made through this client. Optional.
      # @param channel_selection [Symbol] The algorithm for selecting a channel from the
      #   pool of available channels. This parameter can have the following symbols:
      #   *  `:least_loaded` selects the channel having least number of concurrent streams.
      # @param channel_count [Integer] The number of channels in the pool.
      # @return [Google::Cloud::Bigtable::Project]
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   client = Google::Cloud::Bigtable.new
      #
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/AbcSize
      def self.new project_id: nil,
                   credentials: nil,
                   emulator_host: nil,
                   scope: nil,
                   endpoint: nil,
                   endpoint_admin: nil,
                   timeout: nil,
                   channel_selection: nil,
                   channel_count: nil
        project_id ||= default_project_id
        scope ||= configure.scope
        timeout ||= configure.timeout
        emulator_host ||= configure.emulator_host
        endpoint ||= configure.endpoint
        endpoint_admin ||= configure.endpoint_admin
        channel_selection ||= configure.channel_selection
        channel_count ||= configure.channel_count

        return new_with_emulator project_id, emulator_host, timeout if emulator_host

        credentials = resolve_credentials credentials, scope
        project_id = resolve_project_id project_id, credentials
        raise ArgumentError, "project_id is missing" if project_id.empty?

        service = Bigtable::Service.new project_id, credentials, host: endpoint,
                                        host_admin: endpoint_admin, timeout: timeout,
                                        channel_selection: channel_selection,
                                        channel_count: channel_count
        Bigtable::Project.new service
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize


      ##
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
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `endpoint_admin` - (String) Override of the admin service endpoint
      #   host name, or `nil` to use the default admin endpoint.
      # * `channel_selection` - (Symbol) The algorithm for selecting a channel from the
      #   pool of available channels. This parameter can have the following symbols:
      #     `:least_loaded` selects the channel having least number of concurrent streams.
      # * `channel_count` - (Integer) The number of channels in the pool.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Bigtable library uses.
      #
      def self.configure
        yield Google::Cloud.configure.bigtable if block_given?

        Google::Cloud.configure.bigtable
      end

      # @private
      # New client given an emulator host.
      #
      def self.new_with_emulator project_id, emulator_host, timeout
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        service = Bigtable::Service.new \
          project_id, :this_channel_is_insecure, host: emulator_host, host_admin: emulator_host, timeout: timeout
        Bigtable::Project.new service
      end

      # @private
      # Resolve credentials
      #
      def self.resolve_credentials given_credentials, scope
        credentials = given_credentials || default_credentials(scope: scope)
        return credentials if credentials.is_a? Google::Auth::Credentials
        Bigtable::Credentials.new credentials, scope: scope
      end

      # @private
      # Resolve project.
      #
      def self.resolve_project_id given_project_id, credentials
        project_id = given_project_id || default_project_id
        project_id ||= credentials.project_id if credentials.respond_to? :project_id
        project_id.to_s # Always cast to a string
      end

      # @private
      # Default project.
      #
      def self.default_project_id
        Google::Cloud.configure.bigtable.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      # @private
      # Default credentials.
      #
      def self.default_credentials scope: nil
        Google::Cloud.configure.bigtable.credentials ||
          Google::Cloud.configure.credentials ||
          Bigtable::Credentials.default(scope: scope)
      end
    end
  end
end
