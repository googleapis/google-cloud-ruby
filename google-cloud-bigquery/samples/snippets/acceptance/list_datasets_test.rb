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

require_relative "../list_datasets"
require_relative "helper"


describe "List datasets" do
  it "lists datasets in a project" do
    bigquery = Google::Cloud::Bigquery.new
    dataset1 = bigquery.create_dataset "test_dataset1_#{time_plus_random}"
    dataset2 = bigquery.create_dataset "test_dataset2_#{time_plus_random}"
    register_temp_datasets dataset1, dataset2

    output = capture_io { list_datasets bigquery.name }
    assert_match dataset1.dataset_id, output.first
    assert_match dataset2.dataset_id, output.first
  end
end
