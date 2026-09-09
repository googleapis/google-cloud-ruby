# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Bigtable
      ##
      # # SampleRowKey
      #
      # Sample row key with byte offset.
      #
      # NOTE:
      # * row_key : Sorted streamed sequence of sample row keys in the table.
      #   The table might have contents before the first row key in the list and after
      #   the last one, but a key containing the empty string indicates
      #   "end of table" and will be the last response given, if present.
      #   Note: that row keys in this list may not have ever been written to or read
      #   from, and users should therefore not make any assumptions about the row key
      #   structure that are specific to their use case.
      #
      # * offset_bytes : Approximate total storage space used by all rows in the table which precede
      #   `row_key`. Buffering the contents of all rows between two subsequent
      #   samples would require space roughly equal to the difference in their
      #   `offset_bytes` fields.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   table.sample_row_keys.each do |r|
      #     p r
      #   end
      #
      class SampleRowKey
        ##
        # @return [String] Sample row key.
        attr_reader :key

        ##
        # @return [Integer] Row offset in bytes.
        attr_reader :offset

        # @private
        #
        # Create SampleRowKey instance.
        #
        # @param key [String]
        # @param offset [Integer] Row offset in bytes.
        #
        def initialize key, offset
          @key = key
          @offset = offset
        end

        # @private
        #
        # Creates a new SampleRowKey instance from a
        # Google::Cloud::Bigtable::V2::SampleRowKey.
        # @param grpc [Google::Cloud::Bigtable::V2::SampleRowKeysResponse]
        # @return [Google::Cloud::Bigtable::SampleRowKey]
        #
        def self.from_grpc grpc
          new grpc.row_key, grpc.offset_bytes
        end
      end
    end
  end
end
