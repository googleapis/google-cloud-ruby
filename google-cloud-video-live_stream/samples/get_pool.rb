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

# [START livestream_get_pool]
require "google/cloud/video/live_stream"

##
# Get the pool
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param pool_id [String] Your pool name (e.g. "default")
#
def get_pool project_id:, location:, pool_id:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the pool.
  name = client.pool_path project: project_id, location: location, pool: pool_id

  # Get the pool.
  pool = client.get_pool name: name

  # Print the pool name.
  puts "Pool: #{pool.name}"
end
# [END livestream_get_pool]
