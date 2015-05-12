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

describe Gcloud::Bigquery::Dataset, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_name) { "my-dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { 999 }
  let(:dataset_hash) { random_dataset_hash dataset_name, description, default_expiration }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }
  let(:dataset_id) { dataset.dataset_id }

  it "knows its attributes" do
    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
  end

  it "knows its creation and modification times" do
    now = Time.now

    dataset.gapi["creationTime"] = nil
    dataset.created_at.must_be :nil?

    dataset.gapi["creationTime"] = (now.to_f * 1000).floor
    dataset.created_at.must_be_close_to now

    dataset.gapi["lastModifiedTime"] = nil
    dataset.modified_at.must_be :nil?

    dataset.gapi["lastModifiedTime"] = (now.to_f * 1000).floor
    dataset.modified_at.must_be_close_to now
  end

  it "can delete itself" do
    mock_connection.delete "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}" do |env|
      env.params.wont_include "deleteContents"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    dataset.delete
  end

  it "can delete itself and all table data" do
    mock_connection.delete "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}" do |env|
      env.params.must_include "deleteContents"
      env.params["deleteContents"].must_equal "true"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    dataset.delete force: true
  end
end
