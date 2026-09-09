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

require "helper"
require "json"
require "uri"

describe Google::Cloud::Bigquery::Model, :metrics, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_hash) { random_model_partial_hash dataset, model_id }
  let(:model_full_hash) { random_model_full_hash dataset, model_id }
  let(:model) { Google::Cloud::Bigquery::Model.from_gapi_json model_full_hash, bigquery.service }

  it "exposes training runs" do
    _(model.training_runs.count).must_equal 1

    _(Time.parse(model.training_runs.first[:startTime])).must_be_close_to ::Time.now, 1

    _(model.training_runs.first[:evaluationMetrics]).must_be_kind_of Hash
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics]).must_be_kind_of Hash
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics][:meanAbsoluteError]).must_equal 0.58
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics][:meanSquaredError]).must_equal 0.628
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics][:meanSquaredLogError]).must_equal 0.035
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics][:medianAbsoluteError]).must_equal 0.04
    _(model.training_runs.first[:evaluationMetrics][:regressionMetrics][:rSquared]).must_equal 0.225

    _(model.training_runs.first[:results].count).must_equal 1
    _(model.training_runs.first[:results].first).must_be_kind_of Hash
    _(model.training_runs.first[:results].first[:durationMs]).must_equal 2531
    _(model.training_runs.first[:results].first[:evalLoss]).must_be_nil
    _(model.training_runs.first[:results].first[:index]).must_equal 0
    _(model.training_runs.first[:results].first[:trainingLoss]).must_equal 0.628

    _(model.training_runs.first[:trainingOptions]).must_be_kind_of Hash
    _(model.training_runs.first[:trainingOptions]).must_be_kind_of Hash
    _(model.training_runs.first[:trainingOptions][:earlyStop]).must_equal true
    _(model.training_runs.first[:trainingOptions][:l1Regularization]).must_equal 0
    _(model.training_runs.first[:trainingOptions][:l2Regularization]).must_equal 0
    _(model.training_runs.first[:trainingOptions][:learnRate]).must_equal 0.4
    _(model.training_runs.first[:trainingOptions][:learnRateStrategy]).must_equal "CONSTANT"
    _(model.training_runs.first[:trainingOptions][:lossType]).must_equal "MEAN_SQUARED_LOSS"
    _(model.training_runs.first[:trainingOptions][:maxIterations]).must_equal 1
    _(model.training_runs.first[:trainingOptions][:minRelativeProgress]).must_equal 0.01
    _(model.training_runs.first[:trainingOptions][:optimizationStrategy]).must_equal "BATCH_GRADIENT_DESCENT"
    _(model.training_runs.first[:trainingOptions][:warmStart]).must_equal false
  end
end
