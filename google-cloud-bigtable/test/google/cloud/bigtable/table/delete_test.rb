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

describe Google::Cloud::Bigtable::Table, :delete, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  }
  let(:table) {
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_table, true, [table_path(instance_id, table_id)]
    bigtable.service.mocked_tables = mock

    result = table.delete
    result.must_equal true
    mock.verify
  end
end
