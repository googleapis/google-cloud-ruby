# Copyright 2021 Google LLC
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
require_relative "../write_samples"

describe Google::Cloud::Bigtable, "Write Samples", :bigtable do
  before do
    @table_id = "mobile-time-series-#{SecureRandom.hex 8}"

    bigtable = Google::Cloud::Bigtable.new

    column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
    column_families.add "stats_summary", gc_rule: nil

    @table = bigtable.create_table bigtable_instance_id, @table_id, column_families: column_families
  end

  after do
    @table.delete
  end

  it "write_simple, write_batch, write_increment, write_conditional" do
    # write_simple
    out, _err = capture_io do
      write_simple bigtable_instance_id, @table_id
    end

    assert_includes out, "Successfully wrote row"

    # write_batch
    out, _err = capture_io do
      write_batch bigtable_instance_id, @table_id
    end

    assert_includes out, "Successfully wrote 2 rows"

    #write_increment
    out, _err = capture_io do
      write_increment bigtable_instance_id, @table_id
    end

    assert_includes out, "Successfully updated row"

    # write_conditional
    out, _err = capture_io do
      write_conditional bigtable_instance_id, @table_id
    end

    assert_includes out, "Successfully updated row's os_name: true"
  end
end
