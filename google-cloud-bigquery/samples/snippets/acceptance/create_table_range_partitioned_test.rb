# Copyright 2025 Google LLC
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

require_relative "helper"
require_relative "../create_table_range_partitioned"

describe "Create range partitioned table" do
  let(:bigquery) { Google::Cloud::Bigquery.new }
  let(:table_id) { "test_table_#{time_plus_random}" }

  before do
    @dataset = create_temp_dataset
  end

  it "creates a range partitioned table" do
    assert_output(/Created range-partitioned table/) do
      create_range_partitioned_table @dataset.dataset_id, table_id
    end

    table = @dataset.table table_id
    assert table
    assert table.range_partitioning?
    assert_equal "integerField", table.range_partitioning_field
    assert_equal 1, table.range_partitioning_start
    assert_equal 2, table.range_partitioning_interval
    assert_equal 10, table.range_partitioning_end
  end
end
