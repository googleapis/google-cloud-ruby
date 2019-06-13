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
#   title:
#   description: Performs synchronous speech recognition with speech adaptation.
#   bundle exec ruby samples/v1p1beta1/speech_adaptation_beta.rb [--sample_rate_hertz 44100] [--language_code "en-US"] [--phrase "Brooklyn Bridge"] [--boost 20] [--uri_path "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"]

require "google/cloud/speech"

# [START speech_adaptation_beta]

# Performs synchronous speech recognition with speech adaptation.
#
# @param sample_rate_hertz {Integer} Sample rate in Hertz of the audio data sent in all
# `RecognitionAudio` messages. Valid values are: 8000-48000.
# @param language_code {String} The language of the supplied audio.
# @param phrase {String} Phrase "hints" help Speech-to-Text API recognize the specified phrases from
# your audio data.
# @param boost {Float} Positive value will increase the probability that a specific phrase will be
# recognized over other similar sounding phrases.
# @param uri_path {String} Path to the audio file stored on GCS.
def sample_recognize sample_rate_hertz, language_code, phrase, boost, uri_path
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # sample_rate_hertz = 44100
  # language_code = "en-US"
  # phrase = "Brooklyn Bridge"
  # boost = 20
  # uri_path = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"
  encoding = :MP3
  phrases = [phrase]
  speech_contexts_element = { phrases: phrases, boost: boost }
  speech_contexts = [speech_contexts_element]
  config = {
    encoding: encoding,
    sample_rate_hertz: sample_rate_hertz,
    language_code: language_code,
    speech_contexts: speech_contexts
  }
  audio = { uri: uri_path }

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

  sample_rate_hertz = 44100
  language_code = "en-US"
  phrase = "Brooklyn Bridge"
  boost = 20
  uri_path = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"

  ARGV.options do |opts|
    opts.on("--sample_rate_hertz=val") { |val| sample_rate_hertz = val }
    opts.on("--language_code=val") { |val| language_code = val }
    opts.on("--phrase=val") { |val| phrase = val }
    opts.on("--boost=val") { |val| boost = val }
    opts.on("--uri_path=val") { |val| uri_path = val }
    opts.parse!
  end


  sample_recognize(sample_rate_hertz, language_code, phrase, boost, uri_path)
end
