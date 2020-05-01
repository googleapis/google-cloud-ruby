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


require "securerandom"

def list_contexts project_id:, session_id:
  # [START dialogflow_list_contexts]
  # project_id = "Your Google Cloud project ID"
  # session_id = "Existing Session ID"

  require "google/cloud/dialogflow"

  contexts_client = Google::Cloud::Dialogflow.contexts
  session_path = contexts_client.session_path project: project_id,
                                              session: session_id

  contexts = contexts_client.list_contexts parent: session_path

  puts "Contexts for session #{session_path}:\n\n"
  contexts.each do |context|
    puts "Context name:   #{context.name}"
    puts "Lifespan count: #{context.lifespan_count}"
    next unless context.parameters
    puts "Fields:"
    context.parameters.fields.each do |field, value|
      puts "\t#{field}: #{value.string_value}" if value.string_value
    end
  end
  # [END dialogflow_list_contexts]
end

def create_context project_id:, session_id:, context_id:
  # [START dialogflow_create_context]
  # project_id = "Your Google Cloud project ID"
  # session_id = "Existing Session ID"
  # context_id = "New Context ID"

  require "google/cloud/dialogflow"

  contexts_client = Google::Cloud::Dialogflow.contexts
  session_path = contexts_client.session_path project: project_id,
                                              session: session_id
  context_path = contexts_client.context_path project: project_id,
                                              session: session_id,
                                              context: context_id
  lifespan_count = 1

  context = { name: context_path, lifespan_count: lifespan_count }

  response = contexts_client.create_context parent:  session_path,
                                            context: context

  puts "Context created: #{response.name}"
  # [END dialogflow_create_context]
end

def delete_context project_id:, session_id:, context_id:
  # [START dialogflow_delete_context]
  # project_id = "Your Google Cloud project ID"
  # context_id = "Existing Context ID"

  require "google/cloud/dialogflow"

  contexts_client = Google::Cloud::Dialogflow.contexts
  context_path = contexts_client.context_path project: project_id,
                                              session: session_id,
                                              context: context_id

  contexts_client.delete_context name: context_path

  puts "Deleted Context: #{context_id}"
  # [END dialogflow_delete_context]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    list_contexts project_id: project_id,
                  session_id: ARGV.shift
  when "create"
    create_context project_id: project_id,
                   session_id: ARGV.shift,
                   context_id: SecureRandom.uuid
  when "delete"
    delete_context project_id: project_id,
                   session_id: ARGV.shift,
                   context_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby context_management.rb [commang] [arguments]

      Commands:
        list                              List all contexts
        create  <session_id>              Create a context for a session
        delete  <sessino_id> <context_id> Delete a context

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
