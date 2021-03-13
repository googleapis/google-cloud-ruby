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

require "google/cloud/pubsub"

def create_avro_schema schema_id:, avsc_file:
  # [START pubsub_create_avro_schema]
  # schema_id = "your-schema-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  definition = File.read avsc_file
  schema = pubsub.create_schema schema_id, :avro, definition

  puts "Schema #{schema.name} created."
  # [END pubsub_create_avro_schema]
end

def create_proto_schema schema_id:, proto_file:
  # [START pubsub_create_proto_schema]
  # schema_id = "your-schema-id"
  # proto_file = "path/to/a/proto/file/(.proto)/formatted/in/protocol/buffers"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  definition = File.read proto_file
  schema = pubsub.create_schema schema_id, :protocol_buffer, definition

  puts "Schema #{schema.name} created."
  # [END pubsub_create_proto_schema]
end

def get_schema schema_id:
  # [START pubsub_get_schema]
  # schema_id = "your-schema-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schema = pubsub.schema schema_id

  puts "Schema #{schema.name} retrieved."
  # [END pubsub_get_schema]
end

def list_schemas
  # [START pubsub_list_schemas]
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schemas = pubsub.schemas

  puts "Schemas in project:"
  schemas.each do |schema|
    puts schema.name
  end
  # [END pubsub_list_schemas]
end

def delete_schema schema_id:
  # [START pubsub_delete_schema]
  # schema_id = "your-schema-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schema = pubsub.schema schema_id
  schema.delete

  puts "Schema #{schema_id} deleted."
  # [END pubsub_delete_schema]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_avro_schema"
    create_avro_schema schema_id: ARGV.shift, avsc_file: ARGV.shift
  when "create_proto_schema"
    create_proto_schema schema_id: ARGV.shift, proto_file: ARGV.shift
  when "get_schema"
    get_schema schema_id: ARGV.shift
  when "list_schemas"
    list_schemas
  when "delete_schema"
    delete_schema schema_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby schemas.rb [command] [arguments]

      Commands:
        create_avro_schema  <schema_id> Create an AVRO schema
        create_proto_schema <schema_id> Create a protobufa schema
        get_schema          <schema_id> Get a schema
        list_schemas                    List schemas in a project
        delete_schema       <schema_id> Delete a schema
    USAGE
  end
end
