# Copyright 2019 Google LLC
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

describe Google::Cloud::Bigtable::Table, :column_families, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Cloud::Bigtable::Admin::V2::Table.new(
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

  it "modifies column families in the table" do
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: "cf4",
        create: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_age: 600)
        )
      ),
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: "cf2",
        update: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 5)
        )
      )
    ]
    gc_rule_1 = Google::Cloud::Bigtable::Admin::V2::GcRule.new(gc_rule_hash(max_age: 600))
    gc_rule_2 = Google::Cloud::Bigtable::Admin::V2::GcRule.new(gc_rule_hash(max_versions: 5))
    column_families_resp = column_families.dup
    column_families_resp["cf4"] = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(gc_rule: gc_rule_1)
    column_families_resp["cf2"] = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(gc_rule: gc_rule_2)
    cluster_states = clusters_state_grpc(num: 1)
    table_resp = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families_resp,
        granularity: :MILLIS
      )
    )

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, table_resp, [
      name: table_path(instance_id, table_id),
      modifications: modifications
    ]
    bigtable.service.mocked_tables = mock

    column_families = table.column_families do |cfm|
      cfm.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
      cfm.update "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
    end

    _(column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(column_families.names.sort).must_equal column_families_resp.keys
    _(column_families["cf4"].gc_rule.to_grpc).must_equal gc_rule_1
    _(column_families["cf2"].gc_rule.to_grpc).must_equal gc_rule_2

    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families_resp.keys
    _(table.column_families["cf4"].gc_rule.to_grpc).must_equal gc_rule_1
    _(table.column_families["cf2"].gc_rule.to_grpc).must_equal gc_rule_2

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS

    mock.verify
  end
end
