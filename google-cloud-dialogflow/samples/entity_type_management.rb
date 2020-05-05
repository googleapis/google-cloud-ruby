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


def list_entity_types project_id:
  # [START dialogflow_list_entity_types]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow.entity_types
  parent = entity_types_client.agent_path project: project_id

  entity_types = entity_types_client.list_entity_types parent: parent

  entity_types.each do |entity_type|
    puts "Entity type name:         #{entity_type.name}"
    puts "Entity type display name: #{entity_type.display_name}"
    puts "Number of entities:       #{entity_type.entities.size}"
  end
  # [END dialogflow_list_entity_types]
end

def create_entity_type project_id:, display_name:, kind:
  # [START dialogflow_create_entity_type]
  # project_id = "Your Google Cloud project ID"
  # display_name = "New Display Name"
  # kind = :KIND_LIST

  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow.entity_types
  parent = entity_types_client.agent_path project: project_id

  entity_type = { display_name: display_name, kind: kind }
  response = entity_types_client.create_entity_type parent:      parent,
                                                    entity_type: entity_type

  puts "Entity type created with display name: #{response.display_name}"
  # [END dialogflow_create_entity_type]
end

def delete_entity_type project_id:, entity_type_id:
  # [START dialogflow_delete_entity_type]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "Existing Entity Type ID"

  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow.entity_types
  entity_type_path =
    entity_types_client.entity_type_path project:     project_id,
                                         entity_type: entity_type_id

  entity_types_client.delete_entity_type name: entity_type_path

  puts "Deleted Entity type: #{entity_type_id}"
  # [END dialogflow_delete_entity_type]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    list_entity_types project_id: project_id
  when "create"
    create_entity_type project_id:   project_id,
                       display_name: ARGV.shift,
                       kind:         (ARGV.shift || "KIND_MAP").to_sym
  when "delete"
    delete_entity_type project_id:     project_id,
                       entity_type_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby entity_type_management.rb [commang] [arguments]

      Commands:
        list                                           List all entitiy types
        create  <display_name> [KIND_MAP or KIND_LIST] Create a new entity type
        delete  <entity_type_id>                       Delete an entity type

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
