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

describe Google::Cloud::Debugger::Transmitter, :mock_debugger do
  describe "#submit" do
    it "puts the breakpoint on queue" do
      breakpoint = OpenStruct.new
      transmitter.start
      transmitter.instance_variable_get(:@lock_cond).stub :broadcast, nil do
        transmitter.submit breakpoint
        transmitter.instance_variable_get(:@queue).pop.must_equal breakpoint
      end
    end

    it "doesn't exceeds max_queue_size" do
      max_queue_size = 3
      transmitter.max_queue_size = max_queue_size
      transmitter.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      max_queue_size.times do |i|
        transmitter.submit i
      end

      wait_until_true do
        transmitter.instance_variable_get(:@queue).size == max_queue_size
      end

      transmitter.submit nil

      wait_until_true do
        transmitter.instance_variable_get(:@queue).size == max_queue_size
      end

      transmitter.instance_variable_get(:@queue).size.must_equal max_queue_size

      transmitter.instance_variable_set :@lock_cond, nil
    end

    it "wakes up the child queue to dequeue the breakpoints" do
      breakpoint = OpenStruct.new
      mocked_service = Minitest::Mock.new
      mocked_service.expect :update_active_breakpoint, nil, [nil, breakpoint]

      transmitter.start

      transmitter.stub :service, mocked_service do
        transmitter.submit breakpoint

        wait_result = wait_until_true do
          transmitter.instance_variable_get(:@queue).size == 0
        end
        wait_result.must_equal :completed
      end

      mocked_service.verify
    end
  end
end
