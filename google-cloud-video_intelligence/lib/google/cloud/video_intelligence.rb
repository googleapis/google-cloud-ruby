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
    # # Ruby Client for Cloud Video Intelligence API ([GA](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Cloud Video Intelligence API][Product Documentation]:
    # Cloud Video Intelligence API.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
    # 3. [Enable the Cloud Video Intelligence API.](https://console.cloud.google.com/apis/api/video-intelligence)
    # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Preview
    # #### VideoIntelligenceServiceClient
    # ```rb
    # require "google/cloud/video_intelligence"
    #
    # video_intelligence_service_client = Google::Cloud::VideoIntelligence.new
    # input_uri = "gs://demomaker/cat.mp4"
    # features_element = :LABEL_DETECTION
    # features = [features_element]
    #
    # # Register a callback during the method call.
    # operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
    #   raise op.results.message if op.error?
    #   op_results = op.results
    #   # Process the results.
    #
    #   metadata = op.metadata
    #   # Process the metadata.
    # end
    #
    # # Or use the return value to register a callback.
    # operation.on_done do |op|
    #   raise op.results.message if op.error?
    #   op_results = op.results
    #   # Process the results.
    #
    #   metadata = op.metadata
    #   # Process the metadata.
    # end
    #
    # # Manually reload the operation.
    # operation.reload!
    #
    # # Or block until the operation completes, triggering callbacks on
    # # completion.
    # operation.wait_until_done!
    # ```
    #
    # ### Next Steps
    # - Read the [Cloud Video Intelligence API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/video-intelligence
    #
    #
    module VideoIntelligence
      # rubocop:enable LineLength

      FILE_DIR = File.realdirpath(Pathname.new(__FILE__).join("..").join("video_intelligence"))

      AVAILABLE_VERSIONS = Dir["#{FILE_DIR}/*"]
        .select { |file| File.directory?(file) }
        .select { |dir| Google::Gax::VERSION_MATCHER.match(File.basename(dir)) }
        .select { |dir| File.exist?(dir + ".rb") }
        .map { |dir| File.basename(dir) }

      ##
      # Service that implements Google Cloud Video Intelligence API.
      #
      # @param version [Symbol, String]
      #   The major version of the service to be used. By default :v1
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
      def self.new(*args, version: :v1, **kwargs)
        unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
          raise "The version: #{version} is not available. The available versions " \
            "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
        end

        require "#{FILE_DIR}/#{version.to_s.downcase}"
        version_module = Google::Cloud::VideoIntelligence
          .constants
          .select {|sym| sym.to_s.downcase == version.to_s.downcase}
          .first
        Google::Cloud::VideoIntelligence.const_get(version_module).new(*args, **kwargs)
      end
    end
  end
end
