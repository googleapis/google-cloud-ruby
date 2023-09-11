# Copyright 2023 Google, Inc
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

# [START livestream_get_asset]
require "google/cloud/video/live_stream"

##
# Get an asset
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param asset_id [String] Your asset name (e.g. "my-asset")
#
def get_asset project_id:, location:, asset_id:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the asset.
  name = client.asset_path project: project_id, location: location, asset: asset_id

  # Get the asset.
  asset = client.get_asset name: name

  # Print the asset name.
  puts "Asset: #{asset.name}"
end
# [END livestream_get_asset]
