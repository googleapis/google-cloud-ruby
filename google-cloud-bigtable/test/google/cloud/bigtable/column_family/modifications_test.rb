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

describe Google::Cloud::Bigtable::ColumnFamily, :create, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: column_families,
      granularity: :MILLIS
    )
  end
  let(:table) do
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  end
  let(:gc_rule) {
    Google::Cloud::Bigtable::GcRule.max_versions(3)
  }

  it "create column family in given table" do
    new_cf_name = "new-cf"

    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        new_cf_name => Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
        )
      }
    )
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: new_cf_name,
        create: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [name: table_path(instance_id, table_id), modifications: modifications]
    bigtable.service.mocked_tables = mock

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)

    column_families = table.column_families do |cfm|
      cfm.add(new_cf_name, gc_rule: gc_rule)
    end

    cf = column_families[new_cf_name]
    _(cf).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf.name).must_equal new_cf_name
    _(cf.gc_rule).wont_be :nil?
    _(cf.gc_rule.max_versions).must_equal 3

    mock.verify
  end

  it "create column family with nil gc_rule" do
    new_cf_name = "new-cf"

    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        new_cf_name => Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new
      }
    )
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: new_cf_name,
        create: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      name: table_path(instance_id, table_id),
      modifications: modifications
    ]
    bigtable.service.mocked_tables = mock

    column_families = table.column_families do |cfm|
      cfm.add(new_cf_name)
    end

    cf = column_families[new_cf_name]
    _(cf).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf.name).must_equal new_cf_name
    _(cf.gc_rule).must_be :nil?

    mock.verify
  end

  it "update column family" do
    cf_name = table.column_families.names.first

    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        cf_name => Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 1)
        )
      }
    )
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: cf_name,
        update: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 1)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      name: table_path(instance_id, table_id),
      modifications: modifications
    ]
    bigtable.service.mocked_tables = mock

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)

    column_families = table.column_families do |cfm|
      cfm.update(cf_name, gc_rule: gc_rule)
    end

    cf = column_families[cf_name]
    _(cf).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf.name).must_equal cf_name
    _(cf.gc_rule).wont_be :nil?
    _(cf.gc_rule.max_versions).must_equal 1

    mock.verify
  end

  it "update column family with nil gc_rule" do
    cf_name = table.column_families.names.first

    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        cf_name => Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: nil
        )
      }
    )
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: cf_name,
        update: Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: nil
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      name: table_path(instance_id, table_id),
      modifications: modifications
    ]
    bigtable.service.mocked_tables = mock

    column_families = table.column_families do |cfm|
      cfm.update(cf_name)
    end

    cf = column_families[cf_name]
    _(cf).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf.name).must_equal cf_name
    _(cf.gc_rule).must_be :nil?

    mock.verify
  end

  it "delete column family" do
    cf_name = table.column_families.names.first

    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id)
    )
    modifications = [
      Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: cf_name,
        drop: true
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      name: table_path(instance_id, table_id),
      modifications: modifications
    ]
    bigtable.service.mocked_tables = mock

    column_families = table.column_families do |cfm|
      cfm.delete(cf_name)
    end

    _(column_families[cf_name]).must_be :nil?

    mock.verify
  end
end
