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
      module RowFilter
        #
        # # SimpleFilter
        #
        class SimpleFilter
          # @private
          # Creates a simple filter instance.
          #
          def initialize
            @grpc = Google::Bigtable::V2::RowFilter.new
          end

          # Outputs all cells directly to the output of the read rather than to any parent filter.
          #
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def sink
            @grpc.sink = true
            self
          end

          # Matches all cells, regardless of input. Functionally equivalent to
          # leaving `filter` unset, but included for completeness.
          #
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def pass
            @grpc.pass_all_filter = true
            self
          end

          # Does not match any cells, regardless of input. Useful for temporarily
          # disabling just part of a filter.
          #
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def block
            @grpc.block_all_filter = true
            self
          end

          # Replaces each cell's value with an empty string.
          #
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def strip_value
            @grpc.strip_value_transformer = true
            self
          end

          # Matches only cells from rows whose keys satisfy the given RE2 regex. In
          # other words, passes through the entire row when the key matches, and
          # otherwise produces an empty row.
          # Note that, since row keys can contain arbitrary bytes, the `\C` escape
          # sequence must be used if a true wildcard is desired. The `.` character
          # will not match the new line character `\n`, which may be present in a
          # binary key.
          #
          # For Regex syntax:
          # @see https://github.com/google/re2/wiki/Syntax
          #
          # @param regex [String] Regex to match row keys.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def key regex
            @grpc.row_key_regex_filter = regex
            self
          end

          # Matches all cells from a row with probability p, and matches no cells
          # from the row with probability 1-p.
          #
          # @param probability [Float]
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def sample probability
            if probability >= 1 || probability <= 0
              raise(
                RowFilterError,
                "Probability must be greather then 0 and less then 1.0"
              )
            end
            @grpc.row_sample_filter = probability
            self
          end

          # Matches only cells from columns whose families satisfy the given RE2
          # regex. For technical reasons, the regex must not contain the `:`
          # character, even if it is not being used as a literal.
          # Note that, since column families cannot contain the new line character
          # `\n`, it is sufficient to use `.` as a full wildcard when matching
          # column family names.
          #
          # @param regex [String] Regex to match family name.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def family regex
            @grpc.family_name_regex_filter = regex
            self
          end

          # Matches only cells from columns whose qualifiers satisfy the given RE2
          # regex.
          # Note that, since column qualifiers can contain arbitrary bytes, the `\C`
          # escape sequence must be used if a true wildcard is desired. The `.`
          # character will not match the new line character `\n`, which may be
          # present in a binary qualifier.
          #
          # @param regex [String] Regex to match column qualifier name.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def qualifier regex
            @grpc.column_qualifier_regex_filter = regex
            self
          end

          # Matches only cells with values that satisfy the given regular expression.
          # Note that, since cell values can contain arbitrary bytes, the `\C` escape
          # sequence must be used if a true wildcard is desired. The `.` character
          # will not match the new line character `\n`, which may be present in a
          # binary value.
          #
          # @param regex [String] Regex to match cell value.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def value regex
            @grpc.value_regex_filter = regex
            self
          end

          # Applies the given label to all cells in the output row. This allows
          # the client to determine which results were produced from which part of
          # the filter.
          #
          # Values must be at most 15 characters in length, and match the RE2
          # pattern `[a-z0-9\\-]+`
          #
          # Due to a technical limitation, it is not possible to apply
          # multiple labels to a cell. As a result, a chain may have no more than
          # one sub-filter whithatch contains an `apply_label_transformer`. It is okay for
          # an interleave to contain multiple `apply_label_transformers`, as they
          # will be applied to separate copies of the input.
          #
          # @param value [String] Label name
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def label value
            @grpc.apply_label_transformer = value
            self
          end

          # Skips the first N cells of each row, matching all subsequent cells.
          # If duplicate cells are present, as is possible when using an interleave,
          # each copy of the cell is counted separately.
          #
          # @param offset [Integer] Offset value.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def cells_per_row_offset offset
            @grpc.cells_per_row_offset_filter = offset
            self
          end

          # Matches only the first N cells of each row.
          # If duplicate cells are present, as is possible when using an Interleave,
          # each copy of the cell is counted separately.
          #
          # @param limit [String] Max cell match per row limit
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def cells_per_row limit
            @grpc.cells_per_row_limit_filter = limit
            self
          end

          # Matches only the most recent N cells within each column. For example,
          # if N=2, this filter would match column `foo:bar` at timestamps 10 and 9,
          # skip all earlier cells in `foo:bar`, and then begin matching again in
          # column `foo:bar2`.
          # If duplicate cells are present, as is possible when using an interleave,
          # each copy of the cell is counted separately.
          #
          # @param limit [String] Max cell match per column limit
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def cells_per_column limit
            @grpc.cells_per_column_limit_filter = limit
            self
          end

          # Creates a timestamp-range filter instance.
          #
          # Matches only cells with timestamps within the given range.
          # Specifies a contiguous range of timestamps.
          #
          # @param from [Integer] Inclusive lower bound. If left empty, interpreted as 0.
          # @param to [Integer] Exclusive upper bound. If left empty, interpreted as infinity.
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def timestamp_range from, to
            range_grpc = Google::Bigtable::V2::TimestampRange.new
            range_grpc.start_timestamp_micros = from if from
            range_grpc.end_timestamp_micros = to if to
            @grpc.timestamp_range_filter = range_grpc
            self
          end

          # Matches only cells with values that fall within the given range.
          #
          # See {Google::Cloud::Bigtable::ValueRange#from} and { Google::Cloud::Bigtable::ValueRange#to} for range
          # option inclusive/exclusive options
          #
          # * The value at which to start the range. If neither field is set, interpreted as an empty string, inclusive.
          # * The value at which to end the range. If neither field is set, interpreted as an infinite string, exclusive.
          #
          # @param range [Google::Cloud::Bigtable::ValueRange]
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def value_range range
            unless range.instance_of?(Google::Cloud::Bigtable::ValueRange)
              raise RowFilterError, "Range type mustbe ValueRange"
            end
            @grpc.value_range_filter = range.to_grpc
            self
          end

          # Matches only cells from columns within the given range.
          #
          # @param range [Google::Cloud::Bigtable::ColumnRange]
          # @return [Google::Cloud::Bigtable::RowFilter::SimpleFilter]
          #
          def column_range range
            unless range.instance_of?(Google::Cloud::Bigtable::ColumnRange)
              raise RowFilterError, "Range type mustbe ColumnRange"
            end
            @grpc.column_range_filter = range.to_grpc
            self
          end

          # @private
          #
          # Converts to a gRPC row filter instance.
          #
          # @return [Google::Bigtable::V2::RowFilter]
          def to_grpc
            @grpc
          end
        end
      end
    end
  end
end
