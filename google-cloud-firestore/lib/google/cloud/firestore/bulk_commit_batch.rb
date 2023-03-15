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
##
# @private
class BulkCommitBatch

  ##
  # Initialize the object
  def initialize service, operations
    @service = service
    @operations = operations
  end

  ##
  # Process the result received for each operation and calls the appropriate callback.
  # Incase of failures, adds the operation to the retry array.
  #
  # @return [Array<bulkWriterOperation>] failed_operations
  def parse_results responses
    failed_operations = []
    responses.each_with_index do |response, idx|
      operation = @operations[idx]
      if response.status == "failed"
        operations.on_failure response.status, response.value
        failed_operations << operation
      else
        operations.on_success response.status, response.value
      end
    end
    failed_operations
  end

  ##
  # Makes the API request with all the operations in the batch and returns the response after processing.
  #
  # @return [Array<bulkWriterOperation>] failed_operations
  def commit
    writes = []
    @operations.each do |operation|
      writes << operation
    end
    responses = @service.batch_write writes
    parse_results responses
  end
end
    end
  end
end

