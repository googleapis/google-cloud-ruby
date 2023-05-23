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

describe Google::Cloud::Trace::TraceRecord do
  let(:my_trace_id) { "1234512345" }
  let(:project_id) { "my-project" }
  let(:my_trace_context) {
    Stackdriver::Core::TraceContext.new trace_id: my_trace_id
  }
  let(:empty_trace) {
    Google::Cloud::Trace::TraceRecord.new project_id, my_trace_context
  }

  it "initializes with a trace context" do
    tc = Stackdriver::Core::TraceContext.new trace_id: my_trace_id,
                                             span_id: 54321,
                                             sampled: true,
                                             capture_stack: false
    trace = Google::Cloud::Trace::TraceRecord.new project_id, tc
    _(trace.trace_context).must_equal tc
    _(trace.trace_id).must_equal my_trace_id
  end

  it "initializes with no spans" do
    trace = empty_trace

    _(trace.all_spans).must_be_empty
    _(trace.root_spans).must_be_empty
  end

  it "can create a new populated span" do
    start_time = Time.at(1000)
    end_time = Time.at(2000)
    labels = {a: 1, b: 2}

    trace = empty_trace
    span = trace.create_span "aname",
                             kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                             start_time: start_time, end_time: end_time,
                             labels: labels

    _(span.trace).must_equal trace
    _(span.parent).must_be_nil
    _(span.kind).must_equal Google::Cloud::Trace::SpanKind::RPC_SERVER
    _(span.name).must_equal "aname"
    _(span.start_time).must_equal start_time
    _(span.end_time).must_equal end_time
    _(span.labels).must_equal labels
    _(span.children).must_be_empty
    _(trace.all_spans.size).must_equal 1
    _(trace.all_spans).must_include span
    _(trace.root_spans.size).must_equal 1
    _(trace.root_spans).must_include span
  end

  it "can create a new empty span" do
    trace = empty_trace
    span = trace.create_span ""

    _(span.trace).must_equal trace
    _(span.parent).must_be_nil
    _(span.kind).must_equal Google::Cloud::Trace::SpanKind::UNSPECIFIED
    _(span.name).must_be_empty
    _(span.start_time).must_be_nil
    _(span.end_time).must_be_nil
    _(span.labels).must_be_empty
    _(trace.all_spans.size).must_equal 1
    _(trace.all_spans).must_include span
    _(trace.root_spans.size).must_equal 1
    _(trace.root_spans).must_include span
  end

  it "can create subspans" do
    trace = empty_trace
    span = trace.create_span "aname",
                             kind: Google::Cloud::Trace::SpanKind::RPC_SERVER
    subspan = span.create_span "bname",
                               kind: Google::Cloud::Trace::SpanKind::RPC_CLIENT

    _(subspan.trace).must_equal trace
    _(subspan.parent).must_equal span
    _(subspan.name).must_equal "bname"
    _(subspan.kind).must_equal Google::Cloud::Trace::SpanKind::RPC_CLIENT
    _(subspan.start_time).must_be_nil
    _(subspan.end_time).must_be_nil
    _(subspan.labels).must_be_empty
    _(trace.all_spans.size).must_equal 2
    _(trace.all_spans).must_include span
    _(trace.all_spans).must_include subspan
    _(trace.root_spans.size).must_equal 1
    _(trace.root_spans).must_include span
    _(span.children.size).must_equal 1
    _(span.children).must_include subspan
  end

  it "can start and finish spans" do
    trace = empty_trace
    span = trace.create_span "aname"

    _(span.start_time).must_be_nil
    _(span.end_time).must_be_nil

    pre_start_time = Time.now.utc
    span.start!

    _(span.start_time).must_be :>=, pre_start_time
    _(span.end_time).must_be_nil

    between_time = Time.now.utc
    span.finish!
    post_end_time = Time.now.utc

    _(span.start_time).must_be :<=, between_time
    _(span.end_time).must_be :>=, between_time
    _(span.end_time).must_be :<=, post_end_time
  end

  it "can delete spans recursively" do
    trace = empty_trace
    span = trace.create_span "aname"
    subspan = span.create_span "bname"
    subsubspan = subspan.create_span "cname"
    subspan.delete

    _(subspan.exists?).must_equal false
    _(subsubspan.exists?).must_equal false
    _(span.children).must_be_empty
    _(trace.all_spans.size).must_equal 1
    _(trace.all_spans).must_include span
    _(trace.root_spans.size).must_equal 1
    _(trace.root_spans).must_include span
  end

  it "can move spans to a new parent" do
    trace = empty_trace
    span1 = trace.create_span "aname"
    span2 = trace.create_span "bname"
    subspan = span1.create_span "cname"

    _(span1.children).must_include subspan
    _(span2.children).must_be_empty
    _(subspan.parent).must_equal span1

    subspan.move_under span2

    _(span1.children).must_be_empty
    _(span2.children).must_include subspan
    _(subspan.parent).must_equal span2
  end

  it "can create span trees using in_span" do
    trace = empty_trace
    sub1 = sub2 = nil
    before_time = Time.now.utc
    root1 = trace.in_span "aname" do |span|
      sub1 = span.in_span("bname") { |s| s }
      sub2 = span.in_span("cname") { |s| s }
      span
    end
    root2 = trace.in_span("dname") { |span| span }
    after_time = Time.now.utc

    _(trace.all_spans.size).must_equal 4
    _(trace.root_spans.size).must_equal 2

    _(root1.children.size).must_equal 2
    _(root1.children).must_include sub1
    _(root1.children).must_include sub2
    _(root2.children).must_be_empty

    _(root1.start_time).must_be :>=, before_time
    _(sub1.start_time).must_be :>=, root1.start_time
    _(sub1.end_time).must_be :>=, sub1.start_time
    _(sub2.start_time).must_be :>=, sub1.end_time
    _(sub2.end_time).must_be :>=, sub2.start_time
    _(root1.end_time).must_be :>=, sub2.end_time
    _(root2.start_time).must_be :>=, root1.end_time
    _(root2.end_time).must_be :>=, root2.start_time
    _(after_time).must_be :>=, root2.end_time
  end

  it "converts to and from a protobuf" do
    span_start = Time.at 10001, 123
    span_start_p = Google::Protobuf::Timestamp.new seconds: 10001, nanos: 123000
    sub_start = Time.at 10002, 456
    sub_start_p = Google::Protobuf::Timestamp.new seconds: 10002, nanos: 456000
    sub_end = Time.at 10003, 789
    sub_end_p = Google::Protobuf::Timestamp.new seconds: 10003, nanos: 789000
    span_end = Time.at 10004, 321
    span_end_p = Google::Protobuf::Timestamp.new seconds: 10004, nanos: 321000
    span_id = 314159
    sub_id = 265359
    span_name = "aname"
    sub_name = "bname"
    span_labels = { "foo" => "bar"}
    sub_labels = { "foo" => "baz"}

    trace = empty_trace
    span = trace.create_span span_name,
                             span_id: span_id,
                             kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                             start_time: span_start, end_time: span_end,
                             labels: span_labels
    span.create_span sub_name,
                     span_id: sub_id,
                     kind: Google::Cloud::Trace::SpanKind::RPC_CLIENT,
                     start_time: sub_start, end_time: sub_end,
                     labels: sub_labels

    proto = Google::Cloud::Trace::V1::Trace.new \
      project_id: project_id,
      trace_id: my_trace_id,
      spans: [
        Google::Cloud::Trace::V1::TraceSpan.new(
          span_id: span_id,
          kind: :RPC_SERVER,
          name: span_name,
          start_time: span_start_p,
          end_time: span_end_p,
          parent_span_id: 0,
          labels: span_labels),
        Google::Cloud::Trace::V1::TraceSpan.new(
          span_id: sub_id,
          kind: :RPC_CLIENT,
          name: sub_name,
          start_time: sub_start_p,
          end_time: sub_end_p,
          parent_span_id: span_id,
          labels: sub_labels)
      ]

    _(trace.to_grpc).must_equal proto
    _(Google::Cloud::Trace::TraceRecord.from_grpc(proto)).must_equal trace
  end

  it "converts to and from a protobuf with an orphaned span" do
    span_start = Time.at 10001, 123
    span_start_p = Google::Protobuf::Timestamp.new seconds: 10001, nanos: 123000
    sub_start = Time.at 10002, 456
    sub_start_p = Google::Protobuf::Timestamp.new seconds: 10002, nanos: 456000
    sub_end = Time.at 10003, 789
    sub_end_p = Google::Protobuf::Timestamp.new seconds: 10003, nanos: 789000
    span_end = Time.at 10004, 321
    span_end_p = Google::Protobuf::Timestamp.new seconds: 10004, nanos: 321000
    context_span_id = 271828
    span_id = 314159
    sub_id = 265359
    span_name = "aname"
    sub_name = "bname"
    span_labels = { "foo" => "bar"}
    sub_labels = { "foo" => "baz"}

    tc = my_trace_context.with span_id: context_span_id
    trace = Google::Cloud::Trace::TraceRecord.new project_id, tc
    span = trace.create_span span_name,
                             span_id: span_id,
                             kind: Google::Cloud::Trace::SpanKind::RPC_SERVER,
                             start_time: span_start, end_time: span_end,
                             labels: span_labels
    span.create_span sub_name,
                     span_id: sub_id,
                     kind: Google::Cloud::Trace::SpanKind::RPC_CLIENT,
                     start_time: sub_start, end_time: sub_end,
                     labels: sub_labels

    proto = Google::Cloud::Trace::V1::Trace.new \
      project_id: project_id,
      trace_id: my_trace_id,
      spans: [
        Google::Cloud::Trace::V1::TraceSpan.new(
          span_id: span_id,
          kind: :RPC_SERVER,
          name: span_name,
          start_time: span_start_p,
          end_time: span_end_p,
          parent_span_id: context_span_id,
          labels: span_labels),
        Google::Cloud::Trace::V1::TraceSpan.new(
          span_id: sub_id,
          kind: :RPC_CLIENT,
          name: sub_name,
          start_time: sub_start_p,
          end_time: sub_end_p,
          parent_span_id: span_id,
          labels: sub_labels)
      ]

    _(trace.to_grpc).must_equal proto
    _(Google::Cloud::Trace::TraceRecord.from_grpc(proto)).must_equal trace
  end
end
