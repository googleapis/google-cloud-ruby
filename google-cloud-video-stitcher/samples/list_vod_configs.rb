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

# [START videostitcher_list_vod_configs]
require "google/cloud/video/stitcher"

##
# List VOD configs for a given location
#
# @param project_id [String] Your Google Cloud project (e.g. `my-project`)
# @param location [String] The location (e.g. `us-central1`)
#
def list_vod_configs project_id:, location:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  response = client.list_vod_configs parent: parent

  puts "VOD configs:"
  # Print out all VOD configs.
  response.each do |vod_config|
    puts vod_config.name
  end
end
# [END videostitcher_list_vod_configs]
