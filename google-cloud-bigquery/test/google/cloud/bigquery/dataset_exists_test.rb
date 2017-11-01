# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Bigquery::Dataset, :exists, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  it "knows if full resource exists when created with an HTTP method" do
    # The absence of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    dataset.wont_be :reference?
    dataset.must_be :resource?
    dataset.wont_be :resource_partial?
    dataset.must_be :resource_full?

    dataset.must_be :exists?
    dataset.wont_be :reference?
    dataset.must_be :resource?
    dataset.wont_be :resource_partial?
    dataset.must_be :resource_full?

    # Additional exists? calls do not make HTTP calls either
    dataset.must_be :exists?
  end

  describe "partial dataset resource from list of a dataset that exists" do
    let(:dataset_partial_gapi) { list_datasets_gapi(1).datasets.first }
    let(:dataset) {Google::Cloud::Bigquery::Dataset.from_gapi dataset_partial_gapi, bigquery.service }

    it "knows if partial resource exists when created with an HTTP method" do
      # The absence of a mock means this test will fail
      # if the method exists? makes an HTTP call.
      dataset.wont_be :reference?
      dataset.must_be :resource?
      dataset.must_be :resource_partial?
      dataset.wont_be :resource_full?

      dataset.must_be :exists?
      dataset.wont_be :reference?
      dataset.must_be :resource?
      dataset.must_be :resource_partial?
      dataset.wont_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      dataset.must_be :exists?
    end
  end

  describe "dataset reference of a dataset that exists" do
    let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "checks if the dataset exists by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
      dataset.service.mocked_service = mock

      dataset.must_be :reference?
      dataset.wont_be :resource?
      dataset.wont_be :resource_partial?
      dataset.wont_be :resource_full?

      dataset.must_be :exists?
      dataset.wont_be :reference?
      dataset.must_be :resource?
      dataset.wont_be :resource_partial?
      dataset.must_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      dataset.must_be :exists?

      mock.verify
    end
  end

  describe "dataset reference of a dataset that does not exist" do
    let(:dataset) { Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "checks if the dataset exists by making an HTTP call" do
      stub = Object.new
      def stub.get_dataset *args
        raise Google::Apis::Error.new("not found", status_code: 404)
      end
      dataset.service.mocked_service = stub

      dataset.must_be :reference?
      dataset.wont_be :resource?
      dataset.wont_be :resource_partial?
      dataset.wont_be :resource_full?

      dataset.wont_be :exists?
      dataset.must_be :reference?
      dataset.wont_be :resource?
      dataset.wont_be :resource_partial?
      dataset.wont_be :resource_full?

      # Additional exists? calls do not make HTTP calls
      dataset.wont_be :exists?
    end
  end
end
