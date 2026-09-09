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
      ##
      # # RowRange
      #
      # Specifies a contiguous range of rows.
      #
      # * From key bound : The row key at which to begin the range.
      #   If neither field is set, interpreted as an empty string, inclusive.
      # * End key bound: The row key at which to end the range.
      #   If neither field is set, interpreted as the infinite row key, exclusive.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   # Range that includes all row keys including "user-001" to "user-005"
      #   table.new_row_range.from("user-001").to("user-005", inclusive: true)
      #
      #   # Range that includes all row keys including "user-001" up to exclusive "user-010".
      #   table.new_row_range.from("user-001").to("user-010")
      #
      #   # Range that includes all row keys including "user-001" up until end of the row keys.
      #   table.new_row_range.from "user-001"
      #
      #   # Range that includes all row keys exclusive "user-001" up until end of the row keys.
      #   table.new_row_range.from "user-001", inclusive: false
      #
      #   # Range with unbounded from and the exclusive end "user-010"
      #   table.new_row_range.to "user-010"
      #
      #   # Range that includes all row keys including from and end row keys "user-001", "user-010"
      #   table.new_row_range.between "user-001", "user-010"
      #
      #   # Range that includes all row keys including "user-001" up until "user-010"
      #   table.new_row_range.of "user-001", "user-010"
      #
      class RowRange
        # @private
        # Creates a row range instance.
        def initialize
          @grpc = Google::Cloud::Bigtable::V2::RowRange.new
        end

        ##
        # Sets a row range with a lower bound.
        #
        # @param key [String] Row key. Required.
        # @param inclusive [String] Inclusive/exclusive lower bound.
        #   Default is an inclusive lower bound.
        # @return [Google::Cloud::Bigtable::RowRange]
        #
        # @example Inclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.from "key-001"
        #
        # @example Exclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.from "key-001", inclusive: false
        #
        def from key, inclusive: true
          if inclusive
            @grpc.start_key_closed = key
          else
            @grpc.start_key_open = key
          end
          self
        end

        ##
        # Sets a row range with an upper bound.
        #
        # @param key [String] Row key. Required.
        # @param inclusive [String] Inclusive/Exclusive upper bound.
        #   Default it is an exclusive upper bound.
        # @return [Google::Cloud::Bigtable::RowRange]
        #
        # @example Inclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.to "key-001", inclusive: true
        #
        # @example Exclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.to "key-001"
        #
        def to key, inclusive: false
          if inclusive
            @grpc.end_key_closed = key
          else
            @grpc.end_key_open = key
          end
          self
        end

        ##
        # Sets a row range with inclusive upper and lower bounds.
        #
        # @param from_key [String] Inclusive from row key. Required.
        # @param to_key [String] Inclusive end row key. Required.
        # @return [Google::Cloud::Bigtable::RowRange]
        #   Range with inclusive from and end row keys.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.between "key-001", "key-010"
        #
        def between from_key, to_key
          from(from_key).to(to_key, inclusive: true)
        end

        ##
        # Sets a row range with an inclusive lower bound and an exclusive upper bound.
        #
        # @param from_key [String] Inclusive from row key.
        # @param to_key [String] Exclusive end row key.
        # @return [Google::Cloud::Bigtable::RowRange]
        #   Range with inclusive from and exclusive end row key.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.of "key-001", "key-010"
        #
        def of from_key, to_key
          from(from_key).to(to_key)
        end

        # @private
        #
        # @return [Google::Cloud::Bigtable::V2::RowRange]
        #
        def to_grpc
          @grpc
        end
      end
    end
  end
end
