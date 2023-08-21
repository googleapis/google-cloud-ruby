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

# [START videostitcher_get_vod_session]
require "google/cloud/video/stitcher"

##
# Get a VOD session. VOD sessions are ephemeral resources that expire
# after a few hours.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param session_id [String] The VOD session ID (e.g. "my-vod-session-id")
#
def get_vod_session project_id:, location:, session_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the VOD session.
  name = client.vod_session_path project: project_id, location: location,
                                 vod_session: session_id

  # Get the VOD session.
  session = client.get_vod_session name: name

  # Print the VOD session name.
  puts "VOD session: #{session.name}"
end
# [END videostitcher_get_vod_session]
