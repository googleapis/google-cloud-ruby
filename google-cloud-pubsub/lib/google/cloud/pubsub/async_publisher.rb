# Copyright 2017 Google LLC
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
      # Used to publish multiple messages in batches to a topic. See
      # {Google::Cloud::Pubsub::Topic#async_publisher}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish_async "task completed" do |result|
      #     if result.succeeded?
      #       log_publish_success result.data
      #     else
      #       log_publish_failure result.data, result.error
      #     end
      #   end
      #
      #   topic.async_publisher.stop.wait!
      #
      # @attr_reader [String] topic_name The name of the topic the messages
      #   are published to. In the form of
      #   "/projects/project-identifier/topics/topic-name".
      # @attr_reader [Integer] max_bytes The maximum size of messages to be
      #   collected before the batch is published. Default is 10,000,000
      #   (10MB).
      # @attr_reader [Integer] max_messages The maximum number of messages to
      #   be collected before the batch is published. Default is 1,000.
      # @attr_reader [Numeric] interval The number of seconds to collect
      #   messages before the batch is published. Default is 0.25.
      # @attr_reader [Numeric] publish_threads The number of threads used to
      #   publish messages. Default is 4.
      # @attr_reader [Numeric] callback_threads The number of threads to
      #   handle the published messages' callbacks. Default is 8.
      #
      class AsyncPublisher
        include MonitorMixin

        attr_reader :topic_name, :max_bytes, :max_messages, :interval,
                    :publish_threads, :callback_threads
        ##
        # @private Implementation accessors
        attr_reader :service, :batch, :publish_thread_pool,
                    :callback_thread_pool

        ##
        # @private Create a new instance of the object.
        def initialize topic_name, service, max_bytes: 10000000,
                       max_messages: 1000, interval: 0.25, threads: {}
          @topic_name = service.topic_path topic_name
          @service    = service

          @max_bytes        = max_bytes
          @max_messages     = max_messages
          @interval         = interval
          @publish_threads  = (threads[:publish] || 4).to_i
          @callback_threads = (threads[:callback] || 8).to_i

          @cond = new_cond

          # init MonitorMixin
          super()
        end

        ##
        # Add a message to the async publisher to be published to the topic.
        # Messages will be collected in batches and published together.
        # See {Google::Cloud::Pubsub::Topic#publish_async}
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

            init_resources!

            publish_batch! if @batch.ready?

            @cond.signal
          end
          nil
        end

        ##
        # Begins the process of stopping the publisher. Messages already in
        # the queue will be published, but no new messages can be added. Use
        # {#wait!} to block until the publisher is fully stopped and all
        # pending messages have been published.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def stop
          synchronize do
            break if @stopped

            @stopped = true
            publish_batch!
            @cond.signal
            @publish_thread_pool.shutdown if @publish_thread_pool
          end

          self
        end

        ##
        # Blocks until the publisher is fully stopped, all pending messages
        # have been published, and all callbacks have completed. Does not stop
        # the publisher. To stop the publisher, first call {#stop} and then
        # call {#wait!} to block until the publisher is stopped.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def wait! timeout = nil
          synchronize do
            if @publish_thread_pool
              @publish_thread_pool.wait_for_termination timeout
            end

            if @callback_thread_pool
              @callback_thread_pool.shutdown
              @callback_thread_pool.wait_for_termination timeout
            end
          end

          self
        end

        ##
        # Forces all messages in the current batch to be published
        # immediately.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def flush
          synchronize do
            publish_batch!
            @cond.signal
          end

          self
        end

        ##
        # Whether the publisher has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        def started?
          !stopped?
        end

        ##
        # Whether the publisher has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        def stopped?
          synchronize { @stopped }
        end

        protected

        def init_resources!
          @first_published_at   ||= Time.now
          @publish_thread_pool  ||= Concurrent::FixedThreadPool.new \
            @publish_threads
          @callback_thread_pool ||= Concurrent::FixedThreadPool.new \
            @callback_threads
          @thread ||= Thread.new { run_background }
        end

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
          Concurrent::Future.new(executor: @publish_thread_pool) do
            begin
              grpc = @service.publish topic_name, batch.messages
              batch.items.zip(Array(grpc.message_ids)) do |item, id|
                next unless item.callback

                item.msg.message_id = id
                publish_result = PublishResult.from_grpc(item.msg)
                execute_callback_async item.callback, publish_result
              end
            rescue => e
              batch.items.each do |item|
                next unless item.callback

                publish_result = PublishResult.from_error(item.msg, e)
                execute_callback_async item.callback, publish_result
              end
            end
          end.execute
        end

        def execute_callback_async callback, publish_result
          Concurrent::Future.new(executor: @callback_thread_pool) do
            callback.call publish_result
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

        ##
        # @private
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
               total_message_bytes + msg.to_proto.size >= @publisher.max_bytes
              return false
            end
            add msg, callback
            true
          end

          def ready?
            total_message_count >= @publisher.max_messages ||
              total_message_bytes >= @publisher.max_bytes
          end

          def total_message_count
            @messages.count
          end

          def total_message_bytes
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
