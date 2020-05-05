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

require_relative "../list_models"
require_relative "../get_model"
require_relative "../list_model_evaluations"
require_relative "../get_model_evaluation"
# require_relative "../list_operation_status"
# require_relative "../get_operation_status"
require_relative "../delete_model"

require "spec_helper"

describe "Generic Model Management" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:model_id) { ENV["AUTOML_EXTRACTION_MODEL_ID"] }

  example "List models" do
    capture do
      list_models actual_project_id: project_id
    end
    expect(captured_output).to include "List of models:"
    expect(captured_output).to match /Model name: projects\/(\d+)\/locations\/us-central1\/models\/#{model_id}/
    expect(captured_output).to include "Model id: #{model_id}"
  end

  example "Get a model" do
    capture do
      get_model actual_project_id: project_id, actual_model_id: model_id
    end
    expect(captured_output).to match /Model name: projects\/(\d+)\/locations\/us-central1\/models\/#{model_id}/
    expect(captured_output).to include "Model id: #{model_id}"
  end

  example "Delete a model" do
    # As model creation can take many hours, instead try to delete a
    # nonexistent model and confirm that the model was not found, but other
    # elements of the request were valid.
    fake_model_id = "TRL0000000000000000000"

    expect do
      delete_model actual_project_id: project_id, actual_model_id: fake_model_id
    end.to raise_error Google::Gax::GaxError, /The model does not exist/
  end

  example "List model evaluations and get model evaluation" do
    capture do
      list_model_evaluations actual_project_id: project_id, actual_model_id: model_id
    end
    model_evaluation_regexp = /Model evaluation name: projects\/\d+\/locations\/us-central1\/models\/#{model_id}\/modelEvaluations\/(.*)/
    model_evaluation_id = captured_output.match(model_evaluation_regexp)[1]

    expect(captured_output).to include "List of model evaluations:"
    expect(captured_output).to match /Model evaluation name: projects\/(\d+)\/locations\/us-central1\/models\/#{model_id}\/modelEvaluations\/#{model_evaluation_id}/

    capture do
      get_model_evaluation actual_project_id: project_id, actual_model_id: model_id, actual_model_evaluation_id: model_evaluation_id
    end
    expect(captured_output).to match /Model evaluation name: projects\/(\d+)\/locations\/us-central1\/models\/#{model_id}\/modelEvaluations\/#{model_evaluation_id}/
  end

  # example "List operation status and get operation status" do
  #   capture do
  #     list_operation_status actual_project_id: project_id
  #   end
  #   operation_regexp = /operation name: projects\/\d+\/locations\/us-central1\/operations\/#{operation_id}\/operationEvaluations\/(.*)/
  #   operation_id = captured_output.match(operation_regexp)[1]
  #
  #   expect(captured_output).to include "List of operations:"
  #   expect(captured_output).to match /operation name: projects\/(\d+)\/locations\/us-central1\/operations\/#{operation_id}/
  #
  #   capture do
  #     get_operation_status actual_project_id: project_id, actual_operation_id: operation_id
  #   end
  #   expect(captured_output).to match /operation name: projects\/(\d+)\/locations\/us-central1\/operations\/#{operation_id}/
  # end
end
