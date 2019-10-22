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

# DO NOT EDIT! This is a generated sample ("LongRunningRequestAsync",  "speech_transcribe_async")

# sample-metadata
#   title: Transcribe Audio File using Long Running Operation (Local File) (LRO)
#   description: Transcribe a long audio file using asynchronous speech recognition
#   bundle exec ruby samples/v1/speech_transcribe_async.rb [--local_file_path "resources/brooklyn_bridge.raw"]

require "google/cloud/speech"

# [START speech_transcribe_async]

# Transcribe a long audio file using asynchronous speech recognition
#
# @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_long_running_recognize local_file_path
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # local_file_path = "resources/brooklyn_bridge.raw"

  # The language of the supplied audio
  language_code = "en-US"

  # Sample rate in Hertz of the audio data sent
  sample_rate_hertz = 16000

  # Encoding of audio data sent. This sample sets this explicitly.
  # This field is optional for FLAC and WAV audio formats.
  encoding = :LINEAR16
  config = {
    language_code: language_code,
    sample_rate_hertz: sample_rate_hertz,
    encoding: encoding
  }
  content = File.binread local_file_path
  audio = { content: content }

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
# [END speech_transcribe_async]


require "optparse"

if $PROGRAM_NAME == __FILE__

  local_file_path = "resources/brooklyn_bridge.raw"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_long_running_recognize(local_file_path)
end
