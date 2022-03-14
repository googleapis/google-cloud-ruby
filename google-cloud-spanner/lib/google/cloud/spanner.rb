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


require "google-cloud-spanner"
require "google/cloud/spanner/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Cloud Spanner
    #
    # Cloud Spanner is a fully managed, mission-critical, relational database
    # service that offers transactional consistency at global scale, schemas,
    # SQL (ANSI 2011 with extensions), and automatic, synchronous replication
    # for high availability.
    #
    # For more information about Cloud Spanner, read the [Cloud
    # Spanner Documentation](https://cloud.google.com/spanner/docs/).
    #
    # See {file:OVERVIEW.md Spanner Overview}.
    #
    module Spanner
      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize

      ##
      # Creates a new object for connecting to the Spanner service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Spanner service
      #   you are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Spanner::Credentials})
      #   If `emulator_host` is present, this becomes optional and the value is
      #   internally overriden with `:this_channel_is_insecure`.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scopes are:
      #
      #   * `https://www.googleapis.com/auth/spanner`
      #   * `https://www.googleapis.com/auth/spanner.data`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses `emulator_host` or the default endpoint.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      # @param [String] emulator_host Spanner emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] lib_name Library name. This will be added as a prefix
      #   to the API call tracking header `x-goog-api-client` with provided
      #   lib version for telemetry. Optional. For example prefix looks like
      #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
      #   `spanner-activerecord/0.0.1` is provided custom library name and
      #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
      #   with version.
      # @param [String] lib_version Library version. This will be added as a
      #   prefix to the API call tracking header `x-goog-api-client` with
      #   provided lib name for telemetry. Optional. For example prefix look like
      #   `spanner-activerecord/0.0.1 gccl/1.13.1`. Here,
      #   `spanner-activerecord/0.0.1` is provided custom library name and
      #   version and `gccl/1.13.1` represents the Cloud Spanner Ruby library
      #   with version.
      #
      # @return [Google::Cloud::Spanner::Project]
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   endpoint: nil, project: nil, keyfile: nil,
                   emulator_host: nil, lib_name: nil, lib_version: nil
        project_id    ||= project || default_project_id
        scope         ||= configure.scope
        timeout       ||= configure.timeout
        emulator_host ||= configure.emulator_host
        endpoint      ||= emulator_host || configure.endpoint
        credentials   ||= keyfile
        lib_name      ||= configure.lib_name
        lib_version   ||= configure.lib_version

        if emulator_host
          credentials = :this_channel_is_insecure
        else
          credentials ||= default_credentials scope: scope
          unless credentials.is_a? Google::Auth::Credentials
            credentials = Spanner::Credentials.new credentials, scope: scope
          end

          if credentials.respond_to? :project_id
            project_id ||= credentials.project_id
          end
        end

        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        Spanner::Project.new(
          Spanner::Service.new(
            project_id, credentials, quota_project: configure.quota_project,
            host: endpoint, timeout: timeout, lib_name: lib_name,
            lib_version: lib_version
          ),
          query_options: configure.query_options
        )
      end

      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

      ##
      # Configure the Google Cloud Spanner library.
      #
      # The following Spanner configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Spanner project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Spanner::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["SPANNER_EMULATOR_HOST"]`.
      # * `lib_name` - (String) Override the lib name , or `nil`
      #   to use the default lib name without prefix in agent tracking
      #   header.
      # * `lib_version` - (String) Override the lib version , or `nil`
      #   to use the default version lib name without prefix in agent
      #   tracking header.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Spanner library uses.
      #
      def self.configure
        yield Google::Cloud.configure.spanner if block_given?

        Google::Cloud.configure.spanner
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.spanner.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.spanner.credentials ||
          Google::Cloud.configure.credentials ||
          Spanner::Credentials.default(scope: scope)
      end
    end
  end

  # @private
  Spanner = Cloud::Spanner unless const_defined? :Spanner
end
