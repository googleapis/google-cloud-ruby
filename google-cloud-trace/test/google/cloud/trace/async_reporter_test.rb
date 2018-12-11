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

describe Google::Cloud::Trace::AsyncReporter, :mock_trace do
  let(:mocked_service) { Minitest::Mock.new }
  let(:async_reporter) { Google::Cloud::Trace::AsyncReporter.new mocked_service }
  let(:trace_context) { Stackdriver::Core::TraceContext.new trace_id: "0123456789abcdef0123456789abcdef" }
  let(:trace1) do
    Google::Cloud::Trace::TraceRecord.new(project, trace_context).tap do |trace|
      trace.create_span "first span",
                        span_id: 12345,
                        kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                        start_time: Time.now - 1,
                        end_time: Time.now
    end
  end
  let(:trace2) do
    Google::Cloud::Trace::TraceRecord.new(project, trace_context).tap do |trace|
      trace.create_span "second span",
                        span_id: 12346,
                        kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                        start_time: Time.now - 1,
                        end_time: Time.now
    end
  end

  before do
    async_reporter.on_error do |error|
      raise error.inspect
    end
  end

  it "patches a single trace" do
    mocked_service.expect :project, "my-project"
    mocked_service.expect :patch_traces, nil, [[trace1]]

    async_reporter.patch_traces trace1

    async_reporter.stop! 1

    mocked_service.verify
  end

  it "patches multiple traces" do
    mocked_service.expect :project, "my-project"
    mocked_service.expect :patch_traces, nil, [[trace1, trace2]]

    async_reporter.patch_traces [trace1, trace2]

    async_reporter.stop! 1

    mocked_service.verify
  end

  it "buffers multiple patch_traces calls" do
    mocked_service.expect :project, "my-project"
    mocked_service.expect :patch_traces, nil, [[trace1, trace2]]

    async_reporter.patch_traces trace1
    async_reporter.patch_traces [trace2]

    async_reporter.stop! 1

    mocked_service.verify
  end
end
