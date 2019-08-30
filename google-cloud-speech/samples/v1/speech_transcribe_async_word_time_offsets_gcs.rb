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

# DO NOT EDIT! This is a generated sample ("LongRunningRequestAsync",  "speech_transcribe_async_word_time_offsets_gcs")

# sample-metadata
#   title: Getting word timestamps (Cloud Storage) (LRO)
#   description: Print start and end time of each word spoken in audio file from Cloud Storage
#   bundle exec ruby samples/v1/speech_transcribe_async_word_time_offsets_gcs.rb [--storage_uri "gs://cloud-samples-data/speech/brooklyn_bridge.flac"]

require "google/cloud/speech"

# [START speech_transcribe_async_word_time_offsets_gcs]

# Print start and end time of each word spoken in audio file from Cloud Storage
#
# @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
def sample_long_running_recognize storage_uri
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.flac"

  # When enabled, the first result returned by the API will include a list
  # of words and the start and end time offsets (timestamps) for those words.
  enable_word_time_offsets = true

  # The language of the supplied audio
  language_code = "en-US"
  config = { enable_word_time_offsets: enable_word_time_offsets, language_code: language_code }
  audio = { uri: storage_uri }

  # Make the long-running operation request
  operation = speech_client.long_running_recognize(config, audio)

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  # The first result includes start and end time word offsets
  result = response.results[0]
  # First alternative is the most probable result
  alternative = result.alternatives[0]
  puts "Transcript: #{alternative.transcript}"
  # Print the start and end time of each word
  alternative.words.each do |word|
    puts "Word: #{word.word}"
    puts "Start time: #{word.start_time.seconds} seconds #{word.start_time.nanos} nanos"
    puts "End time: #{word.end_time.seconds} seconds #{word.end_time.nanos} nanos"
  end
end
# [END speech_transcribe_async_word_time_offsets_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/brooklyn_bridge.flac"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.parse!
  end


  sample_long_running_recognize(storage_uri)
end
