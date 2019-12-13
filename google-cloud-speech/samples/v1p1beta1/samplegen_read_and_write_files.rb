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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_read_and_write_files")

# sample-metadata
#   title: Read binary file into bytes field & write string in response to file
#   description: Read binary file into bytes field & write string in response to file
#   bundle exec ruby samples/v1p1beta1/samplegen_read_and_write_files.rb

# Read binary file into bytes field & write string in response to file
def sample_recognize
  # [START samplegen_read_and_write_files]
  # Import client library
  require "google/cloud/speech"

  # Instantiate a client
  speech_client = Google::Cloud::Speech.new version: :v1p1beta1

  encoding = :MP3

  config = { encoding: encoding }

  # The bytes from this file will be read into `content`
  content = File.binread "path/to/file.mp3"

  audio = { content: content }

  response = speech_client.recognize(config, audio)


  # Your audio has been transcribed.

  # Writing audio transcript to transcript.txt for demonstration:
  File.write "transcript.txt", response.results[0].alternatives[0].transcript

  # [END samplegen_read_and_write_files]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_recognize
end
