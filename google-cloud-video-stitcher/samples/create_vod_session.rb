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

# [START videostitcher_create_vod_session]
require "google/cloud/video/stitcher"

##
# Create a video on demand (VOD) session. VOD sessions are ephemeral resources
# that expire after a few hours.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param source_uri [String] The URI of an MPEG-DASH manifest (.mpd) file or
#   an M3U playlist manifest (.m3u8) file
#   (e.g. "https://storage.googleapis.com/my-bucket/main.mpd")
# @param ad_tag_uri [String] The URI of the ad tag. See VMAP Pre-roll at
#   https://developers.google.com/interactive-media-ads/docs/sdks/html5/client-side/tags.
#
def create_vod_session project_id:, location:, source_uri:, ad_tag_uri:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Set the session fields.
  new_vod_session = {
    source_uri: source_uri,
    ad_tag_uri: ad_tag_uri
  }

  response = client.create_vod_session parent: parent, vod_session: new_vod_session

  # Print the VOD session name.
  puts "VOD session: #{response.name}"
end
# [END videostitcher_create_vod_session]
