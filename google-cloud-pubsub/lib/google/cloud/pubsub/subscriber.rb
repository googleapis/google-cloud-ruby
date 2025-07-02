# Copyright 2015 Google LLC
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


require "google/cloud/pubsub/convert"
require "google/cloud/errors"
require "google/cloud/pubsub/received_message"
require "google/cloud/pubsub/retry_policy"
require "google/cloud/pubsub/message_listener"
require "google/cloud/pubsub/v1"

module Google
  module Cloud
    module PubSub
      ##
      # # Subscriber

      # A {Subscriber} is the primary interface for data plane operations,
      # enabling you to receive messages from a subscription, either by streaming
      # with a {MessageListener} or by pulling them directly.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   subscriber = pubsub.subscriber "my-topic-sub"
      #   listener = subscriber.listen do |received_message|
      #     # process message
      #     received_message.acknowledge!
      #   end
      #
      #   # Handle exceptions from listener
      #   listener.on_error do |exception|
      #      puts "Exception: #{exception.class} #{exception.message}"
      #   end
      #
      #   # Gracefully shut down the subscriber
      #   at_exit do
      #     listener.stop!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   listener.start
      #   sleep
      class Subscriber
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The gRPC Google::Cloud::PubSub::V1::Subscription object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Subscriber} object.
        def initialize
          @service = nil
          @grpc = nil
          @resource_name = nil
          @exists = nil
        end

        ##
        # The underlying Subscription resource.
        #
        # Provides access to the `Google::Cloud::PubSub::V1::Subscription`
        # resource managed by this subscriber.
        #
        # Makes an API call to retrieve the actual subscription when called
        # on a reference object. See {#reference?}.
        #
        # @return [Google::Cloud::PubSub::V1::Subscription]
        #
        def subscription_resource
          ensure_grpc!
          @grpc
        end

        ##
        # The name of the subscription.
        #
        # @return [String] A fully-qualified subscription name in the form
        #   `projects/{project_id}/subscriptions/{subscription_id}`.
        #
        def name
          return @resource_name if reference?
          @grpc.name
        end

        ##
        # This value is the maximum number of seconds after a subscriber
        # receives a message before the subscriber should acknowledge the
        # message.
        #
        # Makes an API call to retrieve the deadline value when called on a
        # reference object. See {#reference?}.
        #
        # @return [Integer]
        def deadline
          ensure_grpc!
          @grpc.ack_deadline_seconds
        end

        ##
        # Whether message ordering has been enabled. When enabled, messages
        # published with the same `ordering_key` will be delivered in the order
        # they were published. When disabled, messages may be delivered in any
        # order.
        #
        # @note At the time of this release, ordering keys are not yet publicly
        #   enabled and requires special project enablements.
        #
        # See {Publisher#publish_async}, {#listen}, and {Message#ordering_key}.
        #
        # Makes an API call to retrieve the enable_message_ordering value when called on a
        # reference object. See {#reference?}.
        #
        # @return [Boolean]
        #
        def message_ordering?
          ensure_grpc!
          @grpc.enable_message_ordering
        end

        ##
        # Determines whether the subscription exists in the Pub/Sub service.
        #
        # Makes an API call to determine whether the subscription resource
        # exists when called on a reference object. See {#reference?}.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   subscriber.exists? #=> true
        #
        def exists?
          # Always true if the object is not set as reference
          return true unless reference?
          # If we have a value, return it
          return @exists unless @exists.nil?
          ensure_grpc!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # Pulls messages from the server, blocking until messages are available
        # when called with the `immediate: false` option, which is recommended
        # to avoid adverse impacts on the performance of pull operations.
        #
        # Raises an API error with status `UNAVAILABLE` if there are too many
        # concurrent pull requests pending for the given subscription.
        #
        # See also {#listen} for the preferred way to process messages as they
        # become available.
        #
        # @param [Boolean] immediate Whether to return immediately or block until
        #   messages are available.
        #
        #   **Warning:** The default value of this field is `true`. However, sending
        #   `true` is discouraged because it adversely impacts the performance of
        #   pull operations. We recommend that users always explicitly set this field
        #   to `false`.
        #
        #   If this field set to `true`, the system will respond immediately
        #   even if it there are no messages available to return in the pull
        #   response. Otherwise, the system may wait (for a bounded amount of time)
        #   until at least one message is available, rather than returning no messages.
        #
        #   See also {#listen} for the preferred way to process messages as they
        #   become available.
        # @param [Integer] max The maximum number of messages to return for this
        #   request. The Pub/Sub system may return fewer than the number
        #   specified. The default value is `100`, the maximum value is `1000`.
        #
        # @return [Array<Google::Cloud::PubSub::ReceivedMessage>]
        #
        # @example The `immediate: false` option is now recommended to avoid adverse impacts on pull operations:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   received_messages = subscriber.pull immediate: false
        #   received_messages.each do |received_message|
        #     received_message.acknowledge!
        #   end
        #
        # @example A maximum number of messages returned can also be specified:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   received_messages = subcriber.pull immediate: false, max: 10
        #   received_messages.each do |received_message|
        #     received_message.acknowledge!
        #   end
        #
        def pull immediate: true, max: 100
          ensure_service!
          options = { immediate: immediate, max: max }
          list_grpc = service.pull name, options
          Array(list_grpc.received_messages).map do |msg_grpc|
            ReceivedMessage.from_grpc msg_grpc, self
          end
        rescue Google::Cloud::DeadlineExceededError
          []
        end

        ##
        # Pulls from the server while waiting for messages to become available.
        # This is the same as:
        #
        #   subscriber.pull immediate: false
        #
        # See also {#listen} for the preferred way to process messages as they
        # become available.
        #
        # @param [Integer] max The maximum number of messages to return for this
        #   request. The Pub/Sub system may return fewer than the number
        #   specified. The default value is `100`, the maximum value is `1000`.
        #
        # @return [Array<Google::Cloud::PubSub::ReceivedMessage>]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   received_messages = subscriber.wait_for_messages
        #   received_messages.each do |received_message|
        #     received_message.acknowledge!
        #   end
        #
        def wait_for_messages max: 100
          pull immediate: false, max: max
        end

        ##
        # Create a {MessageListener} object that receives and processes messages
        # using the code provided in the callback. Messages passed to the
        # callback should acknowledge ({ReceivedMessage#acknowledge!}) or reject
        # ({ReceivedMessage#reject!}) the message. If no action is taken, the
        # message will be removed from the subscriber and made available for
        # redelivery after the callback is completed.
        #
        # Google Cloud Pub/Sub ordering keys provide the ability to ensure
        # related messages are sent to subscribers in the order in which they
        # were published. Messages can be tagged with an ordering key, a string
        # that identifies related messages for which publish order should be
        # respected. The service guarantees that, for a given ordering key and
        # publisher, messages are sent to subscribers in the order in which they
        # were published. Ordering does not require sacrificing high throughput
        # or scalability, as the service automatically distributes messages for
        # different ordering keys across subscribers.
        #
        # To use ordering keys, the subscription must be created with message
        # ordering enabled before calling {#listen}. When enabled, the subscriber
        # will deliver messages with the same `ordering_key` in the order they were
        # published.
        #
        # @note At the time of this release, ordering keys are not yet publicly
        #   enabled and requires special project enablements.
        #
        # @param [Numeric] deadline The default number of seconds the stream
        #   will hold received messages before modifying the message's ack
        #   deadline. The minimum is 10, the maximum is 600. Default is
        #   {#deadline}. Optional.
        #
        #   When using a reference object an API call will be made to retrieve
        #   the default deadline value for the subscription when this argument
        #   is not provided. See {#reference?}.
        # @param [Boolean] message_ordering Whether message ordering has been
        #   enabled. The value provided must match the value set on the Pub/Sub
        #   service. See {#message_ordering?}. Optional.
        #
        #   When using a reference object an API call will be made to retrieve
        #   the default message_ordering value for the subscription when this
        #   argument is not provided. See {#reference?}.
        # @param [Integer] streams The number of concurrent streams to open to
        #   pull messages from the subscription. Default is 2. Optional.
        # @param [Hash, Integer] inventory The settings to control how received messages are to be handled by the
        #   subscriber. When provided as an Integer instead of a Hash only `max_outstanding_messages` will be set.
        #   Optional.
        #
        #   Hash keys and values may include the following:
        #
        #     * `:max_outstanding_messages` [Integer] The number of received messages to be collected by subscriber.
        #       Default is 1,000. (Note: replaces `:limit`, which is deprecated.)
        #     * `:max_outstanding_bytes` [Integer] The total byte size of received messages to be collected by
        #       subscriber. Default is 100,000,000 (100MB). (Note: replaces `:bytesize`, which is deprecated.)
        #     * `:max_total_lease_duration` [Integer] The number of seconds that received messages can be held awaiting
        #       processing. Default is 3,600 (1 hour). (Note: replaces `:extension`, which is deprecated.)
        #     * `:max_duration_per_lease_extension` [Integer] The maximum amount of time in seconds for a single lease
        #       extension attempt. Bounds the delay before a message redelivery if the subscriber fails to extend the
        #       deadline. Default is 0 (disabled).
        # @param [Hash] threads The number of threads to create to handle
        #   concurrent calls by each stream opened by the subscriber. Optional.
        #
        #   Hash keys and values may include the following:
        #
        #     * `:callback` (Integer) The number of threads used to handle the
        #       received messages. Default is 8.
        #     * `:push` (Integer) The number of threads to handle
        #       acknowledgement ({ReceivedMessage#ack!}) and modify ack deadline
        #       messages ({ReceivedMessage#nack!},
        #       {ReceivedMessage#modify_ack_deadline!}). Default is 4.
        #
        # @yield [received_message] a block for processing new messages
        # @yieldparam [ReceivedMessage] received_message the newly received
        #   message
        #
        # @return [MessageListener]
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
        #     puts "Data: #{received_message.message.data}, published at #{received_message.message.published_at}"
        #     received_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example Configuring to increase concurrent callbacks:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscription "my-topic-sub"
        #
        #   listener = subscriber.listen threads: { callback: 16 } do |rec_message|
        #     # store the message somewhere before acknowledging
        #     store_in_backend rec_message.data # takes a few seconds
        #     rec_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example Ordered messages are supported using ordering_key:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.subscriber "my-ordered-topic-sub"
        #   subscriber.message_ordering? #=> true
        #
        #   listener = subscriber.listen do |received_message|
        #     # messsages with the same ordering_key are received
        #     # in the order in which they were published.
        #     received_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example Set the maximum amount of time before redelivery if the subscriber fails to extend the deadline:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #
        #   listener = subscriber.listen inventory: { max_duration_per_lease_extension: 20 } do |received_message|
        #     # Process message very slowly with possibility of failure.
        #     process rec_message.data # takes minutes
        #     rec_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def listen deadline: nil, message_ordering: nil, streams: nil, inventory: nil, threads: {}, &block
          ensure_service!
          deadline ||= self.deadline
          message_ordering = message_ordering? if message_ordering.nil?

          MessageListener.new name, block, deadline: deadline, streams: streams, inventory: inventory,
                                      message_ordering: message_ordering, threads: threads, service: service
        end

        ##
        # Acknowledges receipt of a message. After an ack,
        # the Pub/Sub system can remove the message from the subscription.
        # Acknowledging a message whose ack deadline has expired may succeed,
        # although the message may have been sent again.
        # Acknowledging a message more than once will not result in an error.
        # This is only used for messages received via pull.
        #
        # See also {ReceivedMessage#acknowledge!}.
        #
        # @param [ReceivedMessage, String] messages One or more
        #   {ReceivedMessage} objects or ack_id values.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   received_messages = sub.pull immediate: false
        #   subscriber.acknowledge received_messages
        #
        def acknowledge *messages
          ack_ids = coerce_ack_ids messages
          return true if ack_ids.empty?
          ensure_service!
          service.acknowledge name, *ack_ids
          true
        end
        alias ack acknowledge

        ##
        # Modifies the acknowledge deadline for messages.
        #
        # This indicates that more time is needed to process the messages, or to
        # make the messages available for redelivery if the processing was
        # interrupted.
        #
        # See also {ReceivedMessage#modify_ack_deadline!}.
        #
        # @param [Integer] new_deadline The new ack deadline in seconds from the
        #   time this request is sent to the Pub/Sub system. Must be >= 0. For
        #   example, if the value is `10`, the new ack deadline will expire 10
        #   seconds after the call is made. Specifying `0` may immediately make
        #   the message available for another pull request.
        # @param [ReceivedMessage, String] messages One or more
        #   {ReceivedMessage} objects or ack_id values.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   received_messages = subscriber.pull immediate: false
        #   subscriber.modify_ack_deadline 120, received_messages
        #
        def modify_ack_deadline new_deadline, *messages
          ack_ids = coerce_ack_ids messages
          ensure_service!
          service.modify_ack_deadline name, ack_ids, new_deadline
          true
        end

        ##
        # Determines whether the subscription object was created without
        # retrieving the resource representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the subscription was created without a
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.get_subscription "my-topic-sub", skip_lookup: true
        #   sub.reference? #=> true
        #
        def reference?
          @grpc.nil?
        end

        ##
        # Determines whether the subscription object was created with a resource
        # representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the subscription was created with a
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.get_subscription "my-topic-sub"
        #   sub.resource? #=> true
        #
        def resource?
          !@grpc.nil?
        end

        ##
        # Reloads the subscription with current data from the Pub/Sub service.
        #
        # @return [Google::Cloud::PubSub::Subscription] Returns the reloaded
        #   subscription
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.get_subscription "my-topic-sub"
        #   sub.reload!
        #
        def reload!
          ensure_service!
          subscription_path = service.subscription_path name
          @grpc = service.subscription_admin.get_subscription subscription: subscription_path
          @resource_name = nil
          self
        end

        ##
        # @private
        # New Subscriber from a Google::Cloud::PubSub::V1::Subscription
        # object.
        def self.from_grpc grpc, service
          new.tap do |f|
            f.grpc = grpc
            f.service = service
          end
        end

        ##
        # @private New reference {Subscriber} object without making an HTTP
        # request.
        def self.from_name name, service, options = {}
          name = service.subscription_path name, options
          from_grpc(nil, service).tap do |s|
            s.instance_variable_set :@resource_name, name
          end
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # Ensures a Google::Cloud::PubSub::V1::Subscription object exists.
        def ensure_grpc!
          ensure_service!
          reload! if reference?
        end

        ##
        # Makes sure the values are the `ack_id`. If given several
        # {ReceivedMessage} objects extract the `ack_id` values.
        def coerce_ack_ids messages
          Array(messages).flatten.map do |msg|
            msg.respond_to?(:ack_id) ? msg.ack_id : msg.to_s
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
