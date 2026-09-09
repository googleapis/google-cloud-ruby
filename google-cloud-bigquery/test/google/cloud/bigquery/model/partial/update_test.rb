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

describe Google::Cloud::Bigquery::Model, :partial, :update, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_type) { "KMEANS" }
  let(:model_name) { "My Model" }
  let(:description) { "This is my model" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { foo: "bar" } }
  let(:model_partial_hash) { random_model_partial_hash dataset, model_id }
  let(:model) {Google::Cloud::Bigquery::Model.from_gapi_json model_partial_hash, bigquery.service }

  it "updates its name" do
    new_model_name = "My Updated Model"

    mock = Minitest::Mock.new
    model_hash = random_model_full_hash dataset, model_id, name: new_model_name, description: description
    patched_model_full_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, friendly_name: "My Updated Model"
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_full_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }

    model.service.mocked_service = mock

    model.name = new_model_name

    mock.verify

    _(model.name).must_equal new_model_name
  end

  it "updates its description" do
    new_description = "This is my updated model"

    mock = Minitest::Mock.new
    model_hash = random_model_full_hash dataset, model_id, name: model_name, description: new_description
    patched_model_full_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, description: "This is my updated model"
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_full_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    model.description = new_description

    mock.verify

    _(model.description).must_equal new_description
  end

  it "updates its labels" do
    new_labels = { bar: "baz" }

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    model_hash = random_model_full_hash dataset, model_id, name: model_name, description: description
    model_hash["labels"] = new_labels
    patched_model_full_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, labels: new_labels
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_full_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    model.labels = new_labels

    mock.verify

    _(model.labels).must_equal new_labels
  end

  it "updates its expires time" do
    one_hour_from_now = Time.now + 60*60

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    model_hash = random_model_full_hash dataset, model_id, name: model_name, description: description
    model_hash["expirationTime"] = Google::Cloud::Bigquery::Convert.time_to_millis(one_hour_from_now)
    patched_model_full_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, expiration_time: Google::Cloud::Bigquery::Convert.time_to_millis(one_hour_from_now)
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_full_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    model.expires_at = one_hour_from_now

    mock.verify

    _(model.expires_at).must_be_close_to one_hour_from_now, 1
  end

  it "updates its expires time to nil" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    model_hash = random_model_full_hash dataset, model_id, name: model_name, description: description
    model_hash["expirationTime"] = nil
    patched_model_full_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, expiration_time: nil
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_full_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    model.expires_at = nil

    mock.verify

    _(model.expires_at).must_be_nil
  end

  it "updates its encryption" do
    kms_key = "path/to/encryption_key_name"

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    model_hash = random_model_full_hash dataset, model_id, name: model_name, description: description
    model_hash["encryptionConfiguration"] = { kmsKeyName: kms_key }
    patched_model_gapi = Google::Apis::BigqueryV2::Model.new model_reference: model.model_ref, encryption_configuration: Google::Apis::BigqueryV2::EncryptionConfiguration.new(kms_key_name: kms_key)
    mock.expect :get_model, random_model_full_hash(dataset, model_id).to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    mock.expect :patch_model, model_hash.to_json,
      [project, dataset, model_id, patched_model_gapi], options: { skip_deserialization: true, header: { "If-Match" => etag } }
    mock.expect :get_model, model_hash.to_json, [project, dataset, model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.encryption).must_be :nil?

    encrypt_config = bigquery.encryption kms_key: kms_key

    model.encryption = encrypt_config

    mock.verify

    _(model.encryption).must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    _(model.encryption.kms_key).must_equal kms_key
    _(model.encryption).must_be :frozen?
  end
end
