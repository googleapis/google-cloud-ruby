# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/cloud/core/gce"
require "google/cloud/speech/service"
require "google/cloud/speech/audio"
require "google/cloud/speech/result"
require "google/cloud/speech/job"

module Google
  module Cloud
    module Speech
      ##
      # # Project
      #
      # ...
      #
      # See {Google::Cloud#speech}
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   speech = gcloud.speech
      #
      #   # ...
      #
      class Project
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Speech Project instance.
        def initialize service
          @service = service
        end

        # The Speech project connected to.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new "my-project-id",
        #                              "/path/to/keyfile.json"
        #   speech = gcloud.speech
        #
        #   speech.project #=> "my-project-id"
        #
        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["SPEECH_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::GCE.project_id
        end

        def audio source, encoding: nil, sample_rate: nil, language: nil
          audio = Audio.from_source source
          audio.encoding = encoding unless encoding.nil?
          audio.sample_rate = sample_rate unless sample_rate.nil?
          audio.language = language unless language.nil?
          audio
        end

        def recognize source, encoding: nil, sample_rate: nil, language: nil,
                      max_alternatives: nil, profanity_filter: nil, phrases: nil
          ensure_service!

          config = audio_config(
            encoding: encoding, sample_rate: sample_rate, language: language,
            max_alternatives: max_alternatives,
            profanity_filter: profanity_filter, phrases: phrases)

          grpc = service.recognize_sync audio(source).to_grpc, config
          grpc.results.map do |result_grpc|
            Result.from_grpc result_grpc
          end
        end

        def recognize_job source, encoding: nil, sample_rate: nil,
                          language: nil, max_alternatives: nil,
                          profanity_filter: nil, phrases: nil
          ensure_service!

          config = audio_config(
            encoding: encoding, sample_rate: sample_rate, language: language,
            max_alternatives: max_alternatives,
            profanity_filter: profanity_filter, phrases: phrases)

          grpc = service.recognize_async audio(source).to_grpc, config
          Job.from_grpc grpc, service
        end

        protected

        def audio_config encoding: nil, sample_rate: nil, language: nil,
                         max_alternatives: nil, profanity_filter: nil,
                         phrases: nil
          context = nil
          context = V1beta1::SpeechContext.new(phrases: phrases) if phrases
          V1beta1::RecognitionConfig.new({
            encoding: convert_encoding(encoding),
            sample_rate: sample_rate,
            language_code: language,
            max_alternatives: max_alternatives,
            profanity_filter: profanity_filter,
            speech_context: context
          }.delete_if { |_, v| v.nil? })
        end

        def convert_encoding encoding
          mapping = { raw: :LINEAR16, linear: :LINEAR16, linear16: :LINEAR16,
                      flac: :FLAC, mulaw: :MULAW, amr: :AMR, amr_wb: :AMR_WB }
          mapping[encoding] || encoding
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
