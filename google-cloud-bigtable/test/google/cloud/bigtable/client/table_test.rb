# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "helper"

describe Google::Cloud::Bigtable::Client::Table, :table, :mock_bigtable do
  let(:instance_id) { "test-instance-id" }
  let(:table){
    Google::Cloud::Bigtable::Client::Table.new(Object.new, "dummy-table-path")
  }

  it "create mutation entry instance" do
    mutation_entry = table.new_mutation_entry("row-1")
    mutation_entry.must_be_kind_of Google::Cloud::Bigtable::MutationEntry
  end

  it "create read modify write row rule instance" do
    rule = table.new_read_modify_write_rule("cf", "field1")
    rule.must_be_kind_of Google::Cloud::Bigtable::ReadModifyWriteRule
  end
end
