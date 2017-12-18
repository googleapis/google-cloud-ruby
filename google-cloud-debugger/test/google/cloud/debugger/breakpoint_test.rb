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

describe Google::Cloud::Debugger::Breakpoint, :mock_debugger do
  let(:breakpoint_hash) { random_breakpoint_hash }
  let(:breakpoint_json) { breakpoint_hash.to_json }
  let(:breakpoint_grpc) {
    Google::Devtools::Clouddebugger::V2::Breakpoint.decode_json breakpoint_json
  }
  let(:breakpoint) {
    Google::Cloud::Debugger::Breakpoint.from_grpc breakpoint_grpc
  }

  let(:logpoint) {
    breakpoint_hash[:action] = :LOG
    breakpoint_hash[:log_message_format] = "Hello $0"
    breakpoint_hash[:expressions] = ["World"]

    Google::Cloud::Debugger::Breakpoint.from_grpc breakpoint_grpc
  }

  describe ".from_grpc" do
    it "knows all of the attributes" do
      timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"

      breakpoint.id.must_equal "abc123"
      breakpoint.action.must_equal :CAPTURE
      breakpoint.location.path.must_equal "my_app/my_class.rb"
      breakpoint.location.line.must_equal 321
      breakpoint.create_time.must_equal timestamp
      breakpoint.final_time.must_equal timestamp
      breakpoint.expressions.must_equal ["[3]"]
      expression_var = breakpoint.evaluated_expressions.first
      expression_var.name.must_equal "local_var"
      expression_var.type.must_equal "Array"
      expression_var.members.wont_be_empty
      stack_frame = breakpoint.stack_frames.first
      stack_frame.function.must_equal "index"
      stack_frame.location.path.must_equal "my_app/my_class.rb"
      stack_frame.location.line.must_equal 321
      stack_frame.arguments.wont_be_empty
      stack_frame.locals.wont_be_empty
      breakpoint.condition.must_equal "i == 2"
      breakpoint.labels.must_equal({"tag" => "hello"})
      breakpoint.is_final_state.wont_equal true
      variable_table_var = breakpoint.variable_table.first
      variable_table_var.must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      variable_table_var.name.must_equal "local_var"
      variable_table_var.type.must_equal "Array"
      variable_table_var.members.wont_be_empty
    end

    it "knows all of the attributes for logpoint" do
      logpoint.action.must_equal :LOG
      logpoint.log_message_format.must_equal "Hello $0"
      logpoint.expressions.must_equal ["World"]
    end

    it "has location even if missing from grpc" do
      breakpoint_hash["location"] = nil

      breakpoint.location.must_be_kind_of Google::Cloud::Debugger::Breakpoint::SourceLocation
    end

    it "has expressions even if missing from grpc" do
      breakpoint_hash["expressions"] = nil

      breakpoint.expressions.must_equal []
    end

    it "has evaluated_expressions even if missing from grpc" do
      breakpoint_hash["evaluated_expressions"] = nil

      breakpoint.evaluated_expressions.must_equal []
    end

    it "has stack_frames even if missing from grpc" do
      breakpoint_hash["stack_frames"] = nil

      breakpoint.stack_frames.must_equal []
    end

    it "has labels even if missing from grpc" do
      breakpoint_hash["labels"] = nil

      breakpoint.labels.must_equal({})
    end
  end

  describe "#to_grpc" do
    it "knows all of the attributes" do
      timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"

      grpc = breakpoint.to_grpc
      grpc.must_be_kind_of Google::Devtools::Clouddebugger::V2::Breakpoint

      grpc.id.must_equal "abc123"
      grpc.create_time.seconds.must_equal timestamp.to_i
      grpc.final_time.seconds.must_equal timestamp.to_i
      grpc.location.path.must_equal "my_app/my_class.rb"
      grpc.location.line.must_equal 321
      grpc.expressions.must_equal ["[3]"]
      expression_var = grpc.evaluated_expressions.first
      expression_var.name.must_equal "local_var"
      expression_var.type.must_equal "Array"
      expression_var.members.wont_be_empty
      stack_frame = breakpoint.stack_frames.first
      stack_frame.function.must_equal "index"
      stack_frame.location.path.must_equal "my_app/my_class.rb"
      stack_frame.location.line.must_equal 321
      stack_frame.arguments.wont_be_empty
      stack_frame.locals.wont_be_empty
      grpc.condition.must_equal "i == 2"
      grpc.labels["tag"].must_equal "hello"
      grpc.variable_table.wont_be_empty
    end
  end

  describe "#complete" do
    it "sets @is_final_state and @final_time" do
      breakpoint.final_time = nil
      breakpoint.is_final_state.must_equal false

      breakpoint.complete

      breakpoint.is_final_state.must_equal true
      breakpoint.final_time.must_be_kind_of Time
    end

    it "doesn't change @final_time if already completed" do
      breakpoint.final_time = nil
      breakpoint.complete

      original_final_time = breakpoint.final_time

      breakpoint.complete
      breakpoint.final_time.must_equal original_final_time
    end
  end

  describe "#path" do
    it "gets path from location" do
      breakpoint.path.must_equal breakpoint.location.path
    end

    it "returns nil if location doesn't exist" do
      breakpoint.location = nil
      breakpoint.path.must_be_nil
    end
  end

  describe "#line" do
    it "gets line from location" do
      breakpoint.line.must_equal breakpoint.location.line
    end

    it "returns nil if location doesn't exist" do
      breakpoint.location = nil
      breakpoint.line.must_be_nil
    end
  end

  describe "#check_condition" do
    it "returns true if condition is nil" do
      breakpoint.condition = nil

      breakpoint.check_condition(nil).must_equal true
    end

    it "returns true if condition is empty" do
      breakpoint.condition = ""
      breakpoint.check_condition(nil).must_equal true
    end

    it "calls breakpoint#set_error_state if Evaluator.eval_condition raises error" do
      stubbed_readonly_eval_expression = ->(_, _) { raise }
      mocked_set_error_state = Minitest::Mock.new
      mocked_set_error_state.expect :call, nil, [String, {refers_to: :BREAKPOINT_CONDITION}]

      Google::Cloud::Debugger::Breakpoint::Evaluator.stub :readonly_eval_expression, stubbed_readonly_eval_expression do
        breakpoint.stub :set_error_state, mocked_set_error_state do
          breakpoint.check_condition nil
        end
      end

      mocked_set_error_state.verify
    end

    it "calls breakpoint#set_error_state if mutation is detected while evaluating condition" do
      mocked_set_error_state = Minitest::Mock.new
      mocked_set_error_state.expect :call, nil, [String, {refers_to: :BREAKPOINT_CONDITION}]
      stubbed_condition_result = Google::Cloud::Debugger::MutationError.new

      Google::Cloud::Debugger::Breakpoint::Evaluator.stub :readonly_eval_expression, stubbed_condition_result do
        breakpoint.stub :set_error_state, mocked_set_error_state do
          breakpoint.check_condition nil
        end
      end

      mocked_set_error_state.verify
    end
  end

  describe "#eql?" do
    it "compares id, path, and line" do
      breakpoint2 = Google::Cloud::Debugger::Breakpoint.new("abc123", "my_app/my_class.rb", 321)

      breakpoint.eql?(breakpoint2).must_equal true
    end
  end

  describe "#set_error_state" do
    it "calls Breakpoint#complete if is_final parameter is true" do
      mocked_complete = Minitest::Mock.new
      mocked_complete.expect :call, nil

      breakpoint.stub :complete, mocked_complete do
        breakpoint.set_error_state ""
      end
    end

    it "doesn't call Breakpoint#complete if is_final parameter is false" do
      stubbed_complete = ->(){ raise "Shouldn't be called" }

      breakpoint.stub :complete, stubbed_complete do
        breakpoint.set_error_state "", is_final: false
      end
    end

    it "sets @status" do
      error_message = "breakpoint is broken"
      status = breakpoint.set_error_state error_message, refers_to: :BREAKPOINT_CONDITION

      breakpoint.status.must_equal status
      breakpoint.status.must_be_kind_of Google::Cloud::Debugger::Breakpoint::StatusMessage

      status.description.must_equal error_message
      status.is_error.must_equal true
      status.refers_to.must_equal :BREAKPOINT_CONDITION
    end
  end
end
