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

describe Google::Cloud::Bigtable::Project, :create_table, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "new-table" }
  let(:initial_splits) { [ "category-1", "category-2" ] }

  it "creates a table with column_families arg" do
    mock = Minitest::Mock.new
    cluster_states = clusters_state_grpc(num: 1)
    column_families = column_families_grpc num: 1, max_versions: 1

    create_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    req_table = Google::Cloud::Bigtable::Admin::V2::Table.new(
      column_families: column_families.to_h,
      granularity: :MILLIS
    )

    mock.expect :create_table, create_res, [
      parent: instance_path(instance_id),
      table_id: table_id,
      table: req_table
    ]
    mock.expect :get_table, create_res.dup, [
      name: table_path(instance_id, table_id),
      view: :REPLICATION_VIEW
    ]
    bigtable.service.mocked_tables = mock

    cfm = Google::Cloud::Bigtable::ColumnFamilyMap.new
    cfm.add('cf1', gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))

    table = bigtable.create_table(
      instance_id,
      table_id,
      column_families: cfm,
      granularity: :MILLIS,
    )

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS
    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    mock.verify
  end

  it "creates a table with column families block" do
    mock = Minitest::Mock.new
    cluster_states = clusters_state_grpc(num: 1)
    column_families = column_families_grpc num: 1, max_versions: 1

    create_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    req_table = Google::Cloud::Bigtable::Admin::V2::Table.new(
      column_families: column_families.to_h,
      granularity: :MILLIS
    )

    mock.expect :create_table, create_res, [
      parent: instance_path(instance_id),
      table_id: table_id,
      table: req_table
    ]
    mock.expect :get_table, create_res.dup, [
                            name: table_path(instance_id, table_id),
                            view: :REPLICATION_VIEW
                          ]
    bigtable.service.mocked_tables = mock

    table = bigtable.create_table(
      instance_id,
      table_id,
      granularity: :MILLIS,
    ) do |cfm|
      cfm.add('cf1', gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS
    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    mock.verify
  end

  it "creates a table with initial split keys" do
    mock = Minitest::Mock.new
    cluster_states = clusters_state_grpc(num: 1)
    column_families = column_families_grpc num: 1, max_versions: 1

    create_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    req_table = Google::Cloud::Bigtable::Admin::V2::Table.new(
      column_families: column_families.to_h,
      granularity: :MILLIS
    )

    mock.expect :create_table, create_res, [
      parent: instance_path(instance_id),
      table_id: table_id,
      table: req_table,
      initial_splits: initial_splits.map { |key| { key: key } }
    ]
    mock.expect :get_table, create_res.dup, [
      name: table_path(instance_id, table_id),
      view: :REPLICATION_VIEW
    ]
    bigtable.service.mocked_tables = mock

    table = bigtable.create_table(
      instance_id,
      table_id,
      granularity: :MILLIS,
      initial_splits: initial_splits
    ) do |cfm|
      cfm.add('cf1', gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS
    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    mock.verify
  end
end
