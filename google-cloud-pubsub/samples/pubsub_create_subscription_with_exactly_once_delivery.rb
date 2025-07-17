# Copyright 2022 Google LLC
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

# Shows how to create a new subscription with exactly once delivery enabled
def create_subscription_with_exactly_once_delivery project_id:, topic_id:, subscription_id:
  # [START pubsub_create_subscription_with_exactly_once_delivery]
  # project_id = "your-project-id"
  # topic_id = "your-topic-id"
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new project_id: project_id

  subscription_admin = pubsub.subscription_admin

  subscription = subscription_admin.create_subscription \
    name: pubsub.subscription_path(subscription_id),
    topic: pubsub.topic_path(topic_id),
    enable_exactly_once_delivery: true

  puts "Created subscription with exactly once delivery enabled: #{subscription_id}"
  # [END pubsub_create_subscription_with_exactly_once_delivery]
end
