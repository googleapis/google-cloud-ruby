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
      class Topic
        ##
        # # AsyncPublisher
        #
        class AsyncPublisher
          include MonitorMixin

          attr_reader :topic_name, :service, :batch
          attr_reader :max_bytes, :max_messages, :interval
          attr_reader :thread, :publisher_thread_pool, :callback_thread_pool

          def initialize topic_name, service, max_bytes: 5242880,
                         max_messages: 1000, interval: 0.25, threads: nil
            @topic_name = service.topic_path topic_name
            @service = service

            @max_bytes = max_bytes
            @max_messages = max_messages
            @interval = interval
            @threads = threads || [2, Concurrent.processor_count * 2].max

            @cond = new_cond

            # init MonitorMixin
            super()
          end

          def publish data = nil, attributes = {}, &block
            msg = create_pubsub_message data, attributes

            synchronize do
              fail "Can't publish when stopped." if @stopped

              if @batch.nil?
                @batch ||= Batch.new self
                @batch.add msg, block
              else
                unless @batch.try_add msg, block
                  publish_batch!
                  @batch = Batch.new self
                  @batch.add msg, block
                end
              end

              @first_published_at ||= Time.now
              @thread_pool ||= Concurrent::FixedThreadPool.new @threads
              @thread ||= Thread.new { run_background }

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
              @thread_pool.shutdown if @thread_pool
            end

            self
          end

          def wait! timeout = nil
            synchronize do
              @thread_pool.wait_for_termination timeout if @thread_pool
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

                time_since_first_publish = Time.now - @first_published_at
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
            return unless @batch

            publish_batch_async @topic_name, @batch
            @batch = nil
            @first_published_at = nil
          end

          def publish_batch_async topic_name, batch
            Concurrent::Future.new(executor: @thread_pool) do
              begin
                grpc = @service.publish topic_name, batch.messages
                batch.items.zip(Array(grpc.message_ids)) do |item, id|
                  next unless item.callback

                  item.msg.message_id = id
                  item.callback.call PublishResult.from_grpc(item.msg)
                end
              rescue => e
                batch.items.each do |item|
                  next unless item.callback

                  item.callback.call PublishResult.from_error(item.msg, e)
                end
              end
            end.execute
          end

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
            data_bytes = String(data).dup.force_encoding("ASCII-8BIT").freeze

            # Convert attributes to strings to match the protobuf definition
            attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

            Google::Pubsub::V1::PubsubMessage.new data: data_bytes,
                                                  attributes: attributes
          end

          class Batch
            attr_reader :messages, :callbacks

            def initialize publisher
              @publisher = publisher
              @messages = []
              @callbacks = []
            end

            def add msg, callback
              @messages << msg
              @callbacks << callback
            end

            def try_add msg, callback
              if total_message_count + 1 > @publisher.max_messages ||
                 total_message_size + msg.to_proto.size >= @publisher.max_bytes
                return false
              end
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

            Item = Struct.new :msg, :callback
          end
        end
      end
    end
  end
end
