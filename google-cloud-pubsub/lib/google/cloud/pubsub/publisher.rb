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
require "google/cloud/pubsub/publish_result"
require "google/cloud/pubsub/service"

module Google
  module Cloud
    module Pubsub
      ##
      # @private
      # # Publisher
      #
      class Publisher
        include MonitorMixin

        MAX_BYTES = 5*1024*1024
        MAX_MESSAGES = 1000
        TIMER_DELAY = 0.25

        attr_reader :service, :queue
        attr_reader :max_bytes, :max_messages, :timer_delay
        attr_reader :thread_pool, :timer_task

        def initialize service, max_bytes: MAX_BYTES,
                       max_messages: MAX_MESSAGES, timer_delay: TIMER_DELAY
          @service = service
          @max_bytes = max_bytes
          @max_messages = max_messages
          @timer_delay = timer_delay

          @queue = {}
          @thread_pool = Concurrent::ThreadPoolExecutor.new
          @timer_task = Concurrent::TimerTask.new(
            execution_interval: @timer_delay) { flush }

          # init MonitorMixin
          super()
        end

        def publish topic_name, data = nil, attributes = {}, &block
          topic_name = service.topic_path topic_name
          msg = create_pubsub_message data, attributes

          synchronize do
            batch = @queue[topic_name]
            if batch.nil?
              # Create a new batch.
              batch = QueuedBatch.new msg, block
            elsif !batch.try_add(msg, block, max_messages: max_messages,
                                             max_bytes: max_bytes)
              # We hit a threshold, publish existing batch.
              publish_batch_async topic_name, batch
              # Create a new batch.
              batch = QueuedBatch.new msg, block
            end
            @queue[topic_name] = batch
          end
          nil
        end

        def start
          @timer_task.execute
        end

        def stop
          flush
          @timer_task.shutdown
        end

        def started?
          @timer_task.running?
        end

        def stopping?
          @timer_task.shuttingdown?
        end

        def stopped?
          @timer_task.shutdown?
        end

        def wait timeout = nil
          @timer_task.wait_for_termination timeout
        end

        def flush
          synchronize do
            @queue.each do |topic_name, batch|
              publish_batch_async topic_name, batch
            end
            @queue = {}
          end
        end

        protected

        def create_pubsub_message data, attributes
          attributes ||= {}
          if data.is_a?(::Hash) && attributes.empty?
            attributes = data
            data = nil
          end

          # Convert IO-ish objects to strings
          if data.respond_to?(:read) && data.respond_to?(:rewind)
            data.rewind
            data = data.read
          end
          # Convert data to encoded byte array to match the protobuf defn
          data = String(data).force_encoding("ASCII-8BIT")

          # Convert attributes to strings to match the protobuf definition
          attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

          Google::Pubsub::V1::PubsubMessage.new data: data,
                                                attributes: attributes
        end

        def publish_batch topic_name, batch
          grpc = service.publish_messages topic_name, batch.messages
          batch.items.zip(Array(grpc.message_ids)) do |item, id|
            item.msg.message_id = id
            if item.callback
              item.callback.call PublishResult.from_grpc(item.msg)
            end
          end
        rescue => e
          batch.items.each do |item|
            if item.callback
              item.callback.call PublishResult.from_error(item.msg, e)
            end
          end
        end

        def publish_batch_async topic_name, batch
          Concurrent::Future.new(executor: @thread_pool) do
            publish_batch topic_name, batch
          end.execute
        end

        class QueuedBatch
          attr_reader :messages, :callbacks

          def initialize msg, callback
            @messages = [msg]
            @callbacks = [callback]
          end

          def add msg, callback
            @messages << msg
            @callbacks << callback
          end

          def try_add msg, callback,
                      max_messages: MAX_MESSAGES, max_bytes: MAX_BYTES
            return false if total_message_count + 1 > max_messages
            return false if total_message_size + msg.to_proto.size >= max_bytes
            add msg, callback
            true
          end

          def total_message_count
            @messages.count
          end

          def total_message_size
            @messages.map(&:to_proto).map(&:size).inject(0, :+)
          end

          def items
            @messages.zip(@callbacks).map do |msg, callback|
              Item.new msg, callback
            end
          end

          class Item
            attr_accessor :msg, :callback
            def initialize msg, callback
              @msg = msg
              @callback = callback
            end
          end
        end
      end
    end
  end
end
