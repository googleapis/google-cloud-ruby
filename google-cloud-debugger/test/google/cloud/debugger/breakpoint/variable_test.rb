# Copyright 2016 Google Inc. All rights reserved.
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


require "helper"

describe Google::Cloud::Debugger::Breakpoint::Variable do
  describe ".from_rb_var" do
    it "returns Variable itself" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.new
      var2 = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var var
      var.object_id.must_equal var2.object_id
    end

    it "converts String" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var "test-str"
      var.type.must_equal "String"
      var.value.must_equal "test-str"
    end

    it "converts Nil" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var nil
      var.type.must_equal "NilClass"
      var.value.must_equal ""
    end

    it "converts Symbol" do
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var :key
      var.type.must_equal "Symbol"
      var.value.must_equal "key"
    end

    it "converts Hash" do
      int_clsas = 1.class.to_s
      h = {k1: 1, k2: {k3: "2", k4: {k5: 3}}}
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var h

      var.name.must_be_empty
      var.value.must_be_nil
      var.type.must_equal "Hash"

      var.members.size.must_equal 2
      var.members[0].must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      var.members[1].must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable

      var.members[0].type.must_equal int_clsas
      var.members[0].name.must_equal "k1"
      var.members[0].value.must_equal "1"

      var.members[1].type.must_equal "Hash"
      var.members[1].name.must_equal "k2"
      var.members[1].value.must_be_nil
      var.members[1].members.size.must_equal 2

      var.members[1].members[0].type.must_equal "String"
      var.members[1].members[0].name.must_equal "k3"
      var.members[1].members[0].value.must_equal "2"

      var.members[1].members[1].type.must_equal "Hash"
      var.members[1].members[1].name.must_equal "k4"
      var.members[1].members[1].value.must_equal({k5: 3}.to_s)
      var.members[1].members[1].members.must_be_empty
    end

    it "converts Array" do
      int_class = 1.class.to_s
      ary = [1, [[2], 3]]
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var ary

      var.name.must_be_empty
      var.type.must_equal "Array"
      var.value.must_be_nil
      var.members.size.must_equal 2

      var.members[0].type.must_equal int_class
      var.members[0].name.must_equal "[0]"
      var.members[0].value.must_equal "1"
      var.members[0].members.must_be_empty

      var.members[1].type.must_equal "Array"
      var.members[1].name.must_equal "[1]"
      var.members[1].value.must_be_nil
      var.members[1].members.size.must_equal 2

      var.members[1].members[0].type.must_equal "Array"
      var.members[1].members[0].name.must_equal "[0]"
      var.members[1].members[0].value.must_equal "[2]"
      var.members[1].members[0].members.must_be_empty

      var.members[1].members[1].type.must_equal int_class
      var.members[1].members[1].name.must_equal "[1]"
      var.members[1].members[1].value.must_equal "3"
      var.members[1].members[1].members.must_be_empty
    end

    it "converts custom class" do
      class Foo
        def initialize
          @foo = "123"
        end
      end

      f = Foo.new
      var = Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var f

      var.type.must_equal "Foo"
      var.name.must_be_empty
      var.value.must_be_nil
      var.members.size.must_equal 1

      var.members[0].type.must_equal "String"
      var.members[0].name.must_equal "@foo"
      var.members[0].value.must_equal "123"
      var.members[0].members.must_be_empty
    end
  end
end
