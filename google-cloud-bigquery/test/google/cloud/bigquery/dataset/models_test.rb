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

describe Google::Cloud::Bigquery::Dataset, :models, :mock_bigquery do
  let(:dataset_hash) { random_dataset_hash }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  it "lists models" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models

    mock.verify

    _(models.size).must_equal 3
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
  end

  it "lists models with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models max: 3

    mock.verify

    _(models.count).must_equal 3
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(models.token).wont_be :nil?
    _(models.token).must_equal "next_page_token"
  end

  it "paginates models" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    first_models = dataset.models
    second_models = dataset.models token: first_models.token

    mock.verify

    _(first_models.count).must_equal 3
    first_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(first_models.token).wont_be :nil?
    _(first_models.token).must_equal "next_page_token"

    _(second_models.count).must_equal 2
    second_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(second_models.token).must_be :nil?
  end

  it "paginates models with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    first_models = dataset.models
    second_models = first_models.next

    mock.verify

    _(first_models.count).must_equal 3
    first_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(first_models.token).wont_be :nil?
    _(first_models.token).must_equal "next_page_token"

    _(second_models.count).must_equal 2
    second_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(second_models.token).must_be :nil?
  end

  it "paginates models with next? and next and max" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: 3, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    first_models = dataset.models max: 3
    second_models = first_models.next

    mock.verify

    _(first_models.count).must_equal 3
    first_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(first_models.next?).must_equal true

    _(second_models.count).must_equal 2
    second_models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
    _(second_models.next?).must_equal false
  end

  it "paginates models with all" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models.all.to_a

    mock.verify

    _(models.count).must_equal 5
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
  end

  it "paginates models with all and max" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: 3, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models(max: 3).all.to_a

    mock.verify

    _(models.count).must_equal 5
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
  end

  it "iterates models with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "second_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models.all.take(5)

    mock.verify

    _(models.count).must_equal 5
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
  end

  it "iterates models with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, options: { skip_deserialization: true }
    mock.expect :list_models, list_models_gapi_json(dataset.dataset_id, 3, "second_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", options: { skip_deserialization: true }
    dataset.service.mocked_service = mock

    models = dataset.models.all(request_limit: 1).to_a

    mock.verify

    _(models.count).must_equal 6
    models.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Model }
  end
end
