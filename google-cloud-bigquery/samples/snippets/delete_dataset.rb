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
# [START bigquery_delete_dataset]
require "google/cloud/bigquery"

def delete_dataset dataset_id = "my_empty_dataset"
  bigquery = Google::Cloud::Bigquery.new

  # Delete a dataset that does not contain any tables
  dataset = bigquery.dataset dataset_id
  dataset.delete
  puts "Dataset #{dataset_id} deleted."
end
# [END bigquery_delete_dataset]
