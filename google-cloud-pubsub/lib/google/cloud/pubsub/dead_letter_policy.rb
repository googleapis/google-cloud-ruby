# Copyright 2020 Google LLC
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
    module PubSub
      ##
      # # DeadLetterPolicy
      #
      # An immutable Dead Letter Policy value object that specifies the conditions for dead lettering messages in a
      # subscription.
      #
      # Dead lettering is done on a best effort basis. The same message might be dead lettered multiple times.
      #
      # If validation on any of the fields fails at subscription creation/updation, the create/update subscription
      # request will fail.
      #
      # @attr [Topic] dead_letter_topic The topic to which dead letter messages for the subscription should be
      #   published. Dead lettering is done on a best effort basis. The same message might be dead lettered multiple
      #   times. The Cloud Pub/Sub service account associated with the enclosing subscription's parent project (i.e.,
      #   `service-\\{project_number}@gcp-sa-pubsub.iam.gserviceaccount.com`) must have permission to Publish() to this
      #   topic.
      #
      #   The operation will fail if the topic does not exist. Users should ensure that there is a subscription attached
      #   to this topic since messages published to a topic with no subscriptions are lost.
      # @attr [Numeric] max_delivery_attempts The maximum number of delivery attempts for any message in the
      #   subscription's dead letter policy. Dead lettering is done on a best effort basis. The same message might be
      #   dead lettered multiple times. The value must be between 5 and 100.
      #
      #   The number of delivery attempts is defined as 1 + (the sum of number of NACKs and number of times the
      #   acknowledgement deadline has been exceeded for the message). A NACK is any call to ModifyAckDeadline with a 0
      #   deadline. Note that client libraries may automatically extend ack_deadlines.
      #
      #   This field will be honored on a best effort basis.
      #
      # @example Configure and read a Dead Letter Policy:
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   # Dead Letter Queue (DLQ) testing requires IAM bindings to the Cloud Pub/Sub service account that is
      #   # automatically created and managed by the service team in a private project.
      #   my_project_number = "000000000000"
      #   service_account_email = "serviceAccount:service-#{my_project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
      #
      #   dead_letter_topic = pubsub.topic "my-dead-letter-topic"
      #   dead_letter_subscription = dead_letter_topic.subscribe "my-dead-letter-sub"
      #
      #   dead_letter_topic.policy { |p| p.add "roles/pubsub.publisher", service_account_email }
      #   dead_letter_subscription.policy { |p| p.add "roles/pubsub.subscriber", service_account_email }
      #
      #   topic = pubsub.topic "my-topic"
      #   sub = topic.subscribe "my-topic-sub",
      #                         dead_letter_topic: dead_letter_topic,
      #                         dead_letter_max_delivery_attempts: 10
      #
      #   sub.dead_letter_policy.dead_letter_topic.name #=> "projects/my-project/topics/my-dead-letter-topic"
      #   sub.dead_letter_policy.max_delivery_attempts #=> 10
      #
      class DeadLetterPolicy
        attr_accessor :dead_letter_topic, :max_delivery_attempts

        ##
        # Creates a new, immutable DeadLetterPolicy value object.
        #
        # @param [Topic] dead_letter_topic The topic to which dead letter messages for the subscription should be
        #   published. Dead lettering is done on a best effort basis. The same message might be dead lettered multiple
        #   times. The Cloud Pub/Sub service account associated with the enclosing subscription's parent project (i.e.,
        #   `service-\\{project_number}@gcp-sa-pubsub.iam.gserviceaccount.com`) must have permission to Publish() to
        #   this topic. The operation will fail if the topic does not exist. Users should ensure that there is a
        #   subscription attached to this topic since messages published to a topic with no subscriptions are lost.
        #   Required.
        # @param [Integer, nil] max_delivery_attempts The maximum number of delivery attempts for any message in the
        #   subscription's dead letter policy. Dead lettering is done on a best effort basis. The same message might be
        #   dead lettered multiple times. The value must be between 5 and 100.
        #
        #   The number of delivery attempts is defined as 1 + (the sum of number of NACKs and number of times the
        #   acknowledgement deadline has been exceeded for the message). A NACK is any call to ModifyAckDeadline with a
        #   0 deadline. Note that client libraries may automatically extend ack_deadlines.
        #
        #   This field will be honored on a best effort basis. If this parameter is 0, a default value of 5 is used.
        #
        def initialize dead_letter_topic: nil, max_delivery_attempts: nil
          @dead_letter_topic = dead_letter_topic
          @max_delivery_attempts = max_delivery_attempts
        end

        ##
        # @private Convert the DeadLetterPolicy to a Google::Cloud::PubSub::V1::DeadLetterPolicy object.
        def to_grpc
          Google::Cloud::PubSub::V1::DeadLetterPolicy.new(
            dead_letter_topic:     dead_letter_topic.name,
            max_delivery_attempts: max_delivery_attempts
          )
        end

        ##
        # @private New DeadLetterPolicy from a Google::Cloud::PubSub::V1::DeadLetterPolicy object.
        def self.from_grpc grpc, service
          new(
            dead_letter_topic:     Topic.from_name(grpc.dead_letter_topic, service),
            max_delivery_attempts: grpc.max_delivery_attempts
          )
        end
      end
    end
  end
end
