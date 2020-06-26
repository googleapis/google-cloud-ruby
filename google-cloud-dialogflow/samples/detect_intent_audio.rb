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

def detect_intent_audio project_id:, session_id:, audio_file_path:,
                        language_code:
  # [START dialogflow_detect_intent_audio]
  # project_id = "Your Google Cloud project ID"
  # session_id = "mysession"
  # audio_file_path = "resources/book_a_room.wav"
  # language_code = "en-US"

  require "google/cloud/dialogflow"

  session_client = Google::Cloud::Dialogflow.sessions
  session = session_client.session_path project: project_id,
                                        session: session_id
  puts "Session path: #{session}"

  begin
    audio_file = File.open audio_file_path, "rb"
    input_audio = audio_file.read
  ensure
    audio_file.close
  end

  audio_config = {
    audio_encoding:    :AUDIO_ENCODING_LINEAR_16,
    sample_rate_hertz: 16_000,
    language_code:     language_code
  }

  query_input = { audio_config: audio_config }

  response = session_client.detect_intent session:     session,
                                          query_input: query_input,
                                          input_audio: input_audio
  query_result = response.query_result

  puts "Query text:        #{query_result.query_text}"
  puts "Intent detected:   #{query_result.intent.display_name}"
  puts "Intent confidence: #{query_result.intent_detection_confidence}"
  puts "Fulfillment text:  #{query_result.fulfillment_text}"
  # [END dialogflow_detect_intent_audio]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  audio_file_path = ARGV.shift

  if audio_file_path
    detect_intent_audio project_id:      project_id,
                        session_id:      SecureRandom.uuid,
                        audio_file_path: audio_file_path,
                        language_code:   "en-US"
  else
    puts <<~USAGE
      Usage: ruby detect_intent_audio.rb [audio_file_path]

      Example:
        ruby detect_intent_audio.rb resources/book_a_room.wav

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
