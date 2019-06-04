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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_multilanguage_beta")

require "google/cloud/speech"

# [START speech_transcribe_multilanguage_beta]

 # Transcribe a short audio file with language detected from a list of possible languages
 #
 # @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_recognize(local_file_path)
  # [START speech_transcribe_multilanguage_beta_core]
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # local_file_path = "resources/brooklyn_bridge.flac"

  # The language of the supplied audio. Even though additional languages are
  # provided by alternative_language_codes, a primary language is still required.
  language_code = "fr"

  # Specify up to 3 additional languages as possible alternative languages of the supplied audio.
  alternative_language_codes_element = "es"
  alternative_language_codes_element_2 = "en"
  alternative_language_codes = [alternative_language_codes_element, alternative_language_codes_element_2]
  config = { language_code: language_code, alternative_language_codes: alternative_language_codes }
  content = File.binread local_file_path
  audio = { content: content }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # The language_code which was detected as the most likely being spoken in the audio
    puts "Detected language: #{result.language_code}"
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end

  # [END speech_transcribe_multilanguage_beta_core]
end
# [END speech_transcribe_multilanguage_beta]


require "optparse"

if $0 == __FILE__

  local_file_path = "resources/brooklyn_bridge.flac"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_recognize(local_file_path)
end