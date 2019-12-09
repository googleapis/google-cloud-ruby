# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_write_bytes_to_file")

# sample-metadata
#   title: Synthesize an .mp3 file with audio saying the provided phrase
#   description: Synthesize an .mp3 file with audio saying the provided phrase
#   bundle exec ruby samples/v1/samplegen_write_bytes_to_file.rb

# Synthesize an .mp3 file with audio saying the provided phrase
def sample_synthesize_speech
  # [START samplegen_write_bytes_to_file]
  # Import client library
  require "google/cloud/text_to_speech"

  # Instantiate a client
  text_to_speech_client = Google::Cloud::TextToSpeech.new version: :v1

  text = "Hello, world!"

  input = { text: text }

  language_code = "en"

  voice = { language_code: language_code }

  audio_encoding = :MP3

  audio_config = { audio_encoding: audio_encoding }

  response = text_to_speech_client.synthesize_speech(input, voice, audio_config)

  puts "Writing the synthsized results to output.mp3"
  File.open("output.mp3", "wb") do |file|
    file.write(response.audio_content)
  end

  # [END samplegen_write_bytes_to_file]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_synthesize_speech
end
