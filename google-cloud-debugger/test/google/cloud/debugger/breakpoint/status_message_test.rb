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
  let(:status_message_json) { status_message_hash.to_json }
  let(:status_message_grpc) {
    Google::Devtools::Clouddebugger::V2::StatusMessage.decode_json status_message_json
  }
  let(:status_message) {
    Google::Cloud::Debugger::Breakpoint::StatusMessage.from_grpc status_message_grpc
  }

  describe ".from_grpc" do
    it "knows all of its attributes" do
      status_message.is_error.must_equal true
      status_message.refers_to.must_equal Google::Cloud::Debugger::Breakpoint::StatusMessage::UNSPECIFIED
      status_message.description.must_equal "test error message"
    end
  end

  describe "#to_grpc" do
    it "exports all of the content" do
      grpc = status_message.to_grpc

      grpc.must_be_kind_of Google::Devtools::Clouddebugger::V2::StatusMessage
      grpc.is_error.must_equal true
      grpc.refers_to.must_equal :UNSPECIFIED
      grpc.description.format.must_equal "test error message"
    end
  end
end