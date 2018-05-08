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

require "google/gax"
require "pathname"

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Google Cloud Memorystore for Redis API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Memorystore for Redis API][Product Documentation]:
    # The Google Cloud Memorystore for Redis API is used for creating and managing
    # Redis instances on the Google Cloud Platform.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
    # 3. [Enable the Google Cloud Memorystore for Redis API.](https://console.cloud.google.com/apis/api/redis)
    # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Next Steps
    # - Read the [Google Cloud Memorystore for Redis API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/redis
    #
    #
    module Redis
      # rubocop:enable LineLength

      FILE_DIR = File.realdirpath(Pathname.new(__FILE__).join("..").join("redis"))

      AVAILABLE_VERSIONS = Dir["#{FILE_DIR}/*"]
        .select { |file| File.directory?(file) }
        .select { |dir| Google::Gax::VERSION_MATCHER.match(File.basename(dir)) }
        .select { |dir| File.exist?(dir + ".rb") }
        .map { |dir| File.basename(dir) }

      ##
      # Configures and manages Cloud Memorystore for Redis instances
      #
      # Google Cloud Memorystore for Redis v1beta1
      #
      # The +redis.googleapis.com+ service implements the Google Cloud Memorystore
      # for Redis API and defines the following resource model for managing Redis
      # instances:
      # * The service works with a collection of cloud projects, named: +/projects/*+
      # * Each project has a collection of available locations, named: +/locations/*+
      # * Each location has a collection of Redis instances, named: +/instances/*+
      # * As such, Redis instances are resources of the form:
      #   +/projects/{project_id}/locations/{location_id}/instances/{instance_id}+
      #
      # Note that location_id must be refering to a GCP +region+; for example:
      # * +projects/redpepper-1290/locations/us-central1/instances/my-redis+
      #
      # @param version [Symbol, String]
      #   The major version of the service to be used. By default :v1beta1
      #   is used.
      # @overload new(version:, credentials:, scopes:, client_config:, timeout:)
      #   @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
      #     Provides the means for authenticating requests made by the client. This parameter can
      #     be many types.
      #     A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
      #     authenticating requests made by this client.
      #     A `String` will be treated as the path to the keyfile to be used for the construction of
      #     credentials for this client.
      #     A `Hash` will be treated as the contents of a keyfile to be used for the construction of
      #     credentials for this client.
      #     A `GRPC::Core::Channel` will be used to make calls through.
      #     A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
      #     should already be composed with a `GRPC::Core::CallCredentials` object.
      #     A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
      #     metadata for requests, generally, to give OAuth credentials.
      #   @param scopes [Array<String>]
      #     The OAuth scopes for this service. This parameter is ignored if
      #     an updater_proc is supplied.
      #   @param client_config [Hash]
      #     A Hash for call options for each method. See
      #     Google::Gax#construct_settings for the structure of
      #     this data. Falls back to the default config if not specified
      #     or the specified config is missing data points.
      #   @param timeout [Numeric]
      #     The default timeout, in seconds, for calls made through this client.
      def self.new(*args, version: :v1beta1, **kwargs)
        unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
          raise "The version: #{version} is not available. The available versions " \
            "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
        end

        require "#{FILE_DIR}/#{version.to_s.downcase}"
        version_module = Google::Cloud::Redis
          .constants
          .select {|sym| sym.to_s.downcase == version.to_s.downcase}
          .first
        Google::Cloud::Redis.const_get(version_module).new(*args, **kwargs)
      end
    end
  end
end
