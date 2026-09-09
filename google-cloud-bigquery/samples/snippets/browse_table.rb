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
# [START bigquery_browse_table]
require "google/cloud/bigquery"

def browse_table
  bigquery = Google::Cloud::Bigquery.new project_id: "bigquery-public-data"
  dataset  = bigquery.dataset "samples"
  table    = dataset.table "shakespeare"

  # Load all rows from a table
  rows = table.data

  # Load the first 10 rows
  rows = table.data max: 10

  # Print row data
  rows.each { |row| puts row }
end
# [END bigquery_browse_table]
