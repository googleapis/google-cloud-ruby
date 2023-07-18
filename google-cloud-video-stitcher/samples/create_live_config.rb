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

# [START videostitcher_create_live_config]
require "google/cloud/video/stitcher"

##
# Create a live config
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param live_config_id [String] Your live config name (e.g. "my-live-config")
# @param source_uri [String] Uri of the live stream to stitch
#                            (e.g. "https://storage.googleapis.com/my-bucket/main.mpd")
# @param ad_tag_uri [String] Uri of the ad tag (e.g. "https://pubads.g.doubleclick.net/gampad/ads...")
# @param slate_id [String] The default slate ID to use when no slates are specified in an ad break's message
#                           (e.g. "my-slate-id")
#
def create_live_config project_id:, location:, live_config_id:, source_uri:, ad_tag_uri:, slate_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Build the resource name of the default slate.
  slate_name = client.slate_path project: project_id, location: location, slate: slate_id

  # Set the live config fields.
  new_live_config = {
    source_uri: source_uri,
    ad_tag_uri: ad_tag_uri,
    ad_tracking: Google::Cloud::Video::Stitcher::V1::AdTracking::SERVER,
    stitching_policy: Google::Cloud::Video::Stitcher::V1::LiveConfig::StitchingPolicy::CUT_CURRENT,
    default_slate: slate_name
  }

  operation = client.create_live_config parent: parent, live_config_id: live_config_id, live_config: new_live_config

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the live config name.
  puts "Live config: #{operation.response.name}"
end
# [END videostitcher_create_live_config]
