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

# [START videostitcher_update_cdn_key]
require "google/cloud/video/stitcher"

##
# Update a Media CDN or Cloud CDN key
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param cdn_key_id [String] The user-defined CDN key ID
# @param hostname [String] The hostname to which this CDN key applies
# @param key_name [String] For a Media CDN key, this is the keyset name.
#   For a Cloud CDN key, this is the public name of the CDN key.
# @param private_key [String] For a Media CDN key, this is a 64-byte Ed25519 private
#   key encoded as a base64-encoded string. See
#   https://cloud.google.com/video-stitcher/docs/how-to/managing-cdn-keys#create-private-key-media-cdn
#   for more information. For a Cloud CDN key, this is a base64-encoded string secret.
# @param is_media_cdn [Boolean] If true, update a Media CDN key. If false, update a Cloud CDN key.
#
def update_cdn_key project_id:, location:, cdn_key_id:, hostname:, key_name:, private_key:, is_media_cdn:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the path for the CDN key resource.
  cdn_key_path = client.cdn_key_path project: project_id, location: location, cdn_key: cdn_key_id

  # Set the CDN key fields.
  new_cdn_key = if is_media_cdn
                  {
                    name: cdn_key_path,
                    hostname: hostname,
                    media_cdn_key: {
                      key_name: key_name,
                      private_key: private_key
                    }
                  }
                else
                  {
                    name: cdn_key_path,
                    hostname: hostname,
                    google_cdn_key: {
                      key_name: key_name,
                      private_key: private_key
                    }
                  }
                end

  update_mask = if is_media_cdn
                  { paths: ["hostname", "media_cdn_key"] }
                else
                  { paths: ["hostname", "google_cdn_key"] }
                end

  response = client.update_cdn_key cdn_key: new_cdn_key, update_mask: update_mask

  # Print the CDN key name.
  puts "Updated CDN key: #{response.name}"
end
# [END videostitcher_update_cdn_key]
