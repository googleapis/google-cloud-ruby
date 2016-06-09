# Copyright 2014 Google Inc. All rights reserved.
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
require "json"
require "uri"

describe "Gcloud Bigquery Backoff", :mock_bigquery do

  it "lists datasets with backoff" do
    num_datasets = 3
    2.times do
      mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
        [500, {"Content-Type"=>"application/json"}, nil]
      end
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(num_datasets)]
    end
    assert_backoff_sleep 1, 2 do
      datasets = bigquery.datasets
      datasets.size.must_equal num_datasets
      datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
    end
  end

  def list_datasets_json count = 2, token = nil
    datasets = count.times.map { random_dataset_small_hash }
    hash = {"kind"=>"bigquery#datasetList", "datasets"=>datasets}
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Gcloud::Backoff.new backoff: callback

    Gcloud::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
