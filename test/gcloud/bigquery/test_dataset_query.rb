# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Dataset, :query, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM [some_project:some_dataset.users]" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }

  it "queries the data with default dataset option set" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].wont_be :nil?
      json["defaultDataset"]["datasetId"].must_equal dataset.dataset_id
      json["defaultDataset"]["projectId"].must_equal dataset.project_id
      json["timeoutMs"].must_be :nil?
      json["dryRun"].must_be :nil?
      json["preserveNulls"].must_be :nil?
      json["useQueryCache"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = dataset.query query
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end
end
