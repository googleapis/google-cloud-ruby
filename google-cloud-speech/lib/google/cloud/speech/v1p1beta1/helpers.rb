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

require "google/cloud/speech/v1p1beta1/speech_client"
require "google/cloud/speech/v1p1beta1/stream"

module Google
  module Cloud
    module Speech
      module V1p1beta1
        class SpeechClient
          # Performs bidirectional streaming speech recognition: receive results
          # while sending audio. This method is only available via the gRPC API
          # (not REST).
          #
          # @param [Google::Cloud::Speech::V1p1beta1::StreamingRecognitionConfig,
          #     Hash] streaming_config
          #   Provides information to the recognizer that specifies how to
          #   process the request.
          #   A hash of the same form as
          #   +Google::Cloud::Speech::V1p1beta1::StreamingRecognitionConfig+
          #   can also be provided.
          # @param [Google::Gax::CallOptions] options
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Cloud::Speech::V1p1beta1::Stream]
          #   An object that streams the requests and responses.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @example
          #   require "google/cloud/speech"
          #
          #   speech_client = Google::Cloud::Speech.new version: :v1p1beta1
          #   streaming_config = {
          #     config: {
          #       encoding: :linear16,
          #       language_code: "en-US",
          #       sample_rate_hertz: 16000
          #     }
          #   }
          #   stream = speech_client.streaming_recognize(streaming_config)
          #
          #   # Stream 5 seconds of audio from the microphone
          #   # Actual implementation of microphone input varies by platform
          #   5.times do
          #     stream.send MicrophoneInput.read(32000)
          #   end
          #
          #   stream.stop
          #   stream.wait_until_complete!
          #
          #   results = stream.results
          #   result = results.first.alternatives.first
          #   result.transcript #=> "how old is the Brooklyn Bridge"
          #   result.confidence #=> 0.9826789498329163
          #
          def streaming_recognize streaming_config, options: nil
            if streaming_config.is_a?(::Hash) &&
               streaming_config[:config] &&
               streaming_config[:config][:encoding]
              streaming_config[:config][:encoding] =
                streaming_config[:config][:encoding].upcase
            end
            V1p1beta1::Stream.new(
              streaming_config,
              proc do |reqs|
                request_protos = reqs.lazy.map do |req|
                  Google::Gax.to_proto(
                    req,
                    Google::Cloud::Speech::V1p1beta1::StreamingRecognizeRequest
                  )
                end
                @streaming_recognize.call(request_protos, options)
              end
            )
          end
        end
      end
    end
  end
end
