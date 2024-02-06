# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :reference, :update, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { 999 }
  let(:dataset_gapi) { random_dataset_gapi dataset_id, dataset_name, description, default_expiration }
  let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

  it "updates its name" do
    new_dataset_name = "My Updated Dataset"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.friendly_name = new_dataset_name
    patch_dataset_gapi = Google::Apis::BigqueryV2::Dataset.new friendly_name: new_dataset_name, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_dataset_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.name).must_be_nil

    dataset.name = new_dataset_name

    _(dataset.name).must_equal new_dataset_name
    mock.verify
  end

  it "updates its description" do
    new_description = "This is my updated dataset"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.description = new_description
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new description: new_description, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.description).must_be_nil

    dataset.description = new_description

    _(dataset.name).must_equal dataset_name
    _(dataset.description).must_equal new_description
    _(dataset.default_expiration).must_equal default_expiration
    mock.verify
  end

  it "updates its default_expiration" do
    new_default_expiration = 888

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.default_table_expiration_ms = new_default_expiration
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new default_table_expiration_ms: new_default_expiration, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.default_expiration).must_be_nil

    dataset.default_expiration = new_default_expiration

    _(dataset.name).must_equal dataset_name
    _(dataset.description).must_equal description
    _(dataset.default_expiration).must_equal new_default_expiration
    mock.verify
  end

  it "updates its labels" do
    new_labels = { "bar" => "baz" }

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.labels = new_labels
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new labels: new_labels, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.labels).must_be_nil

    dataset.labels = new_labels

    _(dataset.labels).must_equal new_labels
    mock.verify
  end

  it "updates its encryption" do
    kms_key = "path/to/encryption_key_name"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.default_encryption_configuration = Google::Apis::BigqueryV2::EncryptionConfiguration.new kms_key_name: kms_key
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new default_encryption_configuration: updated_gapi.default_encryption_configuration, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.default_encryption).must_be_nil

    dataset.default_encryption = bigquery.encryption kms_key: kms_key

    _(dataset.default_encryption).must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    _(dataset.default_encryption.kms_key).must_equal kms_key
    _(dataset.default_encryption).must_be :frozen?
    mock.verify
  end

  it "updates its storage_billing_model" do
    storage_billing_model = "LOGICAL"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    updated_gapi = dataset_gapi.dup
    updated_gapi.storage_billing_model = storage_billing_model
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new storage_billing_model: storage_billing_model, etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}

    _(dataset.storage_billing_model).must_be_nil

    dataset.storage_billing_model = storage_billing_model

    _(dataset.storage_billing_model).must_equal storage_billing_model
    mock.verify
  end
end
