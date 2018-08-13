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

describe Google::Cloud::Bigtable::Table, :exists?, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:column_families) { column_families_grpc }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  }

  it "checks existence of the table" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_grpc, [table_path(instance_id, table_id), view: :NAME_ONLY]
    bigtable.service.mocked_tables = mock

    table = bigtable.table(instance_id, table_id)
    table.exists?.must_equal true
    mock.verify
  end
end
