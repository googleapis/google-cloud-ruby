# Copyright 2023 Google LLC
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

# [START videostitcher_get_live_config]
require "google/cloud/video/stitcher"

##
# Get a live config
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param live_config_id [String] Your live config name (e.g. "my-live-config")
#
def get_live_config project_id:, location:, live_config_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the live config.
  name = client.live_config_path project: project_id, location: location,
                                 live_config: live_config_id

  # Get the live config.
  live_config = client.get_live_config name: name

  # Print the live config name.
  puts "Live config: #{live_config.name}"
end
# [END videostitcher_get_live_config]
