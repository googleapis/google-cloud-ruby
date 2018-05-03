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

describe Google::Cloud::Bigtable::Table::ClusterState, :mock_bigtable do
  it "knows the identifiers" do
    cluster_name = "test-cluster"
    grpc = Google::Bigtable::Admin::V2::Table::ClusterState.new(
      replication_state: :READY
    )
    cluster_state = Google::Cloud::Bigtable::Table::ClusterState.from_grpc(
      grpc, cluster_name
    )

    cluster_state.must_be_kind_of Google::Cloud::Bigtable::Table::ClusterState
    cluster_state.cluster_name.must_equal cluster_name
    cluster_state.replication_state.must_equal :READY
    cluster_state.ready?.must_equal true
    cluster_state.initializing?.wont_equal true
    cluster_state.planned_maintenance?.wont_equal true
    cluster_state.unplanned_maintenance?.wont_equal true
  end
end
