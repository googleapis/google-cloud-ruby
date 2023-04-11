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
require "google/cloud/firestore/errors"
require "google/cloud/firestore/transaction"

module Google
  module Cloud
    module Firestore
      ##
      # @private
      class BulkCommitBatch

        attr_reader :operations

        ##
        # Initialize the object
        def initialize service, operations
          @service = service
          @operations = operations
        end

        ##
        # Updates the operation based on the result received from the API request.
        #
        # @param [Google::Cloud::Firestore::V1::BatchWriteResponse] responses
        #
        # @return [nil]
        #
        def parse_results responses
          @operations.zip responses.write_results, responses.status do |operation, write_result, status|
            begin
              status&.code&.zero? ? operation.on_success(write_result) : operation.on_failure(status)
            rescue StandardError => e
              # TODO: Log the error while parsing response
            end
          end
        end

        ##
        # Makes the BatchWrite API request with all the operations in the batch and
        # parses the results for each operation.
        #
        # @return [nil]
        #
        def commit
          begin
            responses = @service.batch_write @operations.map(&:write)
            parse_results responses
          rescue StandardError => e
            raise BulkCommitBatchError, e.message
          end
        end
      end
    end
  end
end

