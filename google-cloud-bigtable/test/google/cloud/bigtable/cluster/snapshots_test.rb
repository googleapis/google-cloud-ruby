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

describe Google::Cloud::Bigtable::Table, :snapshots, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:cluster_grpc){
    Google::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: 3,
      location: location_path("us-east-1b"),
      default_storage_type: :SSD,
      state: :READY
    )
  }
  let(:cluster) {
    Google::Cloud::Bigtable::Cluster.from_grpc(cluster_grpc, bigtable.service)
  }
  let(:first_page) do
    h = snapshots_hash(instance_id)
    h[:next_page_token] = "next_page_token"
    Google::Bigtable::Admin::V2::ListSnapshotsResponse.new(h)
  end
  let(:second_page) do
    h = snapshots_hash(instance_id, start_id: 10)
    h[:next_page_token] = "second_page_token"
    Google::Bigtable::Admin::V2::ListSnapshotsResponse.new(h)
  end
  let(:last_page) do
    h = snapshots_hash(instance_id, start_id: 20)
    h[:snapshots].pop
    Google::Bigtable::Admin::V2::ListSnapshotsResponse.new(h)
  end

  it "list snapshots" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, get_res, [cluster_path(instance_id, cluster_id), page_size: nil]
    bigtable.service.mocked_tables = mock

    snapshots = cluster.snapshots

    mock.verify

    snapshots.size.must_equal 3
  end

  it "paginates tables with next? and next" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, get_res, [cluster_path(instance_id, cluster_id), page_size: nil]
    bigtable.service.mocked_tables = mock

    list = cluster.snapshots

    mock.verify

    list.size.must_equal 3
    list.next?.must_equal true
    list.next.size.must_equal 2
    list.next?.must_equal false
  end

  it "paginates tables with all" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, get_res, [cluster_path(instance_id, cluster_id), page_size: nil]
    bigtable.service.mocked_tables = mock

    snapshots = cluster.snapshots.all.to_a

    mock.verify

    snapshots.size.must_equal 5
  end

  it "iterates tables with all using Enumerator" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, get_res, [cluster_path(instance_id, cluster_id), page_size: nil]
    bigtable.service.mocked_tables = mock

    snapshots = cluster.snapshots.all.take(5)

    mock.verify

    snapshots.size.must_equal 5
  end
end
