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
    class Topic
      ##
      # Batch object used to publish multiple messages at once.
      class Batch
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
        # See {Gcloud::Pubsub::Topic#publish}
        def publish data, attributes = {}
          # Convert attributes to strings to match the protobuf definition
          attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]
          @messages << [data, attributes]
        end

        ##
        # @private Create Message objects with message ids.
        def to_gcloud_messages message_ids
          msgs = @messages.zip(Array(message_ids)).map do |arr, id|
            Message.from_grpc(Google::Pubsub::V1::PubsubMessage.new(
                                data: String(arr[0]).encode("ASCII-8BIT"),
                                attributes: arr[1],
                                message_id: id))
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
