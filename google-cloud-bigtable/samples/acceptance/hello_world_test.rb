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
require_relative "../hello_world"

describe Google::Cloud::Bigtable, "Hello World", :bigtable do
  let(:column_qualifier) { "greeting" }

  it "hello_world" do
    table_id = "test_table_#{SecureRandom.hex 8}"
    out, _err = capture_io do
      hello_world bigtable_instance_id, table_id, "cf", column_qualifier
    end
    assert_includes out, "Table #{table_id} created"
    assert_includes out, "Writing,  Row key: #{column_qualifier}0, Value: Hello World!"
    assert_includes out, "\nRow key: #{column_qualifier}0, Value: Hello World!"
    assert_includes out, "Deleting the table #{table_id}"
  end
end
