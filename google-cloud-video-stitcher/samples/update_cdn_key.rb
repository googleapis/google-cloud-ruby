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
# Update a CDN key
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param cdn_key_id [String] The user-defined CDN key ID
# @param hostname [String] The hostname to which this CDN key applies
# @param gcdn_keyname [String] Applies to a Google Cloud CDN key. A base64-encoded string secret.
# @param gcdn_private_key [String] Applies to a Google Cloud CDN key. Public name of the key.
# @param akamai_token_key [String] Applies to an Akamai CDN key. A base64-encoded string token key.
#
def update_cdn_key project_id:, location:, cdn_key_id:, hostname:, gcdn_keyname:, gcdn_private_key:, akamai_token_key:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the path for the CDN key resource.
  cdn_key_path = client.cdn_key_path project: project_id, location: location, cdn_key: cdn_key_id

  # Set the CDN key fields.
  if !akamai_token_key.nil?
    update_mask = { paths: ["hostname", "akamai_cdn_key"] }
    new_cdn_key = {
      name: cdn_key_path,
      hostname: hostname,
      akamai_cdn_key: {
        token_key: akamai_token_key
      }
    }
  elsif !gcdn_private_key.nil?
    update_mask = { paths: ["hostname", "google_cdn_key"] }
    new_cdn_key = {
      name: cdn_key_path,
      hostname: hostname,
      google_cdn_key: {
        key_name: gcdn_keyname,
        private_key: gcdn_private_key
      }
    }
  end

  response = client.update_cdn_key cdn_key: new_cdn_key, update_mask: update_mask

  # Print the CDN key name.
  puts "Updated CDN key: #{response.name}"
end
# [END videostitcher_update_cdn_key]
