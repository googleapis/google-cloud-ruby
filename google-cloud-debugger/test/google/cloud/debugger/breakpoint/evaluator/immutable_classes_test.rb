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
require_relative "expression_test_helper"

describe Google::Cloud::Debugger::Breakpoint::Evaluator do
  let(:evaluator) { Google::Cloud::Debugger::Breakpoint::Evaluator }

  before do
    if ENV["GCLOUD_TEST_COVERAGE_DEBUGGER_TIMEOUT"]
      # Have to set it here because configure gets reset by some tests.
      eval_time_limit = Float ENV["GCLOUD_TEST_COVERAGE_DEBUGGER_TIMEOUT"]
      Google::Cloud::Debugger.configure.evaluation_time_limit = eval_time_limit
    end
  end

  describe "Bignum" do
    it "allows #multiplication" do
      expression_must_equal "123123123123123123123 * 3",
                            369369369369369369369
    end

    it "allows #abs operation" do
      expression_must_equal "-1234567890987654321.abs",
                            1234567890987654321
    end
  end

  describe "Complex" do
    it "allows .rectangular method" do
      expression_must_be_kind_of "Complex.rectangular(1, 2)", Complex
    end

    it "allows #abs method" do
      expression_must_equal "Complex(-1).abs", 1
    end
  end

  describe "Fixnum or Integer" do
    it "allows #*" do
      expression_must_equal "3 * 3", 9
    end

    it "allows #abs" do
      expression_must_equal "-3.abs", 3
    end
  end

  describe "FalseClass" do
    it "allows #& method" do
      expression_must_equal "false & true", false
    end
  end

  describe "Float" do
    it "allows #+ operation" do
      expression_must_equal "1.0 + 2.0", 3.0
    end

    it "allows #abs operation" do
      expression_must_equal "-3.0.abs", 3.0
    end
  end

  describe "MatchData" do
    it "allows #begin method" do
      matchdata = "hello".match /ll/
      expression_must_equal "matchdata.begin 0", 2, binding
    end
  end

  describe "NilClass" do
    it "allows #& method" do
      expression_must_equal "nil & true", false
    end
  end

  describe "Numeric" do
    it "allows #real? method" do
      expression_must_equal "1.real?", true
    end
  end

  describe "Proc" do
    it "allows #new" do
      expression_must_be_kind_of "Proc.new {}", Proc
    end

    it "allows #arity method" do
      proc = Proc.new { |_, _| nil }
      expression_must_equal "proc.arity", 2, binding
    end
  end

  describe "Range" do
    it "allows #new" do
      expression_must_be_kind_of "Range.new 1, 4", Range
    end

    it "allows #begin method" do
      expression_must_equal "(5..9).begin", 5
    end
  end

  describe "Regexp" do
    it "allows .escape method" do
      expression_must_equal "Regexp.escape('*?{}.')", '\*\?\{\}\.'
    end

    it "allows #match method" do
      expression_must_be_kind_of '/R.../.match "Ruby"', MatchData
    end
  end

  describe "Struct" do
    it "allows instance method" do
      struct = Struct.new :a, :b
      instance = struct.new 1, 2
      expression_must_be_kind_of "instance.each", Enumerator, binding
    end
  end

  describe "Symbol" do
    it "allows class method" do
      expression_must_be_kind_of "Symbol.all_symbols", Array
    end

    it "allows instance method" do
      expression_must_equal ":abc.empty?", false
    end
  end

  describe "TrueClass" do
    it "allows instance method" do
      expression_must_equal "true & :abc", true
    end
  end

  describe "Comparable" do
    it "allows instance method" do
      expression_must_equal "3.between? 1, 5", true
    end
  end

  describe "Enumerable" do
    it "allows instance method" do
      expression_must_be_kind_of "[].collect_concat", Enumerator
    end
  end

  describe "Math" do
    it "allows trigonometric functions" do
      expression_must_equal "Math.sin(Math::PI/2)", 1.0
    end

    it "allows sqrt operation" do
      expression_must_equal "Math.sqrt 4", 2.0
    end
  end
end
