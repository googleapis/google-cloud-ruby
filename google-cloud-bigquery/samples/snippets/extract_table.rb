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
# [START bigquery_extract_table]
require "google/cloud/bigquery"

def extract_table bucket_name = "my-bucket",
                  dataset_id  = "my_dataset_id",
                  table_id    = "my_table_id"
  bigquery = Google::Cloud::Bigquery.new
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table    table_id

  # Define a destination URI. Use a single wildcard URI if you think
  # your exported data will be larger than the 1 GB maximum value.
  destination_uri = "gs://#{bucket_name}/output-*.csv"

  extract_job = table.extract_job destination_uri do |config|
    # Location must match that of the source table.
    config.location = "US"
  end
  extract_job.wait_until_done! # Waits for the job to complete

  puts "Exported #{table.id} to #{destination_uri}"
end
# [END bigquery_extract_table]
