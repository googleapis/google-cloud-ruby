# Copyright 2021 Google LLC
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


require "google/cloud/pubsub/errors"
require "concurrent/atomics"

module Google
  module Cloud
    module PubSub
      ##
      # @private
      #
      # Used to control the flow of messages passing through it.
      #
      class FlowController
        attr_reader :message_limit
        attr_reader :byte_limit
        attr_reader :limit_exceeded_behavior
        ##
        # @private Implementation accessors
        attr_reader :outstanding_messages, :outstanding_bytes, :awaiting_message_acquires, :awaiting_bytes_acquires

        def initialize message_limit: 1000, byte_limit: 10_000_000, limit_exceeded_behavior: :ignore
          # init MonitorMixin
          # super()
          unless [:ignore, :error, :block].include? limit_exceeded_behavior
            raise ArgumentError, "limit_exceeded_behavior must be one of :ignore, :error, :block"
          end
          @mutex = Mutex.new
          @message_limit = message_limit
          @byte_limit = byte_limit
          @limit_exceeded_behavior = limit_exceeded_behavior
          @outstanding_messages = 0
          @outstanding_bytes = 0

          @awaiting_message_acquires = []
          @awaiting_bytes_acquires = []
        end

        def acquire message_size
          return if limit_exceeded_behavior == :ignore
          @mutex.lock
          if limit_exceeded_behavior == :error && @outstanding_messages + 1 > message_limit
            raise FlowControlLimitError, "Flow control message limit (#{message_limit}) would be exceeded"
          end
          if limit_exceeded_behavior == :error && @outstanding_bytes + message_size > byte_limit
            raise FlowControlLimitError,
                  "Flow control byte limit (#{byte_limit}) would be exceeded, message_size: #{message_size}"
          end
          if limit_exceeded_behavior == :block && message_limit < 1
            raise FlowControlLimitError,
                  "Flow control message limit (#{message_limit}) exceeded by a single message, would block forever"
          end
          if limit_exceeded_behavior == :block && message_size > byte_limit
            raise FlowControlLimitError,
                  "Flow control byte limit (#{byte_limit}) exceeded by a single message, would block forever"
          end

          acquire_message
          acquire_bytes message_size
        ensure
          @mutex.unlock if @mutex.locked?
        end

        # rubocop:disable Style/IdenticalConditionalBranches
        # rubocop:disable Style/GuardClause

        def acquire_message
          waiter = nil
          while @outstanding_messages + 1 > message_limit
            if waiter.nil?
              waiter = Concurrent::Event.new
              # This waiter gets added to the back of the line.
              @awaiting_message_acquires << waiter
            else
              waiter = Concurrent::Event.new
              # This waiter already in line stays at the head of the line.
              @awaiting_message_acquires[0] = waiter
            end
            @mutex.unlock
            waiter.wait
            @mutex.lock
          end
          @outstanding_messages += 1

          @awaiting_message_acquires.shift if waiter # Remove the newly released waiter from the head of the queue.

          # There may be some surplus messages left; let the next message waiting for a token have one.
          if !@awaiting_message_acquires.empty? && @outstanding_messages < message_limit
            @awaiting_message_acquires.first.set
          end
        end

        def acquire_bytes bytes_remaining
          waiter = nil
          while @outstanding_bytes + bytes_remaining > byte_limit
            # Take what is available.
            available = byte_limit - @outstanding_bytes
            bytes_remaining -= available
            @outstanding_bytes = byte_limit
            if waiter.nil?
              waiter = Concurrent::Event.new
              # This waiter gets added to the back of the line.
              @awaiting_bytes_acquires << waiter
            else
              waiter = Concurrent::Event.new
              # This waiter already in line stays at the head of the line.
              @awaiting_bytes_acquires[0] = waiter
            end
            @mutex.unlock
            waiter.wait
            @mutex.lock
          end
          @outstanding_bytes += bytes_remaining

          @awaiting_bytes_acquires.shift if waiter # Remove the newly released waiter from the head of the queue.

          # There may be some surplus bytes left; let the next message waiting for a token have some.
          if !@awaiting_bytes_acquires.empty? && @outstanding_bytes < byte_limit
            @awaiting_bytes_acquires.first.set
          end
        end

        # rubocop:enable Style/IdenticalConditionalBranches
        # rubocop:enable Style/GuardClause

        def release message_size
          return if limit_exceeded_behavior == :ignore
          @mutex.synchronize do
            # Releasing a message decreases the load.
            @outstanding_messages -= 1
            @outstanding_bytes -= message_size
            if @outstanding_messages.negative? || @outstanding_bytes.negative?
              # Releasing a message that was never added or already released.
              @outstanding_messages = [0, @outstanding_messages].max
              @outstanding_bytes = [0, @outstanding_bytes].max
            end
            @awaiting_message_acquires.first.set unless @awaiting_message_acquires.empty?
            @awaiting_bytes_acquires.first.set unless @awaiting_bytes_acquires.empty?
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
