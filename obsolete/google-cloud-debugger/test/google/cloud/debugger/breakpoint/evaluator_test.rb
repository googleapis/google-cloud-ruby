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

describe Google::Cloud::Debugger::Breakpoint::Evaluator do
  describe ".readonly_eval_expression" do
    after do
      Google::Cloud::Debugger.configure.allow_mutating_methods = false
    end

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
      expression_triggers_mutation expression, binding
      _(local_var).must_equal "original local var"
    end

    it "allows setting local variable in readonly function calls" do
      expression_must_equal "readonly_func3()", 2, binding
    end

    it "doesn't allow setting global variables" do
      $global_var = "original global var"
      expression = "$global_var = 'new global var'"
      expression_triggers_mutation expression, binding
      _($global_var).must_equal "original global var"
    end

    it "doesn't allow setting instance variable" do
      @instance_var = "original instance var"
      expression = "@instance_var = 'new instance var'"
      expression_triggers_mutation expression, binding
      _(@instance_var).must_equal "original instance var"
    end

    it "doesn't allow setting class variable" do
      expression = "@@class_var = 'new class var'"
      expression_triggers_mutation expression, binding
    end

    it "doesn't allow setting constant" do
      TEST_CONST  = "original constant"
      expression = "TEST_CONST = 'new constant'"
      expression_triggers_mutation expression, binding
      _(TEST_CONST).must_equal "original constant"
    end

    it "doesn't allow << operator" do
      ary = [1,2]
      expression = "ary << 3"
      expression_triggers_mutation expression, binding
      _(ary.size).must_equal 2
    end

    it "doesn't allow array set" do
      ary = [1,2]
      expression = "ary[0] = 2"
      expression_triggers_mutation expression, binding
      _(ary).must_include 1
    end

    it "doesn't allow hash set with string key" do
      hsh = {"abc" => 123}
      expression = "hsh['abc'] = 456"
      expression_triggers_mutation expression, binding
      _(hsh["abc"]).must_equal 123
    end

    it "doesn't allow return operation in expression" do
      expression = "return"
      result = evaluator.readonly_eval_expression binding, expression
      if RUBY_VERSION.to_f >= 2.6
        # Ruby 2.6 raises LocalJumpError
        _(result.message).must_match "unexpected return"
      else
        # Ruby 2.4 and 2.5 treat this as a mutation
        _(result.message).must_match evaluator::PROHIBITED_OPERATION_MSG
      end
    end

    it "doesn't allow using proc as block" do
      proc = Proc.new { |arg| "arg: #{arg}" }
      expression = "readonly_func4(123, &proc)"
      expression_triggers_mutation expression, binding
    end

    it "allows function call with block" do
      expression_must_equal 'readonly_func4(123) { |arg| "arg: #{arg}" }',
                            "arg: 123"
    end

    it "doesn't allow function with rescue block" do
      expression = "mutating_func1()"
      expression_triggers_mutation expression, binding
    end

    it "doesn't allow function that sets global variable with" do
      expression = "mutating_func2()"
      expression_triggers_mutation expression, binding
    end

    it "returns ZeroDivisionError" do
      expression = "1/0"
      result = evaluator.readonly_eval_expression binding, expression
      _(result).must_be_kind_of ZeroDivisionError
      _(result.message).must_match "divided by 0"
    end

    it "returns NameError" do
      expression = "a_thing_that_is_not_defined"
      result = evaluator.readonly_eval_expression binding, expression
      _(result).must_be_kind_of NameError
      _(result.message).must_match "undefined local variable or method"
    end

    it "returns NoMethodError" do
      expression = "nil.blahblahblah"
      result = evaluator.readonly_eval_expression binding, expression
      _(result).must_be_kind_of NoMethodError
      _(result.message).must_match "undefined method"
    end

    it "returns ArgumentError" do
      expression = "nil.send"
      result = evaluator.readonly_eval_expression binding, expression
      _(result).must_be_kind_of ArgumentError
      _(result.message).must_match "no method name given"
    end

    it "errors out if evaluation takes too long" do
      expression = "infinite_loop()"
      result = evaluator.readonly_eval_expression binding, expression
      _(result).must_be_kind_of Google::Cloud::Debugger::EvaluationError
      _(result.message).must_match "Evaluation exceeded time limit"
    end

    it "does not allow direct mutating in allow_mutating_methods" do
      $global_var = "global"
      expression = <<-EXPR
        Google::Cloud::Debugger.allow_mutating_methods! do
          $global_var = 2
        end
      EXPR
      expression_triggers_mutation expression, binding
    end

    it "allows calling a mutating method in allow_mutating_methods" do
      $global_var = "global"
      expression = <<-EXPR
        Google::Cloud::Debugger.allow_mutating_methods! do
          mutating_func2()
        end
        $global_var
      EXPR
      expression_must_equal expression, 2, binding
    end

    it "restores mutation detection after allow_mutating_methods block" do
      $global_var = "global"
      expression = <<-EXPR
        Google::Cloud::Debugger.allow_mutating_methods! do
          mutating_func2()
        end
        mutating_func2()
      EXPR
      expression_triggers_mutation expression, binding
    end

    it "allows calling a mutating method after allow_mutating_methods" do
      $global_var = "global"
      expression = <<-EXPR
        Google::Cloud::Debugger.allow_mutating_methods!
        mutating_func2()
        $global_var
      EXPR
      expression_must_equal expression, 2, binding
    end

    it "allows calling a mutating method with the right config" do
      Google::Cloud::Debugger.configure.allow_mutating_methods = true
      $global_var = "global"
      expression_must_equal "mutating_func2()", 2, binding
    end
  end

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

  def infinite_loop
    while true; end
  end
end
