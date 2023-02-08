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

module Google
  module Cloud
    module Firestore
      class BulkWriterOperation

        attr_reader :retry_time
        attr_reader :result
        attr_reader :completion_event

        MAX_RETRY_ATTEMPTS = 10

        def initialize write, document_reference, operation_type
          @write = write
          @completion_event = Concurrent::Event.new
          @status = nil
          @result = nil
          @operation_type = operation_type
          @failed_attempts = 0
          @document_reference = document_reference
          @retry_time = Time.now
          @failure_message = nil
        end

        def on_success status, values
          # Updates @status, @result and marks the operation complete by setting the event.
        end

        def on_failure status, message
          # Updates various attributes like @failed_attempts, @status, @result and @failure_message
          # and update the @retry_time based on the backoff algorithm.
          # If this was last attempt then @result will be set as BulkWriter Exception and the operation
          # will be marked as complete by setting the event.
        end

        def backoff_duration
          # Provides the time to wait before next attempt
        end

      end
    end
  end
end

