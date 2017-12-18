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

module Google
  module Cloud
    module Pubsub
      ##
      # # Message
      #
      # Represents a Pub/Sub Message.
      #
      # Message objects are created by {Topic#publish}. {Subscription#pull}
      # returns an array of {ReceivedMessage} objects, each of which contains a
      # Message object. Each {ReceivedMessage} object can be acknowledged and/or
      # delayed.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #
      #   # Publish a message
      #   topic = pubsub.topic "my-topic"
      #   message = topic.publish "task completed"
      #   message.data #=> "task completed"
      #
      #   # Listen for messages
      #   sub = pubsub.subscription "my-topic-sub"
      #   subscriber = sub.listen do |received_message|
      #     # process message
      #     received_message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   subscriber.start
      #
      #   # Shut down the subscriber when ready to stop receiving messages.
      #   subscriber.stop.wait!
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
        # The message payload. This data is a list of bytes encoded as
        # ASCII-8BIT.
        def data
          @grpc.data
        end

        ##
        # Optional attributes for the message.
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
        # The time at which the message was published.
        def published_at
          Convert.timestamp_to_time @grpc.publish_time
        end
        alias_method :publish_time, :published_at

        ##
        # @private New Message from a Google::Pubsub::V1::PubsubMessage object.
        def self.from_grpc grpc
          new.tap do |m|
            m.instance_variable_set "@grpc", grpc
          end
        end
      end
    end
  end
end
