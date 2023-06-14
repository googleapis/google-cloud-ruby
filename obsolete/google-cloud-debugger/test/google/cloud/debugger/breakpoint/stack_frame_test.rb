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

describe Google::Cloud::Debugger::Breakpoint::StackFrame, :mock_debugger do
  let(:stack_frame_hash) { random_stack_frame_hash }
  let(:stack_frame_grpc) {
    Google::Cloud::Debugger::V2::StackFrame.new stack_frame_hash
  }
  let(:stack_frame) {
    Google::Cloud::Debugger::Breakpoint::StackFrame.from_grpc stack_frame_grpc
  }

  describe ".from_grpc" do
    it "has all of the attributes" do
      _(stack_frame.function).must_equal "index"
      _(stack_frame.location).must_be_kind_of Google::Cloud::Debugger::Breakpoint::SourceLocation
      _(stack_frame.arguments[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
      _(stack_frame.locals[0]).must_be_kind_of Google::Cloud::Debugger::Breakpoint::Variable
    end
  end

  describe "#to_grpc" do
    it "has all of the attributes" do
      grpc = stack_frame.to_grpc

      _(grpc.function).must_equal stack_frame_grpc.function
      _(grpc.location).must_equal stack_frame_grpc.location
      _(grpc.arguments).must_equal stack_frame_grpc.arguments
      _(grpc.locals).must_equal stack_frame_grpc.locals
    end

    it "has arguments even if missing from object" do
      stack_frame.arguments = nil
      _(stack_frame.to_grpc.arguments).must_equal []
    end

    it "has locals even if missing from object" do
      stack_frame.locals = nil
      _(stack_frame.to_grpc.locals).must_equal []
    end
  end
end
