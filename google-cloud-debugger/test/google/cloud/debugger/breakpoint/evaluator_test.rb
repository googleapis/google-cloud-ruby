# Copyright 2017 Google Inc. All rights reserved.
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
require_relative "evaluator/expression_test_helper"

def readonly_func1
  "readonly func1"
end

def readonly_func2
  readonly_func1
end

def readonly_func3
  local_var = 1
  local_var += 1
  local_var
end

def readonly_func4 arg
  yield arg
end

def mutating_func1
  begin
  rescue => e
    e.message
  end
end

def mutating_func2
  $global_var = 2
end

describe Google::Cloud::Debugger::Breakpoint::Evaluator do
  let(:evaluator) { Google::Cloud::Debugger::Breakpoint::Evaluator }

  describe ".eval_expressions" do
    it "calls readonly_eval_expression and return Debugger::Variable of result" do
      mock_binding = "A binding"
      mock_expressions = ["1 + 1"]

      stubbed_readonly_eval_expression = ->(b, e) {
        b.must_equal mock_binding
        e.must_equal mock_expressions.first
        "Readonly Evaluated"
      }

      evaluator.stub :readonly_eval_expression, stubbed_readonly_eval_expression do
        result = evaluator.eval_expressions mock_binding, mock_expressions
        result.size.must_equal 1
        result.first.value.must_equal Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var("Readonly Evaluated").value
        result.first.name.must_equal mock_expressions.first
      end
    end
  end

  describe ".readonly_eval_expression" do
    it "uses the binding object passed in" do
      mock_binding = MiniTest::Mock.new
      mock_binding.expect :eval, nil, [String]
      evaluator.readonly_eval_expression mock_binding, ""
      mock_binding.verify
    end

    it "allows readonly operations" do
      expression_must_equal "1 + 1", 2
    end

    it "allows readonly operations #2" do
      local_var = "local"
      expression_must_equal "local_var + ' var'", "local var", binding
    end

    it "allows readonly operations #3" do
      $global_var = "global"
      expression_must_equal "$global_var + ' var'", "global var", binding
    end

    it "allows readonly function" do
      expression_must_equal "readonly_func1()", "readonly func1", binding
    end

    it "allows nested readonly function" do
      expression_must_equal "readonly_func2()", "readonly func1", binding
    end

    it "doesn't allow setting local variable from expression" do
      local_var = "original local var"
      expression = "local_var = 'new local var'"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      local_var.must_equal "original local var"
    end

    it "allows setting local variable in readonly function calls" do
      expression_must_equal "readonly_func3()", 2, binding
    end

    it "doesn't allow setting global variables" do
      $global_var = "original global var"
      expression = "$global_var = 'new global var'"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      $global_var.must_equal "original global var"
    end

    it "doesn't allow setting instance variable" do
      @instance_var = "original instance var"
      expression = "@instance_var = 'new instance var'"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      @instance_var.must_equal "original instance var"
    end

    it "doesn't allow setting class variable" do
      expression = "@@class_var = 'new class var'"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
    end

    it "doesn't allow setting constant" do
      TEST_CONST  = "original constant"
      expression = "TEST_CONST = 'new constant'"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      TEST_CONST.must_equal "original constant"
    end

    it "doesn't allow << operator" do
      ary = [1,2]
      expression = "ary << 3"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      ary.size.must_equal 2
    end

    it "doesn't allow array set" do
      ary = [1,2]
      expression = "ary[0] = 2"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      ary.must_include 1
    end

    it "doesn't allow hash set with string key" do
      hsh = {"abc" => 123}
      expression = "hsh['abc'] = 456"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
      hsh["abc"].must_equal 123
    end

    it "doesn't allow return operation in expression" do
      expression = "return"
      result = evaluator.readonly_eval_expression binding, expression
      if RUBY_VERSION.to_f >= 2.4
        result.must_match "Invalid operation detected"
      else
        result.must_match "Unable to compile expression"
      end
    end

    it "doesn't allow using proc as block" do
      proc = Proc.new { |arg| "arg: #{arg}" }
      expression = "readonly_func4(123, &proc)"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
    end

    it "allows function call with block" do
      expression_must_equal 'readonly_func4(123) { |arg| "arg: #{arg}" }',
                            "arg: 123"
    end

    it "doesn't allow function with rescue block" do
      expression = "mutating_func1()"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
    end

    it "doesn't allow function that sets global variable with" do
      expression = "mutating_func2()"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "Mutation detected!"
    end

    it "returns ZeroDivisionError error message" do
      expression = "1/0"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "divided by 0"
    end

    it "returns NameError error message" do
      expression = "a_thing_that_is_not_defined"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "undefined local variable or method"
    end

    it "returns NoMethodError error message" do
      expression = "nil.blahblahblah"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "undefined method"
    end

    it "returns Argument error message" do
      expression = "nil.send"
      result = evaluator.readonly_eval_expression binding, expression
      result.must_match "no method name given"
    end
  end

  describe ".format_message" do
    it "formats basic message" do
      evaluator.format_message("Hello World", []).must_equal "Hello World"
    end

    it "formats message with expressions" do
      evaluator.format_message("Hello $0$1", ["World", :!]).must_equal "Hello \"World\":!"
    end

    it "formats message with extra expressions" do
      evaluator.format_message("Hello $0$1", ["World", :!, :zomg]).must_equal "Hello \"World\":!"
    end

    it "formats message with extra placeholder" do
      evaluator.format_message("Hello $0$1$2", ["World", :!]).must_equal "Hello \"World\":!"
    end

    it "doesn't substitute escaped placeholder and unescape them" do
      evaluator.format_message("Hello 0 $0 $$0 $$$$0", ["World"]).must_equal "Hello 0 \"World\" $0 $$0"
    end
  end
end
