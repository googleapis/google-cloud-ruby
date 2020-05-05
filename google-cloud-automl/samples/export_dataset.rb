# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def export_dataset actual_project_id:, actual_dataset_id:, actual_gcs_uri:
  # Export a dataset.
  # [START automl_export_dataset]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  dataset_id = "YOUR_DATASET_ID"
  gcs_uri = "gs://BUCKET_ID/path_to_export/"
  # [END automl_export_dataset]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  dataset_id = actual_dataset_id
  gcs_uri = actual_gcs_uri
  # [START automl_export_dataset]

  client = Google::Cloud::AutoML::AutoML.new

  # Get the full path of the dataset
  dataset_full_id = client.dataset_path project: project_id, location: "us-central1", dataset: dataset_id
  output_config = {
    gcs_destination: {
      output_uri_prefix: gcs_uri
    }
  }

  operation = client.export_data dataset_full_id, output_config

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Dataset exported."
  # [END automl_export_dataset]
end
