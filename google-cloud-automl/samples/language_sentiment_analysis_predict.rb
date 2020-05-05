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

def sentiment_analysis_predict actual_project_id:, actual_model_id:, actual_content:
  # Predict.
  # [START automl_language_sentiment_analysis_predict]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  content = "text to predict"
  # [END automl_language_sentiment_analysis_predict]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  content = actual_content
  # [START automl_language_sentiment_analysis_predict]

  prediction_client = Google::Cloud::AutoML::Prediction.new

  # Get the full path of the model.
  model_full_id = prediction_client.model_path project: project_id, location: "us-central1", model: model_id
  payload = {
    text_snippet: {
      content:   content,
      # Types: 'text/plain', 'text/html'
      mime_type: "text/plain"
    }
  }

  response = prediction_client.predict model_full_id, payload

  response.payload.each do |annotation_payload|
    puts "Predicted class name: #{annotation_payload.display_name}"
    puts "Predicted sentiment score: #{annotation_payload.text_sentiment.sentiment}"
  end
  # [END automl_language_sentiment_analysis_predict]
end
