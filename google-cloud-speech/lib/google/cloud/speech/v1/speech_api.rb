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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/speech/v1/cloud_speech.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/cloud/speech/v1/cloud_speech_services_pb"

module Google
  module Cloud
    module Speech
      module V1
        # Service that implements Google Cloud Speech API.
        #
        # @!attribute [r] stub
        #   @return [Google::Cloud::Speech::V1::Speech::Stub]
        class SpeechApi
          attr_reader :stub

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
            google_api_client = "#{app_name}/#{app_version} " \
              "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "speech_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.speech.v1.Speech",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Cloud::Speech::V1::Speech::Stub.method(:new)
            )

            @non_streaming_recognize = Google::Gax.create_api_call(
              @stub.method(:non_streaming_recognize),
              defaults["non_streaming_recognize"]
            )
          end

          # Service calls

          # Perform non-streaming speech-recognition: receive results after all audio
          # has been sent and processed.
          #
          # @param initial_request [Google::Cloud::Speech::V1::InitialRecognizeRequest]
          #   The +initial_request+ message provides information to the recognizer
          #   that specifies how to process the request.
          #
          #   The first +RecognizeRequest+ message must contain an +initial_request+.
          #   Any subsequent +RecognizeRequest+ messages must not contain an
          #   +initial_request+.
          # @param audio_request [Google::Cloud::Speech::V1::AudioRequest]
          #   The audio data to be recognized. For REST or +NonStreamingRecognize+, all
          #   audio data must be contained in the first (and only) +RecognizeRequest+
          #   message. For gRPC streaming +Recognize+, sequential chunks of audio data
          #   are sent in sequential +RecognizeRequest+ messages.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Speech::V1::NonStreamingRecognizeResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          def non_streaming_recognize \
              initial_request,
              audio_request,
              options: nil
            req = Google::Cloud::Speech::V1::RecognizeRequest.new(
              initial_request: initial_request,
              audio_request: audio_request
            )
            @non_streaming_recognize.call(req, options)
          end
        end
      end
    end
  end
end
