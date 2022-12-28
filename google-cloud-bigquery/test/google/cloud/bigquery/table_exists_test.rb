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

describe Google::Cloud::Bigquery::Table, :exists, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "knows if full resource exists when created with an HTTP method" do
    # The absence of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    _(table).wont_be :reference?
    _(table).must_be :resource?
    _(table).wont_be :resource_partial?
    _(table).must_be :resource_full?

    _(table).must_be :exists?
    _(table).wont_be :reference?
    _(table).must_be :resource?
    _(table).wont_be :resource_partial?
    _(table).must_be :resource_full?

    # Additional exists? calls do not make HTTP calls either
    _(table).must_be :exists?
  end

  describe "partial dataset resource from list of a dataset that exists" do
    let(:table_partial_gapi) { list_tables_gapi(1).tables.first }
    let(:table) {Google::Cloud::Bigquery::Table.from_gapi table_partial_gapi, bigquery.service }

    it "knows if partial resource exists when created with an HTTP method" do
      # The absence of a mock means this test will fail
      # if the method exists? makes an HTTP call.
      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).must_be :resource_partial?
      _(table).wont_be :resource_full?

      _(table).must_be :exists?
      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).must_be :resource_partial?
      _(table).wont_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      _(table).must_be :exists?
    end
  end

  describe "dataset reference of a dataset that exists" do
    let(:table) {Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }

    it "checks if the dataset exists by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id], **patch_table_args
      table.service.mocked_service = mock

      _(table).must_be :reference?
      _(table).wont_be :resource?
      _(table).wont_be :resource_partial?
      _(table).wont_be :resource_full?

      _(table).must_be :exists?
      _(table).wont_be :reference?
      _(table).must_be :resource?
      _(table).wont_be :resource_partial?
      _(table).must_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      _(table).must_be :exists?

      mock.verify
    end
  end

  describe "dataset reference of a dataset that does not exist" do
    let(:table) { Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }

    it "checks if the dataset exists by making an HTTP call" do
      stub = Object.new
      def stub.get_table *args
        raise Google::Apis::Error.new("not found", status_code: 404)
      end
      table.service.mocked_service = stub

      _(table).must_be :reference?
      _(table).wont_be :resource?
      _(table).wont_be :resource_partial?
      _(table).wont_be :resource_full?

      _(table).wont_be :exists?
      _(table).must_be :reference?
      _(table).wont_be :resource?
      _(table).wont_be :resource_partial?
      _(table).wont_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      _(table).wont_be :exists?
    end
  end
end
