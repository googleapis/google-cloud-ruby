# Copyright 2016 Google LLC
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


require "google/cloud/speech/v1"
require "google/cloud/speech/result"
require "monitor"
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
      #   stream = speech.stream encoding: :linear16,
      #                          language: "en-US",
      #                          sample_rate: 16000
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
      #   result = results.first
      #   result.transcript #=> "how old is the Brooklyn Bridge"
      #   result.confidence #=> 0.9826789498329163
      #
      class Stream
        include MonitorMixin
        ##
        # @private Creates a new Speech Stream instance.
        # This must always be private, since it may change as the implementation
        # changes over time.
        def initialize service, streaming_recognize_request
          @service = service
          @streaming_recognize_request = streaming_recognize_request
          @results = []
          @callbacks = Hash.new { |h, k| h[k] = [] }
          super() # to init MonitorMixin
        end

        ##
        # Starts the stream. The stream will be started in the first #send call.
        def start
          return if @request_queue
          @request_queue = EnumeratorQueue.new(self)
          @request_queue.push @streaming_recognize_request

          Thread.new { background_run }
        end

        ##
        # Checks if the stream has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        def started?
          synchronize do
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
        #   audio = speech.audio "path/to/audio.raw"
        #
        #   stream = speech.stream encoding: :linear16,
        #                          language: "en-US",
        #                          sample_rate: 16000
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
        #   result = results.first
        #   result.transcript #=> "how old is the Brooklyn Bridge"
        #   result.confidence #=> 0.9826789498329163
        #
        def send bytes
          start # lazily call start if the stream wasn't started yet
          # TODO: do not send if stopped?
          synchronize do
            req = V1::StreamingRecognizeRequest.new(
              audio_content: bytes.encode("ASCII-8BIT")
            )
            @request_queue.push req
          end
        end

        ##
        # Stops the stream. Signals to the server that no more data will be
        # sent.
        def stop
          synchronize do
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
          synchronize do
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
        #   stream = speech.stream encoding: :linear16,
        #                          language: "en-US",
        #                          sample_rate: 16000
        #
        #   # Stream 5 seconds of audio from the microphone
        #   # Actual implementation of microphone input varies by platform
        #   5.times do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        #   results = stream.results
        #   results.each do |result|
        #     puts result.transcript
        #     puts result.confidence
        #   end
        #
        def results
          synchronize do
            @results
          end
        end

        ##
        # Whether all speech recognition results have been returned.
        #
        # @return [Boolean] All speech recognition results have been returned.
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
        #   # Stream 5 seconds of audio from the microphone
        #   # Actual implementation of microphone input varies by platform
        #   5.times do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        #   stream.wait_until_complete!
        #   stream.complete? #=> true
        #
        #   results = stream.results
        #   results.each do |result|
        #     puts result.transcript
        #     puts result.confidence
        #   end
        #
        def complete?
          synchronize do
            @complete
          end
        end

        ##
        # Blocks until all speech recognition results have been returned.
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
        #   # Stream 5 seconds of audio from the microphone
        #   # Actual implementation of microphone input varies by platform
        #   5.times do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop
        #
        #   stream.wait_until_complete!
        #   stream.complete? #=> true
        #
        #   results = stream.results
        #   results.each do |result|
        #     puts result.transcript
        #     puts result.confidence
        #   end
        #
        def wait_until_complete!
          complete_check = nil
          synchronize { complete_check = @complete }
          while complete_check.nil?
            sleep 1
            synchronize { complete_check = @complete }
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
        def on_interim &block
          synchronize do
            @callbacks[:interim] << block
          end
        end

        ##
        # @private yields two arguments, all final results and the
        # non-final/incomplete result
        def pass_interim! interim_results
          synchronize do
            @callbacks[:interim].each { |c| c.call results, interim_results }
          end
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
        #   stream = speech.stream encoding: :linear16,
        #                          language: "en-US",
        #                          sample_rate: 16000
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
        #   result = results.first
        #   result.transcript #=> "how old is the Brooklyn Bridge"
        #   result.confidence #=> 0.9826789498329163
        #
        def on_result &block
          synchronize do
            @callbacks[:result] << block
          end
        end

        ##
        # @private add a result object, and call the callbacks
        def pass_result! result_grpc
          synchronize do
            @results << Result.from_grpc(result_grpc)
            @callbacks[:result].each { |c| c.call @results }
          end
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
        #   stream = speech.stream encoding: :linear16,
        #                          language: "en-US",
        #                          sample_rate: 16000
        #
        #   # register callback for when stream has ended.
        #   stream.on_complete do
        #     puts "Stream has ended."
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
        def on_complete &block
          synchronize do
            @callbacks[:complete] << block
          end
        end

        ##
        # @private yields when the end of the audio stream has been reached.
        def pass_complete!
          synchronize do
            @complete = true
            @callbacks[:complete].each(&:call)
          end
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
        #   stream = speech.stream encoding: :linear16,
        #                          language: "en-US",
        #                          sample_rate: 16000,
        #                          utterance: true
        #
        #   # register callback for when utterance has occurred.
        #   stream.on_utterance do
        #     puts "Utterance has occurred."
        #     stream.stop
        #   end
        #
        #   # Stream 5 seconds of audio from the microphone
        #   # Actual implementation of microphone input varies by platform
        #   5.times do
        #     stream.send MicrophoneInput.read(32000)
        #   end
        #
        #   stream.stop unless stream.stopped?
        #
        def on_utterance &block
          synchronize do
            @callbacks[:utterance] << block
          end
        end

        ##
        # @private returns single final result once :END_OF_SINGLE_UTTERANCE is
        # received.
        def pass_utterance!
          synchronize do
            @callbacks[:utterance].each(&:call)
          end
        end

        ##
        # Register to be notified of an error received during the stream.
        #
        # @yield [callback] The block for accessing final results.
        # @yieldparam [Exception] error The error raised.
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
        #   # register callback for when an error is returned
        #   stream.on_error do |error|
        #     puts "The following error occurred while streaming: #{error}"
        #     stream.stop
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
        def on_error &block
          synchronize do
            @callbacks[:error] << block
          end
        end

        # @private returns error object from the stream thread.
        def error! err
          synchronize do
            @callbacks[:error].each { |c| c.call err }
          end
        end

        protected

        def background_run
          response_enum = @service.recognize_stream @request_queue.each_item
          response_enum.each do |response|
            begin
              background_results response
              background_event_type response.speech_event_type
              background_error response.error
            rescue StandardError => e
              error! Google::Cloud::Error.from_error(e)
            end
          end
        rescue StandardError => e
          error! Google::Cloud::Error.from_error(e)
        ensure
          pass_complete!
          Thread.pass
        end

        def background_results response
          # Handle the results (StreamingRecognitionResult)
          return unless response.results && response.results.any?

          final_grpc, interim_grpcs = *response.results
          unless final_grpc && final_grpc.is_final
            # all results are interim
            final_grpc = nil
            interim_grpcs = response.results
          end

          # convert to Speech object from GRPC object
          interim_results = Array(interim_grpcs).map do |grpc|
            InterimResult.from_grpc grpc
          end

          # callback for interim results received
          pass_interim! interim_results if interim_results.any?
          # callback for final results received, if any
          pass_result! final_grpc if final_grpc
        end

        def background_event_type event_type
          # Handle the event_type by raising events
          # TODO: do we automatically call stop here?
          pass_utterance! if event_type == :END_OF_SINGLE_UTTERANCE
        end

        def background_error error
          return if error.nil?

          require "grpc/errors"
          raise GRPC::BadStatus.new(error.code, error.message)
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
              raise r if r.is_a? Exception
              yield r
            end
          end
        end
      end
    end
  end
end
