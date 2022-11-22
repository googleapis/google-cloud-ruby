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


require "google/cloud/bigtable/row"
require "google/cloud/bigtable/rows_reader"
require "google/cloud/bigtable/row_range"
require "google/cloud/bigtable/row_filter"
require "google/cloud/bigtable/sample_row_key"

module Google
  module Cloud
    module Bigtable
      ##
      # # ReadOperations
      #
      # Collection of read-rows APIs.
      #
      #   * Sample row key
      #   * Read row
      #   * Read rows
      #
      module ReadOperations
        ##
        # Reads sample row keys.
        #
        # Returns a sample of row keys in the table. The returned row keys will
        # delimit contiguous sections of the table of approximately equal size. The
        # sections can be used to break up the data for distributed tasks like
        # MapReduces.
        #
        # @yieldreturn [Google::Cloud::Bigtable::SampleRowKey]
        # @return [:yields: sample_row_key]
        #   Yield block for each processed SampleRowKey.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.sample_row_keys.each do |sample_row_key|
        #     p sample_row_key.key # user00116
        #     p sample_row_key.offset # 805306368
        #   end
        #
        def sample_row_keys
          return enum_for :sample_row_keys unless block_given?

          response = service.sample_row_keys path, app_profile_id: @app_profile_id
          response.each do |grpc|
            yield SampleRowKey.from_grpc grpc
          end
        end

        ##
        # Reads rows.
        #
        # Streams back the contents of all requested rows in key order, optionally
        # applying the same Reader filter to each.
        # `read_rows`, `row_ranges` and `filter` if not specified, reads from all rows.
        #
        # See {Google::Cloud::Bigtable::RowFilter} for filter types.
        #
        # @param keys [Array<String>] List of row keys to be read. Optional.
        # @param ranges [Google::Cloud::Bigtable::RowRange | Array<Google::Cloud::Bigtable::RowRange>]
        #   Row ranges array or single range. Optional.
        # @param filter [SimpleFilter, ChainFilter, InterleaveFilter, ConditionFilter]
        #   The filter to apply to the contents of the specified row(s). If unset,
        #   reads the entries of each row. Optional.
        # @param limit [Integer] Limit number of read rows count. Optional.
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @return [Array<Google::Cloud::Bigtable::Row> | :yields: row]
        #   Array of row or yield block for each processed row.
        # @example Read with limit.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.read_rows(limit: 10).each do |row|
        #     puts row
        #   end
        #
        # @example Read using row keys.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.read_rows(keys: ["user-1", "user-2"]).each do |row|
        #     puts row
        #   end
        #
        # @example Read using row ranges.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.between "user-1", "user-100"
        #
        #   table.read_rows(ranges: range).each do |row|
        #     puts row
        #   end
        #
        # @example Read using filter.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   filter = table.filter.key "user-*"
        #   # OR
        #   # filter = Google::Cloud::Bigtable::RowFilter.key "user-*"
        #
        #   table.read_rows(filter: filter).each do |row|
        #     puts row
        #   end
        #
        # @example Read using filter with limit.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   filter = table.filter.key "user-*"
        #   # OR
        #   # filter = Google::Cloud::Bigtable::RowFilter.key "user-*"
        #
        #   table.read_rows(filter: filter, limit: 10).each do |row|
        #     puts row
        #   end
        #
        def read_rows keys: nil, ranges: nil, filter: nil, limit: nil, &block
          return enum_for :read_rows, keys: keys, ranges: ranges, filter: filter, limit: limit unless block_given?

          row_set = build_row_set keys, ranges
          rows_limit = limit
          rows_filter = filter.to_grpc if filter
          rows_reader = RowsReader.new self

          begin
            rows_reader.read rows: row_set, filter: rows_filter, rows_limit: rows_limit, &block
          rescue *RowsReader::RETRYABLE_ERRORS => e
            rows_reader.retry_count += 1
            raise Google::Cloud::Error.from_error(e) unless rows_reader.retryable?
            rows_limit, row_set = rows_reader.retry_options limit, row_set
            retry
          end
        end

        ##
        # Reads a single row by row key.
        #
        # @param key [String] Row key. Required.
        # @param filter [Google::Cloud::Bigtable::RowFilter]
        #   The filter to apply to the contents of the specified row. Optional.
        # @return [Google::Cloud::Bigtable::Row]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   row = table.read_row "user-1"
        #
        # @example Read row with filter.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   filter = Google::Cloud::Bigtable::RowFilter.cells_per_row 3
        #
        #   row = table.read_row "user-1", filter: filter
        #
        def read_row key, filter: nil
          read_rows(keys: [key], filter: filter).first
        end

        ##
        # Creates a new instance of ValueRange.
        #
        # @return [Google::Cloud::Bigtable::ValueRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range
        #   range.from "abc"
        #   range.to "xyz"
        #
        #   # OR
        #   range = table.new_value_range.from("abc").to("xyz")
        #
        # @example With exclusive from range.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_value_range.from("abc", inclusive: false).to("xyz")
        #
        def new_value_range
          Google::Cloud::Bigtable::ValueRange.new
        end

        ##
        # Gets a new instance of ColumnRange.
        #
        # @param family [String] Column family name.
        # @return [Google::Cloud::Bigtable::ColumnRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_column_range "test-family"
        #   range.from "abc"
        #   range.to "xyz"
        #
        #   # OR
        #   range = table.new_column_range("test-family").from("key-1").to("key-5")
        #
        # @example With exclusive from range.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_column_range("test-family").from("key-1", inclusive: false).to("key-5")
        #
        def new_column_range family
          Google::Cloud::Bigtable::ColumnRange.new family
        end

        ##
        # Gets a new instance of RowRange.
        #
        # @return [Google::Cloud::Bigtable::RowRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range
        #   range.from "abc"
        #   range.to "xyz"
        #
        #   # OR
        #   range = table.new_row_range.from("key-1").to("key-5")
        #
        # @example With exclusive from range.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   range = table.new_row_range.from("key-1", inclusive: false).to("key-5")
        #
        def new_row_range
          Google::Cloud::Bigtable::RowRange.new
        end

        ##
        # Gets a row filter.
        #
        # @return [Google::Cloud::Bigtable::RowRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   filter = table.filter.key "user-*"
        #
        def filter
          Google::Cloud::Bigtable::RowFilter
        end

        private

        ##
        # Builds a RowSet object from row keys and row ranges.
        #
        # @param row_keys [Array<String>]
        # @param row_ranges [Google::Cloud::Bigtable::RowRange | Array<Google::Cloud::Bigtable::RowRange>]
        # @return [Google::Cloud::Bigtable::V2::RowSet]
        #
        def build_row_set row_keys, row_ranges
          row_set = {}
          row_set[:row_keys] = row_keys if row_keys

          if row_ranges
            row_ranges = [row_ranges] unless row_ranges.instance_of? Array
            row_set[:row_ranges] = row_ranges.map(&:to_grpc)
          end

          Google::Cloud::Bigtable::V2::RowSet.new row_set
        end
      end
    end
  end
end
