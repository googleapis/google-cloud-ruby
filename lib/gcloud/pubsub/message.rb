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
    # # Message
    #
    # Represents a Pub/Sub Message.
    #
    # Message objects are created by {Topic#publish}.
    # {Subscription#pull} returns an array of {ReceivedMessage} objects, each of
    # which contains a Message object. Each {ReceivedMessage} object can be
    # acknowledged and/or delayed.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #
    #   # Publish a message
    #   topic = pubsub.topic "my-topic"
    #   message = topic.publish "new-message"
    #   puts message.data #=>  "new-message"
    #
    #   # Pull a message
    #   sub = pubsub.subscription "my-topic-sub"
    #   received_message = sub.pull.first
    #   puts received_message.message.data #=>  "new-message"
    #
    class Message
      ##
      # @private The gRPC Google::Pubsub::V1::PubsubMessage object.
      attr_accessor :grpc

      ##
      # Create an empty Message object.
      # This can be used to publish several messages in bulk.
      def initialize data = nil, attributes = {}
        # Convert attributes to strings to match the protobuf definition
        attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

        @grpc = Google::Pubsub::V1::PubsubMessage.new(
          data: String(data).encode("ASCII-8BIT"),
          attributes: attributes)
      end

      ##
      # The received data.
      def data
        @grpc.data
      end

      ##
      # The received attributes.
      def attributes
        return @grpc.attributes.to_h if @grpc.attributes.respond_to? :to_h
        # Enumerable doesn't have to_h on Ruby 2.0, so fallback to this
        Hash[@grpc.attributes.to_a]
      end

      ##
      # The ID of this message, assigned by the server at publication time.
      # Guaranteed to be unique within the topic.
      def message_id
        @grpc.message_id
      end
      alias_method :msg_id, :message_id

      ##
      # @private New Message from a Google::Pubsub::V1::PubsubMessage object.
      def self.from_grpc grpc
        new.tap do |m|
          m.instance_eval do
            @grpc = grpc
          end
        end
      end
    end
  end
end
