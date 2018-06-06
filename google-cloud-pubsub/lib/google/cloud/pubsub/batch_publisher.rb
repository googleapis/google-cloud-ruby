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


module Google
  module Cloud
    module Pubsub
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
        # Add a message to the batch to be published to the topic.
        # All messages added to the batch will be published at once.
        # See {Google::Cloud::Pubsub::Topic#publish}
        def publish data, attributes = {}
          @messages << create_pubsub_message(data, attributes)
        end

        ##
        # @private Create Message objects with message ids.
        def to_gcloud_messages message_ids
          msgs = @messages.zip(Array(message_ids)).map do |msg, id|
            msg.message_id = id
            Message.from_grpc msg
          end
          # Return just one Message if a single publish,
          # otherwise return the array of Messages.
          if @mode == :single && msgs.count <= 1
            msgs.first
          else
            msgs
          end
        end

        protected

        def create_pubsub_message data, attributes
          attributes ||= {}
          if data.is_a?(::Hash) && attributes.empty?
            attributes = data
            data = nil
          end
          # Convert IO-ish objects to strings
          if data.respond_to?(:read) && data.respond_to?(:rewind)
            data.rewind
            data = data.read
          end
          # Convert data to encoded byte array to match the protobuf defn
          data_bytes = \
            String(data).dup.force_encoding(Encoding::ASCII_8BIT).freeze

          # Convert attributes to strings to match the protobuf definition
          attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

          Google::Pubsub::V1::PubsubMessage.new data: data_bytes,
                                                attributes: attributes
        end
      end
    end
  end
end
