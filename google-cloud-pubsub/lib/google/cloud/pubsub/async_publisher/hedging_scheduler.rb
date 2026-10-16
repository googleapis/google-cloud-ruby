# Copyright 2026 Google LLC
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


require "google/cloud/pubsub/async_publisher/cancellation_sharer"

module Google
  module Cloud
    module PubSub
      class AsyncPublisher
        ##
        # @private
        #
        # Lightweight FIFO entry representing a scheduled hedge check.
        # Holds only the CancellationSharer coordinator, attempt_number, and
        # monotonic send_after timestamp (never a direct reference to the
        # message batch payload).
        #
        HedgedRequest = Struct.new :coordinator, :attempt_number, :send_after, keyword_init: true

        ##
        # @private
        #
        # Event-driven single-timer FIFO scheduler for Publish Hedging.
        #
        # Because every batch on a Publisher shares the same hedge_delay,
        # appending new HedgedRequest items with send_after = now + hedge_delay
        # keeps the queue naturally ordered by timestamp.
        #
        # Enforces strict lock ordering: due items are popped while holding
        # @mutex, and @mutex is released before inspecting CancellationSharer,
        # acquiring a token from HedgingTokenBucket, logging, or dispatching RPCs.
        #
        class HedgingScheduler
          MAX_HEDGED_ATTEMPT_TIMEOUT = 10.0
          LOG_SUBTAG = "publish-hedged".freeze

          attr_reader :hedge_delay
          attr_reader :token_bucket

          def initialize hedge_delay:,
                         token_bucket:,
                         logger: nil,
                         clock: nil,
                         auto_start: true,
                         &dispatch_block
            @hedge_delay = hedge_delay.to_f
            @token_bucket = token_bucket
            @logger = logger
            @clock = clock || -> { Process.clock_gettime Process::CLOCK_MONOTONIC }
            @auto_start = auto_start
            @dispatch_block = dispatch_block

            @mutex = Mutex.new
            @condvar = ConditionVariable.new
            @queue = []
            @stopped = false
            @timer_thread = nil
          end

          def now
            @clock.call
          end

          def size
            @mutex.synchronize { @queue.size }
          end

          def stopped?
            @mutex.synchronize { @stopped }
          end

          ##
          # Enqueues a hedge check for +coordinator+ at +now + hedge_delay+
          # (or an explicit +send_after+ timestamp).
          #
          # @param [CancellationSharer] coordinator
          # @param [Integer] attempt_number
          # @param [Numeric, nil] send_after
          # @return [HedgedRequest, nil]
          #
          def schedule coordinator, attempt_number: 1, send_after: nil
            target_time = send_after || (now + @hedge_delay)
            req = HedgedRequest.new(
              coordinator: coordinator,
              attempt_number: attempt_number,
              send_after: target_time
            )

            @mutex.synchronize do
              return nil if @stopped

              @queue << req
              if @auto_start
                ensure_timer_thread_locked
                @condvar.broadcast if @queue.length == 1
              end
            end

            req
          end

          ##
          # Pops and returns all HedgedRequest items whose send_after <= current_time
          # while holding @mutex, clearing popped references from the queue.
          #
          # @param [Numeric] current_time
          # @return [Array<HedgedRequest>]
          #
          def drain_due_requests current_time = now
            @mutex.synchronize do
              return [] if @stopped

              ready = []
              ready << @queue.shift while !@queue.empty? && @queue.first.send_after <= current_time
              ready
            end
          end

          ##
          # Drains due HedgedRequest items under @mutex and processes them
          # outside @mutex to avoid lock-order inversion.
          #
          # @param [Numeric] current_time
          # @return [Integer] Number of hedged attempts dispatched.
          #
          def process_queue current_time = now
            ready = drain_due_requests current_time
            dispatched = 0

            ready.each do |req|
              dispatched += 1 if process_due_request req, current_time
            end

            dispatched
          end

          ##
          # Stops the hedging scheduler, waking the timer thread and clearing
          # any pending hedge checks.
          #
          def stop!
            thread = @mutex.synchronize do
              @stopped = true
              @queue.clear
              @condvar.broadcast
              t = @timer_thread
              @timer_thread = nil
              t
            end

            thread.join 1.0 if thread && thread != Thread.current
            self
          end

          private

          def process_due_request req, current_time
            coordinator = req.coordinator
            batch = coordinator.batch
            return false if batch.nil? || coordinator.done?

            remaining_timeout = coordinator.deadline - current_time
            return false if remaining_timeout <= 0

            attempt_timeout = [remaining_timeout, MAX_HEDGED_ATTEMPT_TIMEOUT].min

            if @token_bucket.try_acquire_hedge_token
              @logger&.log(:debug, LOG_SUBTAG) { "Publishing hedged attempt #{req.attempt_number}" }
              schedule(
                coordinator,
                attempt_number: req.attempt_number + 1,
                send_after: current_time + @hedge_delay
              )
              @dispatch_block&.call coordinator, batch, req.attempt_number, attempt_timeout
              true
            else
              @logger&.log(:debug, LOG_SUBTAG) { "Hedging rate limited due to lack of tokens." }
              false
            end
          end

          def ensure_timer_thread_locked
            return if @timer_thread&.alive?

            @timer_thread = Thread.new { timer_loop }
          end

          def timer_loop
            loop do
              should_process = false

              @mutex.synchronize do
                return if @stopped

                if @queue.empty?
                  @condvar.wait @mutex
                else
                  wait_seconds = @queue.first.send_after - now
                  if wait_seconds.positive?
                    @condvar.wait @mutex, wait_seconds
                  else
                    should_process = true
                  end
                end
              end

              process_queue now if should_process
            end
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
