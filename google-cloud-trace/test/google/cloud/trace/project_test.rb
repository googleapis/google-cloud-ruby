# Copyright 2016 Google LLC
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

describe Google::Cloud::Trace::Project, :mock_trace do
  MockPagedEnum = ::Struct.new :page

  let(:simple_trace_id) { "0123456789abcdef0123456789abcdef" }
  let(:simple_span_id) { 54321 }
  let(:simple_span_name) { "/path/to/resource" }
  let(:simple_span_start) { Time.at 10001, 123 }
  let(:simple_span_end) { Time.at 10002, 456 }
  let(:simple_span_start_proto) { Google::Protobuf::Timestamp.new seconds: 10001, nanos: 123000 }
  let(:simple_span_end_proto) { Google::Protobuf::Timestamp.new seconds: 10002, nanos: 456000 }
  let(:simple_span_labels) { { "foo" => "bar" } }
  let(:simple_span_proto) {
    Google::Devtools::Cloudtrace::V1::TraceSpan.new \
      span_id: simple_span_id,
      kind: :RPC_SERVER,
      name: simple_span_name,
      start_time: simple_span_start_proto,
      end_time: simple_span_end_proto,
      parent_span_id: 0,
      labels: simple_span_labels
  }
  let(:simple_trace_proto) {
    Google::Devtools::Cloudtrace::V1::Trace.new \
      project_id: project,
      trace_id: simple_trace_id,
      spans: [simple_span_proto]
  }
  let(:simple_traces_proto) {
    traces_proto = Google::Devtools::Cloudtrace::V1::Traces.new
    traces_proto.traces.push simple_trace_proto
    traces_proto
  }
  let(:simple_trace_context) { Stackdriver::Core::TraceContext.new trace_id: simple_trace_id }
  let(:simple_trace) {
    trace = Google::Cloud::Trace::TraceRecord.new project, simple_trace_context
    trace.create_span simple_span_name,
                      span_id: simple_span_id,
                      kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                      start_time: simple_span_start,
                      end_time: simple_span_end,
                      labels: simple_span_labels
    trace
  }

  let(:second_trace_id) { "fedcba9876543210fedcba9876543210" }
  let(:second_span_id) { 98765 }
  let(:second_span_name) { "/path/to/resource" }
  let(:second_span_start) { Time.at 10003, 123 }
  let(:second_span_end) { Time.at 10004, 456 }
  let(:second_span_start_proto) { Google::Protobuf::Timestamp.new seconds: 10003, nanos: 123000 }
  let(:second_span_end_proto) { Google::Protobuf::Timestamp.new seconds: 10004, nanos: 456000 }
  let(:second_span_labels) { { "foo" => "baz" } }
  let(:second_span_proto) {
    Google::Devtools::Cloudtrace::V1::TraceSpan.new \
      span_id: second_span_id,
      kind: :RPC_SERVER,
      name: second_span_name,
      start_time: second_span_start_proto,
      end_time: second_span_end_proto,
      parent_span_id: 0,
      labels: second_span_labels
  }
  let(:second_trace_proto) {
    Google::Devtools::Cloudtrace::V1::Trace.new \
      project_id: project,
      trace_id: second_trace_id,
      spans: [second_span_proto]
  }
  let(:second_trace_context) { Stackdriver::Core::TraceContext.new trace_id: second_trace_id }
  let(:second_trace) {
    trace = Google::Cloud::Trace::TraceRecord.new project, second_trace_context
    trace.create_span second_span_name,
                      span_id: second_span_id,
                      kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                      start_time: second_span_start,
                      end_time: second_span_end,
                      labels: second_span_labels
    trace
  }

  let(:range_start_proto) { Google::Protobuf::Timestamp.new seconds: 10000, nanos: 0 }
  let(:range_end_proto) { Google::Protobuf::Timestamp.new seconds: 10010, nanos: 0 }
  let(:range_start) { Time.at 10000, 0 }
  let(:range_end) { Time.at 10010, 0 }

  let(:default_options) { Google::Gax::CallOptions.new }
  let(:next_page_token) { "next" }
  let(:gax_page) {
    response = {
      resource: [simple_trace_proto, second_trace_proto],
      page_token: next_page_token
    }
    Google::Gax::PagedEnumerable::Page.new response, :page_token, :resource
  }
  let(:gax_paged_enum) {
    MockPagedEnum.new gax_page
  }

  it "knows the project identifier" do
    tracer.must_be_kind_of Google::Cloud::Trace::Project
    tracer.project.must_equal project
  end

  it "gets a single trace" do
    mock = Minitest::Mock.new
    mock.expect :get_trace, simple_trace_proto, [project, simple_trace_id]
    tracer.service.mocked_lowlevel_client = mock

    actual_trace = tracer.get_trace simple_trace_id

    mock.verify
    actual_trace.must_equal simple_trace
  end

  it "lists traces" do
    mock = Minitest::Mock.new
    mock.expect :list_traces, gax_paged_enum,
                [project,
                  start_time: range_start_proto,
                  end_time: range_end_proto,
                  view: nil,
                  page_size: nil,
                  filter: nil,
                  order_by: nil,
                  options: default_options]
    tracer.service.mocked_lowlevel_client = mock

    actual_result = tracer.list_traces range_start, range_end

    mock.verify
    actual_result.must_be_kind_of Google::Cloud::Trace::ResultSet
    actual_result.project.must_equal project
    actual_result.next_page_token.must_equal next_page_token
    actual_result.start_time.must_equal range_start
    actual_result.end_time.must_equal range_end
    actual_result.results_pending?.must_equal true
    actual_result.to_a.must_equal [simple_trace, second_trace]
  end

  it "patches a trace" do
    mock = Minitest::Mock.new
    mock.expect :patch_traces, nil, [project, simple_traces_proto]
    tracer.service.mocked_lowlevel_client = mock

    tracer.patch_traces simple_trace

    mock.verify
  end
end
