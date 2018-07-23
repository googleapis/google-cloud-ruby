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

describe "DataClient Check and Mutate Row", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "check and mutate row" do
    row_key = "checkmutate-#{random_str}"
    qualifier = "checkmutate"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "Value 1")
    table.mutate_row(entry)

    predicate_filter = table.filter.value("Value.*")

    matched_mutations = table.new_mutation_entry.set_cell(
      family, qualifier, "predicate matched"
    )

    otherwise_mutations = table.new_mutation_entry.delete_from_family(family)

    response = table.check_and_mutate_row(
      row_key,
      predicate_filter,
      on_match: matched_mutations,
      otherwise: otherwise_mutations
    )

    response.must_equal true
  end
end
