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

describe Google::Cloud::Bigquery::Model, :columns, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_hash) { random_model_partial_hash dataset, model_id }
  let(:model_full_hash) { random_model_full_hash dataset, model_id }
  let(:model) { Google::Cloud::Bigquery::Model.from_gapi_json model_full_hash, bigquery.service }

  it "maps columns to primitive ruby values" do
    _(model.feature_columns.count).must_equal 1
    _(model.feature_columns[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(model.feature_columns[0].name).must_equal "f1"
    _(model.feature_columns[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(model.feature_columns[0].type.type_kind).must_equal "STRING"
    _(model.feature_columns[0].type.array_element_type).must_be_nil
    _(model.feature_columns[0].type.struct_type).must_be_nil

    _(model.label_columns.count).must_equal 1
    _(model.label_columns[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(model.label_columns[0].name).must_equal "predicted_label"
    _(model.label_columns[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(model.label_columns[0].type.type_kind).must_equal "FLOAT64"
    _(model.label_columns[0].type.array_element_type).must_be_nil
    _(model.label_columns[0].type.struct_type).must_be_nil
  end
end
