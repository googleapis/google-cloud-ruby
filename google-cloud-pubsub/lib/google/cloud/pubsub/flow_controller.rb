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
        attr_reader :outstanding_messages, :outstanding_bytes, :awaiting

        def initialize message_limit: 1000, byte_limit: 10_000_000, limit_exceeded_behavior: :ignore
          unless [:ignore, :error, :block].include? limit_exceeded_behavior
            raise ArgumentError, "limit_exceeded_behavior must be one of :ignore, :error, :block"
          end
          if [:error, :block].include?(limit_exceeded_behavior) && message_limit < 1
            raise ArgumentError,
                  "Flow control message limit (#{message_limit}) exceeded by a single message, would block forever"
          end
          @mutex = Mutex.new
          @message_limit = message_limit
          @byte_limit = byte_limit
          @limit_exceeded_behavior = limit_exceeded_behavior
          @outstanding_messages = 0
          @outstanding_bytes = 0

          @awaiting = []
        end

        def acquire message_size
          return if limit_exceeded_behavior == :ignore
          @mutex.lock
          if limit_exceeded_behavior == :error && would_exceed_message_limit?
            raise FlowControlLimitError, "Flow control message limit (#{message_limit}) would be exceeded"
          end
          if limit_exceeded_behavior == :error && would_exceed_byte_limit?(message_size)
            raise FlowControlLimitError,
                  "Flow control byte limit (#{byte_limit}) would be exceeded, message_size: #{message_size}"
          end
          if limit_exceeded_behavior == :block && message_size > byte_limit
            raise FlowControlLimitError,
                  "Flow control byte limit (#{byte_limit}) exceeded by a single message, would block forever"
          end

          acquire_or_wait message_size
        ensure
          @mutex.unlock if @mutex.owned?
        end

        def release message_size
          return if limit_exceeded_behavior == :ignore
          @mutex.synchronize do
            raise "Flow control messages count would be negative" if (@outstanding_messages - 1).negative?
            raise "Flow control bytes count would be negative" if (@outstanding_bytes - message_size).negative?

            @outstanding_messages -= 1
            @outstanding_bytes -= message_size
            @awaiting.first.set unless @awaiting.empty?
          end
        end

        protected

        # rubocop:disable Style/IdenticalConditionalBranches
        # rubocop:disable Style/GuardClause

        def acquire_or_wait message_size
          waiter = nil
          while is_new_and_others_wait?(waiter) ||
                would_exceed_byte_limit?(message_size) ||
                would_exceed_message_limit?

            if waiter.nil?
              waiter = Concurrent::Event.new
              # This waiter gets added to the back of the line.
              @awaiting << waiter
            else
              waiter = Concurrent::Event.new
              # This waiter already in line stays at the head of the line.
              @awaiting[0] = waiter
            end
            @mutex.unlock
            waiter.wait
            @mutex.lock
          end
          @outstanding_messages += 1
          @outstanding_bytes += message_size

          @awaiting.shift if waiter # Remove the newly released waiter from the head of the queue.

          # There may be some surplus left; let the next message waiting try to acquire a permit.
          if !@awaiting.empty? && @outstanding_bytes < byte_limit && @outstanding_messages < message_limit
            @awaiting.first.set
          end
        end

        # rubocop:enable Style/IdenticalConditionalBranches
        # rubocop:enable Style/GuardClause

        def is_new_and_others_wait? waiter
          waiter.nil? && !@awaiting.empty?
        end

        def would_exceed_message_limit?
          @outstanding_messages + 1 > message_limit
        end

        def would_exceed_byte_limit? bytes_requested
          @outstanding_bytes + bytes_requested > byte_limit
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
