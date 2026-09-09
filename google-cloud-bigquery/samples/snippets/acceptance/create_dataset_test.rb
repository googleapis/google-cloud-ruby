# Copyright 2020 Google LLC
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

require_relative "../create_dataset"
require_relative "helper"

describe "Create dataset" do
  let(:bigquery) { Google::Cloud::Bigquery.new }
  let(:dataset_id) { "test_dataset_#{time_plus_random}" }
  let(:dataset_location) { "US" }

  after do
    bigquery.dataset(dataset_id).delete
  end

  it "creates a new dataset" do
    create_dataset dataset_id, dataset_location

    dataset = bigquery.dataset dataset_id
    assert_equal dataset_location, dataset.location
  end
end
