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

def predict actual_project_id:, actual_model_id:, actual_file_path:
  # Predict.
  # [START automl_translate_predict]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  file_path = "path_to_local_file.txt"
  # [START automl_translate_predict]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  file_path = actual_file_path
  # [START automl_translate_predict]

  prediction_client = Google::Cloud::AutoML::Prediction.new

  # Get the full path of the model.
  model_full_id = prediction_client.model_path project: project_id, location: "us-central1", model: model_id

  # Read the file content for translation.
  content = File.read file_path

  payload = {
    text_snippet: {
      content: content
    }
  }

  response = prediction_client.predict model_full_id, payload
  translated_content = response.payload[0].translation.translated_content

  puts "Translated content: #{translated_content.content}"
  # [END automl_translate_predict]
end
