# Copyright 2015 Google Inc. All rights reserved.
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


require "google/cloud/errors"
require "google/cloud/pubsub/message"

module Google
  module Cloud
    module Pubsub
      ##
      # # ReceivedMessage
      #
      # Represents a Pub/Sub {Message} that can be acknowledged or delayed.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   subscriber = sub.listen do |received_message|
      #     puts received_message.message.data
      #     received_message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   subscriber.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   subscriber.stop.wait!
      #
      class ReceivedMessage
        ##
        # @private The {Subscription} object.
        attr_accessor :subscription

        ##
        # @private The gRPC Google::Pubsub::V1::ReceivedMessage object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Subscription} object.
        def initialize
          @subscription = nil
          @grpc = Google::Pubsub::V1::ReceivedMessage.new
        end

        ##
        # The acknowledgment ID for the message.
        def ack_id
          @grpc.ack_id
        end

        ##
        # The received message.
        def message
          Message.from_grpc @grpc.message
        end
        alias_method :msg, :message

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
        alias_method :msg_id, :message_id

        ##
        # The time at which the message was published.
        def published_at
          message.published_at
        end
        alias_method :publish_time, :published_at

        ##
        # Acknowledges receipt of the message.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   subscriber = sub.listen do |received_message|
        #     puts received_message.message.data
        #
        #     received_message.acknowledge!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   subscriber.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop.wait!
        #
        def acknowledge!
          ensure_subscription!
          subscription.acknowledge ack_id
        end
        alias_method :ack!, :acknowledge!

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
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   subscriber = sub.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Delay for 2 minutes
        #     received_message.delay! 120
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   subscriber.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop.wait!
        #
        def delay! new_deadline
          ensure_subscription!
          subscription.delay new_deadline, ack_id
        end
        alias_method :modify_ack_deadline!, :delay!

        ##
        # Resets the acknowledge deadline for the message without acknowledging
        # it.
        #
        # This will make the message available for redelivery.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   subscriber = sub.listen do |received_message|
        #     puts received_message.message.data
        #
        #     # Release message back to the API.
        #     received_message.reject!
        #   end
        #
        #   # Start background threads that will call block passed to listen.
        #   subscriber.start
        #
        #   # Shut down the subscriber when ready to stop receiving messages.
        #   subscriber.stop.wait!
        #
        def reject!
          delay! 0
        end
        alias_method :nack!, :reject!
        alias_method :ignore!, :reject!

        ##
        # @private New ReceivedMessage from a
        # Google::Pubsub::V1::ReceivedMessage object.
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
          fail "Must have active subscription" unless subscription
        end
      end
    end
  end
end
