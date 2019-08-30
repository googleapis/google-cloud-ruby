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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_quickstart_beta")

# sample-metadata
#   title: Quickstart Beta
#   description: Performs synchronous speech recognition on an audio file
#   bundle exec ruby samples/v1p1beta1/speech_quickstart_beta.rb [--storage_uri "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"]

require "google/cloud/speech"

# [START speech_quickstart_beta]

# Performs synchronous speech recognition on an audio file
#
# @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
def sample_recognize storage_uri
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"

  # The language of the supplied audio
  language_code = "en-US"

  # Sample rate in Hertz of the audio data sent
  sample_rate_hertz = 44100

  # Encoding of audio data sent. This sample sets this explicitly.
  # This field is optional for FLAC and WAV audio formats.
  encoding = :MP3
  config = {
    language_code: language_code,
    sample_rate_hertz: sample_rate_hertz,
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
# [END speech_quickstart_beta]


require "optparse"

if $PROGRAM_NAME == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.mp3"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.parse!
  end


  sample_recognize(storage_uri)
end
