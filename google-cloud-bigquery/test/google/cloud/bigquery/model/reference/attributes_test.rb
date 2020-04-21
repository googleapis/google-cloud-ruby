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

describe Google::Cloud::Bigquery::Model, :reference, :attributes, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  let(:model) {Google::Cloud::Bigquery::Model.new_reference project, dataset, model_id, bigquery.service }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_type) { "KMEANS" }
  let(:model_name) { "My Model" }
  let(:description) { "This is my model" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { "foo" => "bar" } }
  let(:model_hash) { random_model_partial_hash dataset, model_id }
  let(:model_full_hash) { random_model_full_hash dataset, model_id, name: model_name, description: description }
  let(:model_gapi) { Google::Apis::BigqueryV2::Model.from_json model_full_hash.to_json }

  it "knows its attributes" do
    _(model.model_id).must_equal model_id
    _(model.dataset_id).must_equal dataset
    _(model.project_id).must_equal project
    # model_ref is private
    _(model.model_ref).must_be_kind_of Google::Apis::BigqueryV2::ModelReference
    _(model.model_ref.model_id).must_equal model_id
    _(model.model_ref.dataset_id).must_equal dataset
    _(model.model_ref.project_id).must_equal project

    _(model.model_type).must_be_nil
    _(model.created_at).must_be_nil
    _(model.modified_at).must_be_nil
    _(model.labels).must_be_nil

    _(model.name).must_be_nil
    _(model.description).must_be_nil
    _(model.etag).must_be_nil
    _(model.location).must_be_nil
    _(model.expires_at).must_be_nil

    _(model.encryption).must_be_nil
  end
end
