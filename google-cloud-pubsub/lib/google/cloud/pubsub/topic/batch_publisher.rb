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


module Google
  module Cloud
    module Pubsub
      class Topic
        ##
        # Topic Batch Publisher object used to publish multiple messages at
        # once.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   topic = pubsub.topic "my-topic"
        #   msgs = topic.publish do |t|
        #     t.publish "task 1 completed", foo: :bar
        #     t.publish "task 2 completed", foo: :baz
        #     t.publish "task 3 completed", foo: :bif
        #   end
        class BatchPublisher
          ##
          # @private The messages to publish
          attr_reader :messages

          ##
          # @private Create a new instance of the object.
          def initialize data = nil, attributes = {}
            @messages = []
            @mode = :batch
            return if data.nil?
            @mode = :single
            publish data, attributes
          end

          ##
          # Add multiple messages to the topic.
          # All messages added will be published at once.
          # See {Google::Cloud::Pubsub::Topic#publish}
          def publish data, attributes = {}
            # Convert IO-ish objects to strings
            if data.respond_to?(:read) && data.respond_to?(:rewind)
              data.rewind
              data = data.read
            end
            # Convert data to encoded byte array to match the protobuf defn
            data = String(data).force_encoding("ASCII-8BIT")
            # Convert attributes to strings to match the protobuf definition
            attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]
            @messages << [data, attributes]
          end

          ##
          # @private Create Message objects with message ids.
          def to_gcloud_messages message_ids
            msgs = @messages.zip(Array(message_ids)).map do |arr, id|
              Message.from_grpc(
                Google::Pubsub::V1::PubsubMessage.new(
                  data: arr[0], attributes: arr[1], message_id: id))
            end
            # Return just one Message if a single publish,
            # otherwise return the array of Messages.
            if @mode == :single && msgs.count <= 1
              msgs.first
            else
              msgs
            end
          end
        end
      end
    end
  end
end
