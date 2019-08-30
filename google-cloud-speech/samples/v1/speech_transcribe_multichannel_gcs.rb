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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_multichannel_gcs")

# sample-metadata
#   title: Multi-Channel Audio Transcription (Cloud Storage)
#   description: Transcribe a short audio file from Cloud Storage with multiple channels
#   bundle exec ruby samples/v1/speech_transcribe_multichannel_gcs.rb [--storage_uri "gs://cloud-samples-data/speech/multi.wav"]

require "google/cloud/speech"

# [START speech_transcribe_multichannel_gcs]

# Transcribe a short audio file from Cloud Storage with multiple channels
#
# @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
def sample_recognize storage_uri
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # storage_uri = "gs://cloud-samples-data/speech/multi.wav"

  # The number of channels in the input audio file (optional)
  audio_channel_count = 2

  # When set to true, each audio channel will be recognized separately.
  # The recognition result will contain a channel_tag field to state which
  # channel that result belongs to
  enable_separate_recognition_per_channel = true

  # The language of the supplied audio
  language_code = "en-US"
  config = {
    audio_channel_count: audio_channel_count,
    enable_separate_recognition_per_channel: enable_separate_recognition_per_channel,
    language_code: language_code
  }
  audio = { uri: storage_uri }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # channel_tag to recognize which audio channel this result is for
    puts "Channel tag: #{result.channel_tag}"
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end
end
# [END speech_transcribe_multichannel_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/multi.wav"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.parse!
  end


  sample_recognize(storage_uri)
end
