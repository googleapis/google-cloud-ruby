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

describe Google::Cloud::Bigquery::Dataset, :model, :mock_bigquery do
  let(:dataset_hash) { random_dataset_hash }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  it "finds a model" do
    found_model_id = "found_model"

    mock = Minitest::Mock.new
    mock.expect :get_model, random_model_full_hash(dataset.dataset_id, found_model_id).to_json, [project, dataset.dataset_id, found_model_id], options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    model = dataset.model found_model_id

    mock.verify

    _(model).must_be_kind_of Google::Cloud::Bigquery::Model
    _(model.model_id).must_equal found_model_id
  end
end
