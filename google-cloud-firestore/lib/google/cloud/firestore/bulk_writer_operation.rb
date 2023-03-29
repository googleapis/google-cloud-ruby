# Copyright 2023 Google LLC
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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/service"
require "google/cloud/firestore/field_path"
require "google/cloud/firestore/field_value"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/collection_group"
require "google/cloud/firestore/batch"
require "google/cloud/firestore/transaction"
require "concurrent"


module Google
  module Cloud
    module Firestore
      ##
      # @private
      class BulkWriterOperation

        attr_reader :retry_time
        attr_reader :result
        attr_reader :completion_event
        attr_reader :write


        MAX_RETRY_ATTEMPTS = 10

        ##
        # Initialize the object
        def initialize write, document_reference
          @write = write
          @completion_event = Concurrent::Event.new
          @status = nil
          @result = nil
          @failed_attempts = 0
          @document_reference = document_reference
          @retry_time = Time.now
          @failure_message = nil
        end

        ##
        # Processing to be done when the response is a failure.
        # Updates the result and set the completion event.
        #
        # @param [String] status The status in the response.
        # @param [] value The value returned in the response.
        def on_success status, value
          # puts "Success"
          @completion_event.set
        end

        ##
        # Processing to be done when the response is a success.
        # Updates the failure attempts. If the retry count reaches
        # the upper threshold, operations will be marked
        # as failure and the completion event will be set.
        #
        # @param [String] status The status in the response.
        # @param [] value The value returned in the response.
        def on_failure status, message
          puts "Failure"
          @completion_event.set
        end

        ##
        # Exponentially increases the waiting time for retry.
        def backoff_duration
          # Provides the time to wait before next attempt
        end
      end
    end
  end
end

