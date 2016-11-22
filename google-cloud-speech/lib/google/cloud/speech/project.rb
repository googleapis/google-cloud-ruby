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
require "google/cloud/core/environment"
require "google/cloud/speech/service"
require "google/cloud/speech/audio"
require "google/cloud/speech/result"
require "google/cloud/speech/job"
require "google/cloud/speech/stream"

module Google
  module Cloud
    module Speech
      ##
      # # Project
      #
      # The Google Cloud Speech API enables developers to convert audio to text
      # by applying powerful neural network models. The API recognizes over 80
      # languages and variants, to support your global user base. You can
      # transcribe the text of users dictating to an application's microphone,
      # enable command-and-control through voice, or transcribe audio files,
      # among many other use cases. Recognize audio uploaded in the request, and
      # integrate with your audio storage on Google Cloud Storage, by using the
      # same technology Google uses to power its own products.
      #
      # See {Google::Cloud#speech}
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   audio = speech.audio "path/to/audio.raw",
      #                        encoding: :raw, sample_rate: 16000
      #   results = audio.recognize
      #
      #   result = results.first
      #   result.transcript #=> "how old is the Brooklyn Bridge"
      #   result.confidence #=> 0.9826789498329163
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
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new(
        #     project: "my-project-id",
        #     keyfile: "/path/to/keyfile.json"
        #   )
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
            Google::Cloud::Core::Environment.project_id
        end

        ##
        # Returns a new Audio instance from the given source. No API call is
        # made.
        #
        # @see https://cloud.google.com/speech/docs/basics#audio-encodings
        #   Audio Encodings
        # @see https://cloud.google.com/speech/docs/basics#sample-rates
        #   Sample Rates
        # @see https://cloud.google.com/speech/docs/basics#languages
        #   Languages
        #
        # @param [String, IO, Google::Cloud::Storage::File] source A string of
        #   the path to the audio file to be recognized, or a File or other IO
        #   object of the audio contents, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] encoding Encoding of audio data to be
        #   recognized. Optional.
        #
        #   Acceptable values are:
        #
        #   * `raw` - Uncompressed 16-bit signed little-endian samples.
        #     (LINEAR16)
        #   * `flac` - The [Free Lossless Audio
        #     Codec](http://flac.sourceforge.net/documentation.html) encoding.
        #     Only 16-bit samples are supported. Not all fields in STREAMINFO
        #     are supported. (FLAC)
        #   * `mulaw` - 8-bit samples that compand 14-bit audio samples using
        #     G.711 PCMU/mu-law. (MULAW)
        #   * `amr` - Adaptive Multi-Rate Narrowband codec. (`sample_rate` must
        #     be 8000 Hz.) (AMR)
        #   * `amr_wb` - Adaptive Multi-Rate Wideband codec. (`sample_rate` must
        #     be 16000 Hz.) (AMR_WB)
        #
        # @param [Integer] sample_rate Sample rate in Hertz of the audio data
        #   to be recognized. Valid values are: 8000-48000. 16000 is optimal.
        #   For best results, set the sampling rate of the audio source to 16000
        #   Hz. If that's not possible, use the native sample rate of the audio
        #   source (instead of re-sampling). Optional.
        # @param [String] language The language of the supplied audio as a
        #   [BCP-47](https://tools.ietf.org/html/bcp47) language
        #   code. If not specified, the language defaults to "en-US".  See
        #   [Language
        #   Support](https://cloud.google.com/speech/docs/languages)
        #   for a list of the currently supported language codes. Optional.
        #
        # @return [Audio] The audio file to be recognized.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   audio = speech.audio "path/to/audio.raw",
        #                        encoding: :raw, sample_rate: 16000
        #
        # @example With a Google Cloud Storage URI:
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   audio = speech.audio "gs://bucket-name/path/to/audio.raw",
        #                        encoding: :raw, sample_rate: 16000
        #
        # @example With a Google Cloud Storage File object:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "bucket-name"
        #   file = bucket.file "path/to/audio.raw"
        #
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   audio = speech.audio file, encoding: :raw, sample_rate: 16000
        #
        def audio source, encoding: nil, sample_rate: nil, language: nil
          if source.is_a? Audio
            audio = source.dup
          else
            audio = Audio.from_source source, self
          end
          audio.encoding = encoding unless encoding.nil?
          audio.sample_rate = sample_rate unless sample_rate.nil?
          audio.language = language unless language.nil?
          audio
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
        # @param [String, IO, Google::Cloud::Storage::File] source A string of
        #   the path to the audio file to be recognized, or a File or other IO
        #   object of the audio contents, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] encoding Encoding of audio data to be
        #   recognized. Optional.
        #
        #   Acceptable values are:
        #
        #   * `raw` - Uncompressed 16-bit signed little-endian samples.
        #     (LINEAR16)
        #   * `flac` - The [Free Lossless Audio
        #     Codec](http://flac.sourceforge.net/documentation.html) encoding.
        #     Only 16-bit samples are supported. Not all fields in STREAMINFO
        #     are supported. (FLAC)
        #   * `mulaw` - 8-bit samples that compand 14-bit audio samples using
        #     G.711 PCMU/mu-law. (MULAW)
        #   * `amr` - Adaptive Multi-Rate Narrowband codec. (`sample_rate` must
        #     be 8000 Hz.) (AMR)
        #   * `amr_wb` - Adaptive Multi-Rate Wideband codec. (`sample_rate` must
        #     be 16000 Hz.) (AMR_WB)
        #
        # @param [Integer] sample_rate Sample rate in Hertz of the audio data
        #   to be recognized. Valid values are: 8000-48000. 16000 is optimal.
        #   For best results, set the sampling rate of the audio source to 16000
        #   Hz. If that's not possible, use the native sample rate of the audio
        #   source (instead of re-sampling). Optional.
        # @param [String] language The language of the supplied audio as a
        #   [BCP-47](https://tools.ietf.org/html/bcp47) language
        #   code. If not specified, the language defaults to "en-US".  See
        #   [Language
        #   Support](https://cloud.google.com/speech/docs/languages)
        #   for a list of the currently supported language codes. Optional.
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
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   results = speech.recognize "path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        # @example With a Google Cloud Storage URI:
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   results = speech.recognize "gs://bucket-name/path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        # @example With a Google Cloud Storage File object:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "bucket-name"
        #   file = bucket.file "path/to/audio.raw"
        #
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   results = speech.recognize file, encoding: :raw,
        #                              sample_rate: 16000,
        #                              max_alternatives: 10
        #
        def recognize source, encoding: nil, sample_rate: nil, language: nil,
                      max_alternatives: nil, profanity_filter: nil, phrases: nil
          ensure_service!

          audio_obj = audio source, encoding: encoding,
                                    sample_rate: sample_rate, language: language

          config = audio_config(
            encoding: audio_obj.encoding, sample_rate: audio_obj.sample_rate,
            language: audio_obj.language, max_alternatives: max_alternatives,
            profanity_filter: profanity_filter, phrases: phrases)

          grpc = service.recognize_sync audio_obj.to_grpc, config
          grpc.results.map do |result_grpc|
            Result.from_grpc result_grpc
          end
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
        # @param [String, IO, Google::Cloud::Storage::File] source A string of
        #   the path to the audio file to be recognized, or a File or other IO
        #   object of the audio contents, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] encoding Encoding of audio data to be
        #   recognized. Optional.
        #
        #   Currently, the only acceptable value is:
        #
        #   * `raw` - Uncompressed 16-bit signed little-endian samples.
        #     (LINEAR16)
        #
        # @param [Integer] sample_rate Sample rate in Hertz of the audio data
        #   to be recognized. Valid values are: 8000-48000. 16000 is optimal.
        #   For best results, set the sampling rate of the audio source to 16000
        #   Hz. If that's not possible, use the native sample rate of the audio
        #   source (instead of re-sampling). Optional.
        # @param [String] language The language of the supplied audio as a
        #   [BCP-47](https://tools.ietf.org/html/bcp47) language
        #   code. If not specified, the language defaults to "en-US".  See
        #   [Language
        #   Support](https://cloud.google.com/speech/docs/languages)
        #   for a list of the currently supported language codes. Optional.
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
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   job = speech.recognize_job "path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        #   job.done? #=> false
        #   job.reload!
        #
        # @example With a Google Cloud Storage URI:
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   job = speech.recognize_job "gs://bucket-name/path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        #   job.done? #=> false
        #   job.reload!
        #
        # @example With a Google Cloud Storage File object:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "bucket-name"
        #   file = bucket.file "path/to/audio.raw"
        #
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   job = speech.recognize_job file, encoding: :raw,
        #                              sample_rate: 16000,
        #                              max_alternatives: 10
        #
        #   job.done? #=> false
        #   job.reload!
        #
        def recognize_job source, encoding: nil, sample_rate: nil,
                          language: nil, max_alternatives: nil,
                          profanity_filter: nil, phrases: nil
          ensure_service!

          audio_obj = audio source, encoding: encoding,
                                    sample_rate: sample_rate, language: language

          config = audio_config(
            encoding: audio_obj.encoding, sample_rate: audio_obj.sample_rate,
            language: audio_obj.language, max_alternatives: max_alternatives,
            profanity_filter: profanity_filter, phrases: phrases)

          grpc = service.recognize_async audio_obj.to_grpc, config
          Job.from_grpc grpc, service
        end

        ##
        # Creates a Stream object to perform bidirectional streaming
        # speech-recognition: receive results while sending audio.
        #
        # @see https://cloud.google.com/speech/docs/basics#streaming-recognition
        #   Streaming Speech API Recognition Requests
        #
        # @param [String, Symbol] encoding Encoding of audio data to be
        #   recognized. Optional.
        #
        #   Acceptable values are:
        #
        #   * `raw` - Uncompressed 16-bit signed little-endian samples.
        #     (LINEAR16)
        #   * `flac` - The [Free Lossless Audio
        #     Codec](http://flac.sourceforge.net/documentation.html) encoding.
        #     Only 16-bit samples are supported. Not all fields in STREAMINFO
        #     are supported. (FLAC)
        #   * `mulaw` - 8-bit samples that compand 14-bit audio samples using
        #     G.711 PCMU/mu-law. (MULAW)
        #   * `amr` - Adaptive Multi-Rate Narrowband codec. (`sample_rate` must
        #     be 8000 Hz.) (AMR)
        #   * `amr_wb` - Adaptive Multi-Rate Wideband codec. (`sample_rate` must
        #     be 16000 Hz.) (AMR_WB)
        #
        # @param [Integer] sample_rate Sample rate in Hertz of the audio data
        #   to be recognized. Valid values are: 8000-48000. 16000 is optimal.
        #   For best results, set the sampling rate of the audio source to 16000
        #   Hz. If that's not possible, use the native sample rate of the audio
        #   source (instead of re-sampling). Optional.
        # @param [String] language The language of the supplied audio as a
        #   [BCP-47](https://tools.ietf.org/html/bcp47) language
        #   code. If not specified, the language defaults to "en-US".  See
        #   [Language
        #   Support](https://cloud.google.com/speech/docs/languages)
        #   for a list of the currently supported language codes. Optional.
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
        # @param [Boolean] utterance When `true`, the service will perform
        #   continuous recognition (continuing to process audio even if the user
        #   pauses speaking) until the client closes the output stream (gRPC
        #   API) or when the maximum time limit has been reached. Default is
        #   `false`.
        # @param [Boolean] interim When `true`, interim results (tentative
        #   hypotheses) may be returned as they become available. Default is
        #   `false`.
        #
        # @return [Stream] A resource that represents the streaming requests and
        #   responses.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = speech.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when a result is returned
        #   stream.on_result do |results|
        #     result = results.first
        #     puts result.transcript # "how old is the Brooklyn Bridge"
        #     puts result.confidence # 0.9826789498329163
        #   end
        #
        #   # Stream 5 seconds of audio from the microphone
        #   # Actual implementation of microphone input varies by platform
        #   5.times do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def stream encoding: nil, sample_rate: nil, language: nil,
                   max_alternatives: nil, profanity_filter: nil, phrases: nil,
                   utterance: nil, interim: nil
          ensure_service!

          grpc_req = V1beta1::StreamingRecognizeRequest.new(
            streaming_config: V1beta1::StreamingRecognitionConfig.new(
              {
                config: audio_config(encoding: convert_encoding(encoding),
                                     sample_rate: sample_rate,
                                     language: language,
                                     max_alternatives: max_alternatives,
                                     profanity_filter: profanity_filter,
                                     phrases: phrases),
                single_utterance: utterance,
                interim_results: interim
              }.delete_if { |_, v| v.nil? }
            )
          )

          Stream.new service, grpc_req
        end

        protected

        def audio_config encoding: nil, sample_rate: nil, language: nil,
                         max_alternatives: nil, profanity_filter: nil,
                         phrases: nil
          context = nil
          context = V1beta1::SpeechContext.new(phrases: phrases) if phrases
          language = String(language) unless language.nil?
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
