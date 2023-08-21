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

def create_avro_schema schema_id:, avsc_file:
  # [START pubsub_create_avro_schema]
  # schema_id = "your-schema-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"

  pubsub = Google::Cloud::Pubsub.new

  definition = File.read avsc_file
  schema = pubsub.create_schema schema_id, :avro, definition

  puts "Schema #{schema.name} created."
  # [END pubsub_create_avro_schema]
end
