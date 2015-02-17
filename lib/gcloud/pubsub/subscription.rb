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
require "gcloud/pubsub/subscription/list"
require "gcloud/pubsub/event"

module Gcloud
  module Pubsub
    ##
    # Represents a Subscription.
    class Subscription
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
      # The name of the subscription.
      def name
        @gapi["name"]
      end

      ##
      # The topic from which this subscription is receiving messages,
      # in the form /topics/project-identifier/topic-name.
      def topic
        @gapi["topic"]
      end

      ##
      # The maximum time after a subscriber receives a message before
      # the subscriber should acknowledge or nack the message.
      # If the ack deadline for a message passes without an ack or a nack,
      # the Pub/Sub system will eventually redeliver the message.
      # If a subscriber acknowledges after the deadline,
      # the Pub/Sub system may accept the ack,
      # but but the message may already have been sent again.
      # Multiple acks to the message are allowed.
      def deadline
        @gapi["ackDeadlineSeconds"]
      end

      ##
      # A URL locating the endpoint that messages are pushed.
      def endpoint
        @gapi["pushConfig"]["pushEndpoint"] if @gapi["pushConfig"]
      end

      ##
      # Deletes an existing subscription.
      # All pending messages in the subscription are immediately dropped.
      def delete
        ensure_connection!
        resp = connection.delete_subscription subscription_name
        if resp.success?
          true
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # Pulls a single message from the server.
      # If immediate is true, the system will respond immediately,
      # either with a message if available or nil if no message is available.
      # Otherwise, the call will block until a message is available,
      # or may return UNAVAILABLE if no messages become available
      # within a reasonable amount of time.
      def pull immediate = true
        ensure_connection!
        resp = connection.pull name, immediate
        if resp.success?
          Event.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Acknowledges receipt of a message. After an ack,
      # the Pub/Sub system can remove the message from the subscription.
      # Acknowledging a message whose ack deadline has expired may succeed,
      # although the message may have been sent again.
      # Acknowledging a message more than once will not result in an error.
      # This is only used for messages received via pull.
      def acknowledge *ack_ids
        ensure_connection!
        resp = connection.acknowledge subscription_name, *ack_ids
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :ack, :acknowledge

      ##
      # New Subscription from a Google API Client object.
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
      # Gets the topic name from the path.
      # "/subscriptions/project-identifier/subscription-name"
      # will return "subscription-name"
      def subscription_name
        name.split("/").last
      end
    end
  end
end
