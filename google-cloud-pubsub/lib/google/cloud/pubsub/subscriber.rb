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


require "google/cloud/pubsub/service"
require "google/cloud/pubsub/subscriber/stream"
require "google/cloud/pubsub/subscriber/timed_unary_buffer"
require "monitor"

module Google
  module Cloud
    module PubSub
      ##
      # Subscriber object used to stream and process messages from a
      # Subscription. See {Google::Cloud::PubSub::Subscription#listen}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #
      #   subscriber = sub.listen do |received_message|
      #     # process message
      #     received_message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   subscriber.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   subscriber.stop!
      #
      # @attr_reader [String] subscription_name The name of the subscription the
      #   messages are pulled from.
      # @attr_reader [Proc] callback The procedure that will handle the messages
      #   received from the subscription.
      # @attr_reader [Numeric] deadline The default number of seconds the stream
      #   will hold received messages before modifying the message's ack
      #   deadline. The minimum is 10, the maximum is 600. Default is 60.
      # @attr_reader [Boolean] message_ordering Whether message ordering has
      #   been enabled.
      # @attr_reader [Integer] streams The number of concurrent streams to open
      #   to pull messages from the subscription. Default is 4.
      # @attr_reader [Integer] callback_threads The number of threads used to
      #   handle the received messages. Default is 8.
      # @attr_reader [Integer] push_threads The number of threads to handle
      #   acknowledgement ({ReceivedMessage#ack!}) and delay messages
      #   ({ReceivedMessage#nack!}, {ReceivedMessage#modify_ack_deadline!}).
      #   Default is 4.
      #
      class Subscriber
        include MonitorMixin

        attr_reader :subscription_name, :callback, :deadline, :streams, :message_ordering, :callback_threads,
                    :push_threads

        ##
        # @private Implementation attributes.
        attr_reader :stream_pool, :thread_pool, :buffer, :service

        ##
        # @private Create an empty {Subscriber} object.
        def initialize subscription_name, callback, deadline: nil, message_ordering: nil, streams: nil, inventory: nil,
                       threads: {}, service: nil
          super() # to init MonitorMixin

          @callback = callback
          @error_callbacks = []
          @subscription_name = subscription_name
          @deadline = deadline || 60
          @streams = streams || 2
          coerce_inventory inventory
          @message_ordering = message_ordering
          @callback_threads = Integer(threads[:callback] || 8)
          @push_threads = Integer(threads[:push] || 4)

          @service = service

          @started = @stopped = nil

          stream_pool = Array.new @streams do
            Thread.new { Stream.new self }
          end
          @stream_pool = stream_pool.map(&:value)

          @buffer = TimedUnaryBuffer.new self
        end

        ##
        # Starts the subscriber pulling from the subscription and processing the
        # received messages.
        #
        # @return [Subscriber] returns self so calls can be chained.
        #
        def start
          start_pool = synchronize do
            @started = true
            @stopped = false

            # Start the buffer before the streams are all started
            @buffer.start
            @stream_pool.map do |stream|
              Thread.new { stream.start }
            end
          end
          start_pool.map(&:join)

          self
        end

        ##
        # Immediately stops the subscriber. No new messages will be pulled from
        # the subscription. All actions taken on received messages that have not
        # yet been sent to the API will be sent to the API. All received but
        # unprocessed messages will be released back to the API and redelivered.
        # Use {#wait!} to block until the subscriber is fully stopped and all
        # received messages have been processed or released.
        #
        # @return [Subscriber] returns self so calls can be chained.
        #
        def stop
          stop_pool = synchronize do
            @started = false
            @stopped = true

            @stream_pool.map do |stream|
              Thread.new { stream.stop }
            end
          end
          stop_pool.map(&:join)
          # Stop the buffer after the streams are all stopped
          synchronize { @buffer.stop }

          self
        end

        ##
        # Blocks until the subscriber is fully stopped and all received messages
        # have been processed or released, or until `timeout` seconds have
        # passed.
        #
        # Does not stop the subscriber. To stop the subscriber, first call
        # {#stop} and then call {#wait!} to block until the subscriber is
        # stopped.
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   subscriber is fully stopped. Default will block indefinitely.
        #
        # @return [Subscriber] returns self so calls can be chained.
        #
        def wait! timeout = nil
          wait_pool = synchronize do
            @stream_pool.map do |stream|
              Thread.new { stream.wait! timeout }
            end
          end
          wait_pool.map(&:join)

          self
        end

        ##
        # Stop this subscriber and block until the subscriber is fully stopped
        # and all received messages have been processed or released, or until
        # `timeout` seconds have passed.
        #
        # The same as calling {#stop} and {#wait!}.
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   subscriber is fully stopped. Default will block indefinitely.
        #
        # @return [Subscriber] returns self so calls can be chained.
        #
        def stop! timeout = nil
          stop
          wait! timeout
        end

        ##
        # Whether the subscriber has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        #
        def started?
          synchronize { @started }
        end

        ##
        # Whether the subscriber has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        #
        def stopped?
          synchronize { @stopped }
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the subscriber will attempt to
        # recover from the error and resume listening.
        #
        # Multiple error handlers can be added.
        #
        # @yield [callback] The block to be called when an error is raised.
        # @yieldparam [Exception] error The error raised.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #
        #   subscriber = sub.listen do |received_message|
        #     # process message
        #     received_message.acknowledge!
        #   end
        #
        #   # Register to be notified when unhandled errors occur.
        #   subscriber.on_error do |error|
        #     # log error
        #     puts error
        #   end
        #
        #   # Start listening for messages and errors.
        #   subscriber.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop!
        #
        def on_error &block
          synchronize do
            @error_callbacks << block
          end
        end

        ##
        # The most recent unhandled error to occur while listening to messages
        # on the subscriber.
        #
        # If an unhandled error has occurred the subscriber will attempt to
        # recover from the error and resume listening.
        #
        # @return [Exception, nil] error The most recent error raised.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #
        #   subscriber = sub.listen do |received_message|
        #     # process message
        #     received_message.acknowledge!
        #   end
        #
        #   # Start listening for messages and errors.
        #   subscriber.start
        #
        #   # If an error was raised, it can be retrieved here:
        #   subscriber.last_error #=> nil
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop!
        #
        def last_error
          synchronize { @last_error }
        end

        ##
        # The number of received messages to be collected by subscriber. Default is 1,000.
        #
        # @return [Integer] The maximum number of messages.
        #
        def max_outstanding_messages
          @inventory[:max_outstanding_messages]
        end
        # @deprecated Use {#max_outstanding_messages}.
        alias inventory_limit max_outstanding_messages
        # @deprecated Use {#max_outstanding_messages}.
        alias inventory max_outstanding_messages

        ##
        # The total byte size of received messages to be collected by subscriber. Default is 100,000,000 (100MB).
        #
        # @return [Integer] The maximum number of bytes.
        #
        def max_outstanding_bytes
          @inventory[:max_outstanding_bytes]
        end
        # @deprecated Use {#max_outstanding_bytes}.
        alias inventory_bytesize max_outstanding_bytes

        ##
        # The number of seconds that received messages can be held awaiting processing. Default is 3,600 (1 hour).
        #
        # @return [Integer] The maximum number of seconds.
        #
        def max_total_lease_duration
          @inventory[:max_total_lease_duration]
        end
        # @deprecated Use {#max_total_lease_duration}.
        alias inventory_extension max_total_lease_duration

        ##
        # The maximum amount of time in seconds for a single lease extension attempt. Bounds the delay before a message
        # redelivery if the subscriber fails to extend the deadline. Default is 0 (disabled).
        #
        # @return [Integer] The maximum number of seconds.
        #
        def max_duration_per_lease_extension
          @inventory[:max_duration_per_lease_extension]
        end

        ##
        # @private
        def stream_inventory
          {
            limit:                            @inventory[:max_outstanding_messages].fdiv(@streams).ceil,
            bytesize:                         @inventory[:max_outstanding_bytes].fdiv(@streams).ceil,
            extension:                        @inventory[:max_total_lease_duration],
            max_duration_per_lease_extension: @inventory[:max_duration_per_lease_extension]
          }
        end

        # @private returns error object from the stream thread.
        def error! error
          error_callbacks = synchronize do
            @last_error = error
            @error_callbacks
          end
          error_callbacks = default_error_callbacks if error_callbacks.empty?
          error_callbacks.each { |error_callback| error_callback.call error }
        end

        ##
        # @private
        def to_s
          "(subscription: #{subscription_name}, streams: [#{stream_pool.map(&:to_s).join(', ')}])"
        end

        ##
        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        protected

        def coerce_inventory inventory
          @inventory = inventory
          if @inventory.is_a? Hash
            @inventory = @inventory.dup
            # Support deprecated field names
            @inventory[:max_outstanding_messages] ||= @inventory.delete :limit
            @inventory[:max_outstanding_bytes] ||= @inventory.delete :bytesize
            @inventory[:max_total_lease_duration] ||= @inventory.delete :extension
          else
            @inventory = { max_outstanding_messages: @inventory }
          end
          @inventory[:max_outstanding_messages] = Integer(@inventory[:max_outstanding_messages] || 1000)
          @inventory[:max_outstanding_bytes] = Integer(@inventory[:max_outstanding_bytes] || 100_000_000)
          @inventory[:max_total_lease_duration] = Integer(@inventory[:max_total_lease_duration] || 3600)
          @inventory[:max_duration_per_lease_extension] = Integer(@inventory[:max_duration_per_lease_extension] || 0)
        end

        def default_error_callbacks
          # This is memoized to reduce calls to the configuration.
          @default_error_callbacks ||= begin
            error_callback = Google::Cloud::PubSub.configure.on_error
            error_callback ||= Google::Cloud.configure.on_error
            if error_callback
              [error_callback]
            else
              []
            end
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
