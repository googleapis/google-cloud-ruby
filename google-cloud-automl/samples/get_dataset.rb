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

def get_dataset actual_project_id:, actual_dataset_id:
  # Get a dataset.
  # [START automl_language_entity_extraction_get_dataset]
  # [START automl_language_sentiment_analysis_get_dataset]
  # [START automl_language_text_classification_get_dataset]
  # [START automl_translate_get_dataset]
  # [START automl_vision_classification_get_dataset]
  # [START automl_vision_object_detection_get_dataset]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  dataset_id = "YOUR_DATASET_ID"
  # [END automl_language_entity_extraction_get_dataset]
  # [END automl_language_sentiment_analysis_get_dataset]
  # [END automl_language_text_classification_get_dataset]
  # [END automl_translate_get_dataset]
  # [END automl_vision_classification_get_dataset]
  # [END automl_vision_object_detection_get_dataset]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  dataset_id = actual_dataset_id
  # [START automl_language_entity_extraction_get_dataset]
  # [START automl_language_sentiment_analysis_get_dataset]
  # [START automl_language_text_classification_get_dataset]
  # [START automl_translate_get_dataset]
  # [START automl_vision_classification_get_dataset]
  # [START automl_vision_object_detection_get_dataset]

  client = Google::Cloud::AutoML::AutoML.new
  # Get the full path of the dataset
  dataset_full_id = client.dataset_path project: project_id, location: "us-central1", dataset: dataset_id
  dataset = client.get_dataset dataset_full_id

  # Display the dataset information
  puts "Dataset name: #{dataset.name}"
  puts "Dataset id: #{dataset.name.split('/').last}"
  puts "Dataset display name: #{dataset.display_name}"
  puts "Dataset create time: #{dataset.create_time.to_time}"
  # [END automl_language_sentiment_analysis_get_dataset]
  # [END automl_language_text_classification_get_dataset]
  # [END automl_translate_get_dataset]
  # [END automl_vision_classification_get_dataset]
  # [END automl_vision_object_detection_get_datset]
  puts "Text extraction dataset metadata: #{dataset.text_extraction_dataset_metadata}"
  # [END automl_language_entity_extraction_get_dataset]

  # [START automl_language_sentiment_analysis_get_dataset]
  puts "Text sentiment dataset metadata: #{dataset.text_sentiment_dataset_metadata}"
  # [END automl_language_sentiment_analysis_get_dataset]

  # [START automl_language_text_classification_get_dataset]
  puts "Text classification dataset metadata: #{dataset.text_classification_dataset_metadata}"
  # [END automl_language_text_classification_get_dataset]

  # [START automl_translate_get_dataset]
  if dataset.translation_dataset_metadata
    puts "Translation dataset metadata:"
    puts "\tsource_language_code: #{dataset.translation_dataset_metadata.source_language_code}"
    puts "\ttarget_language_code: #{dataset.translation_dataset_metadata.target_language_code}"
  end
  # [END automl_translate_get_dataset]

  # [START automl_vision_classification_get_dataset]
  puts "Image classification dataset metadata: #{dataset.image_classification_dataset_metadata}"
  # [END automl_vision_classification_get_dataset]

  # [START automl_vision_object_detection_get_dataset]
  puts "Image object detection dataset metadata: #{dataset.image_object_detection_dataset_metadata}"
  # [END automl_vision_object_detection_get_dataset]
end
