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

describe Google::Cloud::Trace::AsyncReporter, :mock_trace do
  let(:reporter) {
    Google::Cloud::Trace::AsyncReporter.new tracer.service
  }

  describe "#patch_traces" do
    let(:queue) { reporter.instance_variable_get :@queue }
    let(:queue_resource) { reporter.instance_variable_get :@queue_resource }

    it "puts the trace on queue" do
      trace = Object.new

      reporter.async_suspend

      reporter.patch_traces trace
      queue.pop.must_equal trace
    end

    it "takes array of traces" do
      trace1 = Object.new
      trace2 = Object.new
      traces = [trace1, trace2]

      reporter.async_suspend

      reporter.patch_traces traces
      queue.pop.must_equal [trace1, trace2]
    end

    it "doesn't exceed max_queue_size" do
      max_queue_size = 3
      reporter.max_queue_size = max_queue_size
      reporter.async_suspend

      max_queue_size.times do |i|
        reporter.patch_traces i
      end

      reporter.patch_traces nil

      queue.size.must_equal max_queue_size

      # Empty the queue so that the reporter doesn't try to execute these
      # bogus items when it is flushed.
      max_queue_size.times do |i|
        queue.pop
      end
    end

    it "wakes up the child thread to dequeue the events" do
      trace = Object.new
      mocked_service = Minitest::Mock.new
      mocked_service.expect :patch_traces, nil, [trace]

      reporter = Google::Cloud::Trace::AsyncReporter.new mocked_service

      reporter.patch_traces trace

      wait_until_true do
        reporter.instance_variable_get(:@queue).size == 0
      end

      mocked_service.verify
    end
  end

  describe "#project" do
    it "returns that of #service" do
      reporter.service.stub :project, "service-project" do
        reporter.project.must_equal "service-project"
      end
    end
  end
end
