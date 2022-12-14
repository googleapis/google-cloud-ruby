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

# [START videostitcher_update_slate]
require "google/cloud/video/stitcher"

##
# Update a slate
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param slate_id [String] Your slate name (e.g. "my-slate")
# @param slate_uri [String] The URI of an MP4 video with at least one audio track
#                           (e.g. "https://my-slate-uri/test.mp4")
#
def update_slate project_id:, location:, slate_id:, slate_uri:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the slate.
  name = client.slate_path project: project_id, location: location, slate: slate_id

  # Set the update mask.
  update_mask = { paths: ["uri"] }

  # Set the slate fields.
  update_slate = {
    name: name,
    uri: slate_uri
  }

  response = client.update_slate slate: update_slate, update_mask: update_mask

  # Print the slate name.
  puts "Updated slate: #{response.name}"
  puts "Updated uri: #{response.uri}"
end
# [END videostitcher_update_slate]
