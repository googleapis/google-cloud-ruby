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

# DO NOT EDIT! This is a generated sample ("Request",  "speech_transcribe_model_selection_gcs")

require "google/cloud/speech"

# [START speech_transcribe_model_selection_gcs]

 # Transcribe a short audio file from Cloud Storage using a specified transcription model
 #
 # @param storage_uri {String} URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
 # @param model {String} The transcription model to use, e.g. video, phone_call, default
 # For a list of available transcription models, see:
 # https://cloud.google.com/speech-to-text/docs/transcription-model#transcription_models
def sample_recognize(storage_uri, model)
  # [START speech_transcribe_model_selection_gcs_core]
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1

  # storage_uri = "gs://cloud-samples-data/speech/hello.wav"
  # model = "phone_call"

  # The language of the supplied audio
  language_code = "en-US"
  config = { model: model, language_code: language_code }
  audio = { uri: storage_uri }

  response = speech_client.recognize(config, audio)
  response.results.each do |result|
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
  end

  # [END speech_transcribe_model_selection_gcs_core]
end
# [END speech_transcribe_model_selection_gcs]


require "optparse"

if $0 == __FILE__

  storage_uri = "gs://cloud-samples-data/speech/hello.wav"
  model = "phone_call"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.on("--model=val") { |val| model = val }
    opts.parse!
  end


  sample_recognize(storage_uri, model)
end