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

# [START videostitcher_get_cdn_key]
require "google/cloud/video/stitcher"

##
# Get a CDN key
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param cdn_key_id [String] Your CDN key name (e.g. "my-cdn-key")
#
def get_cdn_key project_id:, location:, cdn_key_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the CDN key.
  name = client.cdn_key_path project: project_id, location: location, cdn_key: cdn_key_id

  # Get the CDN key.
  cdn_key = client.get_cdn_key name: name

  # Print the CDN key name.
  puts "CDN key: #{cdn_key.name}"
end
# [END videostitcher_get_cdn_key]
