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
    modifications = []
    modifications << Google::Cloud::Bigtable::ColumnFamilyModification.create(
      "cf1", Google::Cloud::Bigtable::GcRule.max_age(600)
    )

    modifications << Google::Cloud::Bigtable::ColumnFamilyModification.update(
      "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
    )

    column_families = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new.tap do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_age(300))
      cfs.add('cf2', Google::Cloud::Bigtable::GcRule.max_versions(3))
    end
    cluster_states = clusters_state_grpc(num: 1)
    res_table = Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, res_table, [
      table_path(instance_id, table_id),
      modifications.map(&:to_grpc)
    ]
    bigtable.service.mocked_tables = mock
    updated_table = table.modify_column_families(modifications)

    mock.verify

    updated_table.project_id.must_equal project_id
    updated_table.instance_id.must_equal instance_id
    updated_table.name.must_equal table_id
    updated_table.path.must_equal table_path(instance_id, table_id)
    updated_table.granularity.must_equal :MILLIS
    updated_table.cluster_states.map(&:cluster_name).sort.must_equal cluster_states.keys
    updated_table.cluster_states.each do |cs|
      cs.replication_state.must_equal :READY
    end

    updated_table.column_families.map(&:name).sort.must_equal column_families.keys
    updated_table.column_families.each do |cf|
      cf.gc_rule.grpc.must_equal column_families[cf.name].gc_rule
    end
  end
end
