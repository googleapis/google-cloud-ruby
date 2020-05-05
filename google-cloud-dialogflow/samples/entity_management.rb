# Copyright 2020 Google LLC
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


def list_entities project_id:, entity_type_id:
  # [START dialogflow_list_entities]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "Existing Entity Type ID"

  require "google/cloud/dialogflow"

  client = Google::Cloud::Dialogflow.entity_types

  entity_type_path = client.entity_type_path project:     project_id,
                                             entity_type: entity_type_id

  entity_type = client.get_entity_type name: entity_type_path

  entity_type.entities.each do |entity|
    puts "Entity value:    #{entity.value}"
    puts "Entity synonyms: #{entity.synonyms}"
  end
  # [END dialogflow_list_entities]
end

def create_entity project_id:, entity_type_id:, entity_value:, synonyms:
  # [START dialogflow_create_entity]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "Existing Entity Type ID"
  # entity_value = "New Entity Value"
  # synonyms = ["synonym1", "synonym2"]

  require "google/cloud/dialogflow"

  client = Google::Cloud::Dialogflow.entity_types

  entity_type_path = client.entity_type_path project:     project_id,
                                             entity_type: entity_type_id
  entity = { value: entity_value, synonyms: synonyms }

  operation = client.batch_create_entities parent:   entity_type_path,
                                           entities: [entity]

  puts "Waiting for the entity creation operation to complete."
  operation.wait_until_done!

  puts "Entity creation completed."
  # [END dialogflow_create_entity]
end

def delete_entity project_id:, entity_type_id:, entity_value:
  # [START dialogflow_delete_entity]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "Existing Entity Type ID"
  # entity_value = "Existing Entity Value"

  require "google/cloud/dialogflow"

  client = Google::Cloud::Dialogflow.entity_types

  entity_type_path = client.entity_type_path project:     project_id,
                                             entity_type: entity_type_id

  client.batch_delete_entities parent:        entity_type_path,
                               entity_values: [entity_value]

  puts "Deleted Entity: #{entity_value}"
  # [END dialogflow_delete_entity]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    list_entities project_id:     project_id,
                  entity_type_id: ARGV.shift
  when "create"
    create_entity project_id:     project_id,
                  entity_type_id: ARGV.shift,
                  entity_value:   ARGV.shift,
                  synonyms:       ARGV
  when "delete"
    delete_entity project_id:     project_id,
                  entity_type_id: ARGV.shift,
                  entity_value:   ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby entity_management.rb [commang] [arguments]

      Commands:
        list    <entity_type_id>
          List all entities of an entity type
        create  <entity_type_id> <entity_value> [<synonym1> [<synonym2> ...]]
          Create a new entity of an entity type
        delete  <entity_type_id> <entity_value>
          Delete an entity of an entity type

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
