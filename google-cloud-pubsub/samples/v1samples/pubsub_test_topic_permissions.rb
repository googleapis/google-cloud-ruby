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

def test_topic_permissions topic_id:
  # [START pubsub_old_version_test_topic_permissions]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic       = pubsub.topic topic_id
  permissions = topic.test_permissions "pubsub.topics.attachSubscription",
                                       "pubsub.topics.publish", "pubsub.topics.update"

  puts "Permission to attach subscription" if permissions.include? "pubsub.topics.attachSubscription"
  puts "Permission to publish" if permissions.include? "pubsub.topics.publish"
  puts "Permission to update" if permissions.include? "pubsub.topics.update"
  # [END pubsub_old_version_test_topic_permissions]
end
