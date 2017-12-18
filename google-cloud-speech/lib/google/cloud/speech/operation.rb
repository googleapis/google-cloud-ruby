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
require "google/cloud/errors"

module Google
  module Cloud
    module Speech
      ##
      # # Operation
      #
      # A resource represents the long-running, asynchronous processing of a
      # speech-recognition operation. The op can be refreshed to retrieve
      # recognition results once the audio data has been processed.
      #
      # See {Project#process} and {Audio#process}.
      #
      # @see https://cloud.google.com/speech/docs/basics#async-responses
      #   Asynchronous Speech API Responses
      # @see https://cloud.google.com/speech/reference/rpc/google.longrunning#google.longrunning.Operations
      #   Long-running Operation
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   op = speech.process "path/to/audio.raw",
      #                       encoding: :linear16,
      #                       language: "en-US",
      #                       sample_rate: 16000
      #
      #   op.done? #=> false
      #   op.reload! # API call
      #   op.done? #=> true
      #   results = op.results
      #
      class Operation
        ##
        # @private The Google::Gax::Operation gRPC object.
        attr_accessor :grpc

        ##
        # @private Creates a new Job instance.
        def initialize
          @grpc = nil
        end

        ##
        # The unique identifier for the long running operation.
        #
        # @return [String] The unique identifier for the long running operation.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.id #=> "1234567890"
        #
        def id
          @grpc.name
        end

        ##
        # Checks if the speech-recognition processing of the audio data is
        # complete.
        #
        # @return [boolean] `true` when complete, `false` otherwise.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> false
        #
        def done?
          @grpc.done?
        end

        ##
        # A speech recognition result corresponding to a portion of the audio.
        #
        # @return [Array<Result>] The transcribed text of audio recognized. If
        #   the op is not done this will return `nil`.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> true
        #   op.results? #=> true
        #   results = op.results
        #
        def results
          return nil unless results?
          @grpc.response.results.map do |result_grpc|
            Result.from_grpc result_grpc
          end
        end

        ##
        # Checks if the speech-recognition processing of the audio data is
        # complete.
        #
        # @return [boolean] `true` when complete, `false` otherwise.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> true
        #   op.results? #=> true
        #   results = op.results
        #
        def results?
          @grpc.response?
        end

        ##
        # The error information if the speech-recognition processing of the
        # audio data has returned an error.
        #
        # @return [Google::Cloud::Error] The error.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> true
        #   op.error? #=> true
        #   error = op.error
        #
        def error
          return nil unless error?
          Google::Cloud::Error.from_error @grpc.error
        end

        ##
        # Checks if the speech-recognition processing of the audio data has
        # returned an error.
        #
        # @return [boolean] `true` when errored, `false` otherwise.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> true
        #   op.error? #=> true
        #   error = op.error
        #
        def error?
          @grpc.error?
        end

        ##
        # Reloads the op with current data from the long-running, asynchronous
        # processing of a speech-recognition operation.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> false
        #   op.reload! # API call
        #   op.done? #=> true
        #
        def reload!
          @grpc.reload!
          self
        end
        alias_method :refresh!, :reload!

        ##
        # Reloads the op until the operation is complete. The delay between
        # reloads will incrementally increase.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   op = speech.process "path/to/audio.raw",
        #                       encoding: :linear16,
        #                       language: "en-US",
        #                       sample_rate: 16000
        #
        #   op.done? #=> false
        #   op.wait_until_done!
        #   op.done? #=> true
        #
        def wait_until_done!
          @grpc.wait_until_done!
        end

        ##
        # @private New Result::Job from a Google::Gax::Operation
        # object.
        def self.from_grpc grpc
          new.tap do |job|
            job.instance_variable_set :@grpc, grpc
          end
        end
      end
    end
  end
end
