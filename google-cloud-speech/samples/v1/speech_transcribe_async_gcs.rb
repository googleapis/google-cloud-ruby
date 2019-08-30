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

# DO NOT EDIT! This is a generated sample ("LongRunningRequestAsync",  "speech_transcribe_async_gcs")

# sample-metadata
#   title: Transcript Audio File using Long Running Operation (Cloud Storage) (LRO)
#   description: Transcribe long audio file from Cloud Storage using asynchronous speech recognition
#   bundle exec ruby samples/v1/speech_transcribe_async_gcs.rb [--storage_uri "gs://cloud-samples-data/speech/brooklyn_bridge.raw"]

require "google/cloud/speech"

# [START speech_transcribe_async_gcs]

# Transcribe long audio file from Cloud Storage using asynchronous speech recognition
#
# @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
def sample_long_running_recognize storage_uri
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.raw"

  # Sample rate in Hertz of the audio data sent
  sample_rate_hertz = 16000

  # The language of the supplied audio
  language_code = "en-US"

  # Encoding of audio data sent. This sample sets this explicitly.
  # This field is optional for FLAC and WAV audio formats.
  encoding = :LINEAR16
  config = {
    sample_rate_hertz: sample_rate_hertz,
    language_code: language_code,
    encoding: encoding
  }
  audio = { uri: storage_uri }

  # Make the long-running operation request
  operation = speech_client.long_running_recognize(config, audio)

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end
end
# [END speech_transcribe_async_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.raw"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.parse!
  end


  sample_long_running_recognize(storage_uri)
end
