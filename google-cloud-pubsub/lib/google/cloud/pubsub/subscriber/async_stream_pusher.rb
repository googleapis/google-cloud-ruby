# Copyright 2017 Google LLC
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


require "monitor"
require "concurrent"

module Google
  module Cloud
    module Pubsub
      class Subscriber
        ##
        # @private
        # # AsyncStreamPusher
        #
        class AsyncStreamPusher
          include MonitorMixin

          attr_reader :batch
          attr_reader :max_bytes, :interval

          def initialize stream, max_bytes: 10000000, interval: 1.0
            @stream = stream

            @max_bytes = max_bytes
            @interval = interval

            @cond = new_cond

            # init MonitorMixin
            super()
          end

          def acknowledge ack_ids
            return true if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                if @batch.nil?
                  @batch = Batch.new max_bytes: @max_bytes
                  @batch.ack ack_id
                else
                  unless @batch.try_ack ack_id
                    push_batch_request!

                    @batch = Batch.new max_bytes: @max_bytes
                    @batch.ack ack_id
                  end
                end

                push_batch_request! if @batch.ready?
              end

              @cond.signal
            end

            nil
          end

          def delay deadline, ack_ids
            return true if ack_ids.empty?

            synchronize do
              ack_ids.each do |ack_id|
                if @batch.nil?
                  @batch = Batch.new max_bytes: @max_bytes
                  @batch.delay deadline, ack_id
                else
                  unless @batch.try_delay deadline, ack_id
                    push_batch_request!

                    @batch = Batch.new max_bytes: @max_bytes
                    @batch.delay deadline, ack_id
                  end
                end

                push_batch_request! if @batch.ready?
              end

              @cond.signal
            end

            nil
          end

          def start
            synchronize do
              @stopped = false

              @background_thread ||= Thread.new { run_background }
            end

            self
          end

          def stop
            synchronize do
              push_batch_request!

              @stopped = true
              @cond.broadcast
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
                  @cond.wait # wait until broadcast
                  next
                end

                time_from_batch_creation = Time.now - @batch.created_at
                time_until_next_push = @interval - time_from_batch_creation

                if time_until_next_push <= 0
                  # interval met, publish the batch...
                  push_batch_request!
                  time_until_next_push = nil # wait until broadcast
                end

                @cond.wait time_until_next_push
              end
            end
          end

          def push_batch_request!
            return unless @batch

            @stream.push @batch.request

            @batch = nil
          end

          class Batch
            attr_reader :max_bytes, :request, :created_at

            def initialize max_bytes: 10000000
              @max_bytes = max_bytes
              @request = Google::Pubsub::V1::StreamingPullRequest.new
              @total_message_bytes = 0
              @created_at = Time.now
            end

            def ack ack_id
              @request.ack_ids << ack_id
              @total_message_bytes += addl_ack_bytes ack_id
            end

            def try_ack ack_id
              addl_bytes = addl_ack_bytes ack_id
              return false if total_message_bytes + addl_bytes >= @max_bytes

              ack ack_id
              true
            end

            def addl_ack_bytes ack_id
              ack_id.bytesize + 2
            end

            def delay deadline, ack_id
              @request.modify_deadline_seconds << deadline
              @request.modify_deadline_ack_ids << ack_id
              @total_message_bytes += addl_delay_bytes deadline, ack_id
            end

            def try_delay deadline, ack_id
              addl_bytes = addl_delay_bytes deadline, ack_id
              return false if total_message_bytes + addl_bytes >= @max_bytes

              delay deadline, ack_id
              true
            end

            def addl_delay_bytes deadline, ack_id
              bytes_for_int(deadline) + ack_id.bytesize + 4
            end

            def bytes_for_int num
              # Ruby 2.0 does not have Integer#bit_length
              return [num].pack("s").bytesize unless num.respond_to? :bit_length

              (num.bit_length / 8.0).ceil
            end

            def ready?
              total_message_bytes >= @max_bytes
            end

            def total_message_bytes
              @total_message_bytes
            end
          end
        end
      end
    end
  end
end
