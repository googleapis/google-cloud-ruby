# Copyright 2016 Google LLC
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


require "google/cloud/speech/v1"
require "google/cloud/speech/convert"

module Google
  module Cloud
    module Speech
      ##
      # # Result
      #
      # A speech recognition result corresponding to a portion of the audio.
      #
      # See {Project#recognize} and {Operation#results}.
      #
      # @see https://cloud.google.com/speech/reference/rpc/google.cloud.speech.V1#google.cloud.speech.V1.SpeechRecognitionResult
      #   SpeechRecognitionResult
      #
      # @attr_reader [String] transcript Transcript text representing the words
      #   that the user spoke.
      # @attr_reader [Float] confidence The confidence estimate between 0.0 and
      #   1.0. A higher number means the system is more confident that the
      #   recognition is correct. This field is typically provided only for the
      #   top hypothesis. A value of 0.0 is a sentinel value indicating
      #   confidence was not set.
      # @attr_reader [Array<Result::Word>] words A list of words with additional
      #   information about each word. Currently, the only additional
      #   information provided is the the start and end time offsets. Available
      #   when using the `words` argument in relevant methods.
      # @attr_reader [Array<Result::Alternative>] alternatives Additional
      #   recognition hypotheses (up to the value specified in
      #   `max_alternatives`). The server may return fewer than
      #   `max_alternatives`.
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   audio = speech.audio "path/to/audio.raw",
      #                        encoding: :linear16,
      #                        language: "en-US",
      #                        sample_rate: 16000
      #   results = audio.recognize
      #
      #   result = results.first
      #   result.transcript #=> "how old is the Brooklyn Bridge"
      #   result.confidence #=> 0.9826789498329163
      #
      class Result
        attr_reader :transcript, :confidence, :words, :alternatives

        ##
        # @private Creates a new Results instance.
        def initialize transcript, confidence, words = [], alternatives = []
          @transcript   = transcript
          @confidence   = confidence
          @words        = words
          @alternatives = alternatives
        end

        ##
        # @private New Results from a SpeechRecognitionAlternative object.
        def self.from_grpc grpc
          head, *tail = *grpc.alternatives
          return nil if head.nil?
          words = Array(head.words).map do |w|
            Word.new w.word, Convert.duration_to_number(w.start_time),
                     Convert.duration_to_number(w.end_time)
          end
          alternatives = tail.map do |alt|
            Alternative.new alt.transcript, alt.confidence
          end
          new head.transcript, head.confidence, words, alternatives
        end

        ##
        # Word-specific information for recognized words. Currently, the only
        # additional information provided is the the start and end time offsets.
        # Available when using the `words` argument in relevant methods.
        #
        # @attr_reader [String] word The word corresponding to this set of
        #   information.
        # @attr_reader [Numeric] start_time Time offset relative to the
        #   beginning of the audio, and corresponding to the start of the spoken
        #   word. This field is only set if `words` was specified. This is an
        #   experimental feature and the accuracy of the time offset can vary.
        # @attr_reader [Numeric] end_time Time offset relative to the
        #   beginning of the audio, and corresponding to the end of the spoken
        #   word. This field is only set if `words` was specified. This is an
        #   experimental feature and the accuracy of the time offset can vary.
        class Word
          attr_reader :word, :start_time, :end_time
          alias_method :to_str, :word

          ##
          # @private Creates a new Result::Word instance.
          def initialize word, start_time, end_time
            @word       = word
            @start_time = start_time
            @end_time   = end_time
          end
        end

        ##
        # # Result::Alternative
        #
        # A speech recognition result corresponding to a portion of the audio.
        #
        # @attr_reader [String] transcript Transcript text representing the
        #   words that the user spoke.
        # @attr_reader [Float] confidence The confidence estimate between 0.0
        #   and 1.0. A higher number means the system is more confident that the
        #   recognition is correct. This field is typically provided only for
        #   the top hypothesis. A value of 0.0 is a sentinel value indicating
        #   confidence was not set.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   audio = speech.audio "path/to/audio.raw",
        #                        encoding: :linear16,
        #                        language: "en-US",
        #                        sample_rate: 16000
        #   results = audio.recognize
        #
        #   result = results.first
        #   result.transcript #=> "how old is the Brooklyn Bridge"
        #   result.confidence #=> 0.9826789498329163
        #   alternative = result.alternatives.first
        #   alternative.transcript #=> "how old is the Brooklyn brim"
        #   alternative.confidence #=> 0.22030000388622284
        #
        class Alternative
          attr_reader :transcript, :confidence

          ##
          # @private Creates a new Result::Alternative instance.
          def initialize transcript, confidence
            @transcript = transcript
            @confidence = confidence
          end
        end
      end

      ##
      # # InterimResult
      #
      # A streaming speech recognition result corresponding to a portion of the
      # audio that is currently being processed.
      #
      # See {Project#stream} and {Stream#on_interim}.
      #
      # @see https://cloud.google.com/speech/reference/rpc/google.cloud.speech.V1#google.cloud.speech.V1.SpeechRecognitionResult
      #   SpeechRecognitionResult
      # @see https://cloud.google.com/speech/reference/rpc/google.cloud.speech.V1#google.cloud.speech.V1.StreamingRecognitionResult
      #   StreamingRecognitionResult
      #
      # @attr_reader [String] transcript Transcript text representing the words
      #   that the user spoke.
      # @attr_reader [Float] confidence The confidence estimate between 0.0 and
      #   1.0. A higher number means the system is more confident that the
      #   recognition is correct. This field is typically provided only for the
      #   top hypothesis. A value of 0.0 is a sentinel value indicating
      #   confidence was not set.
      # @attr_reader [Float] stability An estimate of the probability that the
      #   recognizer will not change its guess about this interim result. Values
      #   range from 0.0 (completely unstable) to 1.0 (completely stable). Note
      #   that this is not the same as confidence, which estimates the
      #   probability that a recognition result is correct.
      # @attr_reader [Array<Result::Alternative>] alternatives Additional
      #   recognition hypotheses (up to the value specified in
      #   `max_alternatives`).
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   stream = speech.stream encoding: :linear16,
      #                          language: "en-US",
      #                          sample_rate: 16000
      #
      #   # register callback for when an interim result is returned
      #   stream.on_interim do |final_results, interim_results|
      #     interim_result = interim_results.first
      #     puts interim_result.transcript # "how old is the Brooklyn Bridge"
      #     puts interim_result.confidence # 0.9826789498329163
      #     puts interim_result.stability # 0.8999
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
      class InterimResult
        attr_reader :transcript, :confidence, :stability, :alternatives

        ##
        # @private Creates a new InterimResult instance.
        def initialize transcript, confidence, stability, alternatives = []
          @transcript  = transcript
          @confidence = confidence
          @stability = stability
          @alternatives = alternatives
        end

        ##
        # @private New InterimResult from a StreamingRecognitionResult object.
        def self.from_grpc grpc
          head, *tail = *grpc.alternatives
          return nil if head.nil?
          alternatives = tail.map do |alt|
            Result::Alternative.new alt.transcript, alt.confidence
          end
          new head.transcript, head.confidence, grpc.stability, alternatives
        end
      end
    end
  end
end
