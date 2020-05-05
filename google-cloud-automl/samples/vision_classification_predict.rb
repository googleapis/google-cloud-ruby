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


def classification_predict actual_project_id:, actual_model_id:, actual_file_path:
  # Predict.
  # [START automl_vision_classification_predict]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  file_path = "path_to_local_file.jpg"
  # [END automl_vision_classification_predict]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  file_path = actual_file_path
  # [START automl_vision_classification_predict]

  prediction_client = Google::Cloud::AutoML::Prediction.new

  # Get the full path of the model.
  model_full_id = prediction_client.model_path project: project_id, location: "us-central1", model: model_id

  # Read the file.
  content = File.binread file_path
  payload = {
    image: {
      image_bytes: content
    }
  }
  # params is additional domain-specific parameters.
  # score_threshold is used to filter the result
  params = { "score_threshold" => "0.8" }

  response = prediction_client.predict model_full_id, payload, params

  puts "Prediction results:"
  response.payload.each do |result|
    puts "Predicted class name: #{result.display_name}"
    puts "Predicted class score: #{result.classification.score}"
  end
  # [END automl_vision_classification_predict]
end
