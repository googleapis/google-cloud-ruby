# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Table, :reload, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "loads the table full resource by making an HTTP call" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.wont_be :reference?
    table.must_be :resource?
    table.wont_be :resource_partial?
    table.must_be :resource_full?

    table.reload!
    table.wont_be :reference?
    table.must_be :resource?
    table.wont_be :resource_partial?
    table.must_be :resource_full?

    mock.verify
  end

  describe "partial table resource from list" do
    let(:table_partial_gapi) { list_tables_gapi(1).tables.first }
    let(:table) {Google::Cloud::Bigquery::Table.from_gapi table_partial_gapi, bigquery.service }

    it "loads the table full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
      table.service.mocked_service = mock

      table.wont_be :reference?
      table.must_be :resource?
      table.must_be :resource_partial?
      table.wont_be :resource_full?

      table.reload!
      table.wont_be :reference?
      table.must_be :resource?
      table.wont_be :resource_partial?
      table.must_be :resource_full?

      mock.verify
    end
  end

  describe "table reference" do
    let(:table) {Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }

    it "loads the table full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
      table.service.mocked_service = mock

      table.must_be :reference?
      table.wont_be :resource?
      table.wont_be :resource_partial?
      table.wont_be :resource_full?

      table.reload!
      table.wont_be :reference?
      table.must_be :resource?
      table.wont_be :resource_partial?
      table.must_be :resource_full?

      mock.verify
    end
  end
end
