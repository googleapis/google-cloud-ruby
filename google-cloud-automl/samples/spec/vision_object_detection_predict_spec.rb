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

require_relative "../vision_batch_predict"
require_relative "../vision_object_detection_predict"

require "spec_helper"
require "google/cloud/storage"

describe "Vision Object Detection Predict" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:model_id) { ENV["AUTOML_VISION_OBJECT_MODEL_ID"] }
  let(:storage) { Google::Cloud::Storage.new project_id: project_id }
  let(:bucket) { storage.bucket ENV["AUTOML_BUCKET_NAME"] }

  example "Predict" do
    file_path = 'resources/salad.jpg'

    capture do
      object_detection_predict actual_project_id: project_id, actual_model_id: model_id, actual_file_path: file_path
    end
    expect(captured_output).to include "Predicted class name: "
    expect(captured_output).to include "Predicted class score: "
    expect(captured_output).to include "X: "
    expect(captured_output).to include "Y: "
  end

  example "Batch Predict", :slow do
    salad_url = ensure_import_file! bucket, "salad.jpg"
    input_io = StringIO.new(salad_url)
    input_file = ensure_import_file! bucket, "batch-vision_object.csv", input_io
    export_path = "export/#{Time.now.strftime '%Y%m%d%H%M%S'}/"
    output_uri = "gs://#{bucket.name}/#{export_path}"

    capture do
      vision_batch_predict actual_project_id: project_id, actual_model_id: model_id,
                           actual_input_uri: input_file, actual_output_uri: output_uri
    end
    expect(captured_output).to include "Batch Prediction results saved to Cloud Storage bucket"

    cleanup_bucket_prefix! bucket.name, export_path
  end
end
