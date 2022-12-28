# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Table, :reload, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table_partial_hash) { random_table_partial_hash dataset_id, table_id }
  let(:table_partial_gapi) { Google::Apis::BigqueryV2::Table.from_json table_partial_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "loads the table full resource by making an HTTP call" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id], **patch_table_args, **patch_table_args
    table.service.mocked_service = mock

    _(table).wont_be :reference?
    _(table).must_be :resource?
    _(table).wont_be :resource_partial?
    _(table).must_be :resource_full?

    table.reload!
    _(table).wont_be :reference?
    _(table).must_be :resource?
    _(table).wont_be :resource_partial?
    _(table).must_be :resource_full?

    mock.verify
  end

  it "loads the table partial resource by making an HTTP call" do
    %w[unspecified basic storage full].each do |view|
      mock = Minitest::Mock.new
      table.service.mocked_service = mock
      table_result = table_gapi

      if view == "basic"
        table_result = table_partial_gapi
      end

      mock.expect :get_table, table_result, [project, dataset_id, table_id],
                  **patch_table_args(view: view)

      partial_table = Google::Cloud::Bigquery::Table.from_gapi table_result, bigquery.service, metadata_view: view

      _(partial_table).wont_be :reference?
      _(partial_table).must_be :resource?
      _(partial_table).wont_be :resource_partial?
      _(partial_table).must_be :resource_full?
      verify_table_metadata partial_table, view

      partial_table.reload!
      _(partial_table).wont_be :reference?
      _(partial_table).must_be :resource?
      _(partial_table).wont_be :resource_partial?
      _(partial_table).must_be :resource_full?
      verify_table_metadata partial_table, view

      mock.verify
    end
  end

  describe "partial table resource from list" do
    let(:table_partial_gapi) { list_tables_gapi(1).tables.first }
    let(:table) {Google::Cloud::Bigquery::Table.from_gapi table_partial_gapi, bigquery.service }

    it "loads the table full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id], **patch_table_args
      table.service.mocked_service = mock

      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).must_be :resource_partial?
      _(table).wont_be :resource_full?

      table.reload!
      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).wont_be :resource_partial?
      _(table).must_be :resource_full?

      mock.verify
    end
  end

  describe "table reference" do
    let(:table) {Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }

    it "loads the table full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id], **patch_table_args
      table.service.mocked_service = mock

      _(table).must_be :reference?
      _(table).wont_be :resource?
      _(table).wont_be :resource_partial?
      _(table).wont_be :resource_full?

      table.reload!
      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).wont_be :resource_partial?
      _(table).must_be :resource_full?

      mock.verify
    end
  end
end
