# frozen_string_literal: true

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

describe Google::Cloud::Bigtable::Cluster, :backup, :mock_bigtable do
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
  let(:backup_id) { "test-backup" }
  let(:source_table_id) { "test-table-source" }
  let(:expire_time) { Time.now.round(0) + 60 * 60 * 7 }
  let :backup_grpc do
    Google::Bigtable::Admin::V2::Backup.new source_table: table_path(instance_id, source_table_id),
                                            expire_time:  expire_time
  end

  it "gets a backup" do
    mock = Minitest::Mock.new
    mock.expect :get_backup, backup_grpc, [backup_path(instance_id, cluster_id, backup_id)]
    bigtable.service.mocked_tables = mock

    backup = cluster.backup backup_id

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup

    mock.verify
  end

  it "returns nil when getting an non-existent backup" do
    not_found_backup_id = "not-found-backup"

    stub = Object.new
    def stub.get_backup *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end

    bigtable.service.mocked_tables = stub

    backup = cluster.backup not_found_backup_id
    _(backup).must_be :nil?
  end
end
