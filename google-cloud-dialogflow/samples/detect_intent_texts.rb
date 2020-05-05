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

def detect_intent_texts project_id:, session_id:, texts:, language_code:
  # [START dialogflow_detect_intent_text]
  # project_id = "Your Google Cloud project ID"
  # session_id = "mysession"
  # texts = ["hello", "book a meeting room"]
  # language_code = "en-US"

  require "google/cloud/dialogflow"

  session_client = Google::Cloud::Dialogflow.sessions
  session = session_client.session_path project: project_id,
                                        session: session_id
  puts "Session path: #{session}"

  texts.each do |text|
    query_input = { text: { text: text, language_code: language_code } }
    response = session_client.detect_intent session:     session,
                                            query_input: query_input
    query_result = response.query_result

    puts "Query text:        #{query_result.query_text}"
    puts "Intent detected:   #{query_result.intent.display_name}"
    puts "Intent confidence: #{query_result.intent_detection_confidence}"
    puts "Fulfillment text:  #{query_result.fulfillment_text}\n"
  end
  # [END dialogflow_detect_intent_text]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  texts = ARGV

  if texts.any?
    detect_intent_texts project_id:    project_id,
                        session_id:    SecureRandom.uuid,
                        texts:         texts,
                        language_code: "en-US"
  else
    puts <<~USAGE
      Usage: ruby detect_intent_texts.rb [texts]

      Example:
        ruby detect_intent_texts.rb "hello" "book a meeting room" "Mountain View"

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
