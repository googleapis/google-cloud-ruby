# Copyright 2025 Google LLC
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

require "google/cloud/bigquery"
require_relative "helper"
require_relative "../inserting_data_types"

describe "Inserting data types" do
  let(:bigquery) { Google::Cloud::Bigquery.new }

  before do
    @dataset = create_temp_dataset
  end

  it "inserts various data types into a table" do
    table_id = "test_table_#{SecureRandom.hex 4}"

    assert_output "Rows successfully inserted into table\n" do
      inserting_data_types @dataset.dataset_id, table_id
    end

    table = @dataset.table table_id
    assert table
    assert_equal 1, table.data.all.count
    table.delete
  end
end
