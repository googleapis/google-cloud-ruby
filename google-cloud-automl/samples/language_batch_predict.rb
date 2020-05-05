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

def batch_predict actual_project_id:, actual_model_id:, actual_input_uri:, actual_output_uri:
  # Batch Predict
  # [START automl_language_batch_predict]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  input_uri = "gs://YOUR_BUCKET_ID/path_to_your_input_file.jsonl"
  output_uri = "gs://YOUR_BUCKET_ID/path_to_save_results/"
  # [END automl_language_batch_predict]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  input_uri = actual_input_uri
  output_uri = actual_output_uri
  # [START automl_language_batch_predict]

  prediction_client = Google::Cloud::AutoML::Prediction.new

  # Get the full path of the model.
  model_full_id = prediction_client.model_path project: project_id, location: "us-central1", model: model_id
  input_config = {
    gcs_source: {
      input_uris: [input_uri]
    }
  }
  output_config = {
    gcs_destination: {
      output_uri_prefix: output_uri
    }
  }

  operation = prediction_client.batch_predict model_full_id, input_config, output_config

  puts "Waiting for operation to complete..."

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Batch Prediction results saved to Cloud Storage bucket."
  # [END automl_language_batch_predict]
end
