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
require "google/cloud/speech/v1beta1/cloud_speech_pb"

module Google
  module Cloud
    module Speech
      module V1beta1
        # Service that implements Google Cloud Speech API.
        #
        # @!attribute [r] speech_stub
        #   @return [Google::Cloud::Speech::V1beta1::Speech::Stub]
        class SpeechApi
          attr_reader :speech_stub

          # The default address of the service.
          SERVICE_ADDRESS = "speech.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

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
          # @param app_name [String]
          #   The codename of the calling service.
          # @param app_version [String]
          #   The version of the calling service.
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: "gax",
              app_version: Google::Gax::VERSION
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/speech/v1beta1/cloud_speech_services_pb"

            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
              "ruby/#{RUBY_VERSION}".freeze
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
          #   require "google/cloud/speech/v1beta1/speech_api"
          #
          #   RecognitionAudio = Google::Cloud::Speech::V1beta1::RecognitionAudio
          #   RecognitionConfig = Google::Cloud::Speech::V1beta1::RecognitionConfig
          #   SpeechApi = Google::Cloud::Speech::V1beta1::SpeechApi
          #
          #   speech_api = SpeechApi.new
          #   config = RecognitionConfig.new
          #   audio = RecognitionAudio.new
          #   response = speech_api.sync_recognize(config, audio)

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
          # @return [Google::Longrunning::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/speech/v1beta1/speech_api"
          #
          #   RecognitionAudio = Google::Cloud::Speech::V1beta1::RecognitionAudio
          #   RecognitionConfig = Google::Cloud::Speech::V1beta1::RecognitionConfig
          #   SpeechApi = Google::Cloud::Speech::V1beta1::SpeechApi
          #
          #   speech_api = SpeechApi.new
          #   config = RecognitionConfig.new
          #   audio = RecognitionAudio.new
          #   response = speech_api.async_recognize(config, audio)

          def async_recognize \
              config,
              audio,
              options: nil
            req = Google::Cloud::Speech::V1beta1::AsyncRecognizeRequest.new({
              config: config,
              audio: audio
            }.delete_if { |_, v| v.nil? })
            @async_recognize.call(req, options)
          end
        end
      end
    end
  end
end
