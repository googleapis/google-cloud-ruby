#--
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
    # = Message
    #
    # Represents a Pubsub Message.
    #
    # Message objects are created by Topic#publish.
    # Subscription#pull returns Event objects, which contain a Message object
    # and can be acknowleged and/or delayed.
    #
    #   require "glcoud/pubsub"
    #
    #   pubsub = Gcloud.pubsub
    #
    #   # Publish a message
    #   topic = pubsub.topic "my-topic"
    #   message = topic.publish "new-message"
    #   puts message.data #=>  "new-message"
    #
    #   # Pull an event/message
    #   sub = pubsub.subscription "my-topic-sub"
    #   event = sub.pull.first
    #   puts event.message.data #=>  "new-message"
    #
    class Message
      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Message object.
      # This can be used to publish several messages in bulk.
      def initialize data = nil, attributes = {}
        @gapi               = {}
        @gapi["data"]       = data
        @gapi["attributes"] = attributes
      end

      ##
      # The received data.
      def data
        @gapi["data"]
      end

      ##
      # The received attributes.
      def attributes
        @gapi["attributes"]
      end

      ##
      # The ID of this message, assigned by the server at publication time.
      # Guaranteed to be unique within the topic.
      def message_id
        @gapi["messageId"]
      end
      alias_method :msg_id, :message_id

      ##
      # New Topic from a Google API Client object.
      def self.from_gapi gapi #:nodoc:
        new.tap do |f|
          f.gapi = gapi
        end
      end
    end
  end
end
