# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Bigquery::Table, :update, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id, table_name, description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }

  let(:schema) { table.schema.dup }

  it "updates its name" do
    new_table_name = "My Updated Table"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, new_table_name, description
    request_table_gapi = Google::Apis::BigqueryV2::Table.new friendly_name: "My Updated Table"
    mock.expect :patch_table, Google::Apis::BigqueryV2::Table.from_json(table_hash.to_json),
      [project, dataset_id, table_id, request_table_gapi]
    table.service.mocked_service = mock

    table.name.must_equal table_name
    table.description.must_equal description
    table.schema.fields.count.must_equal schema.fields.count

    table.name = new_table_name

    table.name.must_equal new_table_name
    table.description.must_equal description
    table.schema.fields.count.must_equal schema.fields.count

    mock.verify
  end

  it "updates its description" do
    new_description = "This is my updated table"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, new_description
    request_table_gapi = Google::Apis::BigqueryV2::Table.new description: "This is my updated table"
    mock.expect :patch_table, Google::Apis::BigqueryV2::Table.from_json(table_hash.to_json),
      [project, dataset_id, table_id, request_table_gapi]
    table.service.mocked_service = mock

    table.name.must_equal table_name
    table.description.must_equal description
    table.schema.fields.count.must_equal schema.fields.count

    table.description = new_description

    table.name.must_equal table_name
    table.description.must_equal new_description
    table.schema.fields.count.must_equal schema.fields.count

    mock.verify
  end
end
