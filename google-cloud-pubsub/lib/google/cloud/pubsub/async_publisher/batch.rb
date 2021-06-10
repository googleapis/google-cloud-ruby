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
require "google/cloud/pubsub/errors"

module Google
  module Cloud
    module PubSub
      class AsyncPublisher
        ##
        # @private
        class Batch
          include MonitorMixin

          attr_reader :items
          attr_reader :ordering_key

          def initialize publisher, ordering_key
            # init MonitorMixin
            super()

            @publisher = publisher
            @ordering_key = ordering_key
            @items = []
            @queue = []
            @default_message_bytes = publisher.topic_name.bytesize + 2
            @total_message_bytes = @default_message_bytes
            @publishing = false
            @stopping = false
            @canceled = false
          end

          ##
          # Adds a message and callback to the batch.
          #
          # The method will indicate how the message is added. It will either be
          # added to the active list of items, it will be queued to be picked up
          # once the active publishing job has been completed, or it will
          # indicate that the batch is full and a publishing job should be
          # created.
          #
          # @param [Google::Cloud::PubSub::V1::PubsubMessage] msg The message.
          # @param [Proc, nil] callback The callback.
          #
          # @return [Symbol] The state of the batch.
          #
          #   * `:added` - Added to the active list of items to be published.
          #   * `:queued` - Batch is publishing, and the messsage is queued.
          #   * `:full` - Batch is full and ready to be published, and the
          #     message is queued.
          #
          def add msg, callback
            synchronize do
              raise AsyncPublisherStopped if @stopping
              raise OrderingKeyError, @ordering_key if @canceled

              if @publishing
                queue_add msg, callback
                :queued
              elsif try_add msg, callback
                :added
              else
                queue_add msg, callback
                :full
              end
            end
          end

          ##
          # Marks the batch to be published.
          #
          # The method will indicate whether a new publishing job should be
          # started to publish the batch. See {publishing?}.
          #
          # @param [Boolean] stop Indicates whether the batch should also be
          #   marked for stopping, and any existing publish job should publish
          #   all items until the batch is empty.
          #
          # @return [Boolean] Returns whether a new publishing job should be
          #   started to publish the batch. If the batch is already being
          #   published then this will return `false`.
          #
          def publish! stop: nil
            synchronize do
              @stopping = true if stop

              return false if @canceled

              # If we are already publishing, do not indicate a new job needs to
              # be started.
              return false if @publishing

              @publishing = !(@items.empty? && @queue.empty?)
            end
          end

          ##
          # Indicates whether the batch has an active publishing job.
          #
          # @return [Boolean]
          #
          def publishing?
            # This probably does not need to be synchronized
            @publishing
          end

          ##
          # Indicates whether the batch has been stopped and all items will be
          # published until the batch is empty.
          #
          # @return [Boolean]
          #
          def stopping?
            # This does not need to be synchronized because nothing un-stops
            @stopping
          end

          ##
          # Fills the batch by sequentially moving the queued items that will
          # fit into the active item list.
          #
          # This method is only intended to be used by the active publishing
          # job.
          #
          def rebalance!
            synchronize do
              return [] if @canceled

              until @queue.empty?
                item = @queue.first
                if try_add item.msg, item.callback
                  @queue.shift
                  next
                end
                break
              end

              @items
            end
          end

          ##
          # Resets the batch after a successful publish. This clears the active
          # item list and moves the queued items that will fit into the active
          # item list.
          #
          # If the batch has enough queued items to fill the batch again, the
          # publishing job should continue to publish the reset batch until the
          # batch indicated it should stop.
          #
          # This method is only intended to be used by the active publishing
          # job.
          #
          # @return [Boolean] Whether the active publishing job should continue
          #   publishing after the reset.
          #
          def reset!
            synchronize do
              @items = []
              @total_message_bytes = @default_message_bytes

              if @canceled
                @queue = []
                @publishing = false
                return false
              end

              until @queue.empty?
                item = @queue.first
                added = try_add item.msg, item.callback
                break unless added
                @queue.shift
              end

              return false unless @publishing
              if @items.empty?
                @publishing = false
                return false
              else
                return true if stopping?
                if @queue.empty?
                  @publishing = false
                  return false
                end
              end
            end
            true
          end

          ##
          # Cancel the batch and hault futher batches until resumed. See
          # {#resume!} and {#canceled?}.
          #
          # @return [Array<Item}] All items, including queued items
          #
          def cancel!
            synchronize do
              @canceled = true
              @items + @queue
            end
          end

          ##
          # Resume the batch and proceed to publish messages. See {#cancel!} and
          # {#canceled?}.
          #
          # @return [Boolean] Whether the batch was resumed.
          #
          def resume!
            synchronize do
              # Return false if the batch is not canceled
              return false unless @canceled

              @items = []
              @queue = []
              @total_message_bytes = @default_message_bytes
              @publishing = false
              @canceled = false
            end
            true
          end

          ##
          # Indicates whether the batch has been canceled due to an error while
          # publishing. See {#cancel!} and {#resume!}.
          #
          # @return [Boolean]
          #
          def canceled?
            # This does not need to be synchronized because nothing un-stops
            synchronize { @canceled }
          end

          ##
          # Determines whether the batch is empty and ready to be culled.
          #
          def empty?
            synchronize do
              return false if @publishing || @canceled || @stopping

              @items.empty? && @queue.empty?
            end
          end

          protected

          def items_add msg, callback
            item = Item.new msg, callback
            @items << item
            @total_message_bytes += item.bytesize + 2
          end

          def try_add msg, callback
            if @items.empty?
              # Always add when empty, even if bytesize is bigger than total
              items_add msg, callback
              return true
            end
            new_message_count = total_message_count + 1
            new_message_bytes = total_message_bytes + msg.to_proto.bytesize + 2
            if new_message_count > @publisher.max_messages ||
               new_message_bytes >= @publisher.max_bytes
              return false
            end
            items_add msg, callback
            true
          end

          def queue_add msg, callback
            item = Item.new msg, callback
            @queue << item
          end

          def total_message_count
            @items.count
          end

          def total_message_bytes
            @total_message_bytes
          end

          Item = Struct.new :msg, :callback do
            def bytesize
              msg.to_proto.bytesize
            end
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
