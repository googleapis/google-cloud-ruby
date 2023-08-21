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

# [START videostitcher_create_slate]
require "google/cloud/video/stitcher"

##
# Create a slate
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param slate_id [String] Your slate name (e.g. "my-slate")
# @param slate_uri [String] The URI of an MP4 video with at least one audio
#   track (e.g. "https://my-slate-uri/test.mp4")
#
def create_slate project_id:, location:, slate_id:, slate_uri:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Set the slate fields.
  new_slate = {
    uri: slate_uri
  }

  operation = client.create_slate parent: parent, slate_id: slate_id,
                                  slate: new_slate

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the slate name.
  puts "Slate: #{operation.response.name}"
end
# [END videostitcher_create_slate]
