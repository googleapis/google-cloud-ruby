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
require "google/cloud/firestore/bulk_writer_exception"



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

        MAX_RETRY_ATTEMPTS = 15

        ##
        # Initialize the object
        def initialize write, document_reference
          @write = write
          @status = false
          @result = true
          @failed_attempts = 0
          @document_reference = document_reference
          @retry_time = Time.now
          @completion_event = Concurrent::Event.new
          @failure_message = nil
        end

        ##
        # Processing to be done when the response is a failure.
        # Updates the result and set the completion event.
        #
        # @param [Google::Cloud::Firestore::V1::WriteResult] result The result returned in the response.
        def on_success result
          @result = WriteResult.new result
          @completion_event.set
        end

        ##
        # Processing to be done when the response is a success.
        # Updates the failure attempts. If the retry count reaches
        # the upper threshold, operations will be marked
        # as failure and the completion event will be set.
        #
        # @param [Google::Rpc::Status] status The status received in the response.
        #
        def on_failure status
          @failed_attempts += 1
          if @failed_attempts == MAX_RETRY_ATTEMPTS
            begin
              @result = BulkWriterException.new status
            rescue StandardError => e
              puts e
            ensure
              @completion_event.set
            end
          else
            backoff_duration
          end
        end

        ##
        # Exponentially increases the waiting time for retry.
        def backoff_duration
          @retry_time = Time.now + (@failed_attempts**2)
        end

        ##
        # Represents the result of applying a write.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   bw = firestore.bulk_writer
        #
        #   # Set the data for NYC
        #   result = bw.set("cities/NYC", { name: "New York City" })
        #
        #   result.wait!
        #
        #   puts result.value
        #
        class WriteResult

          ##
          # The last update time of the document after applying the write. Set to
          # nil for a +delete+ mutation.
          #
          # If the write did not actually change the document, this will be
          # the previous update_time.
          #
          # @return [Time] The last update time.
          attr_reader :update_time

          ##
          # @private
          def initialize result
            @update_time = Convert.timestamp_to_time result.update_time
          end
        end
      end
    end
  end
end
