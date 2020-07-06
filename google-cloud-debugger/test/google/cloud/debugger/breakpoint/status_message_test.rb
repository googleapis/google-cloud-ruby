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

describe Google::Cloud::Debugger::Breakpoint::StatusMessage, :mock_debugger do
  let(:status_message_hash) do
    {
      is_error: true,
      refers_to: :UNSPECIFIED,
      description: {
        format: "test error message",
        parameters: ["test param"]
      }
    }
  end
  let(:status_message_grpc) {
    Google::Cloud::Debugger::V2::StatusMessage.new status_message_hash
  }
  let(:status_message) {
    Google::Cloud::Debugger::Breakpoint::StatusMessage.from_grpc status_message_grpc
  }

  describe ".from_grpc" do
    it "knows all of its attributes" do
      _(status_message.is_error).must_equal true
      _(status_message.refers_to).must_equal Google::Cloud::Debugger::Breakpoint::StatusMessage::UNSPECIFIED
      _(status_message.description).must_equal "test error message"
    end
  end

  describe "#to_grpc" do
    it "exports all of the content" do
      grpc = status_message.to_grpc

      _(grpc).must_be_kind_of Google::Cloud::Debugger::V2::StatusMessage
      _(grpc.is_error).must_equal true
      _(grpc.refers_to).must_equal :UNSPECIFIED
      _(grpc.description.format).must_equal "test error message"
    end
  end
end
