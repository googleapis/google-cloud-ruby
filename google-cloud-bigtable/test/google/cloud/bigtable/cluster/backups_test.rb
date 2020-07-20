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


require "helper"

describe Google::Cloud::Bigtable::Cluster, :backups, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let :cluster_grpc do
    Google::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: 3,
      location: location_path("us-east-1b"),
      default_storage_type: :SSD,
      state: :READY
    )
  end
  let(:cluster) { Google::Cloud::Bigtable::Cluster.from_grpc cluster_grpc, bigtable.service }
  let(:first_page) do
    resp = backups_grpc count: 3
    resp.next_page_token = "next_page_token"
    resp
  end
  let(:second_page) do
    resp = backups_grpc
    resp.next_page_token = "next_page_token"
    resp
  end
  let(:last_page) do
    resp = backups_grpc
    resp
  end

  it "list backups" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [cluster_path(instance_id, cluster_id)]
    bigtable.service.mocked_tables = mock

    backups = cluster.backups

    mock.verify

    _(backups.size).must_equal 3
  end

  it "paginates backups with next? and next" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [cluster_path(instance_id, cluster_id)]
    bigtable.service.mocked_tables = mock

    list = cluster.backups

    mock.verify

    _(list.size).must_equal 3
    _(list.next?).must_equal true
    _(list.next.size).must_equal 2
    _(list.next?).must_equal false
  end

  it "paginates backups with all" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [cluster_path(instance_id, cluster_id)]
    bigtable.service.mocked_tables = mock

    backups = cluster.backups.all.to_a

    mock.verify

    _(backups.size).must_equal 5
  end

  it "iterates backups with all using Enumerator" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [cluster_path(instance_id, cluster_id)]
    bigtable.service.mocked_tables = mock

    backups = cluster.backups.all.take(5)

    mock.verify

    _(backups.size).must_equal 5
  end
end
