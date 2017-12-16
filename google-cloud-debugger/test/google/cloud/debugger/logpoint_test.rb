# Copyright 2017 Google LLC
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

describe Google::Cloud::Debugger::Logpoint, :mock_debugger do
  let(:breakpoint_hash) { random_breakpoint_hash }
  let(:breakpoint_json) { breakpoint_hash.to_json }
  let(:breakpoint_grpc) {
    Google::Devtools::Clouddebugger::V2::Breakpoint.decode_json breakpoint_json
  }
  let(:logpoint) {
    breakpoint_hash[:action] = :LOG
    breakpoint_hash[:log_message_format] = "Hello $0"
    breakpoint_hash[:expressions] = ["World"]

    Google::Cloud::Debugger::Logpoint.from_grpc breakpoint_grpc
  }

  describe "#format_message" do
    it "formats basic message" do
      logpoint.format_message("Hello World", []).must_equal "Hello World"
    end

    it "formats message with expressions" do
      logpoint.format_message("Hello $0$1", ["World", :!]).must_equal "Hello \"World\":!"
    end

    it "formats message with extra expressions" do
      logpoint.format_message("Hello $0$1", ["World", :!, :zomg]).must_equal "Hello \"World\":!"
    end

    it "formats message with extra placeholder" do
      logpoint.format_message("Hello $0$1$2", ["World", :!]).must_equal "Hello \"World\":!"
    end

    it "doesn't substitute escaped placeholder and unescape them" do
      logpoint.format_message("Hello 0 $0 $$0 $$$$0", ["World"]).must_equal "Hello 0 \"World\" $0 $$0"
    end
  end

  describe "#evaluate" do
    it "returns false if logpoint is evaluated already" do
      logpoint.complete

      logpoint.evaluate([]).must_equal false
    end

    it "returns false if logpoint condition check fails" do
      logpoint.stub :check_condition, false do
        logpoint.evaluate [nil]
      end
    end

    it "sets @evaluated_log_message for logpoint" do
      stubbed_format_message = -> (_, _) { "test log message" }

      logpoint.stub :format_message, stubbed_format_message do
        logpoint.stub :check_condition, true do
          logpoint.evaluate([nil])

          logpoint.evaluated_log_message.must_equal "test log message"
        end
      end
    end

    it "doesn't complete logpoints" do
      logpoint.condition = nil

      logpoint.evaluate []

      logpoint.complete?.must_equal false
    end
  end
end
