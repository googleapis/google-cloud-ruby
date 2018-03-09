# frozen_string_literal: true

module Google
  module Cloud
    module Bigtable
      class RowsReader # :nodoc:
        # It merge rows chunks and create flat rows and build options
        # for retry read rows

        attr_reader :rows_count, :chunk_reader

        def initialize client, table_path, app_profile_id, options
          @client = client
          @options = options
          @app_profile_id = app_profile_id
          @table_path = table_path
          @chunk_reader = ChunkReader.new
          @rows_count = 0
          @result = []
        end

        def read \
            rows: nil,
            filter: nil,
            rows_limit: nil
          response = @client.read_rows(
            @table_path,
            app_profile_id: @app_profile_id,
            rows: rows,
            filter: filter,
            rows_limit: rows_limit,
            options: @options
          )

          response.each do |res|
            res.chunks.each do |chunk|
              row = @chunk_reader.process(chunk)
              next if row.nil?

              if block_given?
                yield row
              else
                @result << row
              end

              @rows_count += 1
            end
          end

          @chunk_reader.validate_last_row_complete
          @result unless block_given?
        end

        def last_key
          @chunk_reader.last_key
        end

        # Calucate and return read rows limit and row set based on last read key
        #
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @param rows [Google::Bigtable::V2::RowSet]
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

          @chunk_reader.reset_to_new_row
          [rows_limit, row_set]
        end

        private

        def start_key_read? range
          start_key = if !range.start_key_closed.empty?
                        range.start_key_closed
                      else
                        range.start_key_open
                      end

          start_key.empty? || last_key >= start_key
        end

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
