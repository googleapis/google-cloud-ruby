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

def list_models actual_project_id:
  # List models.
  # [START automl_list_models]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  # [END automl_list_models]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  # [START automl_list_models]

  client = Google::Cloud::AutoML::AutoML.new
  # A resource that represents Google Cloud Platform location.
  project_location = client.class.location_path project_id, "us-central1"
  models = client.list_models project_location

  puts "List of models:"

  models.each do |model|
    # Display the model information.
    deployment_state = if model.deployment_state == :DEPLOYED
                         "deployed"
                       else
                         "undeployed"
                       end

    puts "Model name: #{model.name}"
    puts "Model id: #{model.name.split('/').last}"
    puts "Model display name: #{model.display_name}"
    puts "Model create time: #{model.create_time.to_time}"
    puts "Model deployment state: #{deployment_state}"
  end
  # [END automl_list_models]
end
