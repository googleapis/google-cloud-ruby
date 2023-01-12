# Copyright 2022 Google LLC
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

require_relative "../authorized_dataset"
require_relative "helper"

describe "Authorize dataset" do
  it "authorize dataset in a project" do
    bigquery = Google::Cloud::Bigquery.new
    # Ensure at least source and user dataset
    dataset1 = bigquery.create_dataset "test_dataset1_#{time_plus_random}"
    dataset2 = bigquery.create_dataset "test_dataset2_#{time_plus_random}"

    out, _err = capture_io do
      authorized_dataset source_project_id: dataset1.project_id,
                         source_database_id: dataset1.dataset_id,
                         user_project_id: dataset2.project_id,
                         user_database_id: dataset2.dataset_id,
                         target_types: ["VIEWS"]
    end
    assert_includes out, "Dataset #{dataset2.dataset_id} added as authorized dataset in dataset #{dataset1.dataset_id}"

    assert dataset1.reload!.access.reader_dataset? dataset2.build_access_entry(target_types: ["VIEWS"])
  end
end
