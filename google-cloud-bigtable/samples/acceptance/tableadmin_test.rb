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
require_relative "../tableadmin"

describe Google::Cloud::Bigtable, "Table Admin", :bigtable do
  it "create table, run table admin operations and delete table" do
    table_id = "test-table-#{SecureRandom.hex 8}"

    out, _err = capture_io do
      run_table_operations bigtable_instance_id, table_id
    end

    assert_includes out, "Table created #{table_id}"
    assert_includes out, "Created column family with max age GC rule: cf1"
    assert_includes out, "Created column family with max versions GC rule: cf2"
    assert_includes out, "Created column family with union GC rule: cf3"
    assert_includes out, "Created column family with intersect GC rule: cf4"
    assert_includes out, "Created column family with a nested GC rule: cf5"
    assert_includes out, "Updated max version GC rule of column_family: cf1"
    assert_includes out, "Deleted column family: cf2"

    out, _err = capture_io do
      delete_table bigtable_instance_id, table_id
    end

    assert_includes out, "Table deleted: #{table_id}"
  end
end
