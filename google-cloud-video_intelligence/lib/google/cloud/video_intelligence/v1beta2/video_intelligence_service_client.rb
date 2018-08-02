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
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/videointelligence/v1beta2/video_intelligence.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/videointelligence/v1beta2/video_intelligence_pb"
require "google/cloud/video_intelligence/v1beta2/credentials"

module Google
  module Cloud
    module VideoIntelligence
      module V1beta2
        # Service that implements Google Cloud Video Intelligence API.
        #
        # @!attribute [r] video_intelligence_service_stub
        #   @return [Google::Cloud::Videointelligence::V1beta2::VideoIntelligenceService::Stub]
        class VideoIntelligenceServiceClient
          attr_reader :video_intelligence_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "videointelligence.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = VideoIntelligenceServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = VideoIntelligenceServiceClient::GRPC_INTERCEPTORS
          end

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
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/videointelligence/v1beta2/video_intelligence_services_pb"

            credentials ||= Google::Cloud::VideoIntelligence::V1beta2::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::VideoIntelligence::V1beta2::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-video_intelligence'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "video_intelligence_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.videointelligence.v1beta2.VideoIntelligenceService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @video_intelligence_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Videointelligence::V1beta2::VideoIntelligenceService::Stub.method(:new)
            )

            @annotate_video = Google::Gax.create_api_call(
              @video_intelligence_service_stub.method(:annotate_video),
              defaults["annotate_video"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Performs asynchronous video annotation. Progress and results can be
          # retrieved through the +google.longrunning.Operations+ interface.
          # +Operation.metadata+ contains +AnnotateVideoProgress+ (progress).
          # +Operation.response+ contains +AnnotateVideoResponse+ (results).
          #
          # @param input_uri [String]
          #   Input video location. Currently, only
          #   [Google Cloud Storage](https://cloud.google.com/storage/) URIs are
          #   supported, which must be specified in the following format:
          #   +gs://bucket-id/object-id+ (other URI formats return
          #   {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
          #   [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
          #   A video URI may include wildcards in +object-id+, and thus identify
          #   multiple videos. Supported wildcards: '*' to match 0 or more characters;
          #   '?' to match 1 character. If unset, the input video should be embedded
          #   in the request as +input_content+. If set, +input_content+ should be unset.
          # @param input_content [String]
          #   The video data bytes.
          #   If unset, the input video(s) should be specified via +input_uri+.
          #   If set, +input_uri+ should be unset.
          # @param features [Array<Google::Cloud::Videointelligence::V1beta2::Feature>]
          #   Requested video annotation features.
          # @param video_context [Google::Cloud::Videointelligence::V1beta2::VideoContext | Hash]
          #   Additional video context and/or feature-specific parameters.
          #   A hash of the same form as `Google::Cloud::Videointelligence::V1beta2::VideoContext`
          #   can also be provided.
          # @param output_uri [String]
          #   Optional location where the output (in JSON format) should be stored.
          #   Currently, only [Google Cloud Storage](https://cloud.google.com/storage/)
          #   URIs are supported, which must be specified in the following format:
          #   +gs://bucket-id/object-id+ (other URI formats return
          #   {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
          #   [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
          # @param location_id [String]
          #   Optional cloud region where annotation should take place. Supported cloud
          #   regions: +us-east1+, +us-west1+, +europe-west1+, +asia-east1+. If no region
          #   is specified, a region will be determined based on video file location.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/video_intelligence"
          #
          #   video_intelligence_service_client = Google::Cloud::VideoIntelligence.new(version: :v1beta2)
          #   input_uri = "gs://demomaker/cat.mp4"
          #   features_element = :LABEL_DETECTION
          #   features = [features_element]
          #
          #   # Register a callback during the method call.
          #   operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Or use the return value to register a callback.
          #   operation.on_done do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Manually reload the operation.
          #   operation.reload!
          #
          #   # Or block until the operation completes, triggering callbacks on
          #   # completion.
          #   operation.wait_until_done!

          def annotate_video \
              input_uri: nil,
              input_content: nil,
              features: nil,
              video_context: nil,
              output_uri: nil,
              location_id: nil,
              options: nil
            req = {
              input_uri: input_uri,
              input_content: input_content,
              features: features,
              video_context: video_context,
              output_uri: output_uri,
              location_id: location_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Videointelligence::V1beta2::AnnotateVideoRequest)
            operation = Google::Gax::Operation.new(
              @annotate_video.call(req, options),
              @operations_client,
              Google::Cloud::Videointelligence::V1beta2::AnnotateVideoResponse,
              Google::Cloud::Videointelligence::V1beta2::AnnotateVideoProgress,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end
        end
      end
    end
  end
end
