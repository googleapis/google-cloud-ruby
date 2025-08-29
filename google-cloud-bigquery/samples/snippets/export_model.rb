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
require "google/cloud/bigquery"

##
# Exports a model to a Google Cloud Storage bucket.
#
# @param dataset_id [String] The ID of the dataset that contains the model.
# @param model_id   [String] The ID of the model to export.
# @param destination_uri [String] The Google Cloud Storage bucket to export the model to.
def export_model dataset_id, model_id, destination_uri
  bigquery = Google::Cloud::Bigquery.new
  dataset = bigquery.dataset dataset_id
  model = dataset.model model_id

  puts "Extracting model #{model.model_id} to #{destination_uri}"
  job = model.extract_job destination_uri
  job.wait_until_done!

  if job.failed?
    puts "Error extracting model: #{job.error}"
  else
    puts "Model extracted successfully"
  end
end
# [END bigquery_export_model]
