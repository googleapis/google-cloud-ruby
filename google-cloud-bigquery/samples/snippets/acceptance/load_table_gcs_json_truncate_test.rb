# Copyright 2020 Google LLC
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

require_relative "../load_table_gcs_json"
require_relative "../load_table_gcs_json_truncate"
require_relative "helper"


describe "Load table from JSON file on GCS and replace existing table data" do
  before do
    @dataset = create_temp_dataset
  end

  it "loads table from JSON file on GCS and replace existing table data" do
    load_table_gcs_json @dataset.dataset_id
    table = @dataset.tables.first
    assert_equal 50, table.rows_count

    output = capture_io do
      load_table_gcs_json_truncate @dataset.dataset_id, table.table_id
    end

    table.reload!
    assert_match table.table_id, output.first
    assert_match "50 rows", output.first
  end
end
