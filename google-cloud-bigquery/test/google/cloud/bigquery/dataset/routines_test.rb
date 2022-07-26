 # Copyright 2020 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :routines, :mock_bigquery do
  let(:dataset_hash) { random_dataset_hash }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }
  let(:filter) { "routineType:SCALAR_FUNCTION" }

  it "lists routines" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines

    mock.verify

    _(routines.size).must_equal 3
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end

  it "lists routines with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines max: 3

    mock.verify

    _(routines.count).must_equal 3
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(routines.token).wont_be :nil?
    _(routines.token).must_equal "next_page_token"
  end

  it "lists routines with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: filter
    dataset.service.mocked_service = mock

    routines = dataset.routines filter: filter

    mock.verify

    _(routines.count).must_equal 3
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(routines.token).wont_be :nil?
    _(routines.token).must_equal "next_page_token"
  end

  it "paginates routines" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    first_routines = dataset.routines
    second_routines = dataset.routines token: first_routines.token

    mock.verify

    _(first_routines.count).must_equal 3
    first_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(first_routines.token).wont_be :nil?
    _(first_routines.token).must_equal "next_page_token"

    _(second_routines.count).must_equal 2
    second_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(second_routines.token).must_be :nil?
  end

  it "paginates routines with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    first_routines = dataset.routines
    second_routines = first_routines.next

    mock.verify

    _(first_routines.count).must_equal 3
    first_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(first_routines.token).wont_be :nil?
    _(first_routines.token).must_equal "next_page_token"

    _(second_routines.count).must_equal 2
    second_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(second_routines.token).must_be :nil?
  end

  it "paginates routines with next? and next and max" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: 3, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    first_routines = dataset.routines max: 3
    second_routines = first_routines.next

    mock.verify

    _(first_routines.count).must_equal 3
    first_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(first_routines.next?).must_equal true

    _(second_routines.count).must_equal 2
    second_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(second_routines.next?).must_equal false
  end

  it "paginates routines with next? and next and filter" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: filter
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: filter
    dataset.service.mocked_service = mock

    first_routines = dataset.routines filter: filter
    second_routines = first_routines.next

    mock.verify

    _(first_routines.count).must_equal 3
    first_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(first_routines.next?).must_equal true

    _(second_routines.count).must_equal 2
    second_routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
    _(second_routines.next?).must_equal false
  end

  it "paginates routines with all" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines.all.to_a

    mock.verify

    _(routines.count).must_equal 5
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end

  it "paginates routines with all and max" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: 3, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: 3, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines(max: 3).all.to_a

    mock.verify

    _(routines.count).must_equal 5
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end

  it "paginates routines with all and filter" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: filter
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 2, nil),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: filter
    dataset.service.mocked_service = mock

    routines = dataset.routines(filter: filter).all.to_a

    mock.verify

    _(routines.count).must_equal 5
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end

  it "iterates routines with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "second_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines.all.take(5)

    mock.verify

    _(routines.count).must_equal 5
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end

  it "iterates routines with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "next_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: nil, filter: nil
    mock.expect :list_routines, list_routines_gapi(dataset.dataset_id, 3, "second_page_token"),
      [project, dataset.dataset_id], max_results: nil, page_token: "next_page_token", filter: nil
    dataset.service.mocked_service = mock

    routines = dataset.routines.all(request_limit: 1).to_a

    mock.verify

    _(routines.count).must_equal 6
    routines.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Routine }
  end
end
