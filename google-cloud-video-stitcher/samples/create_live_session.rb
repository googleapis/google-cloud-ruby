# Copyright 2022 Google LLC
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

# [START videostitcher_create_live_session]
require "google/cloud/video/stitcher"

##
# Create a live stream session. Live sessions are ephemeral resources
# that expire after a few minutes.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param live_config_id [String] Your live config name (e.g. "my-live-config")
#
def create_live_session project_id:, location:, live_config_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Build the resource name of the live config.
  live_config_name = client.live_config_path project: project_id,
                                             location: location,
                                             live_config: live_config_id

  # Set the session fields.
  new_live_session = {
    live_config: live_config_name
  }

  response = client.create_live_session parent: parent,
                                        live_session: new_live_session

  # Print the live session name.
  puts "Live session: #{response.name}"
end
# [END videostitcher_create_live_session]
