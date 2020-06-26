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


def list_intents project_id:
  # [START dialogflow_list_intents]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/dialogflow"

  intents_client = Google::Cloud::Dialogflow.intents
  parent = intents_client.class.agent_path project: project_id

  intents = intents_client.list_intents parent: parent

  intents.each do |intent|
    puts "Intent name:            #{intent.name}"
    puts "Intent display name:    #{intent.display_name}"
    puts "Action:                 #{intent.action}"
    puts "Root followup intent:   #{intent.root_followup_intent_name}"
    puts "Parent followup intent: #{intent.parent_followup_intent_name}"

    puts "Input contexts:"
    intent.input_context_names.each do |input_context_name|
      puts "\tName: #{input_context_name}"
    end

    puts "Output contexts:"
    intent.output_contexts.each do |output_context|
      puts "\tName: #{output_context.name}"
    end
  end
  # [END dialogflow_list_intents]
end

def create_intent project_id:, display_name:, message_text:,
                  training_phrases_parts:
  # [START dialogflow_create_intent]
  # project_id = "Your Google Cloud project ID"
  # display_name = "New Display Name"
  # message_text = "some message text"
  # training_phrases_parts = ["part1", "part2"]

  require "google/cloud/dialogflow"

  intents_client = Google::Cloud::Dialogflow.intents
  parent = intents_client.agent_path project: project_id

  intent = {
    display_name:     display_name,
    messages:         [{ text: { text: [message_text] } }],
    training_phrases: training_phrases_parts.map do |part|
      { parts: [{ text: part }] }
    end
  }
  response = intents_client.create_intent parent: parent, intent: intent

  puts "Intent created"
  puts "Display name: #{response.display_name}"
  puts "Messages:     #{response.messages}"
  # [END dialogflow_create_intent]
end

def delete_intent project_id:, intent_id:
  # [START dialogflow_delete_intent]
  # project_id = "Your Google Cloud project ID"
  # intent_id = "Existing Intent ID"

  require "google/cloud/dialogflow"

  intents_client = Google::Cloud::Dialogflow.intents
  intent_path = intents_client.intent_path project: project_id,
                                           intent:  intent_id

  intents_client.delete_intent name: intent_path

  puts "Deleted Intent: #{intent_id}"
  # [END dialogflow_delete_intent]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    list_intents project_id: project_id
  when "create"
    create_intent project_id:             project_id,
                  display_name:           ARGV.shift,
                  message_text:           ARGV.shift,
                  training_phrases_parts: ARGV
  when "delete"
    delete_intent project_id: project_id,
                  intent_id:  ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby intent_management.rb [commang] [arguments]

      Commands:
        list
          List all intents
        create  <display_name> <message_text> [training_phrase1, [training_phrase2, ...]]
          Create a new intent
        delete  <intent_id>
          Delete an intent

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
