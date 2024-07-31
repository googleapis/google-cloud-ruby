# Copyright 2024 Google LLC
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

# [START videostitcher_get_vod_config]
require "google/cloud/video/stitcher"

##
# Get a VOD config
#
# @param project_id [String] Your Google Cloud project (e.g. `my-project`)
# @param location [String] The location (e.g. `us-central1`)
# @param vod_config_id [String] Your VOD config name (e.g. `my-vod-config`)
#
def get_vod_config project_id:, location:, vod_config_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the VOD config.
  name = client.vod_config_path project: project_id, location: location,
                                vod_config: vod_config_id

  # Get the VOD config.
  vod_config = client.get_vod_config name: name

  # Print the vod config name.
  puts "VOD config: #{vod_config.name}"
end
# [END videostitcher_get_vod_config]
