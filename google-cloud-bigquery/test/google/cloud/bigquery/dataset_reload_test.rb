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

describe Google::Cloud::Bigquery::Dataset, :reload, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  it "loads the dataset full resource by making an HTTP call" do
    mock = Minitest::Mock.new
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id], access_policy_version: nil, dataset_view: nil
    dataset.service.mocked_service = mock

    _(dataset).wont_be :reference?
    _(dataset).must_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).must_be :resource_full?

    dataset.reload!
    _(dataset).wont_be :reference?
    _(dataset).must_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).must_be :resource_full?

    mock.verify
  end

  describe "partial dataset resource from list" do
    let(:dataset_partial_gapi) { list_datasets_gapi(1).datasets.first }
    let(:dataset) {Google::Cloud::Bigquery::Dataset.from_gapi dataset_partial_gapi, bigquery.service }

    it "loads the dataset full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_dataset, dataset_gapi, [project, dataset_id], access_policy_version: nil, dataset_view: nil
      dataset.service.mocked_service = mock

      _(dataset).wont_be :reference?
      _(dataset).must_be :resource?
      _(dataset).must_be :resource_partial?
      _(dataset).wont_be :resource_full?

      dataset.reload!
      _(dataset).wont_be :reference?
      _(dataset).must_be :resource?
      _(dataset).wont_be :resource_partial?
      _(dataset).must_be :resource_full?

      mock.verify
    end
  end

  describe "dataset reference" do
    let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "loads the dataset full resource by making an HTTP call" do
      mock = Minitest::Mock.new
      mock.expect :get_dataset, dataset_gapi, [project, dataset_id], access_policy_version: nil, dataset_view: nil
      dataset.service.mocked_service = mock

      _(dataset).must_be :reference?
      _(dataset).wont_be :resource?
      _(dataset).wont_be :resource_partial?
      _(dataset).wont_be :resource_full?

      dataset.reload!
      _(dataset).wont_be :reference?
      _(dataset).must_be :resource?
      _(dataset).wont_be :resource_partial?
      _(dataset).must_be :resource_full?

      mock.verify
    end
  end
end
