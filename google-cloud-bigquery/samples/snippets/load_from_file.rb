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
# [START bigquery_load_from_file]
require "google/cloud/bigquery"

def load_from_file dataset_id = "your_dataset_id",
                   file_path  = "path/to/file.csv"
  bigquery = Google::Cloud::Bigquery.new
  dataset  = bigquery.dataset dataset_id
  table_id = "new_table_id"

  # Infer the config.location based on the location of the referenced dataset.
  load_job = dataset.load_job table_id, file_path do |config|
    config.skip_leading = 1
    config.autodetect   = true
  end
  load_job.wait_until_done! # Waits for table load to complete.

  table = dataset.table table_id
  puts "Loaded #{table.rows_count} rows into #{table.id}"
end
# [END bigquery_load_from_file]
