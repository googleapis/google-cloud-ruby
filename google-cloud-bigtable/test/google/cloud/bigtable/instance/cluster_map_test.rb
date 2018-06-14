# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "helper"

describe Google::Cloud::Bigtable::Instance::ClusterMap, :mock_bigtable do
  it "add cluster to map" do
    location = location_path("us-east-1b")
    cluster_id = "test-cluster"

    cluster_map = Google::Cloud::Bigtable::Instance::ClusterMap.new
    cluster_map.must_be :empty?

    cluster_map.add(cluster_id, location, nodes: 3, storage_type: :SSD)
    cluster_map.length.must_equal 1

    cluster_grpc = cluster_map[cluster_id]
    cluster_grpc.must_be_kind_of Google::Bigtable::Admin::V2::Cluster
    cluster_grpc.location.must_equal location_path("us-east-1b")
    cluster_grpc.serve_nodes.must_equal 3
    cluster_grpc.default_storage_type.must_equal :SSD
  end
end
