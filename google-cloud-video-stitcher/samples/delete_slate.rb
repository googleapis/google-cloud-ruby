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

# [START videostitcher_delete_slate]
require "google/cloud/video/stitcher"

##
# Delete a slate
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param slate_id [String] Your slate name (e.g. "my-slate")
#
def delete_slate project_id:, location:, slate_id:
  # Create a Video Stitcher client.
  client = Google::Cloud::Video::Stitcher.video_stitcher_service

  # Build the resource name of the slate.
  name = client.slate_path project: project_id, location: location, slate: slate_id

  # Delete the slate.
  operation = client.delete_slate name: name

  # Wait for the response and print a result message
  operation.wait_until_done!
  if operation.response?
    puts "Deleted slate"
  else
    puts "No response received"
  end
end
# [END videostitcher_delete_slate]
