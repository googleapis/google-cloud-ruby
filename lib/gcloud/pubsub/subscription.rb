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
      # New Topic from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end
    end
  end
end
