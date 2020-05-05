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

def list_datasets actual_project_id:
  # List datasets.
  # [START automl_language_entity_extraction_list_datasets]
  # [START automl_language_sentiment_analysis_list_datasets]
  # [START automl_language_text_classification_list_datasets]
  # [START automl_translate_list_datasets]
  # [START automl_vision_classification_list_datasets]
  # [START automl_vision_object_detection_list_datasets]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  # [END automl_language_entity_extraction_list_datasets]
  # [END automl_language_sentiment_analysis_list_datasets]
  # [END automl_language_text_classification_list_datasets]
  # [END automl_translate_list_datasets]
  # [END automl_vision_classification_list_datasets]
  # [END automl_vision_object_detection_list_datasets]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  # [START automl_language_entity_extraction_list_datasets]
  # [START automl_language_sentiment_analysis_list_datasets]
  # [START automl_language_text_classification_list_datasets]
  # [START automl_translate_list_datasets]
  # [START automl_vision_classification_list_datasets]
  # [START automl_vision_object_detection_list_datasets]

  client = Google::Cloud::AutoML::AutoML.new

  # A resource that represents Google Cloud Platform location.
  project_location = client.class.location_path project_id, "us-central1"

  # List all the datasets available in the region.
  datasets = client.list_datasets project_location

  puts "List of datasets:"

  datasets.each do |dataset|
    puts "Dataset name: #{dataset.name}"
    puts "Dataset id: #{dataset.name.split('/').last}"
    puts "Dataset display name: #{dataset.display_name}"
    puts "Dataset create time: #{dataset.create_time.to_time}"
    # [END automl_language_sentiment_analysis_list_datasets]
    # [END automl_language_text_classification_list_datasets]
    # [END automl_translate_list_datasets]
    # [END automl_vision_classification_list_datasets]
    # [END automl_vision_object_detection_list_datasets]
    puts "Text extraction dataset metadata: #{dataset.text_extraction_dataset_metadata}"
    # [END automl_language_entity_extraction_list_datasets]

    # [START automl_language_sentiment_analysis_list_datasets]
    puts "Text sentiment dataset metadata: #{dataset.text_sentiment_dataset_metadata}"
    # [END automl_language_sentiment_analysis_list_datasets]

    # [START automl_language_text_classification_list_datasets]
    puts "Text classification dataset metadata: #{dataset.text_classification_dataset_metadata}"
    # [END automl_language_text_classification_list_datasets]

    if dataset.translation_dataset_metadata
      # [START automl_translate_list_datasets]
      puts "Translation dataset metadata:"
      puts "\tsource_language_code: #{dataset.translation_dataset_metadata.source_language_code}"
      puts "\ttarget_language_code: #{dataset.translation_dataset_metadata.target_language_code}"
      # [END automl_translate_list_datasets]
    end

    # [START automl_vision_classification_list_datasets]
    puts "Image classification dataset metadata: #{dataset.image_classification_dataset_metadata}"
    # [END automl_vision_classification_list_datasets]

    # [START automl_vision_object_detection_list_datasets]
    puts "Image object detection dataset metadata: #{dataset.image_object_detection_dataset_metadata}"
    # [END automl_vision_object_detection_list_datasets]

    # [START automl_language_entity_extraction_list_datasets]
    # [START automl_language_sentiment_analysis_list_datasets]
    # [START automl_language_text_classification_list_datasets]
    # [START automl_translate_list_datasets]
    # [START automl_vision_classification_list_datasets]
    # [START automl_vision_object_detection_list_datasets]
  end
  # [END automl_language_entity_extraction_list_datasets]
  # [END automl_language_sentiment_analysis_list_datasets]
  # [END automl_language_text_classification_list_datasets]
  # [END automl_translate_list_datasets]
  # [END automl_vision_classification_list_datasets]
  # [END automl_vision_object_detection_list_datasets]
end
