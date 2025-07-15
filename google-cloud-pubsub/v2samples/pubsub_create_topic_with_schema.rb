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

def create_topic_with_schema topic_id:, schema_id:, message_encoding:
  # [START pubsub_old_version_create_topic_with_schema]
  # topic_id = "your-topic-id"
  # schema_id = "your-schema-id"
  # Choose either BINARY or JSON as valid message encoding in this topic.
  # message_encoding = :binary

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.create_topic topic_id, schema_name: schema_id, message_encoding: message_encoding

  puts "Topic #{topic.name} created."
  # [END pubsub_old_version_create_topic_with_schema]
end
