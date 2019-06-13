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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_model_selection")

# sample-metadata
#   title: Selecting a Transcription Model (Local File)
#   description: Transcribe a short audio file using a specified transcription model
#   bundle exec ruby samples/v1/speech_transcribe_model_selection.rb [--local_file_path "resources/hello.wav"] [--model "phone_call"]

require "google/cloud/speech"

# [START speech_transcribe_model_selection]

# Transcribe a short audio file using a specified transcription model
#
# @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
# @param model {String} The transcription model to use, e.g. video, phone_call, default
# For a list of available transcription models, see:
# https://cloud.google.com/speech-to-text/docs/transcription-model#transcription_models
def sample_recognize local_file_path, model
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # local_file_path = "resources/hello.wav"
  # model = "phone_call"

  # The language of the supplied audio
  language_code = "en-US"
  config = { model: model, language_code: language_code }
  content = File.binread local_file_path
  audio = { content: content }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end
end
# [END speech_transcribe_model_selection]


require "optparse"

if $PROGRAM_NAME == __FILE__

  local_file_path = "resources/hello.wav"
  model = "phone_call"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.on("--model=val") { |val| model = val }
    opts.parse!
  end


  sample_recognize(local_file_path, model)
end
