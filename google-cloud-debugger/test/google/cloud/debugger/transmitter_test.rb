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

describe Google::Cloud::Debugger::Transmitter, :mock_debugger do
  describe "#submit" do
    let(:mocked_service) { Minitest::Mock.new }

    let(:breakpoint_hash) { random_breakpoint_hash }
    let(:breakpoint_grpc) { Google::Devtools::Clouddebugger::V2::Breakpoint.new breakpoint_hash }
    let(:breakpoint) { Google::Cloud::Debugger::Breakpoint.from_grpc breakpoint_grpc }

    before do
      service.mocked_transmitter = mocked_service
      transmitter.on_error do |error|
        raise error.inspect
      end
      transmitter.start
    end

    after do
      transmitter.stop
      mocked_service.verify
    end

    it "submits a breakpoint to the API" do
      mocked_service.expect :update_active_breakpoint, nil, ["", breakpoint_grpc, Hash]

      transmitter.start
      transmitter.submit breakpoint
      transmitter.stop 10
    end
  end
end
