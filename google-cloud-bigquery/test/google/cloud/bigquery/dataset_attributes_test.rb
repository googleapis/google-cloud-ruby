# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :attributes, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { "999" } # String per google/google-api-ruby-client#439
  let(:dataset_gapi) {  Google::Apis::BigqueryV2::DatasetList::Dataset.from_json random_dataset_partial_hash(dataset_id, dataset_name).to_json }
  let(:dataset_full_json) { random_dataset_hash(dataset_id, dataset_name, description, default_expiration).to_json }
  let(:dataset_full_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_full_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  it "gets full data for created_at" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_full_gapi, [project, dataset_id]

    _(dataset.created_at).must_be_close_to ::Time.now, 1

    # A second call to attribute does not make a second HTTP API call
    _(dataset.created_at).must_be_close_to ::Time.now, 1
    mock.verify
  end

  it "gets full data for modified_at" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_full_gapi, [project, dataset_id]

    _(dataset.modified_at).must_be_close_to ::Time.now, 1

    # A second call to attribute does not make a second HTTP API call
    _(dataset.modified_at).must_be_close_to ::Time.now, 1
    mock.verify
  end

  it "gets full data for default_encryption" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_full_gapi, [project, dataset_id]

    _(dataset.default_encryption).must_be_nil

    # A second call to attribute does not make a second HTTP API call
    _(dataset.default_encryption).must_be_nil
    mock.verify
  end

  it "gets full data for tags" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_dataset, dataset_full_gapi, [project, dataset_id]

    _(dataset.tags).must_be_kind_of Array

    # Subsequent calls to the method does not make a second HTTP API call
    _(dataset.tags.first).must_be_kind_of Google::Cloud::Bigquery::Dataset::Tag
    _(dataset.tags.first.tag_key).must_be_kind_of String
    mock.verify
  end

  def self.attr_test attr, val
    define_method "test_#{attr}" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      mock.expect :get_dataset, dataset_full_gapi, [project, dataset_id]

      _(dataset.send(attr)).must_equal val

      # A second call to attribute does not make a second HTTP API call
      _(dataset.send(attr)).must_equal val
      mock.verify
    end
  end

  attr_test :description, "This is my dataset"
  attr_test :default_expiration, 999
  attr_test :etag, "etag123456789"
  attr_test :api_url, "http://googleapi/bigquery/v2/projects/test-project/datasets/my_dataset"
end
