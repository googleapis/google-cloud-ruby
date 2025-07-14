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

# [START pubsub_old_version_create_subscription_with_exactly_once_delivery]
require "google/cloud/pubsub"

# Shows how to create a new subscription with exactly once delivery enabled
class PubsubCreateSubscriptionWithExactlyOnceDelivery
  def create_subscription_with_exactly_once_delivery project_id:, topic_id:, subscription_id:
    pubsub = Google::Cloud::Pubsub.new project_id: project_id
    topic = pubsub.topic topic_id
    subscription = topic.subscribe subscription_id, enable_exactly_once_delivery: true
    puts "Created subscription with exactly once delivery enabled: #{subscription_id}"
  end

  def self.run
    # TODO(developer): Replace these variables before running the sample.
    project_id = "your-project-id"
    topic_id = "your-topic-id"
    subscription_id = "id-for-new-subcription"
    pubsub_old_version_create_subscription_with_exactly_once_delivery = PubsubCreateSubscriptionWithExactlyOnceDelivery.new
    pubsub_old_version_create_subscription_with_exactly_once_delivery.create_subscription_with_exactly_once_delivery(
      project_id: project_id,
      topic_id: topic_id,
      subscription_id: subscription_id
    )
  end
end

if $PROGRAM_NAME == __FILE__
  PubsubCreateSubscriptionWithExactlyOnceDelivery.run
end
# [END pubsub_old_version_create_subscription_with_exactly_once_delivery]
