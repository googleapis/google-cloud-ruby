# Copyright 2021 Google, Inc
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

def quickstart topic_id:
  # [START pubsub_quickstart_create_topic]
  # [START require_library]
  # Imports the Google Cloud client library
  require "google/cloud/pubsub"
  # [END require_library]

  # Instantiates a client
  pubsub = Google::Cloud::Pubsub.new
  topic_admin = pubsub.topic_admin

  # The name for the new topic
  # topic_id = "your-topic-id"

  # Creates the new topic
  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id)

  puts "Topic #{topic.name} created."
  # [END pubsub_quickstart_create_topic]
end

quickstart topic_id: ARGV.shift if $PROGRAM_NAME == __FILE__
