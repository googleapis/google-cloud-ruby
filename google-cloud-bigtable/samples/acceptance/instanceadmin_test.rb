# Copyright 2021 Google LLC
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

require_relative "helper"
require_relative "../instanceadmin"

describe Google::Cloud::Bigtable, "Instance Admin", :bigtable do
  it "create production instance, list instances, list clusters, add cluster, \
      delete cluster delete instance" do
    instance_id = "test-instance-#{SecureRandom.hex 8}"
    cluster_id = "test-cluster-#{SecureRandom.hex 8}"
    cluster_location = "us-central1-f"

    out, _err = capture_io do
      create_prod_instance(
        instance_id,
        cluster_id,
        cluster_location
      )
    end

    assert_includes out, "Creating a PRODUCTION Instance"
    assert_includes out, "Created Instance: #{instance_id}"
    assert_includes out, "Instance: #{instance_id}"
    assert_includes out, "Get Instance id: #{instance_id}"
    assert_includes out, "Cluster: #{cluster_id}"

    cluster_id1 = "test-cluster-#{SecureRandom.hex 8}"
    cluster_id1_locations = "us-central1-c"
    out, _err = capture_io do
      add_cluster instance_id, cluster_id1, cluster_id1_locations
    end

    assert_includes out, "Cluster created: #{cluster_id1}"

    out, _err = capture_io do
      delete_cluster instance_id, cluster_id1
    end

    assert_includes out, "Cluster deleted: #{cluster_id1}"

    out, _err = capture_io do
      delete_instance instance_id
    end

    assert_includes out, "Instance deleted: #{instance_id}"
  end

  it "create development instance" do
    instance_id = "test-instance-#{SecureRandom.hex 8}"
    cluster_id = "test-cluster-#{SecureRandom.hex 8}"
    cluster_location = "us-central1-f"

    out, _err = capture_io do
      create_dev_instance instance_id, cluster_id, cluster_location
    end

    assert_includes out, "Creating a DEVELOPMENT Instance"
    assert_includes out, "Created development instance: #{instance_id}"

    instance = @bigtable.instance instance_id
    instance.delete
  end
end
