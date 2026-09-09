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

# [START livestream_update_pool]
require "google/cloud/video/live_stream"

##
# Update the pool's peered network
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param pool_id [String] Your pool name (e.g. "my-pool")
# @param peered_network [String] The updated peer network
#   (e.g. "projects/my-network-project-number/global/networks/my-network-name")
#
def update_pool project_id:, location:, pool_id:, peered_network:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the pool.
  name = client.pool_path project: project_id, location: location, pool: pool_id

  # Set the update mask.
  update_mask = { paths: ["network_config"] }

  # Update the pool's peered network.
  update_pool = {
    name: name,
    network_config: {
      peered_network: peered_network
    }
  }

  operation = client.update_pool update_mask: update_mask, pool: update_pool

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the pool name.
  puts "Updated pool: #{operation.response.name}"
end
# [END livestream_update_pool]
