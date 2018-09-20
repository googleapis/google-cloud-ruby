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


require "bigtable_helper"

describe "Table drop rows", :bigtable do
  it "delete all rows" do
    table_id = "test-table-#{random_str}"
    table = create_table(table_id, row_count: 2)
    table.delete_all_rows(timeout: 300).must_equal true

    rows = table.read_rows.to_a
    rows.must_be_empty
  end

  it "delete rows by prefix" do
    table_id = "test-table-#{random_str}"
    table = create_table(table_id, row_count: 2)
    table.delete_rows_by_prefix("test-1", timeout: 300).must_equal true

    rows = table.read_rows.to_a
    rows.length.must_equal 1
  end
end
