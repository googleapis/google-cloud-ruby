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

def commit_avro_schema schema_id:, avsc_file:
  # [START pubsub_commit_avro_schema]
  # schema_id = "your-schema-id"
  # avsc_file = "path/to/a/avsc_file.avsc"

  pubsub = Google::Cloud::Pubsub.new

  schemas = pubsub.schemas

  schema = schemas.get_schema name: pubsub.schema_path(schema_id)

  definition = File.read avsc_file

  schema.definition = definition

  result = schemas.commit_schema name: schema.name,
                                 schema: schema

  puts "Schema commited with revision #{result.revision_id}."
  result
  # [END pubsub_commit_avro_schema]
end
