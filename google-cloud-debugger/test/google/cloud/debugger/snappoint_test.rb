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

describe Google::Cloud::Debugger::Snappoint, :mock_debugger do
  let(:breakpoint_hash) { random_breakpoint_hash }
  let(:breakpoint_json) { breakpoint_hash.to_json }
  let(:breakpoint_grpc) {
    Google::Devtools::Clouddebugger::V2::Breakpoint.decode_json breakpoint_json
  }
  let(:snappoint) {
    Google::Cloud::Debugger::Snappoint.from_grpc breakpoint_grpc
  }

  let(:evaluator) { Google::Cloud::Debugger::Breakpoint::Evaluator }

  describe ".eval_expressions" do
    it "calls readonly_eval_expression and return Debugger::Variable of result" do
      mock_binding = "A binding"
      mock_expressions = ["1 + 1"]
      snappoint.expressions = mock_expressions

      stubbed_readonly_eval_expression = ->(b, e) {
        b.must_equal mock_binding
        e.must_equal mock_expressions.first
        "Readonly Evaluated"
      }

      evaluator.stub :readonly_eval_expression, stubbed_readonly_eval_expression do
        snappoint.eval_expressions mock_binding

        snappoint.evaluated_expressions.size.must_equal 1
        snappoint.evaluated_expressions.first.must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
        snappoint.evaluated_expressions.first.value.must_equal "Readonly Evaluated".inspect
        snappoint.evaluated_expressions.first.name.must_equal mock_expressions.first
      end
    end
  end

  describe "#evaluate" do
    it "returns false if breakpoint is evaluated already" do
      snappoint.complete

      snappoint.evaluate([]).must_equal false
    end

    it "returns false if condition check fails" do
      snappoint.stub :check_condition, false do
        snappoint.evaluate [nil]
      end
    end

    it "returns false if Evaluator.eval_condition raises exception" do
      stubbed_eval_call_stack = ->(_) { raise }
      snappoint.stub :eval_call_stack, stubbed_eval_call_stack do
        snappoint.stub :check_condition, true do
          snappoint.evaluate([nil]).must_equal false
        end
      end
    end

    it "returns false if #eval_expressions raises exception" do
      stubbed_eval_expressions = ->(_) { raise }

      snappoint.stub :eval_call_stack, nil do
        snappoint.stub :eval_expressions, stubbed_eval_expressions do
          snappoint.stub :check_condition, true do
            snappoint.evaluate([nil]).must_equal false
          end
        end
      end
    end

    it "sets @evaluated_expressions and @stack_frames for breakpoint" do
      snappoint.evaluated_expressions = []
      snappoint.stack_frames = []

      snappoint.stub :check_condition, true do
        snappoint.evaluate([binding])

        snappoint.evaluated_expressions.wont_be_empty
        snappoint.stack_frames.wont_be_empty
      end
    end

    it "calls complete if finishes evaluation" do
      mocked_complete = Minitest::Mock.new
      mocked_complete.expect :call, nil

      snappoint.stub :eval_call_stack, [] do
        snappoint.stub :eval_expressions, [] do
          snappoint.stub :check_condition, true do
            snappoint.stub :complete, mocked_complete do
              snappoint.evaluate([nil]).must_equal true
            end
          end
        end
      end

      mocked_complete.verify
    end
  end

  describe "#eval_expressions" do
    it "set @evaluated_expressions to array of Breakpoint::Variable" do
      snappoint.evaluated_expressions = []
      snappoint.eval_expressions binding
      snappoint.evaluated_expressions.must_be_kind_of Array
      snappoint.evaluated_expressions.all? { |var| var.is_a? Google::Cloud::Debugger::Breakpoint::Variable }.must_equal true
    end

    it "sets the Breakpoint::Variable name to the expression itself" do
      snappoint.evaluated_expressions = []
      snappoint.eval_expressions binding

      snappoint.evaluated_expressions.wont_be_empty
      snappoint.evaluated_expressions.first.name.must_equal snappoint.expressions.first
    end
  end

  describe "#eval_call_stack" do
    it "set @stack_frames to array of Breakpoint::StackFrame" do
      snappoint.stack_frames = []
      snappoint.eval_call_stack binding.callers

      snappoint.stack_frames.all? { |sf| sf.is_a? Google::Cloud::Debugger::Breakpoint::StackFrame }.must_equal true
    end

    it "gets local variables within STACK_EVAL_DEPTH level" do
      local_var = "test-local-var"

      snappoint.stack_frames = []
      snappoint.eval_call_stack [binding, *binding.callers]

      snappoint.stack_frames.wont_be_empty
      snappoint.stack_frames.first.locals.first.value.must_equal "test-local-var".inspect
      snappoint.stack_frames.each_with_index do |sf, i|
        if i >= Google::Cloud::Debugger::Snappoint::STACK_EVAL_DEPTH
          sf.locals.must_be_empty
        end
      end
    end
  end
end
