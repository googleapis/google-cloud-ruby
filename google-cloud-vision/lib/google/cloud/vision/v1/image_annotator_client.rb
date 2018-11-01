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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/vision/v1/image_annotator.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/vision/v1/image_annotator_pb"
require "google/cloud/vision/v1/credentials"

module Google
  module Cloud
    module Vision
      module V1
        # Service that performs Google Cloud Vision API detection tasks over client
        # images, such as face, landmark, logo, label, and text detection. The
        # ImageAnnotator service returns detected entities from the images.
        #
        # @!attribute [r] image_annotator_stub
        #   @return [Google::Cloud::Vision::V1::ImageAnnotator::Stub]
        class ImageAnnotatorClient
          # @private
          attr_reader :image_annotator_stub

          # The default address of the service.
          SERVICE_ADDRESS = "vision.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-vision"
          ].freeze

          # @private
          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = ImageAnnotatorClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = ImageAnnotatorClient::GRPC_INTERCEPTORS
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
            require "google/cloud/vision/v1/image_annotator_services_pb"

            credentials ||= Google::Cloud::Vision::V1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Vision::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-vision'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "image_annotator_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.vision.v1.ImageAnnotator",
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
            @image_annotator_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Vision::V1::ImageAnnotator::Stub.method(:new)
            )

            @batch_annotate_images = Google::Gax.create_api_call(
              @image_annotator_stub.method(:batch_annotate_images),
              defaults["batch_annotate_images"],
              exception_transformer: exception_transformer
            )
            @async_batch_annotate_files = Google::Gax.create_api_call(
              @image_annotator_stub.method(:async_batch_annotate_files),
              defaults["async_batch_annotate_files"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Run image detection and annotation for a batch of images.
          #
          # @param requests [Array<Google::Cloud::Vision::V1::AnnotateImageRequest | Hash>]
          #   Individual image annotation requests for this batch.
          #   A hash of the same form as `Google::Cloud::Vision::V1::AnnotateImageRequest`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::BatchAnnotateImagesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision/v1"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1)
          #
          #   # TODO: Initialize `requests`:
          #   requests = []
          #   response = image_annotator_client.batch_annotate_images(requests)

          def batch_annotate_images \
              requests,
              options: nil,
              &block
            req = {
              requests: requests
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::BatchAnnotateImagesRequest)
            @batch_annotate_images.call(req, options, &block)
          end

          # Run asynchronous image detection and annotation for a list of generic
          # files, such as PDF files, which may contain multiple pages and multiple
          # images per page. Progress and results can be retrieved through the
          # `google.longrunning.Operations` interface.
          # `Operation.metadata` contains `OperationMetadata` (metadata).
          # `Operation.response` contains `AsyncBatchAnnotateFilesResponse` (results).
          #
          # @param requests [Array<Google::Cloud::Vision::V1::AsyncAnnotateFileRequest | Hash>]
          #   Individual async file annotation requests for this batch.
          #   A hash of the same form as `Google::Cloud::Vision::V1::AsyncAnnotateFileRequest`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision/v1"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1)
          #
          #   # TODO: Initialize `requests`:
          #   requests = []
          #
          #   # Register a callback during the method call.
          #   operation = image_annotator_client.async_batch_annotate_files(requests) do |op|
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

          def async_batch_annotate_files \
              requests,
              options: nil
            req = {
              requests: requests
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::AsyncBatchAnnotateFilesRequest)
            operation = Google::Gax::Operation.new(
              @async_batch_annotate_files.call(req, options),
              @operations_client,
              Google::Cloud::Vision::V1::AsyncBatchAnnotateFilesResponse,
              Google::Cloud::Vision::V1::OperationMetadata,
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
