# Copyright 2021 Google LLC
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
require "google/cloud/config"
require "gapic/config"

module Google
  module Cloud
    module Spanner
      module Admin
        module Instance
          ##
          # Create a new client object for a InstanceAdmin.
          #
          # This returns an instance of
          # Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Client
          # for version V1 of the API.
          #
          # ## About InstanceAdmin
          #
          # Google Cloud Spanner Instance Admin Service
          #
          # The Cloud Spanner Instance Admin API can be used to create, delete,
          # modify and list instances. Instances are dedicated Cloud Spanner
          # serving and storage resources to be used by Cloud Spanner databases.
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
          # @return [Admin::Instance::V1::InstanceAdmin::Client] A client object of version V1.
          #
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
          def self.instance_admin project_id: nil,
                                  credentials: nil,
                                  scope: nil,
                                  timeout: nil,
                                  endpoint: nil,
                                  project: nil,
                                  keyfile: nil,
                                  emulator_host: nil,
                                  lib_name: nil,
                                  lib_version: nil
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

            configure.quota_project ||= credentials.quota_project_id if credentials.respond_to? :quota_project_id

            Admin::Instance::V1::InstanceAdmin::Client.new do |config|
              config.credentials = channel endpoint, credentials
              config.quota_project = configure.quota_project
              config.timeout = timeout if timeout
              config.endpoint = endpoint if endpoint
              config.lib_name = lib_name_with_prefix lib_name, lib_version
              config.lib_version = Google::Cloud::Spanner::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{project_id}" }
            end
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength

          ##
          # Configure the Google Cloud Spanner Instance Admin library. This configuration can be
          # applied globally to all clients.
          #
          # @example
          #
          # Modify the global config, setting the timeout to 10 seconds for all admin instances.
          #
          # require "google/cloud/spanner/admin/instance"
          #
          # ::Google::Cloud::Spanner::Admin::Instance.configure do |config|
          #   config.timeout = 10.0
          # end
          #
          # The following configuration parameters are supported:
          #
          # * `credentials` (*type:* `String, Hash, Google::Auth::Credentials`) -
          #   The path to the keyfile as a String, the contents of the keyfile as a
          #   Hash, or a Google::Auth::Credentials object.
          # * `lib_name` (*type:* `String`) -
          #   The library name as recorded in instrumentation and logging.
          # * `lib_version` (*type:* `String`) -
          #   The library version as recorded in instrumentation and logging.
          # * `interceptors` (*type:* `Array<GRPC::ClientInterceptor>`) -
          #   An array of interceptors that are run before calls are executed.
          # * `timeout` (*type:* `Numeric`) -
          #   Default timeout in seconds.
          # * `emulator_host` - (String) Host name of the emulator. Defaults to
          #   `ENV["SPANNER_EMULATOR_HOST"]`.
          # * `metadata` (*type:* `Hash{Symbol=>String}`) -
          #   Additional gRPC headers to be sent with the call.
          # * `retry_policy` (*type:* `Hash`) -
          #   The retry policy. The value is a hash with the following keys:
          #     * `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
          #     * `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
          #     * `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
          #     * `:retry_codes` (*type:* `Array<String>`) -
          #       The error codes that should trigger a retry.
          #
          # @return [::Google::Cloud::Config] The default configuration used by this library
          #
          def self.configure
            @configure ||= begin
              namespace = ["Google", "Cloud", "Spanner"]
              parent_config = while namespace.any?
                                parent_name = namespace.join "::"
                                parent_const = const_get parent_name
                                break parent_const.configure if parent_const.respond_to? :configure
                                namespace.pop
                              end

              default_config = Instance::Configuration.new parent_config
              default_config
            end
            yield @configure if block_given?
            @configure
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

          ##
          # @private gRPC channel.
          def self.channel host, credentials
            require "grpc"
            GRPC::Core::Channel.new host, chan_args, chan_creds(credentials)
          end

          ##
          # @private gRPC channel args.
          def self.chan_args
            { "grpc.service_config_disable_resolution" => 1 }
          end

          ##
          # @private gRPC channel credentials
          def self.chan_creds credentials
            return credentials if credentials == :this_channel_is_insecure
            require "grpc"
            GRPC::Core::ChannelCredentials.new.compose \
              GRPC::Core::CallCredentials.new credentials.client.updater_proc
          end

          ##
          # @private Spanner client library version with the prefix.
          def self.lib_name_with_prefix lib_name, lib_version
            return "gccl" if [nil, "gccl"].include? lib_name

            value = lib_name.dup
            value << "/#{lib_version}" if lib_version
            value << " gccl"
          end

          ##
          # Configuration class for the Spanner Admin Instance.
          #
          # This class provides control over timeouts, retry behavior,
          # query options, and other low-level controls.
          #
          # @!attribute [rw] endpoint
          #   The hostname or hostname:port of the service endpoint.
          #   Defaults to `"spanner.googleapis.com"`.
          #   @return [::String]
          # @!attribute [rw] credentials
          #   Credentials to send with calls. You may provide any of the following types:
          #    *  (`String`) The path to a service account key file in JSON format
          #    *  (`Hash`) A service account key as a Hash
          #    *  (`Google::Auth::Credentials`) A googleauth credentials object
          #       (see the [googleauth docs](https://googleapis.dev/ruby/googleauth/latest/index.html))
          #    *  (`Signet::OAuth2::Client`) A signet oauth2 client object
          #       (see the [signet docs](https://googleapis.dev/ruby/signet/latest/Signet/OAuth2/Client.html))
          #    *  (`GRPC::Core::Channel`) a gRPC channel with included credentials
          #    *  (`GRPC::Core::ChannelCredentials`) a gRPC credentails object
          #    *  (`nil`) indicating no credentials
          #   @return [::Object]
          # @!attribute [rw] scope
          #   The OAuth scopes
          #   @return [::Array<::String>]
          # @!attribute [rw] lib_name
          #   The library name as recorded in instrumentation and logging
          #   @return [::String]
          # @!attribute [rw] lib_version
          #   The library version as recorded in instrumentation and logging
          #   @return [::String]
          # @!attribute [rw] interceptors
          #   An array of interceptors that are run before calls are executed.
          #   @return [::Array<::GRPC::ClientInterceptor>]
          # @!attribute [rw] timeout
          #   The call timeout in seconds.
          #   @return [::Numeric]
          # @!attribute [rw] metadata
          #   Additional gRPC headers to be sent with the call.
          #   @return [::Hash{::Symbol=>::String}]
          # @!attribute [rw] retry_policy
          #   The retry policy. The value is a hash with the following keys:
          #    *  `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
          #    *  `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
          #    *  `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
          #    *  `:retry_codes` (*type:* `Array<String>`) - The error codes that should
          #       trigger a retry.
          #   @return [::Hash]
          # @!attribute [rw] quota_project
          #   A separate project against which to charge quota.
          #   @return [::String]
          #
          class Configuration
            extend ::Gapic::Config

            config_attr :endpoint,      "spanner.googleapis.com", ::String
            config_attr :credentials,   nil do |value|
              allowed = [::String, ::Hash, ::Google::Auth::Credentials, ::Signet::OAuth2::Client, nil]
              allowed += [::GRPC::Core::Channel, ::GRPC::Core::ChannelCredentials] if defined? ::GRPC
              allowed.any? { |klass| klass === value }
            end
            config_attr :project_id,    nil, ::String, nil
            config_attr :scope,         nil, ::String, ::Array, nil
            config_attr :lib_name,      nil, ::String,  nil
            config_attr :lib_version,   nil, ::String,  nil
            config_attr :interceptors,  nil, ::Array,   nil
            config_attr :timeout,       nil, ::Numeric, nil
            config_attr :quota_project, nil, ::String,  nil
            config_attr :emulator_host, nil, ::String,  nil
            config_attr :query_options, nil, ::Hash,    nil
            config_attr :metadata,      nil, ::Hash,    nil
            config_attr :retry_policy,  nil, ::Hash,    nil

            # @private
            def initialize parent_config = nil
              @parent_config = parent_config unless parent_config.nil?

              yield self if block_given?
            end
          end
        end
      end
    end
  end
end
