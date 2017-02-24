# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/speech/v1beta1/cloud_speech.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/speech/v1beta1/cloud_speech_pb"

module Google
  module Cloud
    module Speech
      module V1beta1
        # Service that implements Google Cloud Speech API.
        #
        # @!attribute [r] speech_stub
        #   @return [Google::Cloud::Speech::V1beta1::Speech::Stub]
        class SpeechClient
          attr_reader :speech_stub

          # The default address of the service.
          SERVICE_ADDRESS = "speech.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: nil,
              app_version: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/speech/v1beta1/cloud_speech_services_pb"

            @operations_client = Google::Longrunning::OperationsClient.new(
              service_path: service_path,
              port: port,
              channel: channel,
              chan_creds: chan_creds,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              app_name: app_name,
              app_version: app_version,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if app_name || app_version
              warn "`app_name` and `app_version` are no longer being used in the request headers."
            end

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "speech_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.speech.v1beta1.Speech",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @speech_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Cloud::Speech::V1beta1::Speech::Stub.method(:new)
            )

            @sync_recognize = Google::Gax.create_api_call(
              @speech_stub.method(:sync_recognize),
              defaults["sync_recognize"]
            )
            @async_recognize = Google::Gax.create_api_call(
              @speech_stub.method(:async_recognize),
              defaults["async_recognize"]
            )
            @streaming_recognize = Google::Gax.create_api_call(
              @speech_stub.method(:streaming_recognize),
              defaults["streaming_recognize"]
            )
          end

          # Service calls

          # Perform synchronous speech-recognition: receive results after all audio
          # has been sent and processed.
          #
          # @param config [Google::Cloud::Speech::V1beta1::RecognitionConfig]
          #   [Required] The +config+ message provides information to the recognizer
          #   that specifies how to process the request.
          # @param audio [Google::Cloud::Speech::V1beta1::RecognitionAudio]
          #   [Required] The audio data to be recognized.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Speech::V1beta1::SyncRecognizeResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/speech/v1beta1/speech_client"
          #
          #   AudioEncoding = Google::Cloud::Speech::V1beta1::RecognitionConfig::AudioEncoding
          #   RecognitionAudio = Google::Cloud::Speech::V1beta1::RecognitionAudio
          #   RecognitionConfig = Google::Cloud::Speech::V1beta1::RecognitionConfig
          #   SpeechClient = Google::Cloud::Speech::V1beta1::SpeechClient
          #
          #   speech_client = SpeechClient.new
          #   encoding = AudioEncoding::FLAC
          #   sample_rate = 44100
          #   config = RecognitionConfig.new
          #   config.encoding = encoding
          #   config.sample_rate = sample_rate
          #   uri = "gs://bucket_name/file_name.flac"
          #   audio = RecognitionAudio.new
          #   audio.uri = uri
          #   response = speech_client.sync_recognize(config, audio)

          def sync_recognize \
              config,
              audio,
              options: nil
            req = Google::Cloud::Speech::V1beta1::SyncRecognizeRequest.new({
              config: config,
              audio: audio
            }.delete_if { |_, v| v.nil? })
            @sync_recognize.call(req, options)
          end

          # Perform asynchronous speech-recognition: receive results via the
          # google.longrunning.Operations interface. Returns either an
          # +Operation.error+ or an +Operation.response+ which contains
          # an +AsyncRecognizeResponse+ message.
          #
          # @param config [Google::Cloud::Speech::V1beta1::RecognitionConfig]
          #   [Required] The +config+ message provides information to the recognizer
          #   that specifies how to process the request.
          # @param audio [Google::Cloud::Speech::V1beta1::RecognitionAudio]
          #   [Required] The audio data to be recognized.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/speech/v1beta1/speech_client"
          #
          #   AudioEncoding = Google::Cloud::Speech::V1beta1::RecognitionConfig::AudioEncoding
          #   RecognitionAudio = Google::Cloud::Speech::V1beta1::RecognitionAudio
          #   RecognitionConfig = Google::Cloud::Speech::V1beta1::RecognitionConfig
          #   SpeechClient = Google::Cloud::Speech::V1beta1::SpeechClient
          #
          #   speech_client = SpeechClient.new
          #   encoding = AudioEncoding::FLAC
          #   sample_rate = 44100
          #   config = RecognitionConfig.new
          #   config.encoding = encoding
          #   config.sample_rate = sample_rate
          #   uri = "gs://bucket_name/file_name.flac"
          #   audio = RecognitionAudio.new
          #   audio.uri = uri
          #
          #   # Register a callback during the method call.
          #   operation = speech_client.async_recognize(config, audio) do |op|
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

          def async_recognize \
              config,
              audio,
              options: nil
            req = Google::Cloud::Speech::V1beta1::AsyncRecognizeRequest.new({
              config: config,
              audio: audio
            }.delete_if { |_, v| v.nil? })
            operation = Google::Gax::Operation.new(
              @async_recognize.call(req, options),
              @operations_client,
              Google::Cloud::Speech::V1beta1::AsyncRecognizeResponse,
              Google::Cloud::Speech::V1beta1::AsyncRecognizeMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Perform bidirectional streaming speech-recognition: receive results while
          # sending audio. This method is only available via the gRPC API (not REST).
          #
          # @param reqs [Enumerable<Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse>]
          #   An enumerable of Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/speech/v1beta1/speech_client"
          #
          #   SpeechClient = Google::Cloud::Speech::V1beta1::SpeechClient
          #   StreamingRecognizeRequest = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest
          #
          #   speech_client = SpeechClient.new
          #   request = StreamingRecognizeRequest.new
          #   requests = [request]
          #   speech_client.streaming_recognize(requests).each do |element|
          #     # Process element.
          #   end

          def streaming_recognize reqs, options: nil
            @streaming_recognize.call(reqs, options)
          end
        end
      end
    end
  end
end
