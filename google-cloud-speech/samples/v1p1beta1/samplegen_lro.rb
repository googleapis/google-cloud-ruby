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

# DO NOT EDIT! This is a generated sample ("LongRunningRequestAsync",  "samplegen_lro")

# sample-metadata
#   title: Calling Long-Running API method
#   description: Calling Long-Running API method
#   bundle exec ruby samples/v1p1beta1/samplegen_lro.rb

# Calling Long-Running API method
def sample_long_running_recognize
  # [START samplegen_lro]
  # Import client library
  require "google/cloud/speech"

  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  encoding = :MP3

  config = { encoding: encoding }

  uri = "gs://[BUCKET]/[FILENAME]"

  audio = { uri: uri }

  # Make the long-running operation request
  operation = speech_client.long_running_recognize(config, audio)

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  # Your audio has been transcribed.
  puts "Transcript: #{response.results[0].alternatives[0].transcript}"
  # [END samplegen_lro]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_long_running_recognize
end
