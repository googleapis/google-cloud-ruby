# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"

describe Google::Cloud::Bigquery::Dataset, :update, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { 999 }
  let(:dataset_gapi) { random_dataset_gapi dataset_id, dataset_name, description, default_expiration }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  it "updates its name" do
    new_dataset_name = "My Updated Dataset"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    updated_gapi.friendly_name = new_dataset_name
    patch_dataset_gapi = Google::Apis::BigqueryV2::Dataset.new friendly_name: new_dataset_name, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_dataset_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.name = new_dataset_name

    dataset.name.must_equal new_dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
    mock.verify
  end

  it "updates its description" do
    new_description = "This is my updated dataset"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    updated_gapi.description = new_description
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new description: new_description, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.description = new_description

    dataset.name.must_equal dataset_name
    dataset.description.must_equal new_description
    dataset.default_expiration.must_equal default_expiration
    mock.verify
  end

  it "updates its default_expiration" do
    new_default_expiration = 888

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    updated_gapi.default_table_expiration_ms = new_default_expiration
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new default_table_expiration_ms: new_default_expiration, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.default_expiration = new_default_expiration

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal new_default_expiration
    mock.verify
  end
end
