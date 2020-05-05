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

def object_detection_create_model actual_project_id:, actual_dataset_id:, actual_display_name:
  # Create a model.
  # [START automl_vision_object_detection_create_model]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  dataset_id = "YOUR_DATASET_ID"
  display_name = "YOUR_MODEL_NAME"
  # [END automl_vision_object_detection_create_model]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  dataset_id = actual_dataset_id
  display_name = actual_display_name
  # [START automl_vision_object_detection_create_model]

  client = Google::Cloud::AutoML::AutoML.new

  # A resource that represents Google Cloud Platform location.
  project_location = client.class.location_path project_id, "us-central1"
  # Leave model unset to use the default base model provided by Google
  model = {
    display_name:                          display_name,
    dataset_id:                            dataset_id,
    image_object_detection_model_metadata: {}
  }

  # Create a model with the model metadata in the region.
  operation = client.create_model project_location, model
  # [END automl_vision_object_detection_create_model]
  # Cancel the operation immediately as it take a very long time to complete
  operation.cancel
  # [START automl_vision_object_detection_create_model]

  puts "Training started..."

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Training complete."
  # [END automl_vision_object_detection_create_model]
end
