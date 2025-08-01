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


require "google/cloud/errors"
require "google/cloud/pubsub/message"

module Google
  module Cloud
    module PubSub
      ##
      # # ReceivedMessage
      #
      # Represents a Pub/Sub {Message} that can be acknowledged or delayed.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   subscriber = pubsub.subscriber "my-topic-sub"
      #   listener = subscriber.listen do |received_message|
      #     puts received_message.message.data
      #     received_message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   listener.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   listener.stop!
      #
      class ReceivedMessage
        ##
        # @private The {Google::Cloud::PubSub::V1::Subscription} object.
        attr_accessor :subscription

        ##
        # @private The gRPC Google::Cloud::PubSub::V1::ReceivedMessage object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Google::Cloud::PubSub::V1::Subscription} object.
        def initialize
          @subscription = nil
          @grpc = Google::Cloud::PubSub::V1::ReceivedMessage.new
        end

        ##
        # The acknowledgment ID for the message.
        def ack_id
          @grpc.ack_id
        end

        ##
        # Returns the delivery attempt counter for the message. If a dead letter policy is not set on the subscription,
        # this will be `nil`.
        #
        # The delivery attempt counter is `1 + (the sum of number of NACKs and number of ack_deadline exceeds)` for the
        # message.
        #
        # A NACK is any call to `ModifyAckDeadline` with a `0` deadline. An `ack_deadline` exceeds event is whenever a
        # message is not acknowledged within `ack_deadline`. Note that `ack_deadline` is initially
        # `Subscription.ackDeadlineSeconds`, but may get extended automatically by the client library.
        #
        # The first delivery of a given message will have this value as `1`. The value is calculated at best effort and
        # is approximate.
        #
        # @return [Integer, nil] A delivery attempt value of `1` or greater, or `nil` if a dead letter policy is not set
        #   on the subscription.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscription_admin = pubsub.subscription_admin
        #
        #   subscription = subscription_admin.create_subscription \
        #     name: pubsub.subscription_path("my-topic-sub"),
        #     topic: pubsub.topic_path("my-topic"),
        #     dead_letter_policy: {
        #       dead_letter_topic: pubsub.topic_path("my-dead-letter-topic"),
        #       max_delivery_attempts: 10
        #     }
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.delivery_attempt
        #   end
        #
        def delivery_attempt
          return nil if @grpc.delivery_attempt && @grpc.delivery_attempt < 1
          @grpc.delivery_attempt
        end

        ##
        # The received message.
        def message
          Message.from_grpc @grpc.message
        end
        alias msg message

        ##
        # The received message payload. This data is a list of bytes encoded as
        # ASCII-8BIT.
        def data
          message.data
        end

        ##
        # Optional attributes for the received message.
        def attributes
          message.attributes
        end

        ##
        # The ID of the received message, assigned by the server at publication
        # time. Guaranteed to be unique within the topic.
        def message_id
          message.message_id
        end
        alias msg_id message_id

        ##
        # Identifies related messages for which publish order should be
        # respected.
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
        # See {Publisher#publish_async} and {Subscriber#listen}.
        #
        # @return [String]
        #
        def ordering_key
          message.ordering_key
        end

        ##
        # The time at which the message was published.
        def published_at
          message.published_at
        end
        alias publish_time published_at

        ##
        # Acknowledges receipt of the message.
        #
        # @yield [callback] The block to be called when reject operation is done.
        # @yieldparam [Google::Cloud::PubSub::AcknowledgeResult] Result object that contains the status and error.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     received_message.acknowledge! do |result|
        #       puts result.status
        #     end
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     received_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def acknowledge!(&)
          ensure_subscription!
          if subscription.respond_to?(:exactly_once_delivery_enabled) && subscription.exactly_once_delivery_enabled
            subscription.acknowledge ack_id, &
          else
            subscription.acknowledge ack_id
            yield AcknowledgeResult.new(AcknowledgeResult::SUCCESS) if block_given?
          end
        end
        alias ack! acknowledge!

        ##
        # Modifies the acknowledge deadline for the message.
        #
        # This indicates that more time is needed to process the message, or to
        # make the message available for redelivery.
        #
        # @param [Integer] new_deadline The new ack deadline in seconds from the
        #   time this request is sent to the Pub/Sub system. Must be >= 0. For
        #   example, if the value is `10`, the new ack deadline will expire 10
        #   seconds after the call is made. Specifying `0` may immediately make
        #   the message available for another pull request.
        #
        # @yield [callback] The block to be called when reject operation is done.
        # @yieldparam [Google::Cloud::PubSub::AcknowledgeResult] Result object that contains the status and error.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Delay for 2 minutes
        #     received_message.modify_ack_deadline! 120 do |result|
        #       puts result.status
        #     end
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Delay for 2 minutes
        #     received_message.modify_ack_deadline! 120
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def modify_ack_deadline!(new_deadline, &)
          ensure_subscription!
          if subscription.respond_to?(:exactly_once_delivery_enabled) && subscription.exactly_once_delivery_enabled
            subscription.modify_ack_deadline new_deadline, ack_id, &
          else
            subscription.modify_ack_deadline new_deadline, ack_id
            yield AcknowledgeResult.new(AcknowledgeResult::SUCCESS) if block_given?
          end
        end

        ##
        # Resets the acknowledge deadline for the message without acknowledging
        # it.
        #
        # This will make the message available for redelivery.
        #
        # @yield [callback] The block to be called when reject operation is done.
        # @yieldparam [Google::Cloud::PubSub::AcknowledgeResult] Result object that contains the status and error.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Release message back to the API.
        #     received_message.reject! do |result|
        #       puts result.status
        #     end
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   subscriber = pubsub.subscriber "my-topic-sub"
        #   listener = subscriber.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Release message back to the API.
        #     received_message.reject!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   listener.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   listener.stop!
        #
        def reject!(&)
          modify_ack_deadline! 0, &
        end
        alias nack! reject!
        alias ignore! reject!

        # @private
        def hash
          @grpc.hash
        end

        # @private
        def eql? other
          return false unless other.is_a? self.class
          @grpc.hash == other.hash
        end
        # @private
        alias == eql?

        # @private
        def <=> other
          return nil unless other.is_a? self.class
          other_grpc = other.instance_variable_get :@grpc
          @grpc <=> other_grpc
        end

        ##
        # @private New ReceivedMessage from a
        # Google::Cloud::PubSub::V1::ReceivedMessage object.
        def self.from_grpc grpc, subscription
          new.tap do |rm|
            rm.grpc         = grpc
            rm.subscription = subscription
          end
        end

        protected

        ##
        # Raise an error unless an active subscription is available.
        def ensure_subscription!
          raise "Must have active subscription" unless subscription
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
