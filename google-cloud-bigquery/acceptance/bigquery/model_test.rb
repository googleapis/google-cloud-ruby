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
    job = dataset.query_job model_sql
    job.wait_until_done!
    job.wont_be :failed?

    # can find the model in the list of models
    dataset.models.all.map(&:model_id).must_include model_id

    # can get the model
    model = dataset.model model_id
    model.must_be_kind_of Google::Cloud::Bigquery::Model
    model.project_id.must_equal bigquery.project
    model.dataset_id.must_equal dataset.dataset_id
    model.model_id.must_equal model_id

    new_description = "Model was updated #{Time.now}"
    model.description = new_description
    model.refresh!
    model.description.must_equal new_description

    model.delete.must_equal true

    dataset.model(model_id).must_be_nil
  end
end
