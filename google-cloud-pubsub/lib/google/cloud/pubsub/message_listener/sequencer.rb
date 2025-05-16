# Copyright 2019 Google LLC
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

module Google
  module Cloud
    module PubSub
      class MessageListener
        ##
        # @private The sequencer's job is simple, keep track of all the
        # streams's recieved message and deliver the messages with an
        # ordering_key in the order they were recieved. The sequencer ensures
        # only one callback can be performed at a time per ordering_key.
        class Sequencer
          include MonitorMixin

          ##
          # @private Create an empty Subscriber::Sequencer object.
          def initialize &block
            raise ArgumentError if block.nil?

            super() # to init MonitorMixin

            @seq_hash = Hash.new { |hash, key| hash[key] = [] }
            @process_callback = block
          end

          ##
          # @private Add a ReceivedMessage to the sequencer.
          def add message
            # Messages without ordering_key are not managed by the sequencer
            if message.ordering_key.empty?
              @process_callback.call message
              return
            end

            perform_callback = synchronize do
              # The purpose of this block is to add the message to the
              # sequencer, and to return whether the message should be processed
              # immediately, or whether it will be processed later by #next. We
              # want to ensure that these operations happen atomically.

              @seq_hash[message.ordering_key].push message
              @seq_hash[message.ordering_key].count == 1
            end

            @process_callback.call message if perform_callback
          end

          ##
          # @private Indicate a ReceivedMessage was processed, and the next in
          # the queue can now be processed.
          def next message
            # Messages without ordering_key are not managed by the sequencer
            return if message.ordering_key.empty?

            next_message = synchronize do
              # The purpose of this block is to remove the message that was
              # processed from the sequencer, and to return the next message to
              # be processed. We want to ensure that these operations happen
              # atomically.

              # The message should be at index 0, so this should be a very quick
              # operation.
              if @seq_hash[message.ordering_key].first != message
                # Raising this error will stop the other messages with this
                # ordering key from being processed by the callback (delivered).
                raise OrderedMessageDeliveryError, message
              end

              # Remove the message
              @seq_hash[message.ordering_key].shift

              # Retrieve the next message to be processed, or nil if empty
              next_msg = @seq_hash[message.ordering_key].first

              # Remove the ordering_key from hash when empty
              @seq_hash.delete message.ordering_key if next_msg.nil?

              # Return the next message to be processed, or nil if empty
              next_msg
            end

            @process_callback.call next_message unless next_message.nil?
          end

          # @private
          def to_s
            "#{@seq_hash.count}/#{@seq_hash.values.sum(&:count)}"
          end

          # @private
          def inspect
            "#<#{self.class.name} (#{self})>"
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
