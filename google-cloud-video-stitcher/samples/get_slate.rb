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

# [START videostitcher_get_slate]
require "google/cloud/video/stitcher"

##
# Get a slate
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param slate_id [String] Your slate name (e.g. "my-slate")
#
def get_slate project_id:, location:, slate_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the slate.
  name = client.slate_path project: project_id, location: location,
                           slate: slate_id

  # Get the slate.
  slate = client.get_slate name: name

  # Print the slate name.
  puts "Slate: #{slate.name}"
end
# [END videostitcher_get_slate]
