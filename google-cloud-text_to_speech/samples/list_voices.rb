# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def list_voices
  # [START tts_list_voices]
  # Lists the available voices.
  require "google/cloud/text_to_speech"

  client = Google::Cloud::TextToSpeech.text_to_speech

  # Performs the list voices request
  voices = client.list_voices({}).voices

  voices.each do |voice|
    # Display the voice's name. Example: tpc-vocoded
    puts "Name: #{voice.name}"

    # Display the supported language codes for this voice. Example: "en-US"
    voice.language_codes.each do |language_code|
      puts "Supported language: #{language_code}"
    end

    # Display the SSML Voice Gender
    puts "SSML Voice Gender: #{voice.ssml_gender}"

    # Display the natural sample rate hertz for this voice. Example: 24000
    puts "Natural Sample Rate Hertz: #{voice.natural_sample_rate_hertz}\n"
  end
  # [END tts_list_voices]
end

list_voices if $PROGRAM_NAME == __FILE__
