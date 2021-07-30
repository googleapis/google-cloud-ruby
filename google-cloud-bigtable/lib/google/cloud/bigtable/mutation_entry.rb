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
      # # MutationEntry
      #
      # MutationEntry is a chainable structure that holds data for different
      # type of mutations.
      # MutationEntry is used in following data operations:
      #
      #   * Mutate row. See {Google::Cloud::Bigtable::Table#mutate_row}
      #   * Mutate rows. See {Google::Cloud::Bigtable::Table#mutate_rows}
      #   * Check and mutate row using a predicate.
      #     See {Google::Cloud::Bigtable::Table#check_and_mutate_row}
      #
      # @example
      #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
      #   timestamp_micros = (Time.now.to_f * 1_000_000).round(-3)
      #   entry.set_cell(
      #     "cf1", "fiel01", "XYZ", timestamp: timestamp_micros
      #   ).delete_cells(
      #     "cf2",
      #     "field02",
      #     timestamp_from: timestamp_micros - 5_000_000,
      #     timestamp_to: timestamp_micros
      #   ).delete_from_family("cf3").delete_from_row
      #
      # @example Create using a table.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   entry = table.new_mutation_entry "user-1"
      #   timestamp_micros = (Time.now.to_f * 1_000_000).round(-3)
      #   entry.set_cell(
      #     "cf1", "fiel01", "XYZ", timestamp: timestamp_micros
      #   )
      #
      class MutationEntry
        attr_accessor :row_key

        # @private
        # mutations gRPC list
        # @return [Array<Google::Cloud::Bigtable::V2::Mutation>]
        attr_accessor :mutations

        ##
        # Creates a mutation entry instance.
        #
        # @param row_key [String]
        #
        def initialize row_key = nil
          @row_key = row_key
          @mutations = []
          @retryable = true
        end

        ##
        # Adds a SetCell to the list of mutations.
        #
        # A SetCell is a mutation that sets the value of the specified cell.
        #
        # @param family [String] Table column family name.
        #   The name of the family into which new data should be written.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @param qualifier [String] Column qualifier name.
        #   The qualifier of the column into which new data should be written.
        #   Can be any byte string, including an empty string.
        # @param value [String, Integer] Cell value data. The value to be written
        #   into the specified cell. If the argument is an Integer, it will be
        #   encoded as a 64-bit signed big-endian integer.
        # @param timestamp [Integer] Timestamp value in microseconds.
        #   The timestamp of the cell into which new data should be written.
        #   Use -1 for current Bigtable server time.
        #   Otherwise, the client should set this value itself, noting that the
        #   default value is a timestamp of zero if the field is left unspecified.
        #   Values are in microseconds but must match the granularity of the
        #   table. Therefore, if {Table#granularity} is `MILLIS` (the default),
        #   the given value must be a multiple of 1000 (millisecond
        #   granularity). For example: `1564257960168000`.
        # @return [MutationEntry]  `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   entry.set_cell "cf1", "field01", "XYZ"
        #
        # @example With timestamp.
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   entry.set_cell(
        #     "cf1",
        #     "field1",
        #     "XYZ",
        #     timestamp: (Time.now.to_f * 1_000_000).round(-3) # microseconds
        #   )
        #
        def set_cell family, qualifier, value, timestamp: nil
          # If value is integer, covert it to a 64-bit signed big-endian integer.
          value = Convert.integer_to_signed_be_64 value
          options = {
            family_name:      family,
            column_qualifier: qualifier,
            value:            value
          }

          if timestamp
            options[:timestamp_micros] = timestamp
            @retryable = timestamp != -1
          end
          @mutations << Google::Cloud::Bigtable::V2::Mutation.new(set_cell: options)
          self
        end

        ##
        # Adds a DeleteFromColumn to the list of mutations.
        #
        # A DeleteFromColumn is a mutation that deletes cells from the
        # specified column, optionally restricting the deletions to a given
        # timestamp range.
        #
        # @param family [String] Table column family name.
        #   The name of the column family from which cells should be deleted.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @param qualifier [String] Column qualifier name.
        #   The qualifier of the column from which cells should be deleted.
        #   Can be any byte string, including an empty string.
        # @param timestamp_from [Integer] Timestamp lower boundary in
        #   microseconds. Optional. Begins the range of timestamps from which
        #   cells should be deleted. Values are in microseconds but must match
        #   the granularity of the table. Therefore, if {Table#granularity} is
        #   `MILLIS` (the default), the given value must be a multiple of 1000
        #   (millisecond granularity). For example: `1564257960168000`.
        # @param timestamp_to [Integer] Timestamp upper boundary in
        #   microseconds. Optional. Ends the range of timestamps from which
        #   cells should be deleted. Values are in microseconds but must match
        #   the granularity of the table. Therefore, if {Table#granularity} is
        #   `MILLIS` (the default), the given value must be a multiple of 1000
        #   (millisecond granularity). For example: `1564257960168000`.
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example Without timestamp range.
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   entry.delete_cells "cf1", "field1"
        #
        # @example With timestamp range.
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   timestamp_micros = (Time.now.to_f * 1_000_000).round(-3)
        #   entry.delete_cells(
        #     "cf1",
        #     "field1",
        #     timestamp_from: timestamp_micros - 5_000_000,
        #     timestamp_to: timestamp_micros
        #   )
        # @example With timestamp range with lower boundary only.
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   timestamp_micros = (Time.now.to_f * 1_000_000).round(-3)
        #   entry.delete_cells(
        #     "cf1",
        #     "field1",
        #     timestamp_from: timestamp_micros - 5_000_000
        #   )
        #
        def delete_cells family, qualifier, timestamp_from: nil, timestamp_to: nil
          grpc = Google::Cloud::Bigtable::V2::Mutation::DeleteFromColumn.new \
            family_name: family, column_qualifier: qualifier
          if timestamp_from || timestamp_to
            time_range = Google::Cloud::Bigtable::V2::TimestampRange.new
            time_range.start_timestamp_micros = timestamp_from if timestamp_from
            time_range.end_timestamp_micros = timestamp_to if timestamp_to
            grpc.time_range = time_range
          end
          @mutations << Google::Cloud::Bigtable::V2::Mutation.new(delete_from_column: grpc)
          self
        end

        ##
        # Adds a DeleteFromFamily to the list of mutations.
        #
        # A DeleteFromFamily is a mutation that deletes all cells from the specified column family.
        #
        # @param family [String] Table column family name.
        #   The name of the column family from which cells should be deleted.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   entry.delete_from_family "cf1"
        #
        def delete_from_family family
          @mutations << Google::Cloud::Bigtable::V2::Mutation.new(delete_from_family: { family_name: family })
          self
        end

        ##
        # Adds a DeleteFromRow to the list of mutations.
        #
        # A DeleteFromRow is a mutation which deletes all cells from the containing row.
        #
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new "user-1"
        #   entry.delete_from_row
        #
        def delete_from_row
          @mutations << Google::Cloud::Bigtable::V2::Mutation.new(delete_from_row: {})
          self
        end

        ##
        # If the mutation entry is retryable or not based on set_cell value.
        #
        # @return [Boolean]
        #
        def retryable?
          @retryable
        end

        ##
        # The number of mutations.
        #
        # @return [Integer]
        #
        def length
          @mutations.length
        end

        # @private
        #
        # Convert mutation entry to gRPC protobuf object.
        #
        # @return [Google::Cloud::Bigtable::V2::MutateRowsRequest::Entry]
        #
        def to_grpc
          Google::Cloud::Bigtable::V2::MutateRowsRequest::Entry.new row_key: @row_key, mutations: @mutations
        end
      end
    end
  end
end
