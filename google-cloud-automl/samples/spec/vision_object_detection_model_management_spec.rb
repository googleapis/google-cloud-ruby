# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../vision_object_detection_create_model"
require_relative "../deploy_model"
require_relative "../undeploy_model"
require_relative "../vision_object_detection_deploy_model_node_count"

require "spec_helper"

describe "Vision Object Detection Model Management" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:dataset_id) { ENV["AUTOML_VISION_OBJECT_DATASET_ID"] }
  let(:model_id) { ENV["AUTOML_VISION_OBJECT_MODEL_ID"] }

  example "Create a model", :slow do
    display_name = "test_create_model#{Time.now.strftime '%Y%m%d%H%M%S'}"
    operation_name = nil

    capture do
      object_detection_create_model actual_project_id: project_id, actual_dataset_id: dataset_id,
                                    actual_display_name: display_name
    end

    expect(captured_output).to include "Training started..."
    expect(captured_output).to include "Training complete."
  end

  example "Undeploy and deploy a model", :slow do
    capture do
      undeploy_model actual_project_id: project_id, actual_model_id: model_id
    end
    expect(captured_output).to include "Model undeployment finished."

    capture do
      deploy_model actual_project_id: project_id, actual_model_id: model_id
    end
    expect(captured_output).to include "Model deployment finished."
  end

  example "Undeploy and deploy a model with node count", :slow do
    capture do
      undeploy_model actual_project_id: project_id, actual_model_id: model_id
    end
    expect(captured_output).to include "Model undeployment finished."

    capture do
      object_detection_deploy_model_node_count actual_project_id: project_id, actual_model_id: model_id
    end
    expect(captured_output).to include "Model deployment finished."
  end
end
