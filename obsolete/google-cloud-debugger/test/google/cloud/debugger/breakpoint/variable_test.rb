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

describe Google::Cloud::Debugger::Breakpoint::Variable, :mock_debugger do
  let(:variable_hash) { random_variable_array_hash }
  let(:variable_grpc) {
    Google::Cloud::Debugger::V2::Variable.new variable_hash
  }
  let(:variable) {
    Google::Cloud::Debugger::Breakpoint::Variable.from_grpc variable_grpc
  }
  let(:var_table) { Google::Cloud::Debugger::Breakpoint::VariableTable.new }

  describe "#to_grpc" do
    it "gets all the attributes" do
      grpc = variable.to_grpc

      _(grpc.name).must_equal variable_grpc.name
      _(grpc.value).must_equal variable_grpc.value
      _(grpc.type).must_equal variable_grpc.type
      _(grpc.members).must_equal variable_grpc.members
    end

    it "has members even if missing from variable" do
      variable.members = nil
      grpc = variable.to_grpc

      _(grpc.name).must_equal variable_grpc.name
      _(grpc.value).must_equal variable_grpc.value
      _(grpc.members).must_equal []
    end
  end

  describe ".from_grpc" do
    it "knows its attributes" do
      _(variable_grpc.name).must_equal "local_var"
      _(variable_grpc.type).must_equal "Array"
      _(variable_grpc.members[0].name).must_equal "[0]"
      _(variable_grpc.members[0].type).must_equal "Integer"
      _(variable_grpc.members[0].value).must_equal "3"
      _(variable_grpc.members[0].members).must_equal []
    end

    it "has members in grpc even if it's missing from variable" do
      variable =
        Google::Cloud::Debugger::Breakpoint::Variable.from_grpc variable_grpc
      variable.members = nil
      grpc = variable.to_grpc
      _(grpc.members).must_equal []
    end
  end

  describe ".from_grpc_list" do
    it "converts all the elements" do
      grpc_ary = [variable_grpc, variable_grpc]
      ary = Google::Cloud::Debugger::Breakpoint::Variable.from_grpc_list grpc_ary

      _(ary.size).must_equal 2
      _(ary[0].name).must_equal variable.name
      _(ary[0].type).must_equal variable.type
      _(ary[0].value).must_equal variable.value
      _(ary[0].members).wont_be_empty

      _(ary[1].name).must_equal variable.name
      _(ary[1].type).must_equal variable.type
      _(ary[1].value).must_equal variable.value
      _(ary[1].members).wont_be_empty
    end
  end

  describe ".buffer_full_variable" do
    it "sets a name if given" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable nil, name: "test name"
      _(var.name).must_equal "test name"
    end

    it "returns a error variable if not given a variable table" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable

      _(var.status.is_error).must_equal true
      _(var.status.description).must_equal Google::Cloud::Debugger::Breakpoint::Variable::BUFFER_FULL_MSG
    end

    it "returns a error variable if given a variable table that doesn't have the shared buffer full variable" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable var_table

      _(var.status.is_error).must_equal true
      _(var.status.description).must_equal Google::Cloud::Debugger::Breakpoint::Variable::BUFFER_FULL_MSG
    end

    it "returns a reference variable to variable table's shared buffer full variable" do
      var_table.add Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable

      var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable var_table

      _(var.reference_variable?).must_equal true
      _(var.var_table_index).must_equal 0
    end
  end

  describe ".from_rb_var" do
    it "returns Variable itself" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.new
      var2 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var var
      _(var.object_id).must_equal var2.object_id
    end

    it "converts String" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var "test-str"
      _(var.name).must_be_nil
      _(var.type).must_equal "String"
      _(var.value).must_equal '"test-str"'
      _(var.members).must_be_empty
    end

    it "converts Nil" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var nil
      _(var.name).must_be_nil
      _(var.type).must_equal "NilClass"
      _(var.value).must_equal "nil"
      _(var.members).must_be_empty
    end

    it "converts Symbol" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var :key
      _(var.name).must_be_nil
      _(var.type).must_equal "Symbol"
      _(var.value).must_equal ":key"
      _(var.members).must_be_empty
    end

    it "converts Time" do
      t = Time.now
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var t
      _(var.name).must_be_nil
      _(var.type).must_equal "Time"
      _(var.value).must_equal t.inspect
      _(var.members).must_be_empty
    end

    it "converts empty Hash" do
      h = {}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h

      _(var.name).must_be_nil
      _(var.type).must_equal "Hash"
      _(var.members).must_be_empty
      _(var.value).must_equal "{}"
    end

    it "converts Hash" do
      int_clsas = 1.class.to_s
      h = {k1: 1, k2: {k3: "2", k4: {k5: {k6: 3}}}}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h

      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.type).must_equal "Hash"

      _(var.members.size).must_equal 2
      _(var.members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var.members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var.members[0].type).must_equal int_clsas
      _(var.members[0].name).must_equal "k1"
      _(var.members[0].value).must_equal "1"

      _(var.members[1].type).must_equal "Hash"
      _(var.members[1].name).must_equal "k2"
      _(var.members[1].value).must_be_nil
      _(var.members[1].members.size).must_equal 2

      _(var.members[1].members[0].type).must_equal "String"
      _(var.members[1].members[0].name).must_equal "k3"
      _(var.members[1].members[0].value).must_equal '"2"'

      _(var.members[1].members[1].type).must_equal "Hash"
      _(var.members[1].members[1].name).must_equal "k4"
      _(var.members[1].members[1].value).must_be_nil
      _(var.members[1].members[1].members.size).must_equal 1

      _(var.members[1].members[1].members[0].type).must_equal "Hash"
      _(var.members[1].members[1].members[0].name).must_equal "k5"
      _(var.members[1].members[1].members[0].value).must_equal({k6: 3}.to_s)
      _(var.members[1].members[1].members[0].members).must_be_empty
    end

    it "converts empty Array" do
      ary = []
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary

      _(var.name).must_be_nil
      _(var.type).must_equal "Array"
      _(var.members).must_be_empty
      _(var.value).must_equal "[]"
    end

    it "converts Array" do
      int_class = 1.class.to_s
      ary = [1, [[2, [4]], 3]]
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary

      _(var.name).must_be_nil
      _(var.type).must_equal "Array"
      _(var.value).must_be_nil
      _(var.members.size).must_equal 2

      _(var.members[0].type).must_equal int_class
      _(var.members[0].name).must_equal "[0]"
      _(var.members[0].value).must_equal "1"
      _(var.members[0].members).must_be_empty

      _(var.members[1].type).must_equal "Array"
      _(var.members[1].name).must_equal "[1]"
      _(var.members[1].value).must_be_nil
      _(var.members[1].members.size).must_equal 2

      _(var.members[1].members[0].type).must_equal "Array"
      _(var.members[1].members[0].name).must_equal "[0]"
      _(var.members[1].members[0].value).must_be_nil
      _(var.members[1].members[0].members.size).must_equal 2

      _(var.members[1].members[0].members[0].type).must_equal int_class
      _(var.members[1].members[0].members[0].name).must_equal "[0]"
      _(var.members[1].members[0].members[0].value).must_equal "2"
      _(var.members[1].members[0].members[0].members).must_be_empty

      _(var.members[1].members[0].members[1].type).must_equal "Array"
      _(var.members[1].members[0].members[1].name).must_equal "[1]"
      _(var.members[1].members[0].members[1].value).must_equal "[4]"
      _(var.members[1].members[0].members[1].members).must_be_empty

      _(var.members[1].members[1].type).must_equal int_class
      _(var.members[1].members[1].name).must_equal "[1]"
      _(var.members[1].members[1].value).must_equal "3"
      _(var.members[1].members[1].members).must_be_empty
    end

    it "converts custom class" do
      class Foo
        def initialize
          @foo = "123"
        end
      end

      f = Foo.new
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var f

      _(var.type).must_equal "Foo"
      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.members.size).must_equal 1

      _(var.members[0].type).must_equal "String"
      _(var.members[0].name).must_equal "@foo"
      _(var.members[0].value).must_equal '"123"'
      _(var.members[0].members).must_be_empty
    end

    it "limits members count to max allowed" do
      max_members = Google::Cloud::Debugger::Breakpoint::Variable::MAX_MEMBERS
      ary = (1..(max_members + 8)).to_a
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary

      _(var.type).must_equal "Array"
      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.members.size).must_equal max_members + 1

      _(var.members[max_members].type).must_be_nil
      _(var.members[max_members].name).must_be_nil
      _(var.members[max_members].value).must_be_nil
      _(var.members[max_members].members).must_be_empty
      _(var.members[max_members].status.description).must_match "Only first #{max_members} items were captured"
    end

    it "limits string length to Variable::MAX_STRING_LENGTH" do
      str_max = Google::Cloud::Debugger::Breakpoint::Variable::MAX_STRING_LENGTH
      long_str = "s" * (str_max + 10)

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var long_str
      _(var.type).must_equal "String"
      _(var.name).must_be_nil
      _(var.value.size).must_equal str_max
      _(var.members).must_be_empty
    end

    it "uses var_table to store repeated variables" do
      hash = { a: 1 }
      ary = [hash, hash]
      int_class = 1.class.to_s

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary, var_table: var_table
      _(var.type).must_be_nil
      _(var.var_table_index).must_equal 0
      _(var.members).must_be_empty
      _(var.value).must_be_nil

      _(var_table.size).must_equal 2
      _(var_table[0].type).must_equal "Array"
      _(var_table[0].members.size).must_equal 2
      _(var_table[0].members[0].var_table_index).must_equal 1
      _(var_table[0].members[1].var_table_index).must_equal 1

      _(var_table[1].type).must_equal "Hash"
      _(var_table[1].members.size).must_equal 1
      _(var_table[1].members[0].name).must_equal "a"
      _(var_table[1].members[0].type).must_equal int_class
      _(var_table[1].members[0].value).must_equal "1"
    end

    it "uses var_table for nested compound variable" do
      ary = [1, [2]]
      int_class = 1.class.to_s

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary, var_table: var_table

      _(var.type).must_be_nil
      _(var.var_table_index).must_equal 0
      _(var.members).must_be_empty
      _(var.value).must_be_nil

      _(var_table.size).must_equal 2
      _(var_table[0].type).must_equal "Array"
      _(var_table[0].members.size).must_equal 2
      _(var_table[0].members[0].name).must_equal "[0]"
      _(var_table[0].members[0].type).must_equal int_class
      _(var_table[0].members[0].value) .must_equal "1"

      _(var_table[0].members[1].name).must_equal "[1]"
      _(var_table[0].members[1].type).must_be_nil
      _(var_table[0].members[1].members).must_be_empty
      _(var_table[0].members[1].var_table_index).must_equal 1

      _(var_table[1].type).must_equal "Array"
      _(var_table[1].name).must_be_nil
      _(var_table[1].members.size).must_equal 1
      _(var_table[1].members[0].type).must_equal int_class
      _(var_table[1].members[0].value) .must_equal "2"
    end

    it "doesn't convert if given size limit is too small" do
      limit = Google::Cloud::Debugger::Breakpoint::Variable::MIN_REQUIRED_SIZE - 1

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var nil, limit: limit

      _(var).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var.status.is_error).must_equal true
      _(var.status.description).must_equal Google::Cloud::Debugger::Breakpoint::Variable::BUFFER_FULL_MSG
    end

    it "full converts simple variable within limit" do
      limit = 1000
      str = "x" * 900

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var str, limit: limit
      _(var.type).must_equal str.class.to_s
      _(var.value).must_equal str.inspect
      _((var.total_size <= limit)).must_equal true
    end

    it "limits simple variable within limit" do
      limit = 1000
      str = "x" * 1100

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var str, limit: limit
      _((var.value.size <= str.inspect.size)).must_equal true
      _((var.total_size <= limit)).must_equal true
    end

    it "full converts nested compound variable within limit" do
      limit = 1000
      int_clsas = 1.class.to_s
      h = {k1: 1, k2: {k3: "2", k4: {k5: {k6: 3}}}}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h, limit: limit

      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.type).must_equal "Hash"

      _(var.members.size).must_equal 2
      _(var.members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var.members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var.members[0].type).must_equal int_clsas
      _(var.members[0].name).must_equal "k1"
      _(var.members[0].value).must_equal "1"

      _(var.members[1].type).must_equal "Hash"
      _(var.members[1].name).must_equal "k2"
      _(var.members[1].value).must_be_nil
      _(var.members[1].members.size).must_equal 2

      _(var.members[1].members[0].type).must_equal "String"
      _(var.members[1].members[0].name).must_equal "k3"
      _(var.members[1].members[0].value).must_equal '"2"'

      _(var.members[1].members[1].type).must_equal "Hash"
      _(var.members[1].members[1].name).must_equal "k4"
      _(var.members[1].members[1].value).must_be_nil
      _(var.members[1].members[1].members.size).must_equal 1

      _(var.members[1].members[1].members[0].type).must_equal "Hash"
      _(var.members[1].members[1].members[0].name).must_equal "k5"
      _(var.members[1].members[1].members[0].value).must_equal({k6: 3}.to_s)
      _(var.members[1].members[1].members[0].members).must_be_empty

      _((var.total_size <= limit)).must_equal true
    end

    it "full converts nested compound variable with variable table within limit" do
      limit = 1000
      int_clsas = 1.class.to_s
      h = {k1: 1, k2: {k3: "2", k4: {k5: {k6: 3}}}}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h, limit: limit,
                                                                      var_table: var_table

      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.var_table_index).must_equal 0
      _(var.members).must_be_empty

      _(var_table.size).must_equal 3
      _(var_table[0].type).must_equal "Hash"
      _(var_table[0].members.size).must_equal 2

      _(var_table[0].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[0].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[0].members[0].type).must_equal int_clsas
      _(var_table[0].members[0].name).must_equal "k1"
      _(var_table[0].members[0].value).must_equal "1"
      _(var_table[0].members[0].var_table_index).must_be_nil

      _(var_table[0].members[1].var_table_index).must_equal 1
      _(var_table[0].members[1].name).must_equal "k2"
      _(var_table[0].members[1].value).must_be_nil
      _(var_table[0].members[1].type).must_be_nil

      _(var_table[1].type).must_equal "Hash"
      _(var_table[1].members.size).must_equal 2

      _(var_table[1].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[1].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[1].members[0].type).must_equal "String"
      _(var_table[1].members[0].name).must_equal "k3"
      _(var_table[1].members[0].value).must_equal "2".inspect
      _(var_table[1].members[0].var_table_index).must_be_nil

      _(var_table[1].members[1].type).must_be_nil
      _(var_table[1].members[1].name).must_equal "k4"
      _(var_table[1].members[1].value).must_be_nil
      _(var_table[1].members[1].var_table_index).must_equal 2

      _(var_table[2].type).must_equal "Hash"
      _(var_table[2].members.size).must_equal 1

      _(var_table[2].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[2].members[0].type).must_equal "Hash"
      _(var_table[2].members[0].name).must_equal "k5"
      _(var_table[2].members[0].value).must_equal({k6: 3}.to_s)

      _((var.total_size <= limit)).must_equal true
    end

    it "limit large nested compound variable with variable table within limit size" do
      limit = 200
      int_clsas = 1.class.to_s
      long_str = "x" * 300
      h = {k1: 1, k2: {k3: long_str, k4: {k5: {k6: 3}}}}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h, limit: limit,
                                                                      var_table: var_table

      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.var_table_index).must_equal 0
      _(var.members).must_be_empty

      _(var_table.size).must_equal 2
      _(var_table[0].type).must_equal "Hash"
      _(var_table[0].members.size).must_equal 2

      _(var_table[0].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[0].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[0].members[0].type).must_equal int_clsas
      _(var_table[0].members[0].name).must_equal "k1"
      _(var_table[0].members[0].value).must_equal "1"
      _(var_table[0].members[0].var_table_index).must_be_nil

      _(var_table[0].members[1].var_table_index).must_equal 1
      _(var_table[0].members[1].name).must_equal "k2"
      _(var_table[0].members[1].value).must_be_nil
      _(var_table[0].members[1].type).must_be_nil

      _(var_table[1].type).must_equal "Hash"
      _(var_table[1].members.size).must_equal 2

      _(var_table[1].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[1].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[1].members[0].type).must_equal "String"
      _(var_table[1].members[0].name).must_equal "k3"
      _(var_table[1].members[0].value).must_match /x+\.\.\./
      _(var_table[1].members[0].var_table_index).must_be_nil

      _(var_table[1].members[1].type).must_be_nil
      _(var_table[1].members[1].name).must_be_nil
      _(var_table[1].members[1].status.is_error).must_equal true
      _(var_table[1].members[1].status.description).must_match /Only first . items were captured/

      _((var.total_size <= limit)).must_equal true
    end

    it "limit large nested compound variable and reuse shared buffer full variable from var_table" do
      limit = 200
      int_clsas = 1.class.to_s
      long_str = "x" * 300
      h = {k1: 1, k2: {k3: long_str, k4: {k5: {k6: 3}}}}
      buffer_full_var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable
      var_table.add buffer_full_var
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h, limit: limit,
                                                                      var_table: var_table

      _(var.name).must_be_nil
      _(var.value).must_be_nil
      _(var.var_table_index).must_equal 1
      _(var.members).must_be_empty

      _(var_table.size).must_equal 3
      _(var_table[1].type).must_equal "Hash"
      _(var_table[1].members.size).must_equal 2

      _(var_table[1].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[1].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[1].members[0].type).must_equal int_clsas
      _(var_table[1].members[0].name).must_equal "k1"
      _(var_table[1].members[0].value).must_equal "1"
      _(var_table[1].members[0].var_table_index).must_be_nil

      _(var_table[1].members[1].var_table_index).must_equal 2
      _(var_table[1].members[1].name).must_equal "k2"
      _(var_table[1].members[1].value).must_be_nil
      _(var_table[1].members[1].type).must_be_nil

      _(var_table[2].type).must_equal "Hash"
      _(var_table[2].members.size).must_equal 2

      _(var_table[2].members[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(var_table[2].members[1]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      _(var_table[2].members[0].type).must_equal "String"
      _(var_table[2].members[0].name).must_equal "k3"
      _(var_table[2].members[0].value).must_match /x+\.\.\./
      _(var_table[2].members[0].var_table_index).must_be_nil

      _(var_table[2].members[1].type).must_be_nil
      _(var_table[2].members[1].name).must_be_nil
      _(var_table[2].members[1].value).must_be_nil
      _(var_table[2].members[1].status.description).must_match /Only first . items were captured/

      _((var.total_size <= limit)).must_equal true
    end

    it "Adds a single buffer full variable to compound members list if limit is scessed" do
      limit = 1010
      str = "x" * 500
      ary = [str] * 5

      buffer_full_var = Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable
      var_table.add buffer_full_var

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary, limit: limit,
                                                                      var_table: var_table

      _(var.var_table_index).must_equal 1

      _(var_table[1].members.size).must_equal 3

      _(var_table[1].members[0].value).must_match /x+/
      _(var_table[1].members[1].value).must_match /x+/
      _(var_table[1].members[2].status.description).must_match /Only first . items were captured/
    end
  end

  describe "#reference_variable?" do
    it "returns true only if it's an empty variable that references another variable in variable table" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.new

      _(var.reference_variable?).must_equal false

      var.var_table_index = 99

      _(var.reference_variable?).must_equal true

      var.value = "a value"

      _(var.reference_variable?).must_equal false
    end
  end

  describe "#buffer_full_variable?" do
    it "returns true if the variable itself is a buffer full error variable" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.new

      _(var.buffer_full_variable?).must_equal false

      var.set_error_state Google::Cloud::Debugger::Breakpoint::Variable::BUFFER_FULL_MSG,
                          refers_to: Google::Cloud::Debugger::Breakpoint::StatusMessage::VARIABLE_VALUE

      _(var.buffer_full_variable?).must_equal true
    end

    it "returns true if the variable references the shared buffer full variable in variable table" do
      var_table.add Google::Cloud::Debugger::Breakpoint::Variable.buffer_full_variable

      var = Google::Cloud::Debugger::Breakpoint::Variable.new
      var.var_table_index = 0

      _(var.buffer_full_variable?).must_equal false

      var.var_table = var_table

      _(var.buffer_full_variable?).must_equal true

      var.value = "a value"

      _(var.buffer_full_variable?).must_equal false
    end
  end

  describe "#payload_size" do
    it "calculates the size for simple variable" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var "hello"

      estimate_size = String.to_s.bytesize + "hello".inspect.bytesize

      _(var.payload_size).must_equal estimate_size
    end

    it "calculates the size of complex compound variable" do
      hash = {key: "value"}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var hash, name: "hash"

      estimate_size = Hash.to_s.bytesize + String.to_s.bytesize + "hash".bytesize +
                      "value".inspect.bytesize + "key".bytesize

      _(var.payload_size).must_equal estimate_size
    end
  end

  describe "#total_size" do
    it "calculates the size for simple variable" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var "hello"

      estimate_size = String.to_s.bytesize + "hello".inspect.bytesize

      _(var.total_size).must_equal estimate_size
    end

    it "calculates the size for simple variable with variable table" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var "hello", var_table: var_table

      estimate_size = String.to_s.bytesize + "hello".inspect.bytesize

      _(var.total_size).must_equal estimate_size
    end

    it "calculates the size of complex compound variable" do
      hash = {key: "value"}
      ary = [hash, hash]
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary, name: "ary"

      nested_size = Hash.to_s.bytesize + String.to_s.bytesize + "[x]".bytesize +
                    "value".inspect.bytesize + "key".bytesize
      estimate_size = nested_size * 2 + "ary".bytesize + Array.to_s.bytesize

      _(var.total_size).must_equal estimate_size
    end

    it "calculates the size of complex compound variable with variable table" do
      hash = {key: "value"}
      ary = [hash, hash]

      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary, name: "ary",
                                                                      var_table: var_table

      nested_size = Hash.to_s.bytesize + String.to_s.bytesize +
        "value".inspect.bytesize + "key".bytesize
      estimate_size = nested_size + "ary".bytesize +
        Array.to_s.bytesize + "[x]".bytesize * 2

      _(var.total_size).must_equal estimate_size
    end
  end
end
