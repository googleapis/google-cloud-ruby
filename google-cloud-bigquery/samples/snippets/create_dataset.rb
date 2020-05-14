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
# [START bigquery_create_dataset]
require "google/cloud/bigquery"

def create_dataset dataset_id = "my_dataset", location = "US"
  bigquery = Google::Cloud::Bigquery.new

  # Create the dataset in a specified geographic location
  bigquery.create_dataset dataset_id, location: location

  puts "Created dataset: #{dataset_id}"
end
# [END bigquery_create_dataset]
