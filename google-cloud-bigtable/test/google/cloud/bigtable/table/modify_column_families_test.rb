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

describe Google::Cloud::Bigtable::Table, :modify_column_families, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  end
  let(:table) do
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  end

  it "modify column family in table" do
    modifications = [
      Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: "cf1",
        create: Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_age: 600)
        )
      ),
      Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: "cf2",
        update: Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 5)
        )
      )
    ]

    column_families = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new.tap do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_age(600))
      cfs.add('cf2', Google::Cloud::Bigtable::GcRule.max_versions(5))
    end
    cluster_states = clusters_state_grpc(num: 1)
    res_table = Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_grpc,
        granularity: :MILLIS
      )
    )

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, res_table, [
      table_path(instance_id, table_id),
      modifications
    ]
    bigtable.service.mocked_tables = mock

    column_families = table.column_families do |cfs|
      cfs.add "cf1", Google::Cloud::Bigtable::GcRule.max_age(600)
      cfs.update "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
    end

    table.project_id.must_equal project_id
    table.instance_id.must_equal instance_id
    table.name.must_equal table_id
    table.path.must_equal table_path(instance_id, table_id)
    table.granularity.must_equal :MILLIS
    table.column_families.keys.sort.must_equal column_families.keys
    table.column_families["cf1"].gc_rule.to_grpc.must_equal Google::Cloud::Bigtable::GcRule.max_age(600).to_grpc
    table.column_families["cf2"].gc_rule.to_grpc.must_equal Google::Cloud::Bigtable::GcRule.max_versions(5).to_grpc

    mock.verify
  end
end
