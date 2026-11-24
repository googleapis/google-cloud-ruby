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
    Google::Cloud::Trace::V1::TraceSpan.new \
      span_id: my_span_id,
      name: my_path,
      kind: :SPAN_KIND_UNSPECIFIED,
      start_time: start_time_proto,
      end_time: start_time_proto,
      parent_span_id: 0,
      labels: span_labels
  }
  let(:trace_proto) {
    Google::Cloud::Trace::V1::Trace.new \
      project_id: project,
      trace_id: my_trace_id,
      spans: [span_proto]
  }
  let(:traces_proto) {
    traces_proto = Google::Cloud::Trace::V1::Traces.new
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
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::Trace::V1::TraceService::Client.configure.endpoint = nil
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = nil
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::Trace::V1::TraceService::Client.configure.endpoint = nil
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = nil
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
      _(middleware.instance_variable_get(:@service)).must_equal "test-service"
    end

    it "creates a default AsyncReporter if service isn't passed in" do
      Google::Cloud::Trace.configure.project_id = "test"
      Google::Cloud::Trace.stub :new, OpenStruct.new(service: nil) do
        middleware = Google::Cloud::Trace::Middleware.new base_app, credentials: credentials
        _(middleware.instance_variable_get(:@service)).must_be_kind_of Google::Cloud::Trace::AsyncReporter
      end
    end

    it "configures endpoint and universe_domain from explicit kwargs" do
      custom_universe = "myuniverse.com"
      custom_endpoint = "custom.example.com"
      creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: custom_universe

      Google::Cloud::Trace.configure do |config|
        config.project_id = project
        config.credentials = creds
      end

      middleware = Google::Cloud::Trace::Middleware.new(
        base_app,
        endpoint: custom_endpoint,
        universe_domain: custom_universe
      )

      reporter = middleware.instance_variable_get :@service
      _(reporter).must_be_kind_of Google::Cloud::Trace::AsyncReporter
      _(reporter.service.universe_domain).must_equal custom_universe
      _(reporter.service.host).must_equal custom_endpoint
      _(reporter.service.lowlevel_client.universe_domain).must_equal custom_universe
      _(reporter.service.lowlevel_client.trace_service_stub.endpoint).must_equal custom_endpoint
    ensure
      reporter&.stop!
    end

    it "picks up endpoint and universe_domain from Trace.configure when kwargs are omitted" do
      custom_universe = "myuniverse.com"
      custom_endpoint = "custom.example.com"
      creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: custom_universe

      Google::Cloud::Trace.configure do |config|
        config.project_id = project
        config.credentials = creds
        config.endpoint = custom_endpoint
        config.universe_domain = custom_universe
      end

      middleware = Google::Cloud::Trace::Middleware.new base_app

      reporter = middleware.instance_variable_get :@service
      _(reporter).must_be_kind_of Google::Cloud::Trace::AsyncReporter
      _(reporter.service.universe_domain).must_equal custom_universe
      _(reporter.service.host).must_equal custom_endpoint
      _(reporter.service.lowlevel_client.universe_domain).must_equal custom_universe
      _(reporter.service.lowlevel_client.trace_service_stub.endpoint).must_equal custom_endpoint
    ensure
      reporter&.stop!
    end

    it "raises Gapic::UniverseDomainMismatch when credentials mismatch configured universe_domain" do
      mismatched_creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: "otheruniverse.com"

      Google::Cloud::Trace.configure do |config|
        config.project_id = project
        config.credentials = mismatched_creds
      end

      middleware = Google::Cloud::Trace::Middleware.new(
        base_app,
        universe_domain: "myuniverse.com"
      )

      reporter = middleware.instance_variable_get :@service
      expect do
        reporter.service.lowlevel_client
      end.must_raise Gapic::UniverseDomainMismatch
    ensure
      reporter&.stop!
    end
  end

  describe ".get_trace_context" do
    it "passes through the existing sampling decision" do
      env = rack_env sample: true
      tc = base_middleware.get_trace_context env

      _(tc.trace_id).must_equal my_trace_id
      _(tc.span_id).must_equal my_span_id
      _(tc.sampled?).must_equal true
      _(tc.capture_stack?).must_equal false
      _(tc.new?).must_equal false
    end

    it "makes a new sampling decision" do
      env = rack_env
      middleware = base_middleware
      tc = ::Time.stub :now, start_time do
        middleware.get_trace_context env
      end

      _(tc.trace_id).must_equal my_trace_id
      _(tc.span_id).must_equal my_span_id
      _(tc.sampled?).must_equal true
      _(tc.capture_stack?).must_equal false
      _(tc.new?).must_equal false
    end

    it "honors path blacklist" do
      env = rack_env path: "/_ah/health"
      middleware = base_middleware
      tc = ::Time.stub :now, start_time do
        middleware.get_trace_context env
      end

      _(tc.trace_id).must_equal my_trace_id
      _(tc.span_id).must_equal my_span_id
      _(tc.sampled?).must_equal false
      _(tc.capture_stack?).must_equal false
      _(tc.new?).must_equal false
    end
  end

  describe ".get_url" do
    it "returns an URL without a query string" do
      url = base_middleware.get_url rack_env
      _(url).must_equal "http://#{hostname}#{my_path}"
    end

    it "returns an URL with a query string" do
      env = rack_env.merge({"QUERY_STRING" => "foo=bar"})
      url = base_middleware.get_url env
      _(url).must_equal "http://#{hostname}#{my_path}?foo=bar"
    end
  end

  describe ".call" do
    it "sends a trace" do
      mock = Minitest::Mock.new
      mock.expect :patch_traces, nil, project_id: project, traces: traces_proto
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
      _(result[1]["X-Cloud-Trace-Context"]).must_equal "#{my_trace_id};o=1"
    end

    it "provides app access to the trace structure" do
      mock = Minitest::Mock.new
      mock.expect :patch_traces, nil, project_id: project, traces: traces_proto
      tracer.service.mocked_lowlevel_client = mock

      env = rack_env sample: true, span_id: nil
      myapp = ::Proc.new do |env|
        _(Google::Cloud::Trace.get.span_id).must_equal my_span_id
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

    it "routes background credential universe mismatch to Trace.configure.on_error as AsyncPatchTracesError" do
      mismatched_creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: "otheruniverse.com"
      errors = Queue.new

      Google::Cloud::Trace.configure do |config|
        config.project_id = project
        config.credentials = mismatched_creds
        config.universe_domain = "myuniverse.com"
        config.sampler = sampler
        config.span_id_generator = mock_span_id_generator
        config.on_error = proc { |error| errors << error }
      end

      middleware = Google::Cloud::Trace::Middleware.new base_app
      reporter = middleware.instance_variable_get :@service
      env = rack_env sample: true, span_id: nil

      result = ::Time.stub :now, start_time do
        middleware.call env
      end
      _(result[0]).must_equal "200"

      reporter.flush!
      reporter.stop! 5

      _(errors.size).must_equal 1
      error = errors.pop
      _(error).must_be_kind_of Google::Cloud::Trace::AsyncPatchTracesError
      _(error.message).must_include "myuniverse.com"
      _(error.message).must_include "otheruniverse.com"
    ensure
      reporter&.stop!
    end
  end
end
