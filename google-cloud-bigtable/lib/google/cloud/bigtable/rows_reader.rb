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
      # Retryable read rows helper
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

        ##
        # Read rows
        #
        # @param rows [Google::Cloud::Bigtable::V2::RowSet]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::V2::RowSet`.
        # @param filter [Google::Cloud::Bigtable::V2::RowFilter | Hash]
        #   The filter to apply to the contents of the specified row(s). If unset,
        #   reads the entirety of each row.
        #   A hash in the form of `Google::Cloud::Bigtable::V2::RowFilter`
        #   can also be provided.
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @return [:yields: row]
        #   Array of row or yield block for each processed row.
        #
        def read rows: nil, filter: nil, rows_limit: nil
          @rows_count = 0
          response = @table.service.read_rows(
            @table.instance_id,
            @table.table_id,
            rows:           rows,
            filter:         filter,
            rows_limit:     rows_limit,
            app_profile_id: @table.app_profile_id
          )
          response.each do |res|
            res.chunks.each do |chunk|
              @retry_count = 0
              row = @chunk_processor.process chunk
              next if row.nil?
              yield row
              @rows_count += 1
            end

            if res.last_scanned_row_key && !res.last_scanned_row_key.empty?
              @chunk_processor.last_key = res.last_scanned_row_key
            end
          end

          @chunk_processor.validate_last_row_complete
        end

        ##
        # Last read row key.
        #
        # @return [String]
        #
        def last_key
          @chunk_processor.last_key
        end

        ##
        # Calculates and returns the read rows limit and row set based on last read key.
        #
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @param row_set [Google::Cloud::Bigtable::V2::RowSet]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   A hash of the same form as `Google::Cloud::Bigtable::V2::RowSet`
        #   can also be provided.
        # @return ResumptionOption
        #
        def retry_options rows_limit, row_set
          return ResumptionOption.new false, rows_limit, row_set unless last_key

          # Check if we've already read read rows_limit number of rows.
          # If true, mark ResumptionOption is_complete to true.
          return ResumptionOption.new true, nil, nil if rows_limit && rows_limit == @rows_count

          # Reduce the limit by the number of already returned responses.
          rows_limit -= @rows_count if rows_limit

          reset_row_set rows_limit, row_set
        end

        ##
        # Calculate the new row_set for the retry request
        # @param rows_limit [Integer]
        #    the updated rows_limit
        # @param row_set [Google::Cloud::Bigtable::V2::RowSet]
        #    original row_set
        # @return ResumptionOption
        def reset_row_set rows_limit, row_set
          # 1. Remove ranges that have already been read, and reduce ranges that
          # include the last read rows
          if last_key
            row_set.row_ranges.reject! { |r| end_key_read? r }
            row_set.row_ranges.each do |range|
              if start_key_read? range
                range.start_key_open = last_key
              end
            end
          end

          # 2. Remove all individual keys before and up to the last read key
          row_set.row_keys.select! { |k| k > last_key }

          # 3. In read_operations, we always add an empty row_range if row_ranges and
          # row_keys are not defined. So if both row_ranges and row_keys are empty,
          # it means that we've already read all the ranges and keys, set ResumptionOption
          # is_complete to true to indicate that this read is successful.
          if last_key && row_set.row_ranges.empty? && row_set.row_keys.empty?
            return ResumptionOption.new true, nil, nil
          end

          @chunk_processor.reset_to_new_row

          ResumptionOption.new false, rows_limit, row_set
        end

        ##
        # Checks if a read operation is retryable.
        #
        # @return [Boolean]
        #
        def retryable?
          @retry_count < RowsReader::RETRY_LIMIT
        end

        private

        ##
        # Checks if the start key was already read for the range.
        #
        # @param range [Google::Cloud::Bigtable::V2::RowRange]
        # @return [Boolean]
        #
        def start_key_read? range
          if !range.start_key_closed.empty?
            last_key >= range.start_key_closed
          elsif !range.start_key_open.empty?
            last_key > range.start_key_closed
          else
            # start is unbounded
            true
          end
        end

        ##
        # Checks if the end key was already read for the range.
        #
        # @param range [Google::Cloud::Bigtable::V2::RowRange]
        # @return [Boolean]
        #
        def end_key_read? range
          if !range.end_key_closed.empty?
            range.end_key_closed <= last_key
          elsif !range.end_key_open.empty?
            range.end_key_open <= last_key
          else
            # end is unbounded
            false
          end
        end
      end

      # @private
      # ResumptionOption
      # Helper class returned by retry_options
      class ResumptionOption
        # @private
        # Creates a ResumptionOption instance
        # @param is_complete [Boolean]
        #    marks if the current read is complete
        # @param rows_limit [Integer]
        #    limit of the retry request
        # @param row_set [Google::Cloud::Bigtable::V2::RowSet]
        #    row_set of the retry request
        def initialize is_complete, rows_limit, row_set
          @is_complete = is_complete
          @rows_limit = rows_limit
          @row_set = row_set
        end

        attr_reader :rows_limit
        attr_reader :row_set

        ##
        # returns if this operation should be retried
        def complete?
          @is_complete
        end
      end
    end
  end
end
