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
require "json"

describe Google::Cloud::Bigquery::Service::Backoff, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }

  it "finds a dataset without any retry or backoff" do
    mock = Minitest::Mock.new
    mock.expect :get_dataset, find_dataset_gapi(dataset_id),
      [project, dataset_id]
    bigquery.service.mocked_service = mock

    dataset = bigquery.dataset dataset_id

    mock.verify

    dataset.must_be_kind_of Google::Cloud::Bigquery::Dataset
    dataset.dataset_id.must_equal dataset_id
  end

  it "handles a single 404 error (retriable) and retries with backoff" do
    mock = Minitest::Mock.new
    mock.expect :retry, nil, [0]

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      @tries ||= 0
      @tries += 1
      if @tries == 1
        # raise Google::Apis::Error.new "notfound", status_code: 400, body: backenderror_body
        raise Google::Apis::Error.new "notfound",
          status_code: 400,
          body: { "error" => { "errors" => [{ "reason" => "backendError" }] } }.to_json
      end

      random_dataset_hash = {
        "kind" => "bigquery#dataset",
        "etag" => "etag123456789",
        "id" => "id",
        "datasetReference" => {
          "datasetId" => "my_dataset",
          "projectId" => "test"
        },
        "friendlyName" => "My Dataset",
      }
      Google::Apis::BigqueryV2::Dataset.from_json random_dataset_hash.to_json
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      dataset = bigquery.dataset dataset_id

      dataset.must_be_kind_of Google::Cloud::Bigquery::Dataset
      dataset.dataset_id.must_equal dataset_id
    end

    mock.verify
  end

  it "handles a single 404 error with multiple reasons (all retriable) and retries with backoff" do
    mock = Minitest::Mock.new
    mock.expect :retry, nil, [0]

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      @tries ||= 0
      @tries += 1
      if @tries == 1
        # raise Google::Apis::Error.new "notfound", status_code: 400, body: backenderror_body
        raise Google::Apis::Error.new "notfound",
          status_code: 400,
          body: { "error" => { "errors" => [{ "reason" => "backendError" }, { "reason" => "rateLimitExceeded" }] } }.to_json
      end

      random_dataset_hash = {
        "kind" => "bigquery#dataset",
        "etag" => "etag123456789",
        "id" => "id",
        "datasetReference" => {
          "datasetId" => "my_dataset",
          "projectId" => "test"
        },
        "friendlyName" => "My Dataset",
      }
      Google::Apis::BigqueryV2::Dataset.from_json random_dataset_hash.to_json
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      dataset = bigquery.dataset dataset_id

      dataset.must_be_kind_of Google::Cloud::Bigquery::Dataset
      dataset.dataset_id.must_equal dataset_id
    end

    mock.verify
  end

  it "handles a single 404 error with multiple reasons (not all retriable) and does not retry with backoff" do
    mock = Minitest::Mock.new

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      raise Google::Apis::Error.new "notfound",
        status_code: 400,
        body: { "error" => { "errors" => [{ "reason" => "backendError" }, { "reason" => "other" }] } }.to_json
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      err = assert_raises Google::Cloud::InvalidArgumentError do
        bigquery.dataset dataset_id
      end

      err.message.must_equal "notfound"
      err.cause.body.must_equal "{\"error\":{\"errors\":[{\"reason\":\"backendError\"},{\"reason\":\"other\"}]}}"
    end

    mock.verify
  end

  it "handles a multiple 500 errors (retriable) and retries with backoff" do
    mock = Minitest::Mock.new
    mock.expect :retry, nil, [0]
    mock.expect :retry, nil, [1]
    mock.expect :retry, nil, [2]
    mock.expect :retry, nil, [3]

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      @tries ||= 0
      @tries += 1
      if @tries < 5
        raise Google::Apis::Error.new "internal",
          status_code: 500,
          body: { "error" => { "errors" => [{ "reason" => "backendError" }] } }.to_json
      end

      random_dataset_hash = {
        "kind" => "bigquery#dataset",
        "etag" => "etag123456789",
        "id" => "id",
        "datasetReference" => {
          "datasetId" => "my_dataset",
          "projectId" => "test"
        },
        "friendlyName" => "My Dataset",
      }
      Google::Apis::BigqueryV2::Dataset.from_json random_dataset_hash.to_json
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      dataset = bigquery.dataset dataset_id

      dataset.must_be_kind_of Google::Cloud::Bigquery::Dataset
      dataset.dataset_id.must_equal dataset_id
    end

    mock.verify
  end

  it "handles a multiple 500 errors (retriable) and then a 400 error (non-retriable)" do
    mock = Minitest::Mock.new
    mock.expect :retry, nil, [0]
    mock.expect :retry, nil, [1]
    mock.expect :retry, nil, [2]
    mock.expect :retry, nil, [3]

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      @tries ||= 0
      @tries += 1
      if @tries < 5
        raise Google::Apis::Error.new "internal",
          status_code: 500,
          body: { "error" => { "errors" => [{ "reason" => "backendError" }] } }.to_json
      end

      raise Google::Apis::Error.new "invalid", status_code: 400
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      err = assert_raises Google::Cloud::InvalidArgumentError do
        bigquery.dataset dataset_id
      end

      err.message.must_equal "invalid"
      err.cause.body.must_be :nil?
    end

    mock.verify
  end

  it "handles a multiple 400 errors (retriable) until retries limit is reached" do
    mock = Minitest::Mock.new
    mock.expect :retry, nil, [0]
    mock.expect :retry, nil, [1]
    mock.expect :retry, nil, [2]
    mock.expect :retry, nil, [3]
    mock.expect :retry, nil, [4]

    mocked_backoff = lambda { |i| mock.retry i }

    stub = Object.new
    def stub.get_dataset *args
      raise Google::Apis::Error.new "invalid",
        status_code: 400,
        body: { "error" => { "errors" => [{ "reason" => "backendError" }] } }.to_json
    end
    bigquery.service.mocked_service = stub

    Google::Cloud::Bigquery::Service::Backoff.stub :backoff, -> { mocked_backoff } do
      err = assert_raises Google::Cloud::InvalidArgumentError do
        bigquery.dataset dataset_id
      end

      err.message.must_equal "invalid"
      err.cause.body.must_equal "{\"error\":{\"errors\":[{\"reason\":\"backendError\"}]}}"
    end

    mock.verify
  end

  it "does not handle a single 404 error (non-retriable)" do
    stub = Object.new
    def stub.get_dataset *args
      raise Google::Apis::Error.new "invalid", status_code: 400
    end
    bigquery.service.mocked_service = stub

    err = assert_raises StandardError do
      bigquery.dataset dataset_id
    end

    err.message.must_equal "invalid"
  end

  it "does not handle a single 404 error with reason (non-retriable)" do
    stub = Object.new
    def stub.get_dataset *args
      raise Google::Apis::Error.new "invalid", status_code: 400,
        body: { "error" => { "errors" => [{ "reason" => "other" }] } }.to_json
    end
    bigquery.service.mocked_service = stub

    err = assert_raises StandardError do
      bigquery.dataset dataset_id
    end

    err.message.must_equal "invalid"
  end

  it "re-raises non-retriable errors" do
    error_proc = -> { raise "nope" }

    stub = Object.new
    def stub.get_dataset *args
      tries ||= 0
      fail "nope"
    end
    bigquery.service.mocked_service = stub

    err = assert_raises StandardError do
      bigquery.dataset dataset_id
    end

    err.message.must_equal "nope"
  end

  def find_dataset_gapi id
    Google::Apis::BigqueryV2::Dataset.from_json random_dataset_hash(id).to_json
  end
end
