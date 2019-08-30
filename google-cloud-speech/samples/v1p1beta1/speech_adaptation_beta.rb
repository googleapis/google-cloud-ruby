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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_adaptation_beta")

# sample-metadata
#   title: Speech Adaptation (Cloud Storage)
#   description: Transcribe a short audio file with speech adaptation.
#   bundle exec ruby samples/v1p1beta1/speech_adaptation_beta.rb [--storage_uri "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"] [--phrase "Brooklyn Bridge"]

require "google/cloud/speech"

# [START speech_adaptation_beta]

# Transcribe a short audio file with speech adaptation.
#
# @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
# @param phrase {String} Phrase "hints" help recognize the specified phrases from your audio.
def sample_recognize storage_uri, phrase
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"
  # phrase = "Brooklyn Bridge"
  phrases = [phrase]

  # Hint Boost. This value increases the probability that a specific
  # phrase will be recognized over other similar sounding phrases.
  # The higher the boost, the higher the chance of false positive
  # recognition as well. Can accept wide range of positive values.
  # Most use cases are best served with values between 0 and 20.
  # Using a binary search happroach may help you find the optimal value.
  boost = 20.0
  speech_contexts_element = { phrases: phrases, boost: boost }
  speech_contexts = [speech_contexts_element]

  # Sample rate in Hertz of the audio data sent
  sample_rate_hertz = 44100

  # The language of the supplied audio
  language_code = "en-US"

  # Encoding of audio data sent. This sample sets this explicitly.
  # This field is optional for FLAC and WAV audio formats.
  encoding = :MP3
  config = {
    speech_contexts: speech_contexts,
    sample_rate_hertz: sample_rate_hertz,
    language_code: language_code,
    encoding: encoding
  }
  audio = { uri: storage_uri }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end
end
# [END speech_adaptation_beta]


require "optparse"

if $PROGRAM_NAME == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"
  phrase = "Brooklyn Bridge"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.on("--phrase=val") { |val| phrase = val }
    opts.parse!
  end


  sample_recognize(storage_uri, phrase)
end
