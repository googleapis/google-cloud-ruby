# Copyright 2016 Google LLC
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

describe Google::Cloud::ErrorReporting::AsyncErrorReporter, :mock_error_reporting do
  let(:reporter) {
    Google::Cloud::ErrorReporting::AsyncErrorReporter.new error_reporting
  }

  describe "report" do
    let(:queue) { reporter.instance_variable_get :@queue }
    let(:queue_resource) { reporter.instance_variable_get :@queue_resource }

    it "puts the error event on queue" do
      event = Object.new

      reporter.async_suspend

      reporter.report event
      queue.pop.must_equal event
    end

    it "doesn't exceed max_queue_size" do
      max_queue_size = 3
      reporter.max_queue_size = max_queue_size
      reporter.async_suspend

      max_queue_size.times do |i|
        reporter.report i
      end

      reporter.report nil

      queue.size.must_equal max_queue_size
    end

    it "wakes up the child thread to dequeue the events" do
      event = Object.new
      mocked_error_reporting = Minitest::Mock.new
      mocked_error_reporting.expect :report, nil, [event]

      reporter = Google::Cloud::ErrorReporting::AsyncErrorReporter.new mocked_error_reporting

      reporter.report event

      wait_until_true do
        reporter.instance_variable_get(:@queue).size == 0
      end

      mocked_error_reporting.verify
    end
  end
end
