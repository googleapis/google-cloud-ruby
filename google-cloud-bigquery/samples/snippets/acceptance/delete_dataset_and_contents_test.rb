# Copyright 2020 Google, LLC
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

require_relative "../delete_dataset_and_contents"
require_relative "helper"

describe "Delete dataset containing tables" do
  it "deletes a dataset and its contents" do
    bigquery = Google::Cloud::Bigquery.new
    dataset = bigquery.create_dataset "test_dataset_w_table_#{time_plus_random}"
    dataset.create_table "test_table_#{time_plus_random}"

    delete_dataset_and_contents dataset.dataset_id

    refute bigquery.dataset(dataset.dataset_id, skip_lookup: true).exists?
  end
end
