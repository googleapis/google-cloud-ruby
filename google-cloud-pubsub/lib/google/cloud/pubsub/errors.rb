# Copyright 2019 Google LLC
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


require "google/cloud/errors"

module Google
  module Cloud
    module PubSub
      ##
      # Indicates that the {AsyncPublisher} has been stopped and cannot accept
      # messages to publish.
      #
      class AsyncPublisherStopped < Google::Cloud::Error
        def initialize message = "Can't publish when stopped."
          super message
        end
      end

      ##
      # Indicates that the {AsyncPublisher} has not been enabled to publish
      # messages with an ordering key. Use
      # {AsyncPublisher#enable_message_ordering!} to enable publishing ordered
      # messages.
      #
      class OrderedMessagesDisabled < Google::Cloud::Error
        def initialize message = "Ordered messages are disabled."
          super message
        end
      end

      ##
      # Indicates that the {Subscriber} for a {Subscription} with message
      # ordering enabled has observed that a message has been delivered out of
      # order.
      #
      class OrderedMessageDeliveryError < Google::Cloud::Error
        attr_reader :ordered_message

        def initialize ordered_message
          @ordered_message = ordered_message

          super "Ordered message delivered out of order."
        end
      end

      ##
      # Indicates that messages using the {#ordering_key} are not being
      # published due to error. Future calls to {Topic#publish_async} with the
      # {#ordering_key} will fail with this error.
      #
      # To allow future messages with the {#ordering_key} to be published, the
      # {#ordering_key} must be passed to {Topic#resume_publish}.
      #
      # If this error is retrieved from {PublishResult#error}, inspect `cause`
      # for the error raised while publishing.
      #
      # @!attribute [r] ordering_key
      #   @return [String] The ordering key that is in a failed state.
      #
      class OrderingKeyError < Google::Cloud::Error
        attr_reader :ordering_key

        def initialize ordering_key
          @ordering_key = ordering_key

          super "Can't publish message using #{ordering_key}."
        end
      end

      ##
      # Raised when the desired action is `error` and the message would exceed
      # flow control limits, or when the desired action is `block` and the
      # message would block forever against the flow control limits.
      #
      class FlowControlLimitError < Google::Cloud::Error
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
