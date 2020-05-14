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

# [START bigquery_table_insert_rows]
require "google/cloud/bigquery"

def table_insert_rows dataset_id = "your_dataset_id", table_id = "your_table_id"
  bigquery = Google::Cloud::Bigquery.new
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  row_data = [
    { name: "Alice", value: 5  },
    { name: "Bob",   value: 10 }
  ]
  response = table.insert row_data

  if response.success?
    puts "Inserted rows successfully"
  else
    puts "Failed to insert #{response.error_rows.count} rows"
  end
end
# [END bigquery_table_insert_rows]
