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

module Google
  module Cloud
    module Speech
      ##
      # # Job
      #
      # A resource represents the long-running, asynchronous processing of a
      # speech-recognition operation. The job can be refreshed to retrieve
      # recognition results once the audio data has been processed.
      #
      # See {Project#recognize_job} and {Audio#recognize_job}.
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
      #   job = speech.recognize_job "path/to/audio.raw",
      #                              encoding: :raw, sample_rate: 16000
      #
      #   job.done? #=> false
      #   job.reload! # API call
      #   job.done? #=> true
      #   results = job.results
      #
      class Job
        ##
        # @private The Google::Gax::Operation gRPC object.
        attr_accessor :grpc

        ##
        # @private Creates a new Job instance.
        def initialize
          @grpc = nil
        end

        ##
        # A speech recognition result corresponding to a portion of the audio.
        #
        # @return [Array<Result>] The transcribed text of audio recognized. If
        #   the job is not done this will return `nil`.
        #
        # @example
        #   require "google/cloud/speech"
        #
        #   speech = Google::Cloud::Speech.new
        #
        #   job = speech.recognize_job "path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        #   job.done? #=> true
        #   results = job.results
        #
        def results
          return nil unless @grpc.response?
          @grpc.response.results.map do |result_grpc|
            Result.from_grpc result_grpc
          end
          # TODO: Ensure we are raising the proper error
          # TODO: Ensure GRPC behavior here, is an error already raised?
          # raise @grpc.error
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
        #   job = speech.recognize_job "path/to/audio.raw",
        #                              encoding: :raw, sample_rate: 16000
        #
        #   job.done? #=> false
        #
        def done?
          @grpc.done?
        end

        ##
        # Reloads the job with current data from the long-running, asynchronous
        # processing of a speech-recognition operation.
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
        #   job.reload! # API call
        #   job.done? #=> true
        #
        def reload!
          @grpc.reload!
          self
        end
        alias_method :refresh!, :reload!

        ##
        # Reloads the job until the operation is complete. The delay between
        # reloads will incrementally increase.
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
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        def wait_until_done!
          @grpc.wait_until_done!
        end

        ##
        # @private New Result::Job from a Google::Longrunning::Operation
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
