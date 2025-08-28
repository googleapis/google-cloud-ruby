# Copyright 2025 Google LLC
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

# [START bigquery_create_table_range_partitioned]
def create_range_partitioned_table dataset_id, table_id
  # dataset_id = "your-dataset-id"
  # table_id   = "your-table-id"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new
  dataset = bigquery.dataset dataset_id

  table = dataset.create_table table_id do |t|
    t.schema do |s|
      s.integer "integerField", mode: :required
      s.string "stringField", mode: :nullable
      s.boolean "booleanField", mode: :nullable
      s.date "dateField", mode: :nullable
    end
    t.range_partitioning_field = "integerField"
    t.range_partitioning_start = 1
    t.range_partitioning_interval = 2
    t.range_partitioning_end = 10
  end

  puts "Created range-partitioned table: #{table.table_id}"
end
# [END bigquery_create_table_range_partitioned]
