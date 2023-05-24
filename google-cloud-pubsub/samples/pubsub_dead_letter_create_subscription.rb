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

  topic             = pubsub.topic topic_id
  dead_letter_topic = pubsub.topic dead_letter_topic_id
  subscription      = topic.subscribe subscription_id,
                                      dead_letter_topic:                 dead_letter_topic,
                                      dead_letter_max_delivery_attempts: 10

  puts "Created subscription #{subscription_id} with dead letter topic #{dead_letter_topic_id}."
  puts "To process dead letter messages, remember to add a subscription to your dead letter topic."
  # [END pubsub_dead_letter_create_subscription]
end
