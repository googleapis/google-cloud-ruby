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

describe Google::Cloud::Bigquery::Model, :partial, :attributes, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_type) { "KMEANS" }
  let(:model_name) { "My Model" }
  let(:description) { "This is my model" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { foo: "bar" } }
  let(:model_hash) { random_model_partial_hash dataset, model_id }
  let(:model_full_hash) { random_model_full_hash dataset, model_id, name: model_name, description: description }
  let(:model) { Google::Cloud::Bigquery::Model.from_gapi_json model_hash, bigquery.service }

  it "knows its attributes" do
    _(model.model_id).must_equal model_id
    _(model.dataset_id).must_equal dataset
    _(model.project_id).must_equal project
    # model_ref is private
    _(model.model_ref).must_be_kind_of Google::Apis::BigqueryV2::ModelReference
    _(model.model_ref.model_id).must_equal model_id
    _(model.model_ref.dataset_id).must_equal dataset
    _(model.model_ref.project_id).must_equal project

    # Only the following fields are populated:
    # modelReference, modelType, creationTime, lastModifiedTime and labels
    _(model.model_type).must_equal model_type
    _(model.created_at).must_be_close_to ::Time.now, 1
    _(model.modified_at).must_be_close_to ::Time.now, 1
    _(model.labels).must_equal labels
    _(model.labels).must_be :frozen?

    _(model.encryption).must_be_nil
  end

  it "gets full data for name" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_full_hash.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.name).must_equal model_name

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.name
  end

  it "gets full data for description" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_full_hash.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.description).must_equal description

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.description
  end

  it "gets full data for etag" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_full_hash.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.etag).must_equal etag

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.etag
  end

  it "gets full data for location" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_full_hash.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.location).must_equal location_code

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.location
  end

  it "gets full data for expires_at" do
    mock = Minitest::Mock.new
    mock.expect :get_model, model_full_hash.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.expires_at).must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.expires_at
  end

  it "handles nil for optional expires_at" do
    mock = Minitest::Mock.new
    model_without_exp_time = model_full_hash.dup
    model_without_exp_time.delete :expirationTime
    mock.expect :get_model, model_without_exp_time.to_json,
      [model.project_id, model.dataset_id, model.model_id], options: { skip_deserialization: true }
    model.service.mocked_service = mock

    _(model.expires_at).must_be :nil?

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    model.expires_at
  end
end
