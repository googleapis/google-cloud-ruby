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

module Google
  module Cloud
    module PubSub
      ##
      # Topic Batch Publisher object used to publish multiple messages at
      # once.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   publisher = pubsub.publisher "my-topic"
      #   msgs = publisher.publish do |batch_publisher|
      #     batch_publisher.publish "task 1 completed", foo: :bar
      #     batch_publisher.publish "task 2 completed", foo: :baz
      #     batch_publisher.publish "task 3 completed", foo: :bif
      #   end
      #
      class BatchPublisher
        ##
        # @private The messages to publish
        attr_reader :messages

        ##
        # @private Enables publisher compression
        attr_reader :compress

        ##
        # @private The threshold bytes size for compression
        attr_reader :compression_bytes_threshold

        ##
        # @private The total bytes size of messages data.
        attr_reader :total_message_bytes

        ##
        # @private Create a new instance of the object.
        def initialize data,
                       attributes,
                       ordering_key,
                       extra_attrs,
                       compress: nil,
                       compression_bytes_threshold: nil
          @messages = []
          @mode = :batch
          @compress = compress || Google::Cloud::PubSub::DEFAULT_COMPRESS
          @compression_bytes_threshold = compression_bytes_threshold ||
                                         Google::Cloud::PubSub::DEFAULT_COMPRESSION_BYTES_THRESHOLD
          @total_message_bytes = 0
          return if data.nil?
          @mode = :single
          publish data, attributes, ordering_key: ordering_key, **extra_attrs
        end

        ##
        # Add a message to the batch to be published to the topic.
        # All messages added to the batch will be published at once.
        # See {Google::Cloud::PubSub::Topic#publish}
        #
        # @param [String, File] data The message payload. This will be converted
        #   to bytes encoded as ASCII-8BIT.
        # @param [Hash] attributes Optional attributes for the message.
        # @param [String] ordering_key Identifies related messages for which
        #   publish order should be respected.
        #
        # @example Multiple messages can be sent at the same time using a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   publisher = pubsub.publisher "my-topic"
        #   msgs = publisher.publish do |batch_publisher|
        #     batch_publisher.publish "task 1 completed", foo: :bar
        #     batch_publisher.publish "task 2 completed", foo: :baz
        #     batch_publisher.publish "task 3 completed", foo: :bif
        #   end
        #
        def publish data, attributes = nil, ordering_key: nil, **extra_attrs
          msg = Convert.pubsub_message data, attributes, ordering_key, extra_attrs
          @total_message_bytes += msg.data.bytesize + 2
          @messages << msg
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

        ##
        # @private  Call the publish API with arrays of data and attrs.
        def publish_batch_messages topic_name, service
          grpc = service.publish topic_name,
                                 messages,
                                 compress: compress && total_message_bytes >= compression_bytes_threshold
          to_gcloud_messages Array(grpc.message_ids)
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
