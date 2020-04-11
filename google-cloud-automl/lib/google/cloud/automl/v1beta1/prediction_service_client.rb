# Copyright 2020 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/automl/v1beta1/prediction_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/automl/v1beta1/prediction_service_pb"
require "google/cloud/automl/v1beta1/credentials"
require "google/cloud/automl/version"

module Google
  module Cloud
    module AutoML
      module V1beta1
        # AutoML Prediction API.
        #
        # On any input that is documented to expect a string parameter in
        # snake_case or kebab-case, either of those cases is accepted.
        #
        # @!attribute [r] prediction_service_stub
        #   @return [Google::Cloud::AutoML::V1beta1::PredictionService::Stub]
        class PredictionServiceClient
          # @private
          attr_reader :prediction_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "automl.googleapis.com".freeze

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
            self::SERVICE_ADDRESS = PredictionServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = PredictionServiceClient::GRPC_INTERCEPTORS
          end

          MODEL_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/models/{model}"
          )

          private_constant :MODEL_PATH_TEMPLATE

          # Returns a fully-qualified model resource name string.
          # @param project [String]
          # @param location [String]
          # @param model [String]
          # @return [String]
          def self.model_path project, location, model
            MODEL_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"model" => model
            )
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/automl/v1beta1/prediction_service_services_pb"

            credentials ||= Google::Cloud::AutoML::V1beta1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version,
              metadata: metadata,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::AutoML::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::AutoML::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "prediction_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.automl.v1beta1.PredictionService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @prediction_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::AutoML::V1beta1::PredictionService::Stub.method(:new)
            )

            @predict = Google::Gax.create_api_call(
              @prediction_service_stub.method(:predict),
              defaults["predict"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @batch_predict = Google::Gax.create_api_call(
              @prediction_service_stub.method(:batch_predict),
              defaults["batch_predict"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Perform an online prediction. The prediction result will be directly
          # returned in the response.
          # Available for following ML problems, and their expected request payloads:
          # * Image Classification - Image in .JPEG, .GIF or .PNG format, image_bytes
          #   up to 30MB.
          # * Image Object Detection - Image in .JPEG, .GIF or .PNG format, image_bytes
          #   up to 30MB.
          # * Text Classification - TextSnippet, content up to 60,000 characters,
          #   UTF-8 encoded.
          # * Text Extraction - TextSnippet, content up to 30,000 characters,
          #   UTF-8 NFC encoded.
          # * Translation - TextSnippet, content up to 25,000 characters, UTF-8
          #   encoded.
          # * Tables - Row, with column values matching the columns of the model,
          #   up to 5MB. Not available for FORECASTING
          #
          # {Google::Cloud::AutoML::V1beta1::TablesModelMetadata#prediction_type prediction_type}.
          # * Text Sentiment - TextSnippet, content up 500 characters, UTF-8
          #   encoded.
          #
          # @param name [String]
          #   Required. Name of the model requested to serve the prediction.
          # @param payload [Google::Cloud::AutoML::V1beta1::ExamplePayload | Hash]
          #   Required. Payload to perform a prediction on. The payload must match the
          #   problem type that the model was trained to solve.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ExamplePayload`
          #   can also be provided.
          # @param params [Hash{String => String}]
          #   Additional domain-specific parameters, any string must be up to 25000
          #   characters long.
          #
          #   * For Image Classification:
          #
          #     `score_threshold` - (float) A value from 0.0 to 1.0. When the model
          #     makes predictions for an image, it will only produce results that have
          #     at least this confidence score. The default is 0.5.
          #
          #   * For Image Object Detection:
          #     `score_threshold` - (float) When Model detects objects on the image,
          #     it will only produce bounding boxes which have at least this
          #     confidence score. Value in 0 to 1 range, default is 0.5.
          #     `max_bounding_box_count` - (int64) No more than this number of bounding
          #     boxes will be returned in the response. Default is 100, the
          #     requested value may be limited by server.
          #   * For Tables:
          #     feature_imp<span>ortan</span>ce - (boolean) Whether feature importance
          #     should be populated in the returned TablesAnnotation.
          #     The default is false.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::PredictResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::PredictResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   prediction_client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # TODO: Initialize `payload`:
          #   payload = {}
          #   response = prediction_client.predict(formatted_name, payload)

          def predict \
              name,
              payload,
              params: nil,
              options: nil,
              &block
            req = {
              name: name,
              payload: payload,
              params: params
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::PredictRequest)
            @predict.call(req, options, &block)
          end

          # Perform a batch prediction. Unlike the online {Google::Cloud::AutoML::V1beta1::PredictionService::Predict Predict}, batch
          # prediction result won't be immediately available in the response. Instead,
          # a long running operation object is returned. User can poll the operation
          # result via {Google::Longrunning::Operations::GetOperation GetOperation}
          # method. Once the operation is done, {Google::Cloud::AutoML::V1beta1::BatchPredictResult BatchPredictResult} is returned in
          # the {Google::Longrunning::Operation#response response} field.
          # Available for following ML problems:
          # * Image Classification
          # * Image Object Detection
          # * Video Classification
          # * Video Object Tracking * Text Extraction
          # * Tables
          #
          # @param name [String]
          #   Required. Name of the model requested to serve the batch prediction.
          # @param input_config [Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig | Hash]
          #   Required. The input configuration for batch prediction.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig`
          #   can also be provided.
          # @param output_config [Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig | Hash]
          #   Required. The Configuration specifying where output predictions should
          #   be written.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig`
          #   can also be provided.
          # @param params [Hash{String => String}]
          #   Required. Additional domain-specific parameters for the predictions, any string must
          #   be up to 25000 characters long.
          #
          #   * For Text Classification:
          #
          #     `score_threshold` - (float) A value from 0.0 to 1.0. When the model
          #     makes predictions for a text snippet, it will only produce results
          #     that have at least this confidence score. The default is 0.5.
          #
          #   * For Image Classification:
          #
          #     `score_threshold` - (float) A value from 0.0 to 1.0. When the model
          #     makes predictions for an image, it will only produce results that
          #     have at least this confidence score. The default is 0.5.
          #
          #   * For Image Object Detection:
          #
          #     `score_threshold` - (float) When Model detects objects on the image,
          #     it will only produce bounding boxes which have at least this
          #     confidence score. Value in 0 to 1 range, default is 0.5.
          #     `max_bounding_box_count` - (int64) No more than this number of bounding
          #     boxes will be produced per image. Default is 100, the
          #     requested value may be limited by server.
          #
          #   * For Video Classification :
          #
          #     `score_threshold` - (float) A value from 0.0 to 1.0. When the model
          #     makes predictions for a video, it will only produce results that
          #     have at least this confidence score. The default is 0.5.
          #     `segment_classification` - (boolean) Set to true to request
          #     segment-level classification. AutoML Video Intelligence returns
          #     labels and their confidence scores for the entire segment of the
          #     video that user specified in the request configuration.
          #     The default is "true".
          #     `shot_classification` - (boolean) Set to true to request shot-level
          #     classification. AutoML Video Intelligence determines the boundaries
          #     for each camera shot in the entire segment of the video that user
          #     specified in the request configuration. AutoML Video Intelligence
          #     then returns labels and their confidence scores for each detected
          #     shot, along with the start and end time of the shot.
          #     WARNING: Model evaluation is not done for this classification type,
          #     the quality of it depends on training data, but there are no metrics
          #     provided to describe that quality. The default is "false".
          #     `1s_interval_classification` - (boolean) Set to true to request
          #     classification for a video at one-second intervals. AutoML Video
          #     Intelligence returns labels and their confidence scores for each
          #     second of the entire segment of the video that user specified in the
          #     request configuration.
          #     WARNING: Model evaluation is not done for this classification
          #     type, the quality of it depends on training data, but there are no
          #     metrics provided to describe that quality. The default is
          #     "false".
          #
          #   * For Tables:
          #
          #     feature_imp<span>ortan</span>ce - (boolean) Whether feature importance
          #     should be populated in the returned TablesAnnotations. The
          #     default is false.
          #
          #   * For Video Object Tracking:
          #
          #     `score_threshold` - (float) When Model detects objects on video frames,
          #     it will only produce bounding boxes which have at least this
          #     confidence score. Value in 0 to 1 range, default is 0.5.
          #     `max_bounding_box_count` - (int64) No more than this number of bounding
          #     boxes will be returned per frame. Default is 100, the requested
          #     value may be limited by server.
          #     `min_bounding_box_size` - (float) Only bounding boxes with shortest edge
          #     at least that long as a relative value of video frame size will be
          #     returned. Value in 0 to 1 range. Default is 0.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   prediction_client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # TODO: Initialize `input_config`:
          #   input_config = {}
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # TODO: Initialize `params`:
          #   params = {}
          #
          #   # Register a callback during the method call.
          #   operation = prediction_client.batch_predict(formatted_name, input_config, output_config, params) do |op|
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

          def batch_predict \
              name,
              input_config,
              output_config,
              params,
              options: nil
            req = {
              name: name,
              input_config: input_config,
              output_config: output_config,
              params: params
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::BatchPredictRequest)
            operation = Google::Gax::Operation.new(
              @batch_predict.call(req, options),
              @operations_client,
              Google::Cloud::AutoML::V1beta1::BatchPredictResult,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
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
