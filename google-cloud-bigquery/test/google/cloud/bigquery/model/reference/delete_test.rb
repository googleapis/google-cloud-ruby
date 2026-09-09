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
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model) {Google::Cloud::Bigquery::Model.new_reference project, dataset, model_id, bigquery.service }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_model, nil,
      [project, dataset, model_id]
    model.service.mocked_service = mock

    _(model.delete).must_equal true

    _(model.exists?).must_equal false

    mock.verify
  end
end
