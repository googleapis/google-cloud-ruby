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


require "monitor"
require "concurrent"

module Google
  module Cloud
    module Pubsub
      class Subscriber
        ##
        # @private
        # # AsyncDelayer
        #
        class AsyncDelayer
          include MonitorMixin

          attr_reader :batch
          attr_reader :max_bytes, :interval

          def initialize stream, max_bytes: 10000000, interval: 0.25
            @stream = stream

            @max_bytes = max_bytes
            @interval = interval

            @cond = new_cond

            # init MonitorMixin
            super()
          end

          def delay deadline, ack_ids
            return true if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                if @batch.nil?
                  @batch = Batch.new max_bytes: @max_bytes
                  @batch.add deadline, ack_id
                else
                  unless @batch.try_add deadline, ack_id
                    publish_batch!

                    @batch = Batch.new max_bytes: @max_bytes
                    @batch.add deadline, ack_id
                  end
                end

                @batch_created_at ||= Time.now
                @background_thread ||= Thread.new { run_background }
              end

              @cond.signal
            end

            nil
          end

          def stop
            synchronize do
              break if @stopped

              @stopped = true
              publish_batch!
              @cond.signal
            end

            self
          end

          def wait!
            synchronize do
              @background_thread.join if @background_thread
            end

            self
          end

          def flush
            synchronize do
              publish_batch!
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

                time_since_first_publish = Time.now - @batch_created_at
                if time_since_first_publish > @interval
                  # interval met, publish the batch...
                  publish_batch!
                  @cond.wait
                else
                  # still waiting for the interval to publish the batch...
                  @cond.wait(@interval - time_since_first_publish)
                end
              end
            end
          end

          def publish_batch!
            return if @batch.nil?

            request = @batch.request
            Concurrent::Future.new(executor: @stream.push_thread_pool) do
              @stream.push request
            end.execute

            @batch = nil
            @batch_created_at = nil
          end

          class Batch
            attr_reader :ack_ids, :request

            def initialize max_bytes: 10000000
              @max_bytes = max_bytes
              @request = Google::Pubsub::V1::StreamingPullRequest.new
            end

            def add deadline, ack_id
              @request.modify_deadline_seconds << deadline
              @request.modify_deadline_ack_ids << ack_id
            end

            def try_add deadline, ack_id
              addl_bytes = deadline.to_s.size + ack_id.size
              return false if total_message_size + addl_bytes >= @max_bytes

              add deadline, ack_id
              true
            end

            def total_message_size
              request.to_proto.size
            end
          end
        end
      end
    end
  end
end
