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

# [START livestream_create_asset]
require "google/cloud/video/live_stream"

##
# Create an asset
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param asset_id [String] Your asset name (e.g. "my-asset")
# @param asset_uri [String] Your asset URI (e.g. "gs://my-bucket/my-video.mp4")
#
def create_asset project_id:, location:, asset_id:, asset_uri:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Set the asset fields.
  new_asset = {
    video: {
      uri: asset_uri
    }
  }

  operation = client.create_asset parent: parent, asset: new_asset, asset_id: asset_id

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the asset name.
  puts "Asset: #{operation.response.name}"
end
# [END livestream_create_asset]
