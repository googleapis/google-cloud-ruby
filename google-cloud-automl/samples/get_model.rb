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

def get_model actual_project_id:, actual_model_id:
  # Get a model.
  # [START automl_get_model]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  model_id = "YOUR_MODEL_ID"
  # [END automl_get_model]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  model_id = actual_model_id
  # [START automl_get_model]

  client = Google::Cloud::AutoML::AutoML.new

  # Get the full path of the model.
  model_full_id = client.model_path project: project_id, location: "us-central1", model: model_id

  model = client.get_model model_full_id

  # Retrieve deployment state.
  deployment_state = if model.deployment_state == :DEPLOYED
                       "deployed"
                     else
                       "undeployed"
                     end

  # Display the model information.
  puts "Model name: #{model.name}"
  puts "Model id: #{model.name.split('/').last}"
  puts "Model display name: #{model.display_name}"
  puts "Model create time: #{model.create_time.to_time}"
  puts "Model deployment state: #{deployment_state}"
  # [END automl_get_model]
end
