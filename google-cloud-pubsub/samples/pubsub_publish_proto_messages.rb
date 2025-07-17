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
require_relative "utilities/us-states_pb"

def publish_proto_messages topic_id:
  # [START pubsub_publish_proto_messages]
  # topic_id = "your-topic-id"

  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  publisher = pubsub.publisher topic_id

  topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)

  encoding = topic.schema_settings.encoding

  state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"

  case encoding
  when :BINARY
    publisher.publish Utilities::StateProto.encode(state)
    puts "Published binary-encoded protobuf message."
  when :JSON
    publisher.publish Utilities::StateProto.encode_json(state)
    puts "Published JSON-encoded protobuf message."
  else
    raise "No encoding specified in #{topic.name}."
  end
  # [END pubsub_publish_proto_messages]
end
