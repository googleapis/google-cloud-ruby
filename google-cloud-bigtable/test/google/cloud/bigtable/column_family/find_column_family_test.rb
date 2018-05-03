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

describe Google::Cloud::Bigtable::ColumnFamily::List, :find_by_name, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:column_families) { column_families_grpc(num: 5, start_id: 1) }
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

  it "find column family by name from the list" do
    column_families = table.column_families

    column_families.wont_be :empty?

    column_family = column_families.find_by_name("cf3")
    column_family.wont_be :nil?
    column_family.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    column_family.name.must_equal "cf3"
  end
end
