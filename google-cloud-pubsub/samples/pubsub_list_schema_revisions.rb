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

def list_schema_revisions schema_id:
  # [START pubsub_list_schema_revisions]
  # schema_id = "your-schema-id"

  pubsub = Google::Cloud::Pubsub.new

  schema = pubsub.schema schema_id

  response = schema.list_revisions

  puts "Listed revisions of schema #{schema_id}"
  response.each do |revision_schema|
    puts revision_schema.revision_id
  end
  # [END pubsub_list_schema_revisions]
end
