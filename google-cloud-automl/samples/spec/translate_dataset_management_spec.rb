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

require_relative "../translate_create_dataset"
require_relative "../import_dataset"
require_relative "../delete_dataset"
require_relative "../list_datasets"
require_relative "../get_dataset"
require_relative "../export_dataset"

require "spec_helper"
require "google/cloud/storage"

describe "Translate Dataset Management" do
  let(:project_id) { ENV["AUTOML_PROJECT_ID"] }
  let(:dataset_id) { ENV["AUTOML_TRANSLATE_DATASET_ID"] }
  let(:storage) { Google::Cloud::Storage.new project_id: project_id }
  let(:bucket) { storage.bucket ENV["AUTOML_BUCKET_NAME"] }

  example "Get a dataset" do
    capture do
      get_dataset actual_project_id: project_id, actual_dataset_id: dataset_id
    end
    expect(captured_output).to include "Dataset id: #{dataset_id}"
  end

  example "Create, import, delete a dataset", :slow do
    dataset_name = "test_#{Time.now.strftime '%Y%m%d%H%M%S'}"
    train_url = ensure_import_file! bucket, "en-ja-train.tmx"
    validation_url = ensure_import_file! bucket, "en-ja-validation.tmx"
    test_url = ensure_import_file! bucket, "en-ja-test.tmx"
    import_io = StringIO.new("TRAIN,#{train_url}\nVALIDATION,#{validation_url}\nTEST,#{test_url}")
    import_file = ensure_import_file! bucket, "en-ja.csv", import_io

    dataset_id = nil
    capture do
      dataset_id = translate_create_dataset actual_project_id: project_id, actual_display_name: dataset_name
    end
    expect(captured_output).to match /Dataset name: projects\/(\d+)\/locations\/us-central1\/datasets\/#{dataset_id}/
    expect(captured_output).to include "Dataset id: #{dataset_id}"

    capture do
      import_dataset actual_project_id: project_id, actual_dataset_id: dataset_id, actual_path: import_file
    end
    expect(captured_output).to include "Data imported."

    capture do
      delete_dataset actual_project_id: project_id, actual_dataset_id: dataset_id
    end
    expect(captured_output).to include "Dataset deleted."
  end

  example "List datasets" do
    capture do
      list_datasets actual_project_id: project_id
    end
    expect(captured_output).to include "Dataset id: #{dataset_id}"
  end

  example "Export a dataset", :slow do
    export_path = "export/#{Time.now.strftime '%Y%m%d%H%M%S'}/"
    gcs_uri = "gs://#{bucket.name}/#{export_path}"

    capture do
      export_dataset actual_project_id: project_id, actual_dataset_id: dataset_id, actual_gcs_uri: gcs_uri
    end
    expect(captured_output).to include "Dataset exported."

    cleanup_bucket_prefix! bucket.name, export_path
  end
end
