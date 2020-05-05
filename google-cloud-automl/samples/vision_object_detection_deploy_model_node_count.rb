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

def object_detection_deploy_model_node_count actual_project_id:, actual_model_id:
  # Deploy a model with a specified node count.
  # [START automl_vision_object_detection_deploy_model_node_count]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  # [END automl_vision_object_detection_deploy_model_node_count]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  # [START automl_vision_object_detection_deploy_model_node_count]

  client = Google::Cloud::AutoML::AutoML.new
  # Get the full path of the model.
  model_full_id = client.model_path project: project_id, location: "us-central1", model: model_id
  metadata = { node_count: 2 }
  operation = client.deploy_model(
    model_full_id,
    image_object_detection_model_deployment_metadata: metadata
  )

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Model deployment finished."
  # [END automl_vision_object_detection_deploy_model_node_count]
end
