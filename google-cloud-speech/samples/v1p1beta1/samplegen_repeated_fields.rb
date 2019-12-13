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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_repeated_fields")

# sample-metadata
#   title: Showing repeated fields (in request and response)
#   description: Showing repeated fields (in request and response)
#   bundle exec ruby samples/v1p1beta1/samplegen_repeated_fields.rb

# Showing repeated fields (in request and response)
def sample_recognize
  # [START samplegen_repeated_fields]
  # Import client library
  require "google/cloud/speech"

  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  encoding = :MP3

  # A list of strings containing words and phrases "hints"
  phrases_element = "Fox in socks"

  phrases_element_2 = "Knox in box"

  phrases = [phrases_element, phrases_element_2]

  speech_contexts_element = { phrases: phrases }

  speech_contexts = [speech_contexts_element]

  config = { encoding: encoding, speech_contexts: speech_contexts }

  uri = "gs://[BUCKET]/[FILENAME]"

  audio = { uri: uri }

  response = speech_client.recognize(config, audio)


  # Loop over all transcription results
  response.results.each do |result|

    # The first "alternative" of each result contains most likely transcription
    alternative = result.alternatives[0]
    puts "Transcription of result: #{alternative.transcript}"
  end
  # [END samplegen_repeated_fields]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_recognize
end
