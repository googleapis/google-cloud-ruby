# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "simplecov"
require "minitest/autorun"

require "google/cloud/container"

class ClusterManagerSmokeTestV1beta1 < Minitest::Test
  def test_list_clusters
    unless ENV["CONTAINER_TEST_PROJECT"]
      fail "CONTAINER_TEST_PROJECT environment variable must be defined"
    end
    project_id = ENV["CONTAINER_TEST_PROJECT"].freeze

    cluster_manager_client = Google::Cloud::Container.cluster_manager version: :v1beta1
    parent = "projects/#{project_id}/locations/us-central1-a"
    response = cluster_manager_client.list_clusters parent: parent
  end
end
