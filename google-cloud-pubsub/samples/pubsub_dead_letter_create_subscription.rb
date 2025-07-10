# Copyright 2023 Google, Inc
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

require "google/cloud/pubsub"

def dead_letter_create_subscription topic_id:, subscription_id:, dead_letter_topic_id:
  # [START pubsub_dead_letter_create_subscription]
  # topic_id             = "your-topic-id"
  # subscription_id      = "your-subscription-id"
  # dead_letter_topic_id = "your-dead-letter-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  subscription_admin = pubsub.subscription_admin

  dl_topic_path = pubsub.topic_path dead_letter_topic_id
  dead_letter_policy = Google::Cloud::PubSub::V1::DeadLetterPolicy.new dead_letter_topic: dl_topic_path,
                                                                       max_delivery_attempts: 10
  subscription = subscription_admin.create_subscription name: pubsub.subscription_path(subscription_id),
                                                        topic: pubsub.topic_path(topic_id),
                                                        dead_letter_policy: dead_letter_policy

  puts "Created subscription #{subscription_id} with dead letter topic #{dead_letter_topic_id}."
  puts "To process dead letter messages, remember to add a subscription to your dead letter topic."
  # [END pubsub_dead_letter_create_subscription]
end
