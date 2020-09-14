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
require "google/cloud/pubsub/errors"
require "google/cloud/pubsub/async_publisher/batch"
require "google/cloud/pubsub/publish_result"
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/convert"

module Google
  module Cloud
    module PubSub
      ##
      # Used to publish multiple messages in batches to a topic. See
      # {Google::Cloud::PubSub::Topic#async_publisher}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
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
      #   topic.async_publisher.stop!
      #
      # @attr_reader [String] topic_name The name of the topic the messages are published to. In the form of
      #   "/projects/project-identifier/topics/topic-name".
      # @attr_reader [Integer] max_bytes The maximum size of messages to be collected before the batch is published.
      #   Default is 1,000,000 (1MB).
      # @attr_reader [Integer] max_messages The maximum number of messages to be collected before the batch is
      #   published. Default is 100.
      # @attr_reader [Numeric] interval The number of seconds to collect messages before the batch is published. Default
      #   is 0.01.
      # @attr_reader [Numeric] publish_threads The number of threads used to publish messages. Default is 2.
      # @attr_reader [Numeric] callback_threads The number of threads to handle the published messages' callbacks.
      #   Default is 4.
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
        def initialize topic_name, service, max_bytes: 1_000_000, max_messages: 100, interval: 0.01, threads: {}
          # init MonitorMixin
          super()
          @topic_name = service.topic_path topic_name
          @service    = service

          @max_bytes        = max_bytes
          @max_messages     = max_messages
          @interval         = interval
          @publish_threads  = (threads[:publish] || 2).to_i
          @callback_threads = (threads[:callback] || 4).to_i

          @published_at = nil
          @publish_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @publish_threads
          @callback_thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: @callback_threads

          @ordered = false
          @batches = {}
          @cond = new_cond

          @thread = Thread.new { run_background }
        end

        ##
        # Add a message to the async publisher to be published to the topic.
        # Messages will be collected in batches and published together.
        # See {Google::Cloud::PubSub::Topic#publish_async}
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
        # @yield [result] the callback for when the message has been published
        # @yieldparam [PublishResult] result the result of the asynchronous
        #   publish
        # @raise [Google::Cloud::PubSub::AsyncPublisherStopped] when the
        #   publisher is stopped. (See {#stop} and {#stopped?}.)
        # @raise [Google::Cloud::PubSub::OrderedMessagesDisabled] when
        #   publishing a message with an `ordering_key` but ordered messages are
        #   not enabled. (See {#message_ordering?} and
        #   {#enable_message_ordering!}.)
        # @raise [Google::Cloud::PubSub::OrderingKeyError] when publishing a
        #   message with an `ordering_key` that has already failed when
        #   publishing. Use {#resume_publish} to allow this `ordering_key` to be
        #   published again.
        #
        def publish data = nil, attributes = nil, ordering_key: nil, **extra_attrs, &callback
          msg = Convert.pubsub_message data, attributes, ordering_key, extra_attrs

          synchronize do
            raise AsyncPublisherStopped if @stopped
            raise OrderedMessagesDisabled if !@ordered && !msg.ordering_key.empty? # default is empty string

            batch = resolve_batch_for_message msg
            raise OrderingKeyError, batch.ordering_key if batch.canceled?
            batch_action = batch.add msg, callback
            if batch_action == :full
              publish_batches!
            elsif @published_at.nil?
              # Set initial time to now to start the background counter
              @published_at = Time.now
            end
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
            publish_batches! stop: true
            @cond.signal
            @publish_thread_pool.shutdown
          end

          self
        end

        ##
        # Blocks until the publisher is fully stopped, all pending messages have
        # been published, and all callbacks have completed, or until `timeout`
        # seconds have passed.
        #
        # Does not stop the publisher. To stop the publisher, first call {#stop}
        # and then call {#wait!} to block until the publisher is stopped
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   publisher is fully stopped. Default will block indefinitely.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def wait! timeout = nil
          synchronize do
            @publish_thread_pool.wait_for_termination timeout

            @callback_thread_pool.shutdown
            @callback_thread_pool.wait_for_termination timeout
          end

          self
        end

        ##
        # Stop this publisher and block until the publisher is fully stopped,
        # all pending messages have been published, and all callbacks have
        # completed, or until `timeout` seconds have passed.
        #
        # The same as calling {#stop} and {#wait!}.
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   publisher is fully stopped. Default will block indefinitely.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def stop! timeout = nil
          stop
          wait! timeout
        end

        ##
        # Forces all messages in the current batch to be published
        # immediately.
        #
        # @return [AsyncPublisher] returns self so calls can be chained.
        def flush
          synchronize do
            publish_batches!
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

        ##
        # Enables message ordering for messages with ordering keys. When
        # enabled, messages published with the same `ordering_key` will be
        # delivered in the order they were published.
        #
        # See {#message_ordering?}. See {Topic#publish_async},
        # {Subscription#listen}, and {Message#ordering_key}.
        #
        def enable_message_ordering!
          synchronize { @ordered = true }
        end

        ##
        # Whether message ordering for messages with ordering keys has been
        # enabled. When enabled, messages published with the same `ordering_key`
        # will be delivered in the order they were published. When disabled,
        # messages may be delivered in any order.
        #
        # See {#enable_message_ordering!}. See {Topic#publish_async},
        # {Subscription#listen}, and {Message#ordering_key}.
        #
        # @return [Boolean]
        #
        def message_ordering?
          synchronize { @ordered }
        end

        ##
        # Resume publishing ordered messages for the provided ordering key.
        #
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
        #
        # @return [boolean] `true` when resumed, `false` otherwise.
        #
        def resume_publish ordering_key
          synchronize do
            batch = resolve_batch_for_ordering_key ordering_key
            return if batch.nil?
            batch.resume!
          end
        end

        protected

        def run_background
          synchronize do
            until @stopped
              if @published_at.nil?
                @cond.wait
                next
              end

              time_since_first_publish = Time.now - @published_at
              if time_since_first_publish > @interval
                # interval met, flush the batches...
                publish_batches!
                @cond.wait
              else
                # still waiting for the interval to publish the batch...
                timeout = @interval - time_since_first_publish
                @cond.wait timeout
              end
            end
          end
        end

        def resolve_batch_for_message msg
          @batches[msg.ordering_key] ||= Batch.new self, msg.ordering_key
        end

        def resolve_batch_for_ordering_key ordering_key
          @batches[ordering_key]
        end

        def publish_batches! stop: nil
          @batches.reject! { |_ordering_key, batch| batch.empty? }
          @batches.values.each do |batch|
            ready = batch.publish! stop: stop
            publish_batch_async @topic_name, batch if ready
          end
          # Set published_at to nil to wait indefinitely
          @published_at = nil
        end

        def publish_batch_async topic_name, batch
          # TODO: raise unless @publish_thread_pool.running?
          return unless @publish_thread_pool.running?

          Concurrent::Promises.future_on(
            @publish_thread_pool, topic_name, batch
          ) { |t, b| publish_batch_sync t, b }
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength

        def publish_batch_sync topic_name, batch
          # The only batch methods that are safe to call from the loop are
          # rebalance! and reset! because they are the only methods that are
          # synchronized.
          loop do
            items = batch.rebalance!

            unless items.empty?
              grpc = @service.publish topic_name, items.map(&:msg)
              items.zip Array(grpc.message_ids) do |item, id|
                next unless item.callback

                item.msg.message_id = id
                publish_result = PublishResult.from_grpc item.msg
                execute_callback_async item.callback, publish_result
              end
            end

            break unless batch.reset!
          end
        rescue StandardError => e
          items = batch.items

          unless batch.ordering_key.empty?
            retry if publish_batch_error_retryable? e
            # Cancel the batch if the error is not to be retried.
            begin
              raise OrderingKeyError, batch.ordering_key
            rescue OrderingKeyError => e
              # The existing e variable is not set to OrderingKeyError
              # Get all unsent messages for the callback
              items = batch.cancel!
            end
          end

          items.each do |item|
            next unless item.callback

            publish_result = PublishResult.from_error item.msg, e
            execute_callback_async item.callback, publish_result
          end

          # publish will retry indefinitely, as long as there are unsent items.
          retry if batch.reset!
        end

        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        PUBLISH_RETRY_ERRORS = [
          GRPC::Cancelled, GRPC::DeadlineExceeded, GRPC::Internal,
          GRPC::ResourceExhausted, GRPC::Unauthenticated, GRPC::Unavailable
        ].freeze

        def publish_batch_error_retryable? error
          PUBLISH_RETRY_ERRORS.any? { |klass| error.is_a? klass }
        end

        def execute_callback_async callback, publish_result
          return unless @callback_thread_pool.running?

          Concurrent::Promises.future_on(
            @callback_thread_pool, callback, publish_result
          ) do |cback, p_result|
            cback.call p_result
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
