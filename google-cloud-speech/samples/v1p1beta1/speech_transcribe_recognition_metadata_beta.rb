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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_recognition_metadata_beta")

# sample-metadata
#   title: Adding recognition metadata (Local File) (Beta)
#   description: Adds additional details short audio file included in this recognition request 

#   bundle exec ruby samples/v1p1beta1/speech_transcribe_recognition_metadata_beta.rb [--local_file_path "resources/commercial_mono.wav"]

require "google/cloud/speech"

# [START speech_transcribe_recognition_metadata_beta]

# Adds additional details short audio file included in this recognition request
#
# @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_recognize local_file_path
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # local_file_path = "resources/commercial_mono.wav"

  # The use case of the audio, e.g. PHONE_CALL, DISCUSSION, PRESENTATION, et al.
  interaction_type = :VOICE_SEARCH

  # The kind of device used to capture the audio
  recording_device_type = :SMARTPHONE

  # The device used to make the recording.
  # Arbitrary string, e.g. 'Pixel XL', 'VoIP', 'Cardioid Microphone', or other value.
  recording_device_name = "Pixel 3"
  metadata = {
    interaction_type: interaction_type,
    recording_device_type: recording_device_type,
    recording_device_name: recording_device_name
  }

  # The language of the supplied audio. Even though additional languages are
  # provided by alternative_language_codes, a primary language is still required.
  language_code = "en-US"
  config = { metadata: metadata, language_code: language_code }
  content = File.binread local_file_path
  audio = { content: content }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end
end
# [END speech_transcribe_recognition_metadata_beta]


require "optparse"

if $PROGRAM_NAME == __FILE__

  local_file_path = "resources/commercial_mono.wav"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_recognize(local_file_path)
end
