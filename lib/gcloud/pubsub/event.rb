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

module Gcloud
  module Pubsub
    ##
    # Represents a Pubsub Event.
    class Event
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Subscription object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The subscription that received the event.
      def subscription
        @gapi["pubsubEvent"]["subscription"]
      end

      ##
      # The acknowledgment ID for the message being acknowledged.
      # This was returned by the Pub/Sub system in the Pull response.
      # This ID must be used to acknowledge the received event.
      def ack_id
        @gapi["ackId"]
      end

      ##
      # The received message.
      def message
        @gapi["pubsubEvent"]["message"]["data"]
      end
      alias_method :msg, :message

      ##
      # The ID of this message, assigned by the server at publication time.
      # Guaranteed to be unique within the topic.
      def message_id
        @gapi["pubsubEvent"]["message"]["messageId"]
      end
      alias_method :msg_id, :message_id

      ##
      # Acknowledges receipt of the message.
      def acknowledge!
        ensure_connection!
        resp = connection.acknowledge subscription_name, ack_id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :ack!, :acknowledge!

      ##
      # New Topic from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      ##
      # Gets the subscription name from the path.
      # "/subscriptions/project-identifier/subscription-name"
      # will return "subscription-name"
      def subscription_name
        subscription.split("/").last
      end
    end
  end
end
