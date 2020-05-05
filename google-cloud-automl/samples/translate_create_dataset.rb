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

def translate_create_dataset actual_project_id:, actual_display_name:
  # Create a dataset.
  # [START automl_translate_create_dataset]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  display_name = "YOUR_DATASET_NAME"
  # [END automl_translate_create_dataset]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  display_name = actual_display_name
  # [START automl_translate_create_dataset]

  client = Google::Cloud::AutoML::AutoML.new

  # A resource that represents Google Cloud Platform location.
  project_location = client.class.location_path project_id, "us-central1"
  dataset = {
    display_name:                 display_name,
    translation_dataset_metadata: {
      source_language_code: "en",
      target_language_code: "ja"
    }
  }

  # Create a dataset with the dataset metadata in the region.
  created_dataset = client.create_dataset project_location, dataset

  # Display the dataset information
  puts "Dataset name: #{created_dataset.name}"
  puts "Dataset id: #{created_dataset.name.split('/').last}"
  # [END automl_translate_create_dataset]

  # Return the dataset_id so it can be used in subsequent calls.
  created_dataset.name.split("/").last
end
