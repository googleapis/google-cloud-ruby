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


require "google/cloud/bigtable/convert"

module Google
  module Cloud
    module Bigtable
      ##
      # # ValueRange
      #
      # Specifies a contiguous range of string values.
      #
      # * from value bound : The value at which to begin the range.
      #   If neither field is set, interpreted as an empty string, inclusive.
      # * End value bound: The value at which to end the range.
      #   If neither field is set, interpreted as an infinite string value, exclusive.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   # Range that includes all row keys including "value-001" to "value-005" excluding.
      #   table.new_value_range.from("value-001").to("value-005")
      #
      #   # Range that includes all row keys including "value-001" up to inclusive "value-010".
      #   table.new_value_range.from("value-001").to("value-010", inclusive: true)
      #
      #   # Range that includes all row keys including "value-001" up until end of the row keys.
      #   table.new_value_range.from "value-001"
      #
      #   # Range that includes all row keys exclusive "value-001" up until end of the row keys.
      #   table.new_value_range.from "value-001", inclusive: false
      #
      #   # Range with unbounded from and the exclusive end "value-100".
      #   table.new_value_range.to "value-100"
      #
      #   # Range that includes all row keys including from and end row keys "value-001", "value-100".
      #   table.new_value_range.between "value-001", "value-100"
      #
      #   # Range that includes all row keys including "value-001" up until "value-100".
      #   table.new_value_range.of "value-001", "value-100"
      #
      class ValueRange
        # @private
        # Creates a value range instance.
        def initialize
          @grpc = Google::Cloud::Bigtable::V2::ValueRange.new
        end

        ##
        # Sets the row range with the lower bound.
        #
        # @param value [String, Integer] The value. Required. If the argument
        #   is an Integer, it will be encoded as a 64-bit signed big-endian
        #   integer.
        # @param inclusive [Boolean] Whether the value is an inclusive or
        #   exclusive lower bound. Default is `true`, an inclusive lower bound.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example Inclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.from "value-001"
        #
        # @example Exclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.from "value-001", inclusive: false
        #
        def from value, inclusive: true
          # If value is integer, covert it to a 64-bit signed big-endian integer.
          value = Convert.integer_to_signed_be_64 value
          if inclusive
            @grpc.start_value_closed = value
          else
            @grpc.start_value_open = value
          end
          self
        end

        ##
        # Sets the value range with upper bound.
        #
        # @param value [String, Integer] value. Required. If the argument
        #   is an Integer, it will be encoded as a 64-bit signed big-endian
        #   integer.
        # @param inclusive [Boolean] Whether the value is an inclusive or
        #   exclusive lower bound. Default is `false`, an exclusive lower bound.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example Inclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.to "value-010", inclusive: true
        #
        # @example Exclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.to "value-010"
        #
        def to value, inclusive: false
          # If value is integer, covert it to a 64-bit signed big-endian integer.
          value = Convert.integer_to_signed_be_64 value
          if inclusive
            @grpc.end_value_closed = value
          else
            @grpc.end_value_open = value
          end
          self
        end

        ##
        # Sets the value range with inclusive lower and upper bounds.
        #
        # @param from_value [String, Integer] Inclusive from value. Required.
        #   If the argument is an Integer, it will be encoded as a 64-bit
        #   signed big-endian integer.
        # @param to_value [String, Integer] Inclusive to value. Required.
        #   If the argument is an Integer, it will be encoded as a 64-bit
        #   signed big-endian integer.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #   Range with inclusive from and to values.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.between "value-001", "value-010"
        #
        def between from_value, to_value
          from(from_value).to(to_value, inclusive: true)
        end

        ##
        # Set value range with an inclusive lower bound and an exclusive upper bound.
        #
        # @param from_value [String, Integer] Inclusive from value. Required.
        #   If the argument is an Integer, it will be encoded as a 64-bit
        #   signed big-endian integer.
        # @param to_value [String, Integer] Exclusive to value. Required.
        #   If the argument is an Integer, it will be encoded as a 64-bit
        #   signed big-endian integer.
        # @return [Google::Cloud::Bigtable::ValueRange]
        #   Range with an inclusive from value and an exclusive to value.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.of "value-001", "value-010"
        #
        def of from_value, to_value
          from(from_value).to(to_value)
        end

        # @private
        #
        # @return [Google::Cloud::Bigtable::V2::ValueRange]
        #
        def to_grpc
          @grpc
        end
      end
    end
  end
end
