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

require_relative "../language_batch_predict"
require_relative "../language_entity_extraction_predict"

require "spec_helper"
require "google/cloud/storage"

describe "Language Entity Extraction Predict" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:model_id) { ENV["AUTOML_EXTRACTION_MODEL_ID"] }
  let(:storage) { Google::Cloud::Storage.new project_id: project_id }
  let(:bucket) { storage.bucket ENV["AUTOML_BUCKET_NAME"] }
  let(:batch_jsonl_file) { "batch-extraction.jsonl" }

  example "Predict" do
    text = "Constitutional mutations in the WT1 gene in patients with Denys-Drash syndrome."

    capture do
      entity_extraction_predict actual_project_id: project_id, actual_model_id: model_id, actual_content: text
    end
    expect(captured_output).to include "Text Extract Entity Types: "
    expect(captured_output).to include "Text Score: "
    expect(captured_output).to include "Text Extract Entity Content: "
    expect(captured_output).to include "Text Start Offset: "
    expect(captured_output).to include "Text End Offset: "
  end

  example "Batch Predict", :slow do
    batch_file = ensure_import_file! bucket, batch_jsonl_file
    export_path = "export/#{Time.now.strftime '%Y%m%d%H%M%S'}/"
    output_uri = "gs://#{bucket.name}/#{export_path}"

    capture do
      language_batch_predict actual_project_id: project_id, actual_model_id: model_id,
                             actual_input_uri: batch_file, actual_output_uri: output_uri
    end
    expect(captured_output).to include "Batch Prediction results saved to Cloud Storage bucket"

    cleanup_bucket_prefix! bucket.name, export_path
  end
end
