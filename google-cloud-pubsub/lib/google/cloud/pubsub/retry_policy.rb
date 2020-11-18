# Copyright 2016 Google LLC
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
      # # RetryPolicy
      #
      # An immutable Retry Policy value object that specifies how Cloud Pub/Sub retries message delivery.
      #
      # Retry delay will be exponential based on provided minimum and maximum backoffs. (See [Exponential
      # backoff](https://en.wikipedia.org/wiki/Exponential_backoff).)
      #
      # Retry Policy will be triggered on NACKs or acknowledgement deadline exceeded events for a given message.
      #
      # Retry Policy is implemented on a best effort basis. At times, the delay between consecutive deliveries may not
      # match the configuration. That is, delay can be more or less than configured backoff.
      #
      # @attr [Numeric] minimum_backoff The minimum delay between consecutive deliveries of a given message. Value
      #   should be between 0 and 600 seconds. The default value is 10 seconds.
      # @attr [Numeric] maximum_backoff The maximum delay between consecutive deliveries of a given message. Value
      #   should be between 0 and 600 seconds. The default value is 600 seconds.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   sub = pubsub.subscription "my-topic-sub"
      #
      #   sub.retry_policy = Google::Cloud::PubSub::RetryPolicy.new minimum_backoff: 5, maximum_backoff: 300
      #
      #   sub.retry_policy.minimum_backoff #=> 5
      #   sub.retry_policy.maximum_backoff #=> 300
      #
      class RetryPolicy
        attr_reader :minimum_backoff, :maximum_backoff

        ##
        # Creates a new, immutable RetryPolicy value object.
        #
        # @attr [Numeric, nil] minimum_backoff The minimum delay between consecutive deliveries of a given message.
        #   Value should be between 0 and 600 seconds. If `nil` is provided, the default value is 10 seconds.
        # @attr [Numeric, nil] maximum_backoff The maximum delay between consecutive deliveries of a given message.
        #   Value should be between 0 and 600 seconds. If `nil` is provided, the default value is 600 seconds.
        #
        def initialize minimum_backoff: nil, maximum_backoff: nil
          @minimum_backoff = minimum_backoff
          @maximum_backoff = maximum_backoff
        end

        ##
        # @private Convert the RetryPolicy to a Google::Cloud::PubSub::V1::RetryPolicy object.
        def to_grpc
          Google::Cloud::PubSub::V1::RetryPolicy.new(
            minimum_backoff: Convert.number_to_duration(minimum_backoff),
            maximum_backoff: Convert.number_to_duration(maximum_backoff)
          )
        end

        ##
        # @private New RetryPolicy from a Google::Cloud::PubSub::V1::RetryPolicy object.
        def self.from_grpc grpc
          new(
            minimum_backoff: Convert.duration_to_number(grpc.minimum_backoff),
            maximum_backoff: Convert.duration_to_number(grpc.maximum_backoff)
          )
        end
      end
    end
  end
end
