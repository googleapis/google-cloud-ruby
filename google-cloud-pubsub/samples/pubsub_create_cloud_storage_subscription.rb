# Copyright 2025 Google LLC
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

def create_cloud_storage_subscription topic_id:, subscription_id:, bucket:
  # [START pubsub_create_cloud_storage_subscription]
  # topic_id        = "your-topic-id"
  # subscription_id = "your-subscription-id"
  # bucket = "your-bucket"

  pubsub = Google::Cloud::Pubsub.new
  subscription_admin = pubsub.subscription_admin

  subscription = subscription_admin.create_subscription \
    name: pubsub.subscription_path(subscription_id),
    topic: pubsub.topic_path(topic_id),
    cloud_storage_config: {
      bucket: bucket
    }

  puts "Cloud storage subscription #{subscription_id} created."
  # [END pubsub_create_cloud_storage_subscription]
end
