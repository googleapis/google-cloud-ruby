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

def list_topic_subscriptions topic_id:
  # [START pubsub_list_topic_subscriptions]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  response = topic_admin.list_topic_subscriptions topic: pubsub.topic_path(topic_id)

  puts "Subscriptions in topic #{topic_id}:"
  response.subscriptions.each do |subscription_name|
    puts subscription_name
  end
  # [END pubsub_list_topic_subscriptions]
end
