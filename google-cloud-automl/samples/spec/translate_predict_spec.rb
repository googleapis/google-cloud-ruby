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

require_relative "../translate_predict"

require "spec_helper"

describe "Translate Predict" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:model_id) { ENV["AUTOML_TRANSLATE_MODEL_ID"] }

  example "Predict" do
    file_path = 'resources/input.txt'

    capture do
      predict actual_project_id: project_id, actual_model_id: model_id, actual_file_path: file_path
    end
    expect(captured_output).to include "Translated content: これがどう終わるか教えて"
  end
end
