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

# [START pubsub_rollback_schema]
require "google/cloud/pubsub"

def rollback_schema project_id:, schema_id:, revision_id:
  # project_id = "your-project-id"
  # schema_id = "your-schema-id"
  # revision_id = "your-revision-id"

  pubsub = Google::Cloud::PubSub.new project_id: project_id
  schema_client = pubsub.schemas

  schema_path = schema_client.schema_path project: project_id, schema: schema_id

  begin
    response = schema_client.rollback_schema name: schema_path,
                                             revision_id: revision_id
    puts "Rolled back schema: #{response.name}"
    puts "New revision ID: #{response.revision_id}"
  rescue Google::Cloud::NotFoundError => e
    puts "Schema #{schema_id} not found."
  end
end
# [END pubsub_rollback_schema]
