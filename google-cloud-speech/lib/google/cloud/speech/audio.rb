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


module Google
  module Cloud
    module Speech
      ##
      # # Audio
      #
      # Represents a source of audio data, with related metadata such as the
      # [audio encoding](https://cloud.google.com/speech/docs/basics#audio-encodings),
      # [sample rate](https://cloud.google.com/speech/docs/basics#sample-rates),
      # and [language](https://cloud.google.com/speech/docs/basics#languages).
      #
      # See {Project#audio}.
      #
      # @see https://cloud.google.com/speech/docs/basics#audio-encodings
      #   Audio Encodings
      # @see https://cloud.google.com/speech/docs/basics#sample-rates
      #   Sample Rates
      # @see https://cloud.google.com/speech/docs/basics#languages
      #   Languages
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   speech = gcloud.speech
      #
      #   audio = speech.audio "path/to/audio.raw",
      #                        encoding: :raw, sample_rate: 16000
      #   results = audio.recognize
      #
      #   result = results.first
      #   result.transcript #=> "how old is the Brooklyn Bridge"
      #   result.confidence #=> 88.15
      #
      class Audio
        # @private The V1beta1::RecognitionAudio object.
        attr_reader :grpc
        # @private The Project object.
        attr_reader :speech
        attr_accessor :encoding
        attr_accessor :sample_rate
        attr_accessor :language

        ##
        # @private Creates a new Audio instance.
        def initialize
          @grpc = V1beta1::RecognitionAudio.new
        end

        ##
        # @private Whether the Audio has content.
        #
        def content?
          @grpc.audio_source == :content
        end

        ##
        # @private Whether the Audio is a URL.
        #
        def url?
          @grpc.audio_source == :uri
        end

        ##
        # Performs synchronous speech recognition. Sends audio data to the
        # Speech API, which performs recognition on that data, and returns
        # results only after all audio has been processed. Limited to audio data
        # of 1 minute or less in duration.
        #
        # The Speech API will take roughly the same amount of time to process
        # audio data sent synchronously as the duration of the supplied audio
        # data. That is, if you send audio data of 30 seconds in length, expect
        # the synchronous request to take approximately 30 seconds to return
        # results.
        #
        # @see https://cloud.google.com/speech/docs/basics#synchronous-recognition
        #   Synchronous Speech API Recognition
        # @see https://cloud.google.com/speech/docs/basics#phrase-hints
        #   Phrase Hints
        #
        # @param [String] max_alternatives The Maximum number of recognition
        #   hypotheses to be returned. Default is 1. The service may return
        #   fewer. Valid values are 0-30. Defaults to 1. Optional.
        # @param [Boolean] profanity_filter When `true`, the service will
        #   attempt to filter out profanities, replacing all but the initial
        #   character in each filtered word with asterisks, e.g. "f***". Default
        #   is `false`.
        # @param [Array<String>] phrases A list of strings containing words and
        #   phrases "hints" so that the speech recognition is more likely to
        #   recognize them. See [usage
        #   limits](https://cloud.google.com/speech/limits#content). Optional.
        #
        # @return [Array<Result>] The transcribed text of audio recognized.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   speech = gcloud.speech
        #
        #   audio = speech.audio "path/to/audio.raw",
        #                        encoding: :raw, sample_rate: 16000
        #   results = audio.recognize
        #
        #   result = results.first
        #   result.transcript #=> "how old is the Brooklyn Bridge"
        #   result.confidence #=> 88.15
        #
        def recognize max_alternatives: nil, profanity_filter: nil, phrases: nil
          ensure_speech!

          speech.recognize self, encoding: encoding, sample_rate: sample_rate,
                                 language: language,
                                 max_alternatives: max_alternatives,
                                 profanity_filter: profanity_filter,
                                 phrases: phrases
        end

        ##
        # Performs asynchronous speech recognition. Requests are processed
        # asynchronously, meaning a Job is returned once the audio data has been
        # sent, and can be refreshed to retrieve recognition results once the
        # audio data has been processed.
        #
        # @see https://cloud.google.com/speech/docs/basics#async-responses
        #   Asynchronous Speech API Responses
        #
        # @param [String] max_alternatives The Maximum number of recognition
        #   hypotheses to be returned. Default is 1. The service may return
        #   fewer. Valid values are 0-30. Defaults to 1. Optional.
        # @param [Boolean] profanity_filter When `true`, the service will
        #   attempt to filter out profanities, replacing all but the initial
        #   character in each filtered word with asterisks, e.g. "f***". Default
        #   is `false`.
        # @param [Array<String>] phrases A list of strings containing words and
        #   phrases "hints" so that the speech recognition is more likely to
        #   recognize them. See [usage
        #   limits](https://cloud.google.com/speech/limits#content). Optional.
        #
        # @return [Job] A resource represents the long-running, asynchronous
        #   processing of a speech-recognition operation.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   speech = gcloud.speech
        #
        #   audio = speech.audio "path/to/audio.raw",
        #                        encoding: :raw, sample_rate: 16000
        #   job = audio.recognize_job
        #
        #   job.done? #=> false
        #   job.reload!
        #   job.done? #=> true
        #   results = job.results
        #
        def recognize_job max_alternatives: nil, profanity_filter: nil,
                          phrases: nil
          ensure_speech!

          speech.recognize_job self, encoding: encoding,
                                     sample_rate: sample_rate,
                                     language: language,
                                     max_alternatives: max_alternatives,
                                     profanity_filter: profanity_filter,
                                     phrases: phrases
        end

        ##
        # @private The Google API Client object for the Audio.
        def to_grpc
          @grpc
        end

        ##
        # @private New Audio from a source object.
        def self.from_source source, speech
          audio = new
          audio.instance_variable_set :@speech, speech
          if source.respond_to?(:read) && source.respond_to?(:rewind)
            source.rewind
            audio.grpc.content = source.read
            return audio
          end
          # Convert Storage::File objects to the URL
          source = source.to_gs_url if source.respond_to? :to_gs_url
          # Everything should be a string from now on
          source = String source
          # Create an Audio from the Google Storage URL
          if source.start_with? "gs://"
            audio.grpc.uri = source
            return audio
          end
          # Create an audio from a file on the filesystem
          if File.file? source
            fail ArgumentError, "Cannot read #{source}" unless \
              File.readable? source
            audio.grpc.content = File.read source, mode: "rb"
            return audio
          end
          fail ArgumentError, "Unable to convert #{source} to an Audio"
        end

        protected

        ##
        # Raise an error unless an active Speech Project object is available.
        def ensure_speech!
          fail "Must have active connection" unless @speech
        end
      end
    end
  end
end
