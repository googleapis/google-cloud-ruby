# Copyright 2018 Google LLC
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


module Google
  module Firestore
    module V1beta1
      # A set of field paths on a document.
      # Used to restrict a get or update operation on a document to a subset of its
      # fields.
      # This is different from standard field masks, as this is always scoped to a
      # {Google::Firestore::V1beta1::Document Document}, and takes in account the dynamic nature of {Google::Firestore::V1beta1::Value Value}.
      # @!attribute [rw] field_paths
      #   @return [Array<String>]
      #     The list of field paths in the mask. See {Google::Firestore::V1beta1::Document#fields Document#fields} for a field
      #     path syntax reference.
      class DocumentMask; end

      # A precondition on a document, used for conditional operations.
      # @!attribute [rw] exists
      #   @return [true, false]
      #     When set to `true`, the target document must exist.
      #     When set to `false`, the target document must not exist.
      # @!attribute [rw] update_time
      #   @return [Google::Protobuf::Timestamp]
      #     When set, the target document must exist and have been last updated at
      #     that time.
      class Precondition; end

      # Options for creating a new transaction.
      # @!attribute [rw] read_only
      #   @return [Google::Firestore::V1beta1::TransactionOptions::ReadOnly]
      #     The transaction can only be used for read operations.
      # @!attribute [rw] read_write
      #   @return [Google::Firestore::V1beta1::TransactionOptions::ReadWrite]
      #     The transaction can be used for both read and write operations.
      class TransactionOptions
        # Options for a transaction that can be used to read and write documents.
        # @!attribute [rw] retry_transaction
        #   @return [String]
        #     An optional transaction to retry.
        class ReadWrite; end

        # Options for a transaction that can only be used to read documents.
        # @!attribute [rw] read_time
        #   @return [Google::Protobuf::Timestamp]
        #     Reads documents at the given time.
        #     This may not be older than 60 seconds.
        class ReadOnly; end
      end
    end
  end
end