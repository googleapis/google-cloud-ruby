# frozen_string_literal: true

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
  module Cloud
    module Bigtable
      # # ReadModifyWriteRule
      #
      # Specifies an atomic read/modify/write operation on the latest value of the
      # specified column.
      #
      # @example Append value rule
      #   rule = Google::Cloud::Bigtable::ReadModifyWriteRule.append(
      #     "cf", "field01", "append-xyz"
      #   )
      #
      # @example increment value rule
      #   rule = Google::Cloud::Bigtable::ReadModifyWriteRule.increment(
      #     "cf", "field01", 1
      #   )
      #
      class ReadModifyWriteRule
        # @private
        # Create an instance of ReadModifyWriteRule
        #
        # @param family [String]
        #   The name of the family to which the read/modify/write should be applied.
        # @param qualifier [String]
        #   The qualifier of the column to which the read/modify/write should be applied.
        #
        def initialize family, qualifier
          @grpc = Google::Bigtable::V2::ReadModifyWriteRule.new
          @grpc.family_name = family
          @grpc.column_qualifier = qualifier
        end

        # Create an instance of an append-value rule .
        #
        # @param family [String]
        #   The name of the family to which the read/modify/write should be applied.
        # @param qualifier [String]
        #   The qualifier of the column to which the read/modify/write should be applied.
        # @param value [String]
        #  Rule specifying that `append_value` be appended to the existing value.
        #  If the targeted cell is unset, it will be treated as if it contains an empty string.
        # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
        #
        # @example Append value rule
        #   rule = Google::Cloud::Bigtable::ReadModifyWriteRule.append(
        #     "cf", "field01", "append-xyz"
        #   )
        #
        def self.append family, qualifier, value
          rule = new(family, qualifier)
          rule.append(value)
          rule
        end

        # Create an instance of an increment-amount rule.
        #
        # @param family [String]
        #   The name of the family to which the read/modify/write should be applied.
        # @param qualifier [String]
        #   The qualifier of the column to which the read/modify/write should be applied.
        # @param amount [String]
        #   Rule specifying that `increment_amount` be added to the existing value.
        #   If the targeted cell is unset, it will be treated as if it contains a zero.
        #   Otherwise, the targeted cell must contain an 8-byte value (interpreted
        #   as a 64-bit big-endian signed integer), or the entire request will fail.
        # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
        #
        # @example increment value rule
        #   rule = Google::Cloud::Bigtable::ReadModifyWriteRule.increment(
        #     "cf", "field01", 1
        #   )
        #
        def self.increment family, qualifier, amount
          rule = new(family, qualifier)
          rule.increment(amount)
          rule
        end

        # Set append value.
        #
        # @param value [String]
        # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
        #
        def append value
          @grpc.append_value = value
          self
        end

        # Set increment amount.
        #
        # @param amount [Integer]
        # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
        #
        def increment amount
          @grpc.increment_amount = amount
          self
        end

        # @private
        #
        # Get gRPC protobuf instance.
        #
        # @return [Google::Bigtable::V2::ReadModifyWriteRule]
        #
        def to_grpc
          @grpc
        end
      end
    end
  end
end
