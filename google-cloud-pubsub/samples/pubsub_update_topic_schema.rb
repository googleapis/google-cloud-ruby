# Copyright 2026 Google LLC
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

# [START pubsub_update_topic_schema]
require "google/cloud/pubsub"

def update_topic_schema topic_id:, first_revision_id:, last_revision_id:
  # topic_id = "your-topic-id"
  # first_revision_id = "your-revision-id"
  # last_revision_id = "your-revision-id"

  pubsub = Google::Cloud::PubSub.new
  topic_admin = pubsub.topic_admin

  schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new(
    first_revision_id: first_revision_id,
    last_revision_id: last_revision_id
  )

  topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
  topic.schema_settings = schema_settings

  topic = topic_admin.update_topic topic: topic,
                                   update_mask: {
                                     paths: [
                                       "schema_settings.first_revision_id",
                                       "schema_settings.last_revision_id"
                                     ]
                                   }

  puts "Updated topic with schema: #{topic.name}"
end
# [END pubsub_update_topic_schema]
