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

# [START tts_quickstart]
# Synthesizes speech from the input string of text or ssml.
# Note: ssml must be well-formed according to:
# https://www.w3.org/TR/speech-synthesis/

require "google/cloud/text_to_speech"

# Instantiates a client
client = Google::Cloud::TextToSpeech.text_to_speech

# Set the text input to be synthesized
synthesis_input = { text: "Hello, World!" }

# Build the voice request, select the language code ("en-US") and the ssml
# voice gender ("neutral")
voice = {
  language_code: "en-US",
  ssml_gender:   "NEUTRAL"
}

# Select the type of audio file you want returned
audio_config = { audio_encoding: "MP3" }

# Perform the text-to-speech request on the text input with the selected
# voice parameters and audio file type
response = client.synthesize_speech(
  input:        synthesis_input,
  voice:        voice,
  audio_config: audio_config
)

# The response's audio_content is binary.
File.open "output.mp3", "wb" do |file|
  # Write the response to the output file.
  file.write response.audio_content
end

puts "Audio content written to file 'output.mp3'"
# [END tts_quickstart]
