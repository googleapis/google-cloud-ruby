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

def commit_proto_schema schema_id:, proto_file:
  # [START pubsub_commit_proto_schema]
  # schema_id = "your-schema-id"
  # proto_file = "path/to/a/proto_file.proto"

  pubsub = Google::Cloud::PubSub.new

  schemas = pubsub.schemas

  schema = schemas.get_schema name: pubsub.schema_path(schema_id)

  definition = File.read proto_file

  schema.definition = definition

  result = schemas.commit_schema name: schema.name,
                                 schema: schema

  puts "Schema commited with revision #{result.revision_id}."
  result
  # [END pubsub_commit_proto_schema]
end
