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

# [START livestream_list_channels]
require "google/cloud/video/live_stream"

##
# List the channels
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
#
def list_channels project_id:, location:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Get the list of channels.
  response = client.list_channels parent: parent

  puts "Channels:"
  # Print out all channels.
  response.each do |channel|
    puts channel.name
  end
end
# [END livestream_list_channels]
