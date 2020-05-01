# Copyright 2020 Google, Inc
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

def quickstart
  # [START speech_quickstart]
  # Imports the Google Cloud client library
  # [START speech_ruby_migration_import]
  require "google/cloud/speech"
  # [END speech_ruby_migration_import]

  # Instantiates a client
  # [START speech_ruby_migration_client]
  speech = Google::Cloud::Speech.speech
  # [END speech_ruby_migration_client]

  # The name of the audio file to transcribe
  file_name = "./resources/brooklyn_bridge.raw"

  # [START speech_ruby_migration_sync_request]
  # [START speech_ruby_migration_config]
  # The raw audio
  audio_file = File.binread file_name

  # The audio file's encoding and sample rate
  config = { encoding:          :LINEAR16,
             sample_rate_hertz: 16_000,
             language_code:     "en-US" }
  audio  = { content: audio_file }

  # Detects speech in the audio file
  response = speech.recognize config: config, audio: audio
  # [END speech_ruby_migration_config]

  results = response.results
  # [END speech_ruby_migration_sync_request]

  # Get first result because we only processed a single audio file
  # Each result represents a consecutive portion of the audio
  results.first.alternatives.each do |alternatives|
    puts "Transcription: #{alternatives.transcript}"
  end
  # [END speech_quickstart]
end
