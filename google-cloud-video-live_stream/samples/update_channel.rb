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

# [START livestream_update_channel]
require "google/cloud/video/live_stream"

##
# Update a channel
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param channel_id [String] Your channel name (e.g. "my-channel")
# @param input_id [String] The input name to update the channel with (e.g. "my-updated-input")
#
def update_channel project_id:, location:, channel_id:, input_id:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the channel.
  name = client.channel_path project: project_id, location: location, channel: channel_id

  # Build the resource name of the input.
  input = client.input_path project: project_id, location: location, input: input_id

  # Set the update mask.
  update_mask = { paths: ["input_attachments"] }

  # Update the channel input_attachments config field.
  update_channel = {
    name: name,
    input_attachments: [
      {
        key: "updated-input",
        input: input
      }
    ]
  }

  operation = client.update_channel update_mask: update_mask, channel: update_channel

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the channel name.
  puts "Updated channel: #{operation.response.name}"
  puts "Updated input_attachments config: #{operation.response.input_attachments[0].key}"
end
# [END livestream_update_channel]
