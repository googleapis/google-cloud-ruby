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

def synthesize_text text:, output_file:
  # [START tts_synthesize_text]
  require "google/cloud/text_to_speech"

  client = Google::Cloud::TextToSpeech.text_to_speech

  input_text = { text: text }

  # Note: the voice can also be specified by name.
  # Names of voices can be retrieved with client.list_voices
  voice = {
    language_code: "en-US",
    ssml_gender:   "FEMALE"
  }

  audio_config = { audio_encoding: "MP3" }

  response = client.synthesize_speech(
    input:        input_text,
    voice:        voice,
    audio_config: audio_config
  )

  # The response's audio_content is binary.
  File.open output_file, "wb" do |file|
    # Write the response to the output file.
    file.write response.audio_content
  end

  puts "Audio content written to file '#{output_file}'"
  # [END tts_synthesize_text]
end

def synthesize_ssml ssml:, output_file:
  # [START tts_synthesize_ssml]
  require "google/cloud/text_to_speech"

  client = Google::Cloud::TextToSpeech.text_to_speech

  input_text = { ssml: ssml }

  # Note: the voice can also be specified by name.
  # Names of voices can be retrieved with client.list_voices
  voice = {
    language_code: "en-US",
    ssml_gender:   "FEMALE"
  }

  audio_config = { audio_encoding: "MP3" }

  response = client.synthesize_speech(
    input:        input_text,
    voice:        voice,
    audio_config: audio_config
  )

  # The response's audio_content is binary.
  File.open output_file, "wb" do |file|
    # Write the response to the output file.
    file.write response.audio_content
  end

  puts "Audio content written to file '#{output_file}'"
  # [END tts_synthesize_ssml]
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift
  text    = ARGV.shift

  if command == "text"
    synthesize_ssml ssml: text
  elsif command == "ssml"
    synthesize_text ssml: text
  else
    puts <<~USAGE
      Usage: ruby synthesize_text.rb (text TEXT | ssml SSML)

      Example:
        ruby synthesize_text.rb text "hello"
        ruby synthesize_text.rb ssml "<speak>Hello there.</speak>"
    USAGE
  end
end
