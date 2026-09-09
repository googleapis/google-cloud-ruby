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

describe Google::Cloud::Bigquery::Model, :resource, :attributes, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_hash) { random_model_full_hash dataset, model_id }
  let(:model) { Google::Cloud::Bigquery::Model.from_gapi_json model_hash, bigquery.service }

  it "can test its existence" do
    _(model.exists?).must_equal true
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_hash.to_json, [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.exists?(force: true)).must_equal true

    mock.verify
  end
end
