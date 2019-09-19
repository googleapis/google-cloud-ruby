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
  let(:model_type) { "KMEANS" }
  let(:model_name) { "My Model" }
  let(:description) { "This is my model" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { foo: "bar" } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:model_hash) { random_model_full_hash dataset, model_id, name: model_name, description: description, kms_key: kms_key }
  let(:model) { Google::Cloud::Bigquery::Model.from_gapi_json model_hash, bigquery.service }

  it "knows its attributes" do
    model.model_id.must_equal model_id
    model.dataset_id.must_equal dataset
    model.project_id.must_equal project
    # model_ref is private
    model.model_ref.must_be_kind_of Google::Apis::BigqueryV2::ModelReference
    model.model_ref.model_id.must_equal model_id
    model.model_ref.dataset_id.must_equal dataset
    model.model_ref.project_id.must_equal project

    # Only the following fields are populated:
    # modelReference, modelType, creationTime, lastModifiedTime and labels
    model.model_type.must_equal model_type
    model.created_at.must_be_close_to ::Time.now, 1
    model.modified_at.must_be_close_to ::Time.now, 1
    model.labels.must_equal labels
    model.labels.must_be :frozen?

    model.name.must_equal model_name
    model.description.must_equal description
    model.etag.must_equal etag
    model.location.must_equal location_code
    model.expires_at.must_be_close_to ::Time.now, 1

    model.encryption.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    model.encryption.kms_key.must_equal kms_key
    model.encryption.must_be :frozen?
  end

  it "handles nil for optional expires_at" do
    model.gapi_json.delete :expirationTime

    model.model_id.must_equal model_id
    model.dataset_id.must_equal dataset
    model.project_id.must_equal project
    # model_ref is private
    model.model_ref.must_be_kind_of Google::Apis::BigqueryV2::ModelReference
    model.model_ref.model_id.must_equal model_id
    model.model_ref.dataset_id.must_equal dataset
    model.model_ref.project_id.must_equal project

    # Only the following fields are populated:
    # modelReference, modelType, creationTime, lastModifiedTime and labels
    model.model_type.must_equal model_type
    model.created_at.must_be_close_to ::Time.now, 1
    model.modified_at.must_be_close_to ::Time.now, 1
    model.labels.must_equal labels
    model.labels.must_be :frozen?

    model.name.must_equal model_name
    model.description.must_equal description
    model.etag.must_equal etag
    model.location.must_equal location_code
    model.expires_at.must_be_nil
  end
end
