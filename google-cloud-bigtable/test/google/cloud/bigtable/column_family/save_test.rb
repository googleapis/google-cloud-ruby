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

describe Google::Cloud::Bigtable::ColumnFamily, :save, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

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
end
