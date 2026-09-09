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

# [START livestream_create_channel_event]
require "google/cloud/video/live_stream"

##
# Create a channel event
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param channel_id [String] Your channel name (e.g. "my-channel")
# @param event_id [String] Your event name (e.g. "my-event")
#
def create_channel_event project_id:, location:, channel_id:, event_id:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.channel_path project: project_id, location: location, channel: channel_id

  # Set the event fields.
  new_event = {
    ad_break: {
      duration: {
        seconds: 100
      }
    },
    execute_now: true
  }

  response = client.create_event parent: parent, event: new_event, event_id: event_id

  # Print the channel event name.
  puts "Channel event: #{response.name}"
end
# [END livestream_create_channel_event]
