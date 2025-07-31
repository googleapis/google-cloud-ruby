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

def create_proto_schema schema_id:, proto_file:
  # [START pubsub_create_proto_schema]
  # schema_id = "your-schema-id"
  # proto_file = "path/to/a/proto/file/(.proto)/formatted/in/protocol/buffers"

  pubsub = Google::Cloud::PubSub.new
  schemas = pubsub.schemas

  definition = File.read proto_file
  schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id,
                                                 type: :PROTOCOL_BUFFER,
                                                 definition: definition

  schema = schemas.create_schema parent: pubsub.project_path,
                                 schema: schema,
                                 schema_id: schema_id

  puts "Schema #{schema.name} created."
  # [END pubsub_create_proto_schema]
end
