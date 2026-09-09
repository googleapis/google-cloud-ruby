# Copyright 2025 Google LLC
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

require_relative "helper"
require_relative "../export_model"
require "google/cloud/storage"

describe "Export model" do
  let(:bigquery) { Google::Cloud::Bigquery.new }
  let(:storage) { Google::Cloud::Storage.new }
  let(:bucket_name) { "test_bucket_#{time_plus_random}" }
  let(:model_id) { "test_model_#{time_plus_random}" }
  let(:table_id) { "test_table_#{time_plus_random}" }

  before do
    @dataset = create_temp_dataset
    @bucket = storage.create_bucket bucket_name

    # Create table and insert data
    @table = @dataset.create_table table_id do |t|
      t.schema do |s|
        s.integer "input_col", mode: :required
        s.integer "label_col", mode: :required
      end
    end
    @table.insert [{ "input_col" => 1, "label_col" => 2 }, { "input_col" => 2, "label_col" => 4 }]

    # Create model
    create_model_sql = "
    CREATE OR REPLACE MODEL `#{@dataset.dataset_id}.#{model_id}`
    OPTIONS(model_type='linear_reg', input_label_cols=['label_col']) AS
    SELECT
      input_col,
      label_col
    FROM
      `#{@dataset.dataset_id}.#{table_id}`
    "
    job = bigquery.query_job create_model_sql
    job.wait_until_done!
  end

  after do
    @bucket.files.each(&:delete)
    @bucket.delete
  end

  it "extracts a model to GCS" do
    destination_uri = "gs://#{bucket_name}/extract-model-test-output"
    assert_output(/Model extracted successfully/) do
      export_model @dataset.dataset_id, model_id, destination_uri
    end

    assert @bucket.files(prefix: "extract-model-test-output/").any?,
           "Expected to find extracted model files in the bucket"
  end
end
