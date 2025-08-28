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

# [START bigquery_export_model]
def export_model dataset_id, model_id, destination_uri
  # dataset_id      = "your-dataset-id"
  # model_id        = "your-model-id"
  # destination_uri = "gs://your-bucket/path/to/your-model"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new
  dataset = bigquery.dataset dataset_id
  model = dataset.model model_id

  puts "Extracting model #{model.model_id} to #{destination_uri}"

  success = model.extract destination_uri

  if success
    puts "Model extracted successfully"
  else
    puts "Error extracting model"
  end
end
# [END bigquery_export_model]
