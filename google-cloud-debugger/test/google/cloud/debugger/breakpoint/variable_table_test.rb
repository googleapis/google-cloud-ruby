# Copyright 2017 Google LLC
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
require "json"

describe Google::Cloud::Debugger::Breakpoint::VariableTable, :mock_debugger do
  let(:var_table) do
    Google::Cloud::Debugger::Breakpoint::VariableTable.new
  end

  describe ".from_grpc" do
    it "knows all the attributes" do
      variable_grpc = Google::Cloud::Debugger::V2::Variable.new random_variable_integer_hash
      variable = Google::Cloud::Debugger::Breakpoint::Variable.from_grpc variable_grpc
      var_table_grpc = [variable_grpc, variable_grpc]

      var_table = Google::Cloud::Debugger::Breakpoint::VariableTable.from_grpc var_table_grpc
      _(var_table).must_be_kind_of Google::Cloud::Debugger::Breakpoint::VariableTable
      _(var_table.size).must_equal 2
      _(var_table[0].source_var).must_be_nil
      _(var_table[0].name).must_equal variable.name
      _(var_table[0].type).must_equal variable.type
      _(var_table[0].value).must_equal variable.value
      _(var_table[0].members).must_equal variable.members
    end
  end

  describe ".to_grpc" do
    it "converts all the attributes" do
      variable_grpc = Google::Cloud::Debugger::V2::Variable.new random_variable_integer_hash
      variable = Google::Cloud::Debugger::Breakpoint::Variable.from_grpc variable_grpc

      var_table.add variable
      var_table.add variable

      var_table_grpc = var_table.to_grpc

      _(var_table_grpc.size).must_equal 2
      _(var_table_grpc[0].name).must_equal variable_grpc.name
      _(var_table_grpc[0].value).must_equal variable_grpc.value
      _(var_table_grpc[0].type).must_equal variable_grpc.type
      _(var_table_grpc[0].members).must_equal variable_grpc.members
    end
  end

  describe "#add" do
    it "doesn't add variable to the list unless it's a Breakpoint::Variable" do
      variable = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 1

      var_table.add "Doesn't add"
      var_table.add variable

      _(var_table.size).must_equal 1
      _(var_table.first).must_equal variable
    end
  end

  describe "#rb_var_index" do
    it "returns index of the item found" do
      variable1 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 4
      variable2 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 5
      variable3 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 6

      var_table.add variable1
      var_table.add variable2
      var_table.add variable3

      _(var_table.rb_var_index(4)).must_equal 0
      _(var_table.rb_var_index(5)).must_equal 1
      _(var_table.rb_var_index(6)).must_equal 2
    end

    it "returns nil if item not found" do
      variable1 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 4
      variable2 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 5
      variable3 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var 6

      var_table.add variable1
      var_table.add variable2
      var_table.add variable3

      _(var_table.rb_var_index(8)).must_be_nil
    end
  end
end
