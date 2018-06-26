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
    Google::Bigtable::Admin::V2::Table.new(
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

  it "create column modification create instance" do
    modification = Google::Cloud::Bigtable::ColumnFamily.create_modification("cf1", gc_rule)
    modification.must_be_kind_of Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification
    modification.id.must_equal "cf1"
    modification.create.must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    modification.create.gc_rule.must_equal gc_rule.to_grpc
  end

  it "create column modification update instance" do
    modification = Google::Cloud::Bigtable::ColumnFamily.update_modification("cf1", gc_rule)
    modification.must_be_kind_of Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification
    modification.id.must_equal "cf1"
    modification.update.must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    modification.update.gc_rule.must_equal gc_rule.to_grpc
  end

  it "create column modification drop instance" do
    modification = Google::Cloud::Bigtable::ColumnFamily.drop_modification("cf1")
    modification.must_be_kind_of Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification
    modification.id.must_equal "cf1"
    modification.drop.must_equal true
  end

  it "create column family in given table" do
    new_cf_name = "new-cf"

    get_res = Google::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        new_cf_name => Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
        )
      }
    )
    modifications = [
      Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: new_cf_name,
        create: Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      table_path(instance_id, table_id),
      modifications
    ]
    bigtable.service.mocked_tables = mock

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
    column_family = table.column_family(new_cf_name, gc_rule)
    column_family.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily

    created_column = column_family.create
    created_column.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily

    mock.verify
  end

  it "update column family" do
    cf_name = "cf"
    cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new(
      gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
    )
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      bigtable.service,
      name: cf_name,
      instance_id: instance_id,
      table_id: table_id
    )

    get_res = Google::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      column_families: {
        cf_name => Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 1)
        )
      }
    )
    modifications = [
      Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: cf_name,
        update: Google::Bigtable::Admin::V2::ColumnFamily.new(
          gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 1)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      table_path(instance_id, table_id),
      modifications
    ]
    bigtable.service.mocked_tables = mock

    column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
    updated_cf = column_family.save
    updated_cf.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily

    mock.verify
  end

  it "delelte column family" do
    cf_name = "cf"
    cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new(
      gc_rule: Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
    )
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      bigtable.service,
      name: cf_name,
      instance_id: instance_id,
      table_id: table_id
    )

    get_res = Google::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id)
    )
    modifications = [
      Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification.new(
        id: cf_name,
        drop: true
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :modify_column_families, get_res, [
      table_path(instance_id, table_id),
      modifications
    ]
    bigtable.service.mocked_tables = mock

    column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
    result = column_family.delete
    result.must_equal true

    mock.verify
  end
end
