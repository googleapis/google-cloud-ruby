# Copyright 2017 Google LLC
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
    # # Ruby Client for Stackdriver Monitoring API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Stackdriver Monitoring API][Product Documentation]:
    # Manages your Stackdriver Monitoring data and configurations. Most projects must
    # be associated with a Stackdriver account, with a few exceptions as noted on the
    # individual method pages.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Stackdriver Monitoring API.](https://console.cloud.google.com/apis/api/monitoring)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Preview
    # #### MetricServiceClient
    # ```rb
    # require "google/cloud/monitoring"
    #
    # metric_service_client = Google::Cloud::Monitoring::Metric.new
    # formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path(project_id)
    #
    # # Iterate over all results.
    # metric_service_client.list_monitored_resource_descriptors(formatted_name).each do |element|
    #   # Process element.
    # end
    #
    # # Or iterate over results one page at a time.
    # metric_service_client.list_monitored_resource_descriptors(formatted_name).each_page do |page|
    #   # Process each page at a time.
    #   page.each do |element|
    #     # Process element.
    #   end
    # end
    # ```
    #
    # ### Next Steps
    # - Read the [Stackdriver Monitoring API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/monitoring
    #
    #
    module Monitoring
      # rubocop:enable LineLength

      FILE_DIR = File.realdirpath(Pathname.new(__FILE__).join("..").join("monitoring"))

      AVAILABLE_VERSIONS = Dir["#{FILE_DIR}/*"]
        .select { |file| File.directory?(file) }
        .select { |dir| Google::Gax::VERSION_MATCHER.match(File.basename(dir)) }
        .select { |dir| File.exist?(dir + ".rb") }
        .map { |dir| File.basename(dir) }

      module Group
        ##
        # The Group API lets you inspect and manage your
        # [groups](https://cloud.google.comgoogle.monitoring.v3.Group).
        #
        # A group is a named filter that is used to identify
        # a collection of monitored resources. Groups are typically used to
        # mirror the physical and/or logical topology of the environment.
        # Because group membership is computed dynamically, monitored
        # resources that are started in the future are automatically placed
        # in matching groups. By using a group to name monitored resources in,
        # for example, an alert policy, the target of that alert policy is
        # updated automatically as monitored resources are added and removed
        # from the infrastructure.
        #
        # @param version [Symbol, String]
        #   The major version of the service to be used. By default :v3
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
        def self.new(*args, version: :v3, **kwargs)
          unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
            raise "The version: #{version} is not available. The available versions " \
              "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
          end

          require "#{FILE_DIR}/#{version.to_s.downcase}"
          version_module = Google::Cloud::Monitoring
            .constants
            .select {|sym| sym.to_s.downcase == version.to_s.downcase}
            .first
          Google::Cloud::Monitoring.const_get(version_module)::Group.new(*args, **kwargs)
        end
      end

      module Metric
        ##
        # Manages metric descriptors, monitored resource descriptors, and
        # time series data.
        #
        # @param version [Symbol, String]
        #   The major version of the service to be used. By default :v3
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
        def self.new(*args, version: :v3, **kwargs)
          unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
            raise "The version: #{version} is not available. The available versions " \
              "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
          end

          require "#{FILE_DIR}/#{version.to_s.downcase}"
          version_module = Google::Cloud::Monitoring
            .constants
            .select {|sym| sym.to_s.downcase == version.to_s.downcase}
            .first
          Google::Cloud::Monitoring.const_get(version_module)::Metric.new(*args, **kwargs)
        end
      end
    end
  end
end
