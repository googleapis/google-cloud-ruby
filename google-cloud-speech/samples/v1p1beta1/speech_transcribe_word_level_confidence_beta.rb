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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_word_level_confidence_beta")

# sample-metadata
#   title: Enabling word-level confidence (Local File) (Beta)
#   description: Print confidence level for individual words in a transcription of a short audio file

#   bundle exec ruby samples/v1p1beta1/speech_transcribe_word_level_confidence_beta.rb [--local_file_path "resources/brooklyn_bridge.flac"]

require "google/cloud/speech"

# [START speech_transcribe_word_level_confidence_beta]

# Print confidence level for individual words in a transcription of a short audio file
#
# @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_recognize local_file_path
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # local_file_path = "resources/brooklyn_bridge.flac"

  # When enabled, the first result returned by the API will include a list
  # of words and the confidence level for each of those words.
  enable_word_confidence = true

  # The language of the supplied audio
  language_code = "en-US"
  config = { enable_word_confidence: enable_word_confidence, language_code: language_code }
  content = File.binread local_file_path
  audio = { content: content }

  response = speech_client.recognize(config, audio)
  # The first result includes confidence levels per word
  result = response.results[0]
  # First alternative is the most probable result
  alternative = result.alternatives[0]
  puts "Transcript: #{alternative.transcript}"
  # Print the confidence level of each word
  alternative.words.each do |word|
    puts "Word: #{word.word}"
    puts "Confidence: #{word.confidence}"
  end
end
# [END speech_transcribe_word_level_confidence_beta]


require "optparse"

if $PROGRAM_NAME == __FILE__

  local_file_path = "resources/brooklyn_bridge.flac"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_recognize(local_file_path)
end
