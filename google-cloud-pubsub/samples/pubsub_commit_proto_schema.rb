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

  pubsub = Google::Cloud::Pubsub.new
  schema = pubsub.schema schema_id

  definition = File.read proto_file

  result = schema.commit definition, :protocol_buffer

  puts "Schema commited with revision #{result.revision_id}."
  # [END pubsub_commit_proto_schema]
end
