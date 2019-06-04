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

# DO NOT EDIT! This is a generated sample ("LongRunningRequestAsync",  "speech_transcribe_diarization_beta")

require "google/cloud/speech"

# [START speech_transcribe_diarization_beta]

 # Print confidence level for individual words in a transcription of a short audio file
 # Separating different speakers in an audio file recording
 #
 # @param local_file_path {String} Path to local audio file, e.g. /path/audio.wav
def sample_long_running_recognize(local_file_path)
  # [START speech_transcribe_diarization_beta_core]
  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  # local_file_path = "resources/commercial_mono.wav"

  # If enabled, each word in the first alternative of each result will be
  # tagged with a speaker tag to identify the speaker.
  enable_speaker_diarization = true

  # Optional. Specifies the estimated number of speakers in the conversation.
  diarization_speaker_count = 2

  # The language of the supplied audio
  language_code = "en-US"
  config = {
    enable_speaker_diarization: enable_speaker_diarization,
    diarization_speaker_count: diarization_speaker_count,
    language_code: language_code
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
    # First alternative has words tagged with speakers
    alternative = result.alternatives[0]
    puts "Transcript: #{alternative.transcript}"
    # Print the speaker_tag of each word
    alternative.words.each do |word|
      puts "Word: #{word.word}"
      puts "Speaker tag: #{word.speaker_tag}"
    end
  end

  # [END speech_transcribe_diarization_beta_core]
end
# [END speech_transcribe_diarization_beta]


require "optparse"

if $0 == __FILE__

  local_file_path = "resources/commercial_mono.wav"

  ARGV.options do |opts|
    opts.on("--local_file_path=val") { |val| local_file_path = val }
    opts.parse!
  end


  sample_long_running_recognize(local_file_path)
end