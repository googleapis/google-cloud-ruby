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


require "concurrent/atomics"

module Google
  module Cloud
    module PubSub
      class AsyncPublisher
        ##
        # @private
        #
        # Internal exception raised when an in-flight publish attempt or its
        # retry backoff sleep is cancelled by a winning sibling attempt.
        #
        class AttemptCancelledError < StandardError
        end

        ##
        # @private
        #
        # Thread-safe cancellation handle for an individual publish RPC attempt
        # (either the original attempt 0 or a hedged backup attempt 1..N).
        #
        class AttemptHandle
          def initialize
            @mutex = Mutex.new
            @cancelled = false
            @operation = nil
            @on_cancel_callbacks = []
            @cancel_event = Concurrent::Event.new
          end

          def cancelled?
            @mutex.synchronize { @cancelled }
          end

          ##
          # Registers an active gRPC operation (or any object responding to #cancel)
          # with this attempt handle. If the handle was already cancelled before
          # registration, cancels the operation immediately and raises AttemptCancelledError.
          #
          # @param [#cancel] operation
          #
          def register_operation operation
            already_cancelled = @mutex.synchronize do
              if @cancelled
                true
              else
                @operation = operation
                false
              end
            end

            return unless already_cancelled

            operation.cancel if operation.respond_to? :cancel
            raise AttemptCancelledError, "Publish attempt cancelled"
          end

          def clear_operation
            @mutex.synchronize { @operation = nil }
          end

          def on_cancel &block
            return unless block_given?

            invoke_now = @mutex.synchronize do
              if @cancelled
                true
              else
                @on_cancel_callbacks << block
                false
              end
            end

            block.call if invoke_now
          end

          ##
          # Sleeps for up to +seconds+, waking and raising AttemptCancelledError
          # immediately if {#cancel!} is called.
          #
          # @param [Numeric] seconds
          #
          def sleep_interruptibly seconds
            raise AttemptCancelledError, "Publish attempt cancelled" if cancelled?
            return if seconds <= 0

            return unless @cancel_event.wait seconds

            raise AttemptCancelledError, "Publish attempt cancelled"
          end

          ##
          # Cancels the attempt, aborting any registered gRPC operation and
          # waking any interruptible retry sleep.
          #
          # @return [Boolean] true if this call transitioned the handle to cancelled.
          #
          def cancel!
            op = nil
            callbacks = nil

            transitioned = @mutex.synchronize do
              if @cancelled
                false
              else
                @cancelled = true
                op = @operation
                @operation = nil
                callbacks = @on_cancel_callbacks.dup
                @on_cancel_callbacks.clear
                @cancel_event.set
                true
              end
            end

            return false unless transitioned

            op.cancel if op.respond_to? :cancel
            callbacks.each(&:call)
            true
          end
        end

        ##
        # @private
        #
        # Per-batch coordinator managing the original publish attempt (attempt 0)
        # and any hedged backup attempts (attempt 1..N).
        #
        # Enforces:
        # 1. First-wins sibling cancellation outside the coordinator mutex.
        # 2. Immediate release of the shared batch payload reference (@batch = nil)
        #    on completion so completed batches can be garbage-collected while
        #    HedgedRequest entries remain queued in HedgingScheduler.
        # 3. Asymmetric error handling: hedged attempt failures are ignored while
        #    attempt 0 is in flight; terminal failure of attempt 0 (or exhaustion
        #    of all running attempts) immediately cancels remaining attempts and
        #    rejects the batch.
        #
        class CancellationSharer
          attr_reader :deadline

          def initialize batch:, token_bucket:, deadline:
            @mutex = Mutex.new
            @batch = batch
            @token_bucket = token_bucket
            @deadline = deadline
            @done = false
            @running_attempts = {}
            @winning_attempt = nil
            @response = nil
            @error = nil
            @completion_event = Concurrent::Event.new
            @on_complete_callbacks = []
          end

          def done?
            @mutex.synchronize { @done }
          end

          def batch
            @mutex.synchronize { @batch }
          end

          def winning_attempt
            @mutex.synchronize { @winning_attempt }
          end

          def running_attempt_count
            @mutex.synchronize { @running_attempts.size }
          end

          ##
          # Registers an attempt handle for +attempt_number+. If the coordinator
          # has already finished, cancels +handle+ immediately outside the mutex
          # and returns nil.
          #
          # @param [Integer] attempt_number
          # @param [AttemptHandle] handle
          # @return [AttemptHandle, nil]
          #
          def add_attempt attempt_number, handle = AttemptHandle.new
            already_done = @mutex.synchronize do
              if @done
                true
              else
                @running_attempts[attempt_number] = handle
                false
              end
            end

            if already_done
              handle.cancel!
              return nil
            end

            handle
          end

          ##
          # Records a successful attempt. If this is the first completion,
          # transitions to done, releases @batch = nil, refills the token bucket,
          # cancels all sibling attempts, and resolves waiting callers outside the lock.
          #
          # @param [Integer] attempt_number
          # @param [Object] response
          # @return [Boolean] true if this attempt won the race.
          #
          def handle_attempt_success attempt_number, response
            other_handles = nil
            callbacks = nil

            won = @mutex.synchronize do
              if @done
                false
              else
                @done = true
                @winning_attempt = attempt_number
                @response = response
                @batch = nil
                @running_attempts.delete attempt_number
                other_handles = @running_attempts.values
                @running_attempts.clear
                callbacks = @on_complete_callbacks.dup
                @on_complete_callbacks.clear
                true
              end
            end

            return false unless won

            @token_bucket&.refill
            other_handles.each(&:cancel!)
            @completion_event.set
            callbacks.each { |cb| cb.call response, nil, attempt_number }
            true
          end

          ##
          # Records a failed attempt. Errors from hedged attempts (attempt_number > 0)
          # are ignored as long as attempt 0 (or another attempt) is still running.
          # If attempt 0 fails terminally or no running attempts remain, cancels any
          # remaining attempts and fails the batch outside the lock.
          #
          # @param [Integer] attempt_number
          # @param [StandardError] error
          # @return [Boolean] true if this failure terminated the batch.
          #
          def handle_attempt_failure attempt_number, error
            other_handles = nil
            callbacks = nil

            terminated = @mutex.synchronize do
              if @done
                false
              else
                @running_attempts.delete attempt_number
                if attempt_number.positive? && !@running_attempts.empty?
                  false
                else
                  @done = true
                  @error = error
                  @batch = nil
                  other_handles = @running_attempts.values
                  @running_attempts.clear
                  callbacks = @on_complete_callbacks.dup
                  @on_complete_callbacks.clear
                  true
                end
              end
            end

            return false unless terminated

            other_handles.each(&:cancel!)
            @completion_event.set
            callbacks.each { |cb| cb.call nil, error, attempt_number }
            true
          end

          ##
          # Cancels all running attempts and marks the batch done.
          #
          # @param [StandardError] error
          # @return [Boolean]
          #
          def cancel_all! error = AttemptCancelledError.new("Batch publish cancelled")
            handles = nil
            callbacks = nil

            cancelled = @mutex.synchronize do
              if @done
                false
              else
                @done = true
                @error = error
                @batch = nil
                handles = @running_attempts.values
                @running_attempts.clear
                callbacks = @on_complete_callbacks.dup
                @on_complete_callbacks.clear
                true
              end
            end

            return false unless cancelled

            handles.each(&:cancel!)
            @completion_event.set
            callbacks.each { |cb| cb.call nil, error, nil }
            true
          end

          ##
          # Registers a completion callback invoked outside the coordinator lock
          # with +(response, error, winning_attempt)+.
          #
          def on_complete &block
            return unless block_given?

            done_now = false
            resp = nil
            err = nil
            winner = nil

            @mutex.synchronize do
              if @done
                done_now = true
                resp = @response
                err = @error
                winner = @winning_attempt
              else
                @on_complete_callbacks << block
              end
            end

            block.call resp, err, winner if done_now
          end

          ##
          # Blocks until the batch completes and returns the winning response
          # or raises the terminal error.
          #
          # @param [Numeric, nil] timeout
          # @return [Object]
          #
          def wait timeout = nil
            @completion_event.wait timeout
            err, resp = @mutex.synchronize { [@error, @response] }
            raise err if err

            resp
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
