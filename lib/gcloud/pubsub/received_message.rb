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


require "gcloud/pubsub/errors"
require "gcloud/pubsub/message"

module Gcloud
  module Pubsub
    ##
    # # ReceivedMessage
    #
    # Represents a Pub/Sub {Message} that can be acknowledged or delayed.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #
    #   sub = pubsub.subscription "my-topic-sub"
    #   received_message = sub.pull.first
    #   if received_message
    #     puts received_message.message.data
    #     received_message.acknowledge!
    #   end
    #
    class ReceivedMessage
      ##
      # @private The {Subscription} object.
      attr_accessor :subscription

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty {Subscription} object.
      def initialize
        @subscription = nil
        @gapi = {}
      end

      ##
      # The acknowledgment ID for the message.
      def ack_id
        @gapi["ackId"]
      end

      ##
      # The received message.
      def message
        Message.from_gapi @gapi["message"]
      end
      alias_method :msg, :message

      ##
      # The received message's data.
      def data
        message.data
      end

      ##
      # The received message's attributes.
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
      # Acknowledges receipt of the message.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   received_message = sub.pull.first
      #   if received_message
      #     puts received_message.message.data
      #     received_message.acknowledge!
      #   end
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   pubsub = gcloud.pubsub
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #   received_message = sub.pull.first
      #   if received_message
      #     puts received_message.message.data
      #     # Delay for 2 minutes
      #     received_message.delay! 120
      #   end
      #
      def delay! new_deadline
        ensure_subscription!
        connection = subscription.connection
        resp = connection.modify_ack_deadline subscription.name,
                                              ack_id, new_deadline
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private New ReceivedMessage from a Google API Client object.
      def self.from_gapi gapi, subscription
        new.tap do |f|
          f.gapi         = gapi
          f.subscription = subscription
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
