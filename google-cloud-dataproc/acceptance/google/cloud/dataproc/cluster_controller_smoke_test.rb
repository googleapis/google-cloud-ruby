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
require "minitest/spec"

require "google/cloud/dataproc"

class ClusterControllerSmokeTest < Minitest::Test
  def test_list_clusters_v1
    unless ENV["DATAPROC_TEST_PROJECT"]
      fail "DATAPROC_TEST_PROJECT environment variable must be defined"
    end
    project_id = ENV["DATAPROC_TEST_PROJECT"].freeze

    client = Google::Cloud::Dataproc.cluster_controller
    client.list_clusters project_id: project_id, region: "global"
  end
end
