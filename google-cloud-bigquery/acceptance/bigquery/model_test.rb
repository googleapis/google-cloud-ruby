# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "bigquery_helper"

describe Google::Cloud::Bigquery, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:model_id) { "model_#{SecureRandom.hex(4)}" }
  let :model_sql do
    model_sql = <<~MODEL_SQL
    CREATE MODEL #{dataset.dataset_id}.#{model_id}
    OPTIONS (
        model_type='linear_reg',
        max_iteration=1,
        learn_rate=0.4,
        learn_rate_strategy='constant'
    ) AS (
        SELECT 'a' AS f1, 2.0 AS label
        UNION ALL
        SELECT 'b' AS f1, 3.8 AS label
    )
    MODEL_SQL
  end

  it "can create, list, read, update, and delete a model" do
    query_job = dataset.query_job model_sql
    query_job.wait_until_done!
    _(query_job).wont_be :failed?

    # can find the model in the list of models
    _(dataset.models.all.map(&:model_id)).must_include model_id

    # can get the model
    model = dataset.model model_id
    _(model).must_be_kind_of Google::Cloud::Bigquery::Model
    _(model.project_id).must_equal bigquery.project
    _(model.dataset_id).must_equal dataset.dataset_id
    _(model.model_id).must_equal model_id

    new_description = "Model was updated #{Time.now}"
    model.description = new_description
    model.refresh!
    _(model.description).must_equal new_description

    _(model.delete).must_equal true

    _(dataset.model(model_id)).must_be_nil
  end

  it "extracts itself to a GCS url with extract" do
    model = nil
    begin
      query_job = dataset.query_job model_sql
      query_job.wait_until_done!
      _(query_job).wont_be :failed?

      model = dataset.model model_id
      _(model).must_be_kind_of Google::Cloud::Bigquery::Model

      Tempfile.open "temp_extract_model" do |tmp|
        extract_url = "gs://#{bucket.name}/#{model_id}"

        # sut
        result = model.extract extract_url
        _(result).must_equal true

        extract_files = bucket.files prefix: model_id
        _(extract_files).wont_be :nil?
        _(extract_files).wont_be :empty?
        extract_file = extract_files.find { |f| f.name == "#{model_id}/saved_model.pb" }
        _(extract_file).wont_be :nil?
        downloaded_file = extract_file.download tmp.path
        _(downloaded_file.size).must_be :>, 0
      end
    ensure
      # cleanup
      model.delete if model
    end
  end

  it "extracts itself to a GCS url with extract_job" do
    model = nil
    begin
      query_job = dataset.query_job model_sql
      query_job.wait_until_done!
      _(query_job).wont_be :failed?

      model = dataset.model model_id
      _(model).must_be_kind_of Google::Cloud::Bigquery::Model

      Tempfile.open "temp_extract_model" do |tmp|
        extract_url = "gs://#{bucket.name}/#{model_id}"

        # sut
        extract_job = model.extract_job extract_url

        extract_job.wait_until_done!
        _(extract_job).wont_be :failed?
        _(extract_job.ml_tf_saved_model?).must_equal true
        _(extract_job.ml_xgboost_booster?).must_equal false
        _(extract_job.model?).must_equal true
        _(extract_job.table?).must_equal false

        source = extract_job.source
        _(source).must_be_kind_of Google::Cloud::Bigquery::Model
        _(source.model_id).must_equal model_id

        extract_files = bucket.files prefix: model_id
        _(extract_files).wont_be :nil?
        _(extract_files).wont_be :empty?
        extract_file = extract_files.find { |f| f.name == "#{model_id}/saved_model.pb" }
        _(extract_file).wont_be :nil?
        downloaded_file = extract_file.download tmp.path
        _(downloaded_file.size).must_be :>, 0
      end
    ensure
      # cleanup
      model.delete if model
    end
  end
end
