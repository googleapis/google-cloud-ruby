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

describe Google::Cloud::Bigtable::Project, :table, :mock_bigtable do
  let(:instance_id) { "test-instance" }

  it "gets a table" do
    table_id = "found-table"
    cluster_states = clusters_state_grpc
    column_families = column_families_grpc
    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )

    mock = Minitest::Mock.new
    mock.expect :get_table, get_res, [name: table_path(instance_id, table_id), view: :FULL]
    bigtable.service.mocked_tables = mock
    table = bigtable.table(instance_id, table_id, view: :FULL, perform_lookup: true)

    mock.verify

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS
    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
  end

  it "returns nil when getting an non-existent table" do
    not_found_table_id = "not-found-table"

    stub = Object.new
    def stub.get_table *args
      raise Google::Cloud::NotFoundError.new("not found")
    end

    bigtable.service.mocked_tables = stub

    table = bigtable.table(instance_id, not_found_table_id, perform_lookup: true)
    _(table).must_be :nil?
  end

  it "load schema view on access schema fields" do
    table_id = "test-table"
    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      cluster_states: clusters_state_grpc,
      column_families: column_families_grpc,
      granularity: :MILLIS
    )

    mock = Minitest::Mock.new
    mock.expect :get_table, get_res, [name: table_path(instance_id, table_id), view: :SCHEMA_VIEW]
    mock.expect :get_table, get_res, [name: table_path(instance_id, table_id), view: :REPLICATION_VIEW]
    bigtable.service.mocked_tables = mock

    table = Google::Cloud::Bigtable::Table.from_grpc(
      Google::Cloud::Bigtable::Admin::V2::Table.new(name: table_path(instance_id, table_id)),
      bigtable.service,
      view: :NAME_ONLY
    )

    2.times do
      _(table.column_families).wont_be :empty?
      _(table.granularity).must_equal :MILLIS
      _(table.cluster_states).wont_be :empty?
    end
    mock.verify
  end

  it "get table object without fetching table" do
    table_id = "my-table"
    app_profile_id = "my-app-profile"

    table = bigtable.table(instance_id, table_id,  app_profile_id: app_profile_id)
    _(table).must_be_kind_of Google::Cloud::Bigtable::Table
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.app_profile_id).must_equal app_profile_id
  end
end
