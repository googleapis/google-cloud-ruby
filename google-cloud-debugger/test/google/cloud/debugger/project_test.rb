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

describe Google::Cloud::Debugger::Project, :mock_debugger do
  it "knows the project identifier" do
    debugger.must_be_kind_of Google::Cloud::Debugger::Project
    debugger.project.must_equal project
  end

  describe "#start" do
    it "calls agent#start" do
      mocked_agent = Minitest::Mock.new
      mocked_agent.expect :start, nil

      debugger.stub :agent, mocked_agent do
        debugger.start
      end

      mocked_agent.verify
    end
  end

  describe "#stop" do
    it "calls agent#stop" do
      mocked_agent = Minitest::Mock.new
      mocked_agent.expect :stop, nil

      debugger.stub :agent, mocked_agent do
        debugger.stop
      end

      mocked_agent.verify
    end
  end
end
