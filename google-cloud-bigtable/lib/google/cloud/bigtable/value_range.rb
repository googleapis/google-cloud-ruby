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
      # # ValueRange
      #
      # Specifies a contiguous range of string values.
      #
      # * from value bound : The value at which to from the range.
      #   If neither field is set, interpreted as the empty string, inclusive.
      # * End value bound: The value at which to end the range.
      #   If neither field is set, interpreted as the infinite string value, exclusive.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   client = bigtable.client("my-instance")
      #   table = client.table("my-table")
      #
      #   # Range that includes all row keys including "value-001" to "value-005" excluding
      #   table.value_range.from("value-001").to("value-005")
      #
      #   # Range that includes all row keys including "value-001" up to inclusive "value-010".
      #   table.value_range.from("value-001").to("value-010", inclusive: true)
      #
      #   # Range that includes all row keys including "value-001" up until end of the row keys.
      #   table.value_range.from("value-001")
      #
      #   # Range that includes all row keys exclusive "value-001" up until end of the row keys.
      #   table.value_range.from("value-001", inclusive: false)
      #
      #   # Range with unbounded from and the exclusive end "value-100"
      #   table.value_range.to("value-100")
      #
      #   # Range that includes all row keys including from and end row keys "value-001", "value-100"
      #   table.value_range.between("value-001", "value-100")
      #
      #   # Range that includes all row keys including "value-001" up until "value-100"
      #   table.value_range.of("value-001", "value-100")
      #
      class ValueRange
        # @private
        # Create value range instance.
        def initialize
          @grpc = Google::Bigtable::V2::ValueRange.new
        end

        # Ser row range with the lower bound.
        #
        # @param value [String] value. Required
        # @param inclusive [String] Inclusive/Exclusive lower bound.
        #   Default it is an inclusive lower bound.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example Inclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.from("value-001")
        #
        # @example Exclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.from("value-001", inclusive: false)
        #
        def from value, inclusive: true
          if inclusive
            @grpc.start_value_closed = value
          else
            @grpc.start_value_open = value
          end
          self
        end

        # Set value range with upper bound.
        #
        # @param value [String] value. Required
        # @param inclusive [String] Inclusive/Exclusive upper bound.
        #   Default it is an exclusive upper bound.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example Inclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.to("value-010", inclusive: true)
        #
        # @example Exclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.to("value-010")
        #
        def to value, inclusive: false
          if inclusive
            @grpc.end_value_closed = value
          else
            @grpc.end_value_open = value
          end
          self
        end

        # Set value range with the inclusive lower and upper bound.
        #
        # @param from_value [String] Inclusive from value. Required
        # @param to_value [String] Inclusive end value. Required
        # @return [Google::Cloud::Bigtable::ValueRange]
        #   Range with inclusive from and end value.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.between("value-001", "value-010")
        #
        def between from_value, to_value
          from(from_value).to(to_value, inclusive: true)
        end

        # Set value range with the inclusive lower and the exclusive upper bound.
        #
        # @param from_value [String] Inclusive from value
        # @param to_value [String] Exclusive to value
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   client = bigtable.client("my-instance")
        #   table = client.table("my-table")
        #
        #   range = table.value_range.of("value-001", "value-010")
        #
        def of from_value, to_value
          from(from_value).to(to_value)
        end

        # @private
        #
        # @return [Google::Bigtable::V2::ValueRange]
        #
        def to_grpc
          @grpc
        end
      end
    end
  end
end
