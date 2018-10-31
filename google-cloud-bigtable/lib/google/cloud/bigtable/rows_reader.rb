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


require "google/cloud/bigtable/chunk_processor"

module Google
  module Cloud
    module Bigtable
      # @private
      # # RowsReader
      #
      # Retyable read rows helper
      #
      class RowsReader
        # @private
        # Retryable error list.
        RETRYABLE_ERRORS = [
          GRPC::DeadlineExceeded,
          GRPC::Aborted,
          GRPC::Unavailable,
          GRPC::Core::CallError
        ].freeze

        # @private
        # Default retry limit
        RETRY_LIMIT = 3

        # @private
        # @return [Integer] Current retry count
        attr_accessor :retry_count

        # @private
        #
        # Creates a read rows instance.
        #
        # @param table [Google::Cloud::Bigtable::TableDataOperations]
        #
        def initialize table
          @table = table
          @chunk_processor = ChunkProcessor.new
          @rows_count = 0
          @retry_count = 0
        end

        # Read rows
        #
        # @param rows [Google::Bigtable::V2::RowSet]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   Alternatively, provide a hash in the form of `Google::Bigtable::V2::RowSet`.
        # @param filter [Google::Bigtable::V2::RowFilter | Hash]
        #   The filter to apply to the contents of the specified row(s). If unset,
        #   reads the entirety of each row.
        #   A hash in the form of `Google::Bigtable::V2::RowFilter`
        #   can also be provided.
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @return [:yields: row]
        #   Array of row or yield block for each processed row.

        def read \
            rows: nil,
            filter: nil,
            rows_limit: nil
          response = @table.client.read_rows(
            @table.path,
            rows: rows,
            filter: filter,
            rows_limit: rows_limit,
            app_profile_id: @table.app_profile_id
          )
          response.each do |res|
            res.chunks.each do |chunk|
              @retry_count = 0
              row = @chunk_processor.process(chunk)
              next if row.nil?
              yield row
              @rows_count += 1
            end
          end

          @chunk_processor.validate_last_row_complete
        end

        # Last read row key.
        #
        # @return [String]

        def last_key
          @chunk_processor.last_key
        end

        # Calucates and returns the read rows limit and row set based on last read key.
        #
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @param row_set [Google::Bigtable::V2::RowSet]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   A hash of the same form as `Google::Bigtable::V2::RowSet`
        #   can also be provided.
        # @return [Integer, Google::Bigtable::V2::RowSet]

        def retry_options rows_limit, row_set
          return [rows_limit, row_set] unless last_key

          # 1. Reduce the limit by the number of already returned responses.
          rows_limit -= @rows_count if rows_limit

          # 2. Remove ranges that have already been read, and reduce ranges that
          # include the last read rows
          if last_key
            delete_indexes = []

            row_set.row_ranges.each_with_index do |range, i|
              if end_key_read?(range)
                delete_indexes << i
              elsif start_key_read?(range)
                range.start_key_open = last_key
              end
            end

            delete_indexes.each { |i| row_set.row_ranges.delete_at(i) }
          end

          if row_set.row_ranges.empty?
            row_set.row_ranges <<
              Google::Bigtable::V2::RowRange.new(start_key_open: last_key)
          end

          # 3. Remove all individual keys before and up to the last read key
          row_set.row_keys.select! { |k| k > last_key }

          @chunk_processor.reset_to_new_row
          [rows_limit, row_set]
        end

        # Checks if a read operation is retryable.
        #
        # @return [Boolean]
        def retryable?
          @retry_count < RowsReader::RETRY_LIMIT
        end

        private

        # Checks if the start key was already read for the range.
        #
        # @param range [Google::Bigtable::V2::RowRange]
        # @return [Boolean]
        #
        def start_key_read? range
          start_key = if !range.start_key_closed.empty?
                        range.start_key_closed
                      else
                        range.start_key_open
                      end

          start_key.empty? || last_key >= start_key
        end

        # Checks if the end key was already read for the range.
        #
        # @param range [Google::Bigtable::V2::RowRange]
        # @return [Boolean]
        #
        def end_key_read? range
          end_key = if !range.end_key_closed.empty?
                      range.end_key_closed
                    else
                      range.end_key_open
                    end

          end_key && end_key <= last_key
        end
      end
    end
  end
end
