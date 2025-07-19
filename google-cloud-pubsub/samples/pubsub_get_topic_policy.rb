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

def get_topic_policy topic_id:
  # [START pubsub_get_topic_policy]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  policy = pubsub.iam.get_iam_policy resource: pubsub.topic_path(topic_id)

  puts "Topic policy:"
  puts policy.bindings.first.role
  # [END pubsub_get_topic_policy]
end
