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

describe Google::Cloud::Bigtable::Table, :check_and_mutate_row, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  it "check and mutate row" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    row_key = "user-1"
    predicate_filter = Google::Bigtable::V2::RowFilter.new(row_key_regex_filter: "user-1*")
    true_mutations = [
      Google::Bigtable::V2::Mutation.new(
        delete_from_column: { family_name: "cf", column_qualifier: "field1" }
      )
    ]
    false_mutations = [
      Google::Bigtable::V2::Mutation.new(delete_from_row: {})
    ]

    res = Google::Bigtable::V2::CheckAndMutateRowResponse.new(predicate_matched: true)
    mock.expect :check_and_mutate_row, res, [
      table_path(instance_id, table_id),
      row_key,
      predicate_filter: predicate_filter,
      true_mutations: true_mutations,
      false_mutations: false_mutations,
      app_profile_id: nil
    ]

    result = table.check_and_mutate_row(
      row_key,
      Google::Cloud::Bigtable::RowFilter.key("user-1*"),
      on_match: Google::Cloud::Bigtable::MutationEntry.new.delete_cells("cf", "field1"),
      otherwise: Google::Cloud::Bigtable::MutationEntry.new.delete_from_row
    )
    result.must_equal true
    mock.verify
  end
end
