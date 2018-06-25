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

  it "creates a table" do
    mock = Minitest::Mock.new
    cluster_states = clusters_state_grpc(num: 1)
    column_families = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new.tap do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    create_res = Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    req_table = Google::Bigtable::Admin::V2::Table.new(
      column_families: column_families.to_h,
      granularity: :MILLIS
    )

    mock.expect :create_table, create_res, [
      instance_path(instance_id),
      table_id,
      req_table,
      initial_splits: nil
    ]
    mock.expect :get_table, create_res.dup, [
      table_path(instance_id, table_id),
      view: :REPLICATION_VIEW
    ]
    bigtable.service.mocked_tables = mock

    table = bigtable.create_table(
      instance_id,
      table_id,
      granularity: :MILLIS,
    ) do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    table.project_id.must_equal project_id
    table.instance_id.must_equal instance_id
    table.name.must_equal table_id
    table.path.must_equal table_path(instance_id, table_id)
    table.granularity.must_equal :MILLIS
    table.column_families.map(&:name).sort.must_equal column_families.keys
    table.column_families.each do |cf|
      cf.gc_rule.to_grpc.must_equal column_families[cf.name].gc_rule
    end
    table.cluster_states.map(&:cluster_name).sort.must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      cs.replication_state.must_equal :READY
    end

    mock.verify
  end

  it "creates a table with initial split keys" do
    mock = Minitest::Mock.new
    cluster_states = clusters_state_grpc(num: 1)
    column_families = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new.tap do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    create_res = Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families.to_h,
        granularity: :MILLIS
      )
    )

    req_table = Google::Bigtable::Admin::V2::Table.new(
      column_families: column_families.to_h,
      granularity: :MILLIS
    )

    mock.expect :create_table, create_res, [
      instance_path(instance_id),
      table_id,
      req_table,
      initial_splits: initial_splits.map { |key| { key: key } }
    ]
    mock.expect :get_table, create_res.dup, [
      table_path(instance_id, table_id),
      view: :REPLICATION_VIEW
    ]
    bigtable.service.mocked_tables = mock

    table = bigtable.create_table(
      instance_id,
      table_id,
      granularity: :MILLIS,
      initial_splits: initial_splits
    ) do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    table.project_id.must_equal project_id
    table.instance_id.must_equal instance_id
    table.name.must_equal table_id
    table.path.must_equal table_path(instance_id, table_id)
    table.granularity.must_equal :MILLIS
    table.column_families.map(&:name).sort.must_equal column_families.keys
    table.column_families.each do |cf|
      cf.gc_rule.to_grpc.must_equal column_families[cf.name].gc_rule
    end
    table.cluster_states.map(&:cluster_name).sort.must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      cs.replication_state.must_equal :READY
    end

    mock.verify
  end
end
