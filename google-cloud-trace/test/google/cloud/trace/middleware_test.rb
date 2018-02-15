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

describe Google::Cloud::Trace::Middleware, :mock_trace do
  let(:my_trace_id) { "0123456789abcdef0123456789abcdef" }
  let(:my_span_id) { 12345 }
  let(:hostname) { "my-app.appspot.com" }
  let(:useragent) { "meowbrowser" }
  let(:pid) { ::Process.pid.to_s }
  let(:tid) { ::Thread.current.object_id.to_s }
  let(:init_time) { ::Time.at 12345678 }
  let(:start_time) { ::Time.at 12345679 }
  let(:start_time_proto) { Google::Protobuf::Timestamp.new seconds: 12345679, nanos: 0 }
  let(:my_path) { "/" }
  let(:span_labels) {
    {
      Google::Cloud::Trace::LabelKey::AGENT => Google::Cloud::Trace::Middleware::AGENT_NAME,
      Google::Cloud::Trace::LabelKey::HTTP_HOST => hostname,
      Google::Cloud::Trace::LabelKey::HTTP_METHOD => "GET",
      Google::Cloud::Trace::LabelKey::HTTP_CLIENT_PROTOCOL => "HTTP/1.1",
      Google::Cloud::Trace::LabelKey::HTTP_USER_AGENT => useragent,
      Google::Cloud::Trace::LabelKey::HTTP_URL => "http://#{hostname}#{my_path}",
      Google::Cloud::Trace::LabelKey::PID => pid,
      Google::Cloud::Trace::LabelKey::TID => tid,
      Google::Cloud::Trace::LabelKey::HTTP_STATUS_CODE => "200"
    }
  }
  let(:span_proto) {
    Google::Devtools::Cloudtrace::V1::TraceSpan.new \
      span_id: my_span_id,
      name: my_path,
      kind: :SPAN_KIND_UNSPECIFIED,
      start_time: start_time_proto,
      end_time: start_time_proto,
      parent_span_id: 0,
      labels: span_labels
  }
  let(:trace_proto) {
    Google::Devtools::Cloudtrace::V1::Trace.new \
      project_id: project,
      trace_id: my_trace_id,
      spans: [span_proto]
  }
  let(:traces_proto) {
    traces_proto = Google::Devtools::Cloudtrace::V1::Traces.new
    traces_proto.traces.push trace_proto
    traces_proto
  }

  let(:sampler) {
    ::Time.stub :now, init_time do
      Google::Cloud::Trace::TimeSampler.new
    end
  }
  let(:mock_span_id_generator) {
    ::Proc.new { my_span_id }
  }
  let(:base_middleware) {
    Google::Cloud::Trace.configure do |config|
      config.sampler = sampler
      config.span_id_generator = mock_span_id_generator
    end
    tracer.service.mocked_lowlevel_client = Minitest::Mock.new
    Google::Cloud::Trace::Middleware.new base_app, service: tracer.service
  }

  before do
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
  end

  after do
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
  end

  def base_app(&block)
    app = ::Struct.new(:block).new(block)
    def app.call env
      block ? block.call(env) : ["200", {}, "Hello, world!\n"]
    end
    app
  end

  def rack_env sample: nil,
               span_id: my_span_id,
               path: my_path
    tc_header = my_trace_id
    tc_header = "#{tc_header}/#{span_id}" if span_id
    tc_header = "#{tc_header};o=1" if sample
    {
      "HTTP_X_CLOUD_TRACE_CONTEXT" => tc_header,
      "PATH_INFO" => path,
      "HTTP_HOST" => hostname,
      "rack.url_scheme" => "http",
      "REQUEST_METHOD" => "GET",
      "SERVER_PROTOCOL" => "HTTP/1.1",
      "HTTP_USER_AGENT" => useragent
    }
  end

  describe ".initialize" do
    it "uses the service object passed in" do
      middleware = Google::Cloud::Trace::Middleware.new base_app, service: "test-service"
      middleware.instance_variable_get(:@service).must_equal "test-service"
    end

    it "creates a default AsyncReporter if service isn't passed in" do
      Google::Cloud::Trace.configure.project_id = "test"
      Google::Cloud::Trace.stub :new, OpenStruct.new(service: nil) do
        middleware = Google::Cloud::Trace::Middleware.new base_app, credentials: credentials
        middleware.instance_variable_get(:@service).must_be_kind_of Google::Cloud::Trace::AsyncReporter
      end
    end
  end

  describe ".get_trace_context" do
    it "passes through the existing sampling decision" do
      env = rack_env sample: true
      tc = base_middleware.get_trace_context env

      tc.trace_id.must_equal my_trace_id
      tc.span_id.must_equal my_span_id
      tc.sampled?.must_equal true
      tc.capture_stack?.must_equal false
      tc.new?.must_equal false
    end

    it "makes a new sampling decision" do
      env = rack_env
      middleware = base_middleware
      tc = ::Time.stub :now, start_time do
        middleware.get_trace_context env
      end

      tc.trace_id.must_equal my_trace_id
      tc.span_id.must_equal my_span_id
      tc.sampled?.must_equal true
      tc.capture_stack?.must_equal false
      tc.new?.must_equal false
    end

    it "honors path blacklist" do
      env = rack_env path: "/_ah/health"
      middleware = base_middleware
      tc = ::Time.stub :now, start_time do
        middleware.get_trace_context env
      end

      tc.trace_id.must_equal my_trace_id
      tc.span_id.must_equal my_span_id
      tc.sampled?.must_equal false
      tc.capture_stack?.must_equal false
      tc.new?.must_equal false
    end
  end

  describe ".get_url" do
    it "returns an URL without a query string" do
      url = base_middleware.get_url rack_env
      url.must_equal "http://#{hostname}#{my_path}"
    end

    it "returns an URL with a query string" do
      env = rack_env.merge({"QUERY_STRING" => "foo=bar"})
      url = base_middleware.get_url env
      url.must_equal "http://#{hostname}#{my_path}?foo=bar"
    end
  end

  describe ".call" do
    it "sends a trace" do
      mock = Minitest::Mock.new
      mock.expect :patch_traces, nil, [project, traces_proto]
      tracer.service.mocked_lowlevel_client = mock

      env = rack_env sample: true, span_id: nil
      Google::Cloud::Trace.configure do |config|
        config.sampler = sampler
        config.span_id_generator = mock_span_id_generator
      end
      middleware = Google::Cloud::Trace::Middleware.new \
        base_app,
        service: tracer.service
      result = ::Time.stub :now, start_time do
        middleware.call env
      end

      mock.verify
      result[1]["X-Cloud-Trace-Context"].must_equal "#{my_trace_id};o=1"
    end

    it "provides app access to the trace structure" do
      mock = Minitest::Mock.new
      mock.expect :patch_traces, nil, [project, traces_proto]
      tracer.service.mocked_lowlevel_client = mock

      env = rack_env sample: true, span_id: nil
      myapp = ::Proc.new do |env|
        Google::Cloud::Trace.get.span_id.must_equal my_span_id
        ["200", {}, "Hello, world!\n"]
      end

      Google::Cloud::Trace.configure do |config|
        config.sampler = sampler
        config.span_id_generator = mock_span_id_generator
      end
      middleware = Google::Cloud::Trace::Middleware.new \
        base_app(&myapp),
        service: tracer.service
      ::Time.stub :now, start_time do
        middleware.call env
      end

      mock.verify
    end
  end
end
