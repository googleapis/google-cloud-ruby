# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/bigquery/convert"
require "monitor"
require "concurrent"

module Google
  module Cloud
    module BigQuery
      class Table
        ##
        # # AsyncInserter
        #
        # Used to insert multiple rows in batches to a topic. See
        # {Google::Cloud::BigQuery::Table#insert_async}.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #   inserter = table.insert_async do |result|
        #     if result.error?
        #       log_error result.error
        #     else
        #       log_insert "inserted #{result.insert_count} rows " \
        #         "with #{result.error_count} errors"
        #     end
        #   end
        #
        #   rows = [
        #     { "first_name" => "Alice", "age" => 21 },
        #     { "first_name" => "Bob", "age" => 22 }
        #   ]
        #   inserter.insert rows
        #
        #   inserter.stop.wait!
        #
        # @attr_reader [Integer] max_bytes The maximum size of rows to be
        #   collected before the batch is inserted. Default is 10,000,000
        #   (10MB).
        # @attr_reader [Integer] max_rows The maximum number of rows to be
        #   collected before the batch is inserted. Default is 500.
        # @attr_reader [Numeric] interval The number of seconds to collect rows
        #   before the batch is inserted. Default is 10.
        # @attr_reader [Integer] threads The number of threads used to insert
        #   rows. Default is 4.
        #
        class AsyncInserter
          include MonitorMixin

          attr_reader :max_bytes, :max_rows, :interval, :threads
          ##
          # @private Implementation accessors
          attr_reader :table, :batch

          ##
          # @private
          def initialize table, skip_invalid: nil, ignore_unknown: nil,
                         max_bytes: 10000000, max_rows: 500, interval: 10,
                         threads: 4, &block
            @table = table
            @skip_invalid = skip_invalid
            @ignore_unknown = ignore_unknown

            @max_bytes = max_bytes
            @max_rows = max_rows
            @interval = interval
            @threads = threads
            @callback = block

            @batch = nil

            @thread_pool = Concurrent::FixedThreadPool.new @threads

            @cond = new_cond

            # init MonitorMixin
            super()
          end

          ##
          # Adds rows to the async inserter to be inserted. Rows will be
          # collected in batches and inserted together.
          # See {Google::Cloud::BigQuery::Table#insert_async}.
          #
          # @param [Hash, Array<Hash>] rows A hash object or array of hash
          #   objects containing the data.
          #
          def insert rows
            return nil if rows.nil?
            return nil if rows.is_a?(Array) && rows.empty?
            rows = [rows] if rows.is_a? Hash

            synchronize do
              rows.each do |row|
                if @batch.nil?
                  @batch = Batch.new max_bytes: @max_bytes, max_rows: @max_rows
                  @batch.insert row
                else
                  unless @batch.try_insert row
                    push_batch_request!

                    @batch = Batch.new max_bytes: @max_bytes,
                                       max_rows: @max_rows
                    @batch.insert row
                  end
                end

                @batch_created_at ||= ::Time.now
                @background_thread ||= Thread.new { run_background }

                push_batch_request! if @batch.ready?
              end

              @cond.signal
            end

            true
          end

          ##
          # Begins the process of stopping the inserter. Rows already in the
          # queue will be inserted, but no new rows can be added. Use {#wait!}
          # to block until the inserter is fully stopped and all pending rows
          # have been inserted.
          #
          # @return [AsyncInserter] returns self so calls can be chained.
          #
          def stop
            synchronize do
              break if @stopped

              @stopped = true
              push_batch_request!
              @cond.signal
            end

            self
          end

          ##
          # Blocks until the inserter is fully stopped, all pending rows
          # have been inserted, and all callbacks have completed. Does not stop
          # the inserter. To stop the inserter, first call {#stop} and then
          # call {#wait!} to block until the inserter is stopped.
          #
          # @return [AsyncInserter] returns self so calls can be chained.
          #
          def wait! timeout = nil
            synchronize do
              @thread_pool.shutdown
              @thread_pool.wait_for_termination timeout
            end

            self
          end

          ##
          # Forces all rows in the current batch to be inserted immediately.
          #
          # @return [AsyncInserter] returns self so calls can be chained.
          #
          def flush
            synchronize do
              push_batch_request!
              @cond.signal
            end

            self
          end

          ##
          # Whether the inserter has been started.
          #
          # @return [boolean] `true` when started, `false` otherwise.
          #
          def started?
            !stopped?
          end

          ##
          # Whether the inserter has been stopped.
          #
          # @return [boolean] `true` when stopped, `false` otherwise.
          #
          def stopped?
            synchronize { @stopped }
          end

          protected

          def run_background
            synchronize do
              until @stopped
                if @batch.nil?
                  @cond.wait
                  next
                end

                time_since_first_publish = ::Time.now - @batch_created_at
                if time_since_first_publish < @interval
                  # still waiting for the interval to insert the batch...
                  @cond.wait(@interval - time_since_first_publish)
                else
                  # interval met, insert the batch...
                  push_batch_request!
                  @cond.wait
                end
              end
            end
          end

          def push_batch_request!
            return unless @batch

            batch_rows = @batch.rows
            Concurrent::Future.new(executor: @thread_pool) do
              begin
                response = @table.insert batch_rows,
                                         skip_invalid:   @skip_invalid,
                                         ignore_unknown: @ignore_unknown
                result = Result.new response
              rescue => e
                result = Result.new nil, e
              ensure
                @callback.call result if @callback
              end
            end.execute

            @batch = nil
            @batch_created_at = nil
          end

          ##
          # @private
          class Batch
            attr_reader :max_bytes, :max_rows, :rows

            def initialize max_bytes: 10000000, max_rows: 500
              @max_bytes = max_bytes
              @max_rows = max_rows
              @rows = []
            end

            def insert row
              @rows << row
            end

            def try_insert row
              addl_bytes = row.to_json.bytes.size + 1
              return false if current_bytes + addl_bytes >= @max_bytes
              return false if @rows.count + 1 >= @max_rows

              insert row
              true
            end

            def ready?
              current_bytes >= @max_bytes || rows.count >= @max_rows
            end

            def current_bytes
              # TODO: add to a counter instead of calling #to_json each time
              Convert.to_json_rows(rows).to_json.bytes.size
            end
          end

          ##
          # AsyncInserter::Result
          #
          # Represents the result from BigQuery, including any error
          # encountered, when data is asynchronously inserted into a table for
          # near-immediate querying. See {Dataset#insert_async} and
          # {Table#insert_async}.
          #
          # @see https://cloud.google.com/bigquery/streaming-data-into-bigquery
          #   Streaming Data Into BigQuery
          #
          # @attr_reader [Google::Cloud::BigQuery::InsertResponse, nil]
          #   insert_response The response from the insert operation if no
          #   error was encountered, or `nil` if the insert operation
          #   encountered an error.
          # @attr_reader [Error, nil] error The error from the insert operation
          #   if any error was encountered, otherwise `nil`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.table "my_table"
          #   inserter = table.insert_async do |result|
          #     if result.error?
          #       log_error result.error
          #     else
          #       log_insert "inserted #{result.insert_count} rows " \
          #         "with #{result.error_count} errors"
          #     end
          #   end
          #
          #   rows = [
          #     { "first_name" => "Alice", "age" => 21 },
          #     { "first_name" => "Bob", "age" => 22 }
          #   ]
          #   inserter.insert rows
          #
          #   inserter.stop.wait!
          #
          class Result
            # @private
            def initialize insert_response, error = nil
              @insert_response = insert_response
              @error = error
            end

            attr_reader :insert_response, :error

            ##
            # Checks if an error is present, meaning that the insert operation
            # encountered an error. Use {#error} to access the error. For
            # row-level errors, see {#success?} and {#insert_errors}.
            #
            # @return [Boolean] `true` when an error is present, `false`
            #   otherwise.
            #
            def error?
              !error.nil?
            end

            ##
            # Checks if the error count for row-level errors is zero, meaning
            # that all of the rows were inserted. Use {#insert_errors} to access
            # the row-level errors. To check for and access any operation-level
            # error, use {#error?} and {#error}.
            #
            # @return [Boolean, nil] `true` when the error count is zero,
            #   `false` when the error count is positive, or `nil` if the insert
            #   operation encountered an error.
            #
            def success?
              return nil if error?
              insert_response.success?
            end


            ##
            # The count of rows in the response, minus the count of errors for
            # rows that were not inserted.
            #
            # @return [Integer, nil] The number of rows inserted, or `nil` if
            #   the insert operation encountered an error.
            #
            def insert_count
              return nil if error?
              insert_response.insert_count
            end


            ##
            # The count of errors for rows that were not inserted.
            #
            # @return [Integer, nil] The number of errors, or `nil` if the
            #   insert operation encountered an error.
            #
            def error_count
              return nil if error?
              insert_response.error_count
            end

            ##
            # The error objects for rows that were not inserted.
            #
            # @return [Array<InsertError>, nil] An array containing error
            #   objects, or `nil` if the insert operation encountered an error.
            #
            def insert_errors
              return nil if error?
              insert_response.insert_errors
            end

            ##
            # The rows that were not inserted.
            #
            # @return [Array<Hash>, nil] An array of hash objects containing the
            #   row data, or `nil` if the insert operation encountered an error.
            #
            def error_rows
              return nil if error?
              insert_response.error_rows
            end

            ##
            # Returns the error object for a row that was not inserted.
            #
            # @param [Hash] row A hash containing the data for a row.
            #
            # @return [InsertError, nil] An error object, `nil` if no error is
            #   found in the response for the row, or `nil` if the insert
            #   operation encountered an error.
            #
            def insert_error_for row
              return nil if error?
              insert_response.insert_error_for row
            end

            ##
            # Returns the error hashes for a row that was not inserted. Each
            # error hash contains the following keys: `reason`, `location`,
            # `debugInfo`, and `message`.
            #
            # @param [Hash, nil] row A hash containing the data for a row.
            #
            # @return [Array<Hash>, nil] An array of error hashes, `nil` if no
            #   errors are found in the response for the row, or `nil` if the
            #   insert operation encountered an error.
            #
            def errors_for row
              return nil if error?
              insert_response.errors_for row
            end

            ##
            # Returns the index for a row that was not inserted.
            #
            # @param [Hash, nil] row A hash containing the data for a row.
            #
            # @return [Integer, nil] An error object, `nil` if no error is
            #   found in the response for the row, or `nil` if the insert
            #   operation encountered an error.
            #
            def index_for row
              return nil if error?
              insert_response.index_for row
            end
          end
        end
      end
    end
  end
end
