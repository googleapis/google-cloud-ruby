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

def list_model_evaluations actual_project_id:, actual_model_id:
  # List model evaluations.
  # [START automl_language_entity_extraction_list_model_evaluations]
  # [START automl_language_sentiment_analysis_list_model_evaluations]
  # [START automl_language_text_classification_list_model_evaluations]
  # [START automl_translate_list_model_evaluations]
  # [START automl_vision_classification_list_model_evaluations]
  # [START automl_vision_object_detection_list_model_evaluations]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  # [END automl_language_entity_extraction_list_model_evaluations]
  # [END automl_language_sentiment_analysis_list_model_evaluations]
  # [END automl_language_text_classification_list_model_evaluations]
  # [END automl_translate_list_model_evaluations]
  # [END automl_vision_classification_list_model_evaluations]
  # [END automl_vision_object_detection_list_model_evaluations]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  # [START automl_language_entity_extraction_list_model_evaluations]
  # [START automl_language_sentiment_analysis_list_model_evaluations]
  # [START automl_language_text_classification_list_model_evaluations]
  # [START automl_translate_list_model_evaluations]
  # [START automl_vision_classification_list_model_evaluations]
  # [START automl_vision_object_detection_list_model_evaluations]

  client = Google::Cloud::AutoML::AutoML.new

  # Get the full path of the model.
  model_full_id = client.model_path project: project_id, location: "us-central1", model: model_id

  model_evaluations = client.list_model_evaluations model_full_id

  puts "List of model evaluations:"

  model_evaluations.each do |evaluation|
    puts "Model evaluation name: #{evaluation.name}"
    puts "Model annotation spec id: #{evaluation.annotation_spec_id}"
    puts "Create Time: #{evaluation.create_time.to_time}"
    puts "Evaluation example count: #{evaluation.evaluated_example_count}"
    # [END automl_language_sentiment_analysis_list_model_evaluations]
    # [END automl_language_text_classification_list_model_evaluations]
    # [END automl_translate_list_model_evaluations]
    # [END automl_vision_classification_list_model_evaluations]
    # [END automl_vision_object_detection_list_model_evaluations]
    puts "Entity extraction model evaluation metrics: #{evaluation.text_extraction_evaluation_metrics}"
    # [END automl_language_entity_extraction_list_model_evaluations]

    # [START automl_language_sentiment_analysis_list_model_evaluations]
    puts "Sentiment analysis model evaluation metrics: #{evaluation.text_sentiment_evaluation_metrics}"
    # [END automl_language_sentiment_analysis_list_model_evaluations]

    # [START automl_language_text_classification_list_model_evaluations]
    # [START automl_vision_classification_list_model_evaluations]
    puts "Classification model evaluation metrics: #{evaluation.classification_evaluation_metrics}"
    # [END automl_language_text_classification_list_model_evaluations]
    # [END automl_vision_classification_list_model_evaluations]

    # [START automl_translate_list_model_evaluations]
    puts "Translation model evaluation metrics: #{evaluation.translation_evaluation_metrics}"
    # [END automl_translate_list_model_evaluations]

    # [START automl_vision_object_detection_list_model_evaluations]
    puts "Object detection model evaluation metrics: #{evaluation.image_object_detection_evaluation_metrics}"
    # [END automl_vision_object_detection_list_model_evaluations]

    # [START automl_language_entity_extraction_list_model_evaluations]
    # [START automl_language_sentiment_analysis_list_model_evaluations]
    # [START automl_language_text_classification_list_model_evaluations]
    # [START automl_translate_list_model_evaluations]
    # [START automl_vision_classification_list_model_evaluations]
    # [START automl_vision_object_detection_list_model_evaluations]
  end
  # [END automl_language_entity_extraction_list_model_evaluations]
  # [END automl_language_sentiment_analysis_list_model_evaluations]
  # [END automl_language_text_classification_list_model_evaluations]
  # [END automl_translate_list_model_evaluations]
  # [END automl_vision_classification_list_model_evaluations]
  # [END automl_vision_object_detection_list_model_evaluations]
end
