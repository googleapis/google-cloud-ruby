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
      # # MutationEntry
      #
      # MutationEntry is a chainable structure, which holds data for diffrent
      # type of mutations.
      # MutationEntry is used in following data operations
      #
      #   * Mutate row. See {Google::Cloud::Bigtable::Table#mutate_row}
      #   * Mutate rows. See {Google::Cloud::Bigtable::Table#mutate_rows}
      #   * Check and mutate row using a predicate.
      #     see {Google::Cloud::Bigtable::Table#check_and_mutate_row}
      #
      # @example
      #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
      #   entry.set_cell(
      #     "cf1", "fiel01", "XYZ", timestamp: Time.now.to_i * 1000
      #   ).delete_cells(
      #     "cf2",
      #     "field02",
      #     timestamp_from: (Time.now.to_i - 1800) * 1000,
      #     timestamp_to: (Time.now.to_i * 1000)
      #   ).delete_from_family("cf3").delete_from_row
      #
      # @example Using table
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   table = bigtable.table("my-instance", "my-table")
      #
      #   entry = table.new_mutation_entry("user-1")
      #   entry.set_cell(
      #     "cf1", "fiel01", "XYZ", timestamp: Time.now.to_i * 1000
      #   )
      #
      class MutationEntry
        attr_accessor :row_key

        # mutations gRPC list
        # @return [Array<Google::Bigtable::V2::Mutation>]
        attr_accessor :mutations

        # Creates a mutation entry instance.
        #
        # @param row_key [String]
        def initialize row_key = nil
          @row_key = row_key
          @mutations = []
          @retryable = true
        end

        # Add SetCell mutation to list of mutations.
        #
        # A Mutation which sets the value of the specified cell.
        #
        # @param family [String] Table column family name.
        #   The name of the family into which new data should be written.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @param qualifier [String] Column qualifier name.
        #   The qualifier of the column into which new data should be written.
        #   Can be any byte string, including the empty string.
        # @param value [String, Integer] Cell value data.
        #   The value to be written into the specified cell.
        # @param timestamp [Time, Integer] Timestamp value.
        #   The timestamp of the cell into which new data should be written.
        #   Use -1 for current Bigtable server time.
        #   Otherwise, the client should set this value itself, noting that the
        #   default value is a timestamp of zero if the field is left unspecified.
        #   Values must match the granularity of the table (e.g. micros, millis).
        # @return [MutationEntry]  `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.set_cell("cf1", "field01", "XYZ")
        #
        # @example With timestamp
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.set_cell(
        #     "cf-1",
        #     "field-1",
        #     "XYZ"
        #     timestamp: Time.now.to_i * 1000 # Time stamp in millis seconds.
        #   )
        #
        def set_cell family, qualifier, value, timestamp: nil
          # If value is integer then covert it to sign 64 bit int big-endian.
          value = [value].pack("q>") if value.is_a?(Integer)
          options = {
            family_name: family,
            column_qualifier: qualifier,
            value: value
          }

          if timestamp
            options[:timestamp_micros] = timestamp
            @retryable = timestamp != -1
          end
          @mutations << Google::Bigtable::V2::Mutation.new(set_cell: options)
          self
        end

        # Add DeleteFromColumn entry to list of mutations.
        #
        # A Mutation which deletes cells from the specified column, optionally
        # restricting the deletions to a given timestamp range.
        #
        # @param family [String] Table column family name.
        #   The name of the family from which cells should be deleted.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @param qualifier [String] Column qualifier name.
        #   The qualifier of the column from which cells should be deleted.
        #   Can be any byte string, including the empty string.
        # @param timestamp_from [Integer] Timestamp lower bound. Optional.
        #   The range of timestamps within which cells should be deleted.
        # @param timestamp_to [Integer] Timestamp upper bound. Optional.
        #   The range of timestamps within which cells should be deleted.
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example Without timestamp range
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.delete_cells("cf-1", "field-1")
        #
        # @example With timestamp range
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.delete_cells(
        #     "cf1",
        #     "field-1",
        #     timestamp_from: (Time.now.to_i - 1800) * 1000,
        #     timestamp_to: (Time.now.to_i * 1000)
        #   )
        # @example With lower bound timestamp range
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.delete_cells(
        #     "cf1",
        #     "field-1",
        #     timestamp_from: (Time.now.to_i - 1800) * 1000
        #   )
        #
        def delete_cells \
            family,
            qualifier,
            timestamp_from: nil,
            timestamp_to: nil
          grpc = Google::Bigtable::V2::Mutation::DeleteFromColumn.new(
            family_name: family,
            column_qualifier: qualifier
          )
          if timestamp_from || timestamp_to
            time_range = Google::Bigtable::V2::TimestampRange.new
            time_range.start_timestamp_micros = timestamp_from if timestamp_from
            time_range.end_timestamp_micros = timestamp_to if timestamp_to
            grpc.time_range = time_range
          end
          @mutations << Google::Bigtable::V2::Mutation.new(
            delete_from_column: grpc
          )
          self
        end

        # Add DeleteFromFamily to list of mutations.
        #
        # A Mutation which deletes all cells from the specified column family.
        #
        # @param family [String] Table column family name.
        #   The name of the family from which cells should be deleted.
        #   Must match `[-_.a-zA-Z0-9]+`
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.delete_from_family("cf-1")
        #
        def delete_from_family family
          @mutations << Google::Bigtable::V2::Mutation.new(
            delete_from_family: { family_name: family }
          )
          self
        end

        # Add DeleteFromRow entry to list of mutations
        #
        # A Mutation which deletes all cells from the containing row.
        #
        # @return [MutationEntry] `self` object of entry for chaining.
        #
        # @example
        #   entry = Google::Cloud::Bigtable::MutationEntry.new("user-1")
        #   entry.delete_from_row
        #
        def delete_from_row
          @mutations << Google::Bigtable::V2::Mutation.new(delete_from_row: {})
          self
        end

        # Mutation entry is retryable or not based on set_cell value.
        #
        # @return [Boolean]
        #
        def retryable?
          @retryable
        end

        # No of mutations
        #
        # @return [Integer]

        def length
          @mutations.length
        end

        # @private
        #
        # Convert mutation entry to gRPC protobuf object.
        #
        # @return [Google::Bigtable::V2::MutateRowsRequest::Entry]
        #
        def to_grpc
          Google::Bigtable::V2::MutateRowsRequest::Entry.new(
            row_key: @row_key,
            mutations: @mutations
          )
        end
      end
    end
  end
end
