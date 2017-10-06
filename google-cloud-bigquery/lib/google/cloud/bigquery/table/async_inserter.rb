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
    module Bigquery
      class Table
        ##
        # # AsyncInserter
        #
        class AsyncInserter
          include MonitorMixin

          attr_reader :table, :batch
          attr_reader :max_bytes, :max_rows, :interval, :threads

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

          def stop
            synchronize do
              break if @stopped

              @stopped = true
              push_batch_request!
              @cond.signal
            end

            self
          end

          def wait! timeout = nil
            synchronize do
              @thread_pool.shutdown
              @thread_pool.wait_for_termination timeout
            end

            self
          end

          def flush
            synchronize do
              push_batch_request!
              @cond.signal
            end

            self
          end

          def started?
            !stopped?
          end

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
                  # still waiting for the interval to publish the batch...
                  @cond.wait(@interval - time_since_first_publish)
                else
                  # interval met, publish the batch...
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
                @callback.call response if @callback
              rescue => e
                raise e.inspect
              end
            end.execute

            @batch = nil
            @batch_created_at = nil
          end

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
        end
      end
    end
  end
end
