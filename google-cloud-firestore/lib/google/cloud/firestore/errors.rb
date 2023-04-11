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
      # Indicates that the an error was reported while scheduling
      # bulkwriter operations.
      #
      class BulkWriterSchedulerError < Google::Cloud::Error
        def initialize message
          super "BulkWriterSchedulerError : #{message}"
        end
      end


      ##
      # Indicates that the an error was reported while committing a
      # batch of operations.
      #
      class BulkCommitBatchError < Google::Cloud::Error
        def initialize message
          super "BulkCommitBatchError : #{message}"
        end
      end

      ##
      # Indicates that the an error was reported while scheduling
      # bulkwriter operations.
      #
      class BulkWriterOperationError < Google::Cloud::Error
        def initialize message
          super "BulkWriterOperationError : #{message}"
        end
      end
    end
  end
end


