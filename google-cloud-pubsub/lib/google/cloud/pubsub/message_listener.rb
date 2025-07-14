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
require "google/cloud/pubsub/message_listener/stream"
require "google/cloud/pubsub/message_listener/timed_unary_buffer"
require "monitor"

module Google
  module Cloud
    module PubSub
      ##
      # MessageListener object used to stream and process messages from a
      # Subscriber. See {Google::Cloud::PubSub::Subscriber#listen}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   subscriber = pubsub.subscriber "my-topic-sub"
      #
      #   listener = subscriber.listen do |received_message|
      #     # process message
      #     received_message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   listener.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   listener.stop!
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
      #   to pull messages from the subscription. Default is 2.
      # @attr_reader [Integer] callback_threads The number of threads used to
      #   handle the received messages. Default is 8.
      # @attr_reader [Integer] push_threads The number of threads to handle
      #   acknowledgement ({ReceivedMessage#ack!}) and delay messages
      #   ({ReceivedMessage#nack!}, {ReceivedMessage#modify_ack_deadline!}).
      #   Default is 4.
      #
      class MessageListener
        include MonitorMixin

        attr_reader :subscription_name
        attr_reader :callback
        attr_reader :deadline
        attr_reader :streams
        attr_reader :message_ordering
        attr_reader :callback_threads
        attr_reader :push_threads

        ##
        # @private Implementation attributes.
        attr_reader :stream_pool, :thread_pool, :buffer, :service

        ##
        # @private Implementation attributes.
        attr_accessor :exactly_once_delivery_enabled

        ##
        # @private Create an empty {MessageListener} object.
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
          @exactly_once_delivery_enabled = nil

          @service = service

          @started = @stopped = nil

          stream_pool = Array.new @streams do
            Thread.new { Stream.new self }
          end
          @stream_pool = stream_pool.map(&:value)

          @buffer = TimedUnaryBuffer.new self
        end

        ##
        # Starts the listener pulling from the subscription and processing the
        # received messages.
        #
        # @return [MessageListener] returns self so calls can be chained.
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
        # Immediately stops the listener. No new messages will be pulled from
        # the subscription. Use {#wait!} to block until all received messages have
        # been processed or released: All actions taken on received messages that
        # have not yet been sent to the API will be sent to the API. All received
        # but unprocessed messages will be released back to the API and redelivered.
        #
        # @return [MessageListener] returns self so calls can be chained.
        #
        def stop
          synchronize do
            @started = false
            @stopped = true
            @stream_pool.map(&:stop)
            wait_stop_buffer_thread!
            self
          end
        end

        ##
        # Blocks until the listener is fully stopped and all received messages
        # have been processed or released, or until `timeout` seconds have
        # passed.
        #
        # Does not stop the listener. To stop the listener, first call
        # {#stop} and then call {#wait!} to block until the listener is
        # stopped.
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   subscriber is fully stopped. Default will block indefinitely.
        #
        # @return [MessageListener] returns self so calls can be chained.
        #
        def wait! timeout = nil
          wait_stop_buffer_thread!
          @wait_stop_buffer_thread.join timeout
          self
        end

        ##
        # Stop this listener and block until the listener is fully stopped
        # and all received messages have been processed or released, or until
        # `timeout` seconds have passed.
        #
        # The same as calling {#stop} and {#wait!}.
        #
        # @param [Number, nil] timeout The number of seconds to block until the
        #   listener is fully stopped. Default will block indefinitely.
        #
        # @return [MessageListener] returns self so calls can be chained.
        #
        def stop! timeout = nil
          stop
          wait! timeout
        end

        ##
        # Whether the listener has been started.
        #
        # @return [boolean] `true` when started, `false` otherwise.
        #
        def started?
          synchronize { @started }
        end

        ##
        # Whether the listener has been stopped.
        #
        # @return [boolean] `true` when stopped, `false` otherwise.
        #
        def stopped?
          synchronize { @stopped }
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the listener will attempt to
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
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #
        #   listener = subscriber.listen do |received_message|
        #     # process message
        #     received_message.acknowledge!
        #   end
        #
        #   # Register to be notified when unhandled errors occur.
        #   listener.on_error do |error|
        #     # log error
        #     puts error
        #   end
        #
        #   # Start listening for messages and errors.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def on_error &block
          synchronize do
            @error_callbacks << block
          end
        end

        ##
        # The most recent unhandled error to occur while listening to messages
        # on the listener.
        #
        # If an unhandled error has occurred the listener will attempt to
        # recover from the error and resume listening.
        #
        # @return [Exception, nil] error The most recent error raised.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #
        #   listener = subscriber.listen do |received_message|
        #     # process message
        #     received_message.acknowledge!
        #   end
        #
        #   # Start listening for messages and errors.
        #   listener.start
        #
        #   # If an error was raised, it can be retrieved here:
        #   listener.last_error #=> nil
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def last_error
          synchronize { @last_error }
        end

        ##
        # The number of received messages to be collected by listener. Default is 1,000.
        #
        # @return [Integer] The maximum number of messages.
        #
        def max_outstanding_messages
          @inventory[:max_outstanding_messages]
        end

        ##
        # The total byte size of received messages to be collected by listener. Default is 100,000,000 (100MB).
        #
        # @return [Integer] The maximum number of bytes.
        #
        def max_outstanding_bytes
          @inventory[:max_outstanding_bytes]
        end

        ##
        # The number of seconds that received messages can be held awaiting processing. Default is 3,600 (1 hour).
        #
        # @return [Integer] The maximum number of seconds.
        #
        def max_total_lease_duration
          @inventory[:max_total_lease_duration]
        end

        ##
        # The maximum amount of time in seconds for a single lease extension attempt. Bounds the delay before a message
        # redelivery if the listener fails to extend the deadline. Default is 0 (disabled).
        #
        # @return [Integer] The maximum number of seconds.
        #
        def max_duration_per_lease_extension
          @inventory[:max_duration_per_lease_extension]
        end

        ##
        # The minimum amount of time in seconds for a single lease extension attempt. Bounds the delay before a message
        # redelivery if the listener fails to extend the deadline. Default is 0 (disabled).
        #
        # @return [Integer] The minimum number of seconds.
        #
        def min_duration_per_lease_extension
          @inventory[:min_duration_per_lease_extension]
        end

        ##
        # @private
        def stream_inventory
          {
            limit:                            @inventory[:max_outstanding_messages].fdiv(@streams).ceil,
            bytesize:                         @inventory[:max_outstanding_bytes].fdiv(@streams).ceil,
            extension:                        @inventory[:max_total_lease_duration],
            max_duration_per_lease_extension: @inventory[:max_duration_per_lease_extension],
            min_duration_per_lease_extension: @inventory[:min_duration_per_lease_extension]
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

        ##
        # Starts a new thread to call wait! (blocking) on each Stream and then stop the TimedUnaryBuffer.
        def wait_stop_buffer_thread!
          synchronize do
            @wait_stop_buffer_thread ||= Thread.new do
              @stream_pool.map(&:wait!)
              # Shutdown the buffer TimerTask (and flush the buffer) after the streams are all stopped.
              @buffer.stop
            end
          end
        end

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
          @inventory[:min_duration_per_lease_extension] = Integer(@inventory[:min_duration_per_lease_extension] || 0)
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
