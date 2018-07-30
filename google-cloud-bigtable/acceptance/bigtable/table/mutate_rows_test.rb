# frozen_string_literal: true

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


require "bigtable_helper"

describe "DataClient Mutate Rows", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "add multiple row entries" do
    postfix = random_str
    row_key = "mutaterows-#{postfix}"
    qualifier = "mutaterows-#{postfix}"

    entry1 = table.new_mutation_entry("#{row_key}-1")
    entry1.set_cell(family, qualifier, "mutatetest value #{postfix} 1")

    entry2 = table.new_mutation_entry("#{row_key}-2")
    entry2.set_cell(family, qualifier, "mutatetest value #{postfix} 2")

    statuses = table.mutate_rows([entry1, entry2])
    statuses.length.must_equal 2

    success_count = statuses.count{|s| s.status.code == 0 }

    keys = ["#{row_key}-1", "#{row_key}-2"]
    rows = table.read_rows(keys: keys).to_a
    rows.length.must_equal success_count
  end
end
