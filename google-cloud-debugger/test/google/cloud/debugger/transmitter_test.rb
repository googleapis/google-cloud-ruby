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
    let(:queue) { transmitter.instance_variable_get(:@queue) }
    let(:queue_resource) { transmitter.instance_variable_get(:@queue_resource) }

    it "puts the breakpoint on queue" do
      breakpoint = OpenStruct.new

      transmitter.submit breakpoint
      queue.pop.must_equal breakpoint
    end

    it "doesn't exceeds max_queue_size" do
      max_queue_size = 3
      transmitter.max_queue_size = max_queue_size
      transmitter.instance_variable_set :@queue_resource, OpenStruct.new(broadcast: nil)

      max_queue_size.times do |i|
        transmitter.submit i
      end

      wait_until_true do
        queue.size == max_queue_size
      end

      transmitter.submit nil

      wait_until_true do
        queue.size == max_queue_size
      end

      queue.size.must_equal max_queue_size

      transmitter.instance_variable_set :@queue_resource, nil
    end

    it "wakes up the child queue to dequeue the breakpoints" do
      breakpoint = OpenStruct.new
      mocked_service = Minitest::Mock.new
      mocked_service.expect :update_active_breakpoint, nil, [nil, breakpoint]

      transmitter.start

      transmitter.stub :service, mocked_service do
        transmitter.submit breakpoint

        wait_result = wait_until_true do
          queue.size == 0
        end
        wait_result.must_equal :completed
      end

      mocked_service.verify

      transmitter.stop
      transmitter.synchronize do
        queue_resource.broadcast
      end
    end
  end
end
