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
  let(:cluster_id) { "test-cluster" }
  let(:loc) { location_path("us-east-1b") }
  let(:kms_key) { "path/to/encryption_key_name" }

  it "adds a cluster" do
    cluster_map = Google::Cloud::Bigtable::Instance::ClusterMap.new
    _(cluster_map).must_be :empty?

    cluster_map.add(cluster_id, loc, nodes: 3, storage_type: :SSD)
    _(cluster_map.length).must_equal 1

    cluster_grpc = cluster_map[cluster_id]
    _(cluster_grpc).must_be_kind_of Google::Cloud::Bigtable::Admin::V2::Cluster
    _(cluster_grpc.location).must_equal loc
    _(cluster_grpc.serve_nodes).must_equal 3
    _(cluster_grpc.default_storage_type).must_equal :SSD
    _(cluster_grpc.encryption_config).must_be :nil?
  end

  it "adds a cluster with KMS key (CMEK)" do
    cluster_map = Google::Cloud::Bigtable::Instance::ClusterMap.new

    cluster_map.add(cluster_id, loc, kms_key: kms_key)
    _(cluster_map.length).must_equal 1

    cluster_grpc = cluster_map[cluster_id]
    _(cluster_grpc).must_be_kind_of Google::Cloud::Bigtable::Admin::V2::Cluster
    _(cluster_grpc.location).must_equal loc
    _(cluster_grpc.serve_nodes).must_equal 0
    _(cluster_grpc.default_storage_type).must_equal :STORAGE_TYPE_UNSPECIFIED
    _(cluster_grpc.encryption_config).must_be_kind_of Google::Cloud::Bigtable::Admin::V2::Cluster::EncryptionConfig
    _(cluster_grpc.encryption_config.kms_key_name).must_equal kms_key
  end
end
