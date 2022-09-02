# Copyright 2022 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def update_input project_id:, location:, input_id:
  # [START livestream_update_input]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location    = "YOUR-INPUT-LOCATION"  # (e.g. "us-central1")
  # input_id    = "YOUR-INPUT"  # (e.g. "my-input")

  # Require the Live Stream client library.
  require "google/cloud/video/live_stream"

  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the input.
  name = client.input_path project: project_id, location: location, input: input_id

  # Set the update mask.
  update_mask = { paths: ["preprocessing_config"] }

  # Update the input pre-processing config field.
  update_input = {
    name: name,
    preprocessing_config: {
      crop: {
        top_pixels: 5,
        bottom_pixels: 5
      }
    }
  }

  operation = client.update_input update_mask: update_mask, input: update_input

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the input name.
  puts "Updated input: #{operation.response.name}"
  # [END livestream_update_input]

  operation.response
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "update_input"
    update_input(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      input_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        update_input <location> <input_id> Updates an input with a cropping config

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
