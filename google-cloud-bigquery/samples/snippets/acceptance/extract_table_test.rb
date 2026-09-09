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

require_relative "../extract_table"
require_relative "../load_from_file"
require_relative "helper"
require "google/cloud/storage"

describe "Extract table" do
  before do
    @storage = Google::Cloud::Storage.new
    @bucket = @storage.create_bucket "test_bucket_#{time_plus_random}"
    @dataset = create_temp_dataset
    file_path = File.expand_path "../resources/people.csv", __dir__
    load_from_file @dataset.dataset_id, file_path
    @table = @dataset.tables.first
  end

  it "extracts table data to GCS" do
    extract_table @bucket.name, @dataset.dataset_id, @table.table_id

    output_file = @bucket.files(prefix: "output").first
    assert output_file
    assert_operator output_file.size, :>, 0
  end

  after do
    @bucket.files.each(&:delete)
    @bucket.delete
  end
end
