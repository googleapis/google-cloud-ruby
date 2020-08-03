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

describe Google::Cloud::Bigtable::Table, :mutate_row, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:app_profile_id) { "test-app-profile-id"}
  let(:table) {
    bigtable.table(instance_id, table_id, app_profile_id: app_profile_id)
  }

  it "mutate row" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock
    row_key = "user-1"

    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    entry.set_cell("cf1", "field1", "XYZ")

    res = Google::Cloud::Bigtable::V2::MutateRowResponse.new
    mutations = Google::Cloud::Bigtable::V2::Mutation.new(set_cell: {
      family_name: "cf1", column_qualifier: "field1", value: "XYZ"
    })
    mock.expect :mutate_row, res, [
      table_name: table_path(instance_id, table_id),
      row_key: row_key,
      mutations: [mutations],
      app_profile_id: app_profile_id
    ]

    _(table.mutate_row(entry)).must_equal true
    mock.verify
  end

  it "mutate row raises Google::Cloud::Error" do
    stub = Object.new
    def stub.mutate_row *args
      raise Google::Cloud::InvalidArgumentError.new("Invalid id for collection columnFamilies")
    end
    table.service.mocked_client = stub

    row_key = "user-1"
    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    entry.set_cell("cf1-BAD ", "field1", "XYZ")


    assert_raises Google::Cloud::InvalidArgumentError do
      _(table.mutate_row(entry)).must_equal true
    end
  end
end
