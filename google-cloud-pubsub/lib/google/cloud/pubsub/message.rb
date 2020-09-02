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
    module PubSub
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
      #   pubsub = Google::Cloud::PubSub.new
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
      #   subscriber.stop!
      #
      class Message
        ##
        # @private The gRPC Google::Cloud::PubSub::V1::PubsubMessage object.
        attr_accessor :grpc

        ##
        # Create an empty Message object.
        # This can be used to publish several messages in bulk.
        def initialize data = nil, attributes = {}
          # Convert attributes to strings to match the protobuf definition
          attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

          @grpc = Google::Cloud::PubSub::V1::PubsubMessage.new(
            data:       String(data).dup.force_encoding(Encoding::ASCII_8BIT),
            attributes: attributes
          )
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
        alias msg_id message_id

        ##
        # The time at which the message was published.
        def published_at
          Convert.timestamp_to_time @grpc.publish_time
        end
        alias publish_time published_at

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
        # See {Topic#publish_async} and {Subscription#listen}.
        #
        # @return [String]
        #
        def ordering_key
          @grpc.ordering_key
        end

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
        # @private New Message from a Google::Cloud::PubSub::V1::PubsubMessage
        # object.
        def self.from_grpc grpc
          new.tap do |m|
            m.instance_variable_set :@grpc, grpc
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
