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

describe Google::Cloud::Debugger::Agent, :mock_debugger do
  describe "#initialize" do
    it "initializes all the children components" do
      agent.debuggee.must_be_kind_of Google::Cloud::Debugger::Debuggee
      agent.tracer.must_be_kind_of Google::Cloud::Debugger::Tracer
      agent.breakpoint_manager.must_be_kind_of Google::Cloud::Debugger::BreakpointManager
      agent.breakpoint_manager.on_breakpoints_change.must_be_kind_of Method
      agent.transmitter.must_be_kind_of Google::Cloud::Debugger::Transmitter
      agent.logger.must_be_kind_of Google::Cloud::Logging::Logger
    end

    it "the default logger shares same project_id and credentials" do
      agent.logger.project.must_equal service.project

      agent.logger.writer.logging.service.credentials.must_equal service.credentials
    end

    it "uses the logger passed in" do
      new_agent = Google::Cloud::Debugger::Agent.new nil, logger: "test-logger",
                                                          service_name: nil,
                                                          service_version: nil
      new_agent.logger.must_equal "test-logger"
    end
  end

  describe "#start" do
    it "calls Transmitter#start" do
      mocked_transmitter = Minitest::Mock.new
      mocked_transmitter.expect :start, nil

      agent.stub :transmitter, mocked_transmitter do
        agent.stub :async_start, nil do
          agent.start
        end
      end

      mocked_transmitter.verify
    end
  end

  describe "#stop" do
    it "calls Tracer#stop and #Transmitter#stop" do
      mocked_transmitter = Minitest::Mock.new
      mocked_transmitter.expect :stop, nil

      mocked_tracer = Minitest::Mock.new
      mocked_tracer.expect :stop, nil

      agent.async_start

      agent.stub :transmitter, mocked_transmitter do
        agent.stub :tracer, mocked_tracer do
          agent.stop
        end
      end

      mocked_tracer.verify
      mocked_transmitter.verify
    end
  end

  describe "#stop_tracer" do
    it "calls Tracer#stop" do
      mocked_tracer = Minitest::Mock.new
      mocked_tracer.expect :stop, nil

      agent.async_start

      agent.stub :tracer, mocked_tracer do
        agent.stop
      end

      mocked_tracer.verify
    end
  end
end
