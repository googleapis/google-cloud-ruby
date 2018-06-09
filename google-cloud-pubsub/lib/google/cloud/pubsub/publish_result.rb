# frozen_string_literal: true

# Copyright 2017 Google LLC
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
      # # PublishResult
      #
      class PublishResult
        ##
        # @private Create an PublishResult object.
        def initialize message, error = nil
          @message = message
          @error = error
        end

        ##
        # The message.
        def message
          @message
        end
        alias msg message

        ##
        # The message's data.
        def data
          message.data
        end

        ##
        # The message's attributes.
        def attributes
          message.attributes
        end

        ##
        # The ID of the message, assigned by the server at publication
        # time. Guaranteed to be unique within the topic.
        def message_id
          message.message_id
        end
        alias msg_id message_id

        ##
        # The time at which the message was published.
        def published_at
          message.published_at
        end
        alias publish_time published_at

        ##
        # The error that was raised when published, if any.
        def error
          @error
        end

        ##
        # Whether the publish request was successful.
        def succeeded?
          error.nil?
        end

        # Whether the publish request failed.
        def failed?
          !succeeded?
        end

        ##
        # @private Create an PublishResult object from a message protobuf.
        def self.from_grpc msg_grpc
          new Message.from_grpc(msg_grpc)
        end

        ##
        # @private Create an PublishResult object from a message protobuf and an
        # error.
        def self.from_error msg_grpc, error
          new Message.from_grpc(msg_grpc), error
        end
      end
    end
  end
end
