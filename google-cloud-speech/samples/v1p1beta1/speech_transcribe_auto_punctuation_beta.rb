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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_auto_punctuation_beta")

require "google/cloud/speech"

# [START speech_transcribe_auto_punctuation_beta]

 # Transcribe a short audio file with punctuation
 #
 # @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_recognize(local_file_path)
  # [START speech_transcribe_auto_punctuation_beta_core]
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # local_file_path = "resources/commercial_mono.wav"

  # When enabled, trascription results may include punctuation (available for select languages).
  enable_automatic_punctuation = true

  # The language of the supplied audio. Even though additional languages are
  # provided by alternative_language_codes, a primary language is still required.
  language_code = "en-US"
  config = { enable_automatic_punctuation: enable_automatic_punctuation, language_code: language_code }
  content = File.binread local_file_path
  audio = { content: content }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end

  # [END speech_transcribe_auto_punctuation_beta_core]
end
# [END speech_transcribe_auto_punctuation_beta]


require "optparse"

if $0 == __FILE__

  local_file_path = "resources/commercial_mono.wav"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_recognize(local_file_path)
end