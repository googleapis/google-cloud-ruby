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

def get_model_evaluation actual_project_id:, actual_model_id:, actual_model_evaluation_id:
  # Get model evaluation.
  # [START automl_language_entity_extraction_get_model_evaluation]
  # [START automl_language_sentiment_analysis_get_model_evaluation]
  # [START automl_language_text_classification_get_model_evaluation]
  # [START automl_translate_get_model_evaluation]
  # [START automl_vision_classification_get_model_evaluation]
  # [START automl_vision_object_detection_get_model_evaluation]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  model_evaluation_id = "YOUR_MODEL_EVALUATION_ID"
  # [END automl_language_entity_extraction_get_model_evaluation]
  # [END automl_language_sentiment_analysis_get_model_evaluation]
  # [END automl_language_text_classification_get_model_evaluation]
  # [END automl_translate_get_model_evaluation]
  # [END automl_vision_classification_get_model_evaluation]
  # [END automl_vision_object_detection_get_model_evaluation]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  model_evaluation_id = actual_model_evaluation_id
  # [START automl_language_entity_extraction_get_model_evaluation]
  # [START automl_language_sentiment_analysis_get_model_evaluation]
  # [START automl_language_text_classification_get_model_evaluation]
  # [START automl_translate_get_model_evaluation]
  # [START automl_vision_classification_get_model_evaluation]
  # [START automl_vision_object_detection_get_model_evaluation]

  client = Google::Cloud::AutoML::AutoML.new

  # Get the full path of the model evaluation.
  model_evaluation_full_id = client.class.model_evaluation_path project_id, "us-central1", model_id, model_evaluation_id

  # Get complete detail of the model evaluation.
  model_evaluation = client.get_model_evaluation model_evaluation_full_id

  puts "Model evaluation name: #{model_evaluation.name}"
  puts "Model annotation spec id: #{model_evaluation.annotation_spec_id}"
  puts "Create Time: #{model_evaluation.create_time.to_time}"
  puts "Evaluation example count: #{model_evaluation.evaluated_example_count}"
  # [END automl_language_sentiment_analysis_get_model_evaluation]
  # [END automl_language_text_classification_get_model_evaluation]
  # [END automl_translate_get_model_evaluation]
  # [END automl_vision_classification_get_model_evaluation]
  # [END automl_vision_object_detection_get_model_evaluation]
  puts "Entity extraction model evaluation metrics: #{model_evaluation.text_extraction_evaluation_metrics}"
  # [END automl_language_entity_extraction_get_model_evaluation]

  # [START automl_language_sentiment_analysis_get_model_evaluation]
  puts "Sentiment analysis model evaluation metrics: #{model_evaluation.text_sentiment_evaluation_metrics}"
  # [END automl_language_sentiment_analysis_get_model_evaluation]

  # [START automl_language_text_classification_get_model_evaluation]
  # [START automl_vision_classification_get_model_evaluation]
  puts "Classification model evaluation metrics: #{model_evaluation.classification_evaluation_metrics}"
  # [END automl_language_text_classification_get_model_evaluation]
  # [END automl_vision_classification_get_model_evaluation]

  # [START automl_translate_get_model_evaluation]
  puts "Translation model evaluation metrics: #{model_evaluation.translation_evaluation_metrics}"
  # [END automl_translate_get_model_evaluation]

  # [START automl_vision_object_detection_get_model_evaluation]
  puts "Object detection model evaluation metrics: #{model_evaluation.image_object_detection_evaluation_metrics}"
  # [END automl_vision_object_detection_get_model_evaluation]
end
