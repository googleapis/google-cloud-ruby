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

# [START livestream_list_channel_events]
require "google/cloud/video/live_stream"

##
# List the channel events
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param channel_id [String] Your channel name (e.g. "my-channel")
#
def list_channel_events project_id:, location:, channel_id:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.channel_path project: project_id, location: location, channel: channel_id

  # Get the list of channel events.
  response = client.list_events parent: parent

  puts "Channel events:"
  # Print out all channel events.
  response.each do |event|
    puts event.name
  end
end
# [END livestream_list_channel_events]
