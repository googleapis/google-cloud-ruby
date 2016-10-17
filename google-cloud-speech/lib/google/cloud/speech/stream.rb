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


require "google/cloud/speech/v1beta1"
require "google/cloud/speech/result"
require "forwardable"

module Google
  module Cloud
    module Speech
      ##
      # # Stream
      #
      # A resource that represents the streaming requests and responses.
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   stream = audio.stream encoding: :raw, sample_rate: 16000
      #
      #   # register callback for when a result is returned
      #   stream.on_result do |results|
      #     result = results.first
      #     puts result.transcript # "how old is the Brooklyn Bridge"
      #     puts result.confidence # 0.9826789498329163
      #   end
      #
      #   # Stream 5 seconds of audio from the microhone
      #   # Actual implementation of microphone input varies by platform
      #   5.times.do
      #     stream.send MicrophoneInput.read(32000)
      #   end
      #
      #   stream.stop
      #
      class Stream
        ##
        # @private Creates a new Speech Stream instance.
        # This must always be private, since it may change as the implementation
        # changes over time.
        def initialize service, streaming_recognize_request
          @service = service
          @streaming_recognize_request = streaming_recognize_request
          @results = []
          @callbacks = Hash.new { |h, k| h[k] = [] }
        end

        # rubocop:disable all
        # Disabled rubocop because start is complex and all the logic needs to
        # happen on the thread. Please refactor this to make it nicer.

        ##
        # Starts the stream. The stream will be started in the first #send call.
        def start
          return if @request_queue
          @request_queue = EnumeratorQueue.new(self)
          @request_queue.push @streaming_recognize_request

          Thread.new do
            @response_enum = @service.recognize_stream @request_queue.each_item
            @response_enum.each do |response|
              unless response.is_a? V1beta1::StreamingRecognizeResponse
                fail ArgumentError, "Unable to handle #{response.class}"
              end

              # results are StreamingRecognitionResult
              final_grpc, interim_grpcs = *response.results
              if final_grpc && final_grpc.is_final
                Mutex.new.synchronize do
                  @results[response.result_index] = Result.from_grpc final_grpc
                end
                # callback for final result received
                result!
              else
                # all results are interim
                interim_grpcs = response.results
              end

              # convert to Speech object from GRPC object
              interim_results = interim_grpcs.map do |grpc|
                InterimResult.from_grpc grpc
              end
              # callback for interim results received
              interim! interim_results if interim_results.any?

              # Handle the endpointer by raising events
              if response.endpointer_type == :START_OF_SPEECH
                speech_start!
              elsif response.endpointer_type == :END_OF_SPEECH
                speech_end!
              elsif response.endpointer_type == :END_OF_AUDIO
                # TODO: do we automatically call stop here?
                complete!
              elsif response.endpointer_type == :END_OF_UTTERANCE
                # TODO: do we automatically call stop here?
                utterance!
              end
            end
            Thread.pass
          end
        end

        # rubocop:enable all

        ##
        # Checks if the stream has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        def started?
          Mutex.new.synchronize do
            !(!@request_queue)
          end
        end

        ##
        # Sends audio content to the server.
        #
        # @param [String] bytes A string of binary audio data to be recognized.
        #   The data should be encoded as `ASCII-8BIT`.
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
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def send bytes
          start # lazily call start if the stream wasn't started yet
          # TODO: do not send if stopped?
          Mutex.new.synchronize do
            req = V1beta1::StreamingRecognizeRequest.new(
              audio_content: bytes.encode("ASCII-8BIT"))
            @request_queue.push req
          end
        end

        ##
        # Stops the stream. Signals to the server that no more data will be
        # sent.
        def stop
          Mutex.new.synchronize do
            return if @request_queue.nil?
            @request_queue.push self
            @stopped = true
          end
        end

        ##
        # Checks if the stream has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        def stopped?
          Mutex.new.synchronize do
            @stopped
          end
        end

        ##
        # The speech recognition results for the audio.
        #
        # @return [Array<Result>] The transcribed text of audio recognized.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        #   results = stream.results
        #   result = results.first
        #   puts result.transcript # "how old is the Brooklyn Bridge"
        #   puts result.confidence # 0.9826789498329163
        #
        def results
          Mutex.new.synchronize do
            @results
          end
        end

        ##
        # Register to be notified on the reception of an interim result.
        #
        # @yield [callback] The block for accessing final and interim results.
        # @yieldparam [Array<Result>] final_results The final results.
        # @yieldparam [Array<Result>] interim_results The interim results.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when an interim result is returned
        #   stream.on_interim do |final_results, interim_results|
        #     interim_result = interim_results.first
        #     puts interim_result.transcript # "how old is the Brooklyn Bridge"
        #     puts interim_result.confidence # 0.9826789498329163
        #     puts interim_result.stability # 0.8999
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def on_interim &block
          @callbacks[:interim] << block
        end

        # @private yields two arguments, all final results and the
        # non-final/incomplete result
        def interim! interim_results
          @callbacks[:interim].each { |c| c.call results, interim_results }
        end

        ##
        # Register to be notified on the reception of a final result.
        #
        # @yield [callback] The block for accessing final results.
        # @yieldparam [Array<Result>] results The final results.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when an interim result is returned
        #   stream.on_result do |results|
        #     result = results.first
        #     puts result.transcript # "how old is the Brooklyn Bridge"
        #     puts result.confidence # 0.9826789498329163
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def on_result &block
          @callbacks[:result] << block
        end

        # @private yields each final results as they are recieved
        def result!
          @callbacks[:result].each { |c| c.call results }
        end

        ##
        # Register to be notified when speech has been detected in the audio
        # stream.
        #
        # @yield [callback] The block to be called when speech has been detected
        #   in the audio stream.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when speech has started.
        #   stream.on_speech_start do
        #     puts "Speech has started."
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def on_speech_start &block
          @callbacks[:speech_start] << block
        end

        # @private returns single final result once :END_OF_UTTERANCE is
        # recieved.
        def speech_start!
          @callbacks[:speech_start].each(&:call)
        end

        ##
        # Register to be notified when speech has ceased to be detected in the
        # audio stream.
        #
        # @yield [callback] The block to be called when speech has ceased to be
        #   detected in the audio stream.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when speech has ended.
        #   stream.on_speech_end do
        #     puts "Speech has ended."
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def on_speech_end &block
          @callbacks[:speech_end] << block
        end

        # @private yields single final result once :END_OF_UTTERANCE is
        # recieved.
        def speech_end!
          @callbacks[:speech_end].each(&:call)
        end

        ##
        # Register to be notified when the end of the audio stream has been
        # reached.
        #
        # @yield [callback] The block to be called when the end of the audio
        #   stream has been reached.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw, sample_rate: 16000
        #
        #   # register callback for when audio has ended.
        #   stream.on_complete do
        #     puts "Audio has ended."
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        def on_complete &block
          @callbacks[:complete] << block
        end

        # @private yields all final results once the recognition is completed
        # depending on how the Stream is configured, this can be on the
        # reception of :END_OF_AUDIO or :END_OF_UTTERANCE.
        def complete!
          @callbacks[:complete].each(&:call)
        end

        ##
        # Register to be notified when the server has detected the end of the
        # user's speech utterance and expects no additional speech. Therefore,
        # the server will not process additional audio. The client should stop
        # sending additional audio data. This event only occurs when `utterance`
        # is `true`.
        #
        # @yield [callback] The block to be called when the end of the audio
        #   stream has been reached.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   stream = audio.stream encoding: :raw,
        #                         sample_rate: 16000,
        #                         utterance: true
        #
        #   # register callback for when utterance has occurred.
        #   stream.on_utterance do
        #     puts "Utterance has occurred."
        #     stream.stop
        #   end
        #
        #   # Stream 5 seconds of audio from the microhone
        #   # Actual implementation of microphone input varies by platform
        #   5.times.do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop unless stream.stopped?
        #
        def on_utterance &block
          @callbacks[:utterance] << block
        end

        # @private returns single final result once :END_OF_UTTERANCE is
        # recieved.
        def utterance!
          @callbacks[:utterance].each(&:call)
        end

        # @private
        class EnumeratorQueue
          extend Forwardable
          def_delegators :@q, :push

          # @private
          def initialize sentinel
            @q = Queue.new
            @sentinel = sentinel
          end

          # @private
          def each_item
            return enum_for(:each_item) unless block_given?
            loop do
              r = @q.pop
              break if r.equal? @sentinel
              fail r if r.is_a? Exception
              yield r
            end
          end
        end
      end
    end
  end
end
