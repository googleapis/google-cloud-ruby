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

def list_inputs project_id:, location:
  # [START livestream_list_inputs]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location   = "YOUR-INPUT-LOCATION"  # (e.g. "us-central1")

  # Require the Live Stream client library.
  require "google/cloud/video/live_stream"

  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Get the list of inputs.
  response = client.list_inputs parent: parent

  puts "Inputs:"
  # Print out all inputs.
  response.each do |input|
    puts input.name.to_s
  end
  # [END livestream_list_inputs]
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "list_inputs"
    list_inputs(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        list_inputs <location>  List all inputs for a given location

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
