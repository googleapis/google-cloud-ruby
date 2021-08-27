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

require_relative "../insert_geography_wkt"
require_relative "helper"

describe "GEOGRAPHY" do
  before do
    @dataset = create_temp_dataset
    @table = @dataset.create_table "test_geojson_table" do |schema|
      schema.geography "geo"
    end
  end

  it "inserts a GEOGRAPHY WKT row into a GEOGRAPHY column in a table" do
    output = capture_io { insert_geography_wkt @dataset.dataset_id, @table.table_id }

    assert_equal "Inserted GEOGRAPHY WKT row successfully\n", output.first
  end
end
