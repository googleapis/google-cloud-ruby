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
require "google/cloud/trace/faraday_middleware"
require "ostruct"

describe Google::Cloud::Trace::FaradayMiddleware do
  let(:app) {
    app = Object.new
    app.define_singleton_method :call do |_| end
    app
  }
  let(:middleware) do
    Google::Cloud::Trace::FaradayMiddleware.new app
  end

  describe "#initialize" do
    it "accepts enable_cross_project_tracing as optional params" do
      middleware = Google::Cloud::Trace::FaradayMiddleware.new app
      _(middleware.instance_variable_get(:@enable_cross_project_tracing)).must_equal false

      middleware = Google::Cloud::Trace::FaradayMiddleware.new app, enable_cross_project_tracing: true
      _(middleware.instance_variable_get(:@enable_cross_project_tracing)).must_equal true
    end
  end

  describe "#call" do
    it "doesn't interfere @app.call even if there are no parent span" do
      mocked_app = Minitest::Mock.new
      mocked_app.expect :call, nil, [NilClass]

      middleware.instance_variable_set :@app, mocked_app

      Google::Cloud::Trace.stub :get, nil do
        middleware.call nil
      end

      mocked_app.verify
    end
  end

  describe "#add_request_labels" do
    it "sets all the labels" do
      env = OpenStruct.new url: Object.new, body: "body"
      env.define_singleton_method(:method) { "test-method" }
      env.url.define_singleton_method(:to_s) { "full-url" }

      span = OpenStruct.new labels: {}

      middleware.send :add_request_labels, span, env

      _(span.labels[Google::Cloud::Trace::LabelKey::HTTP_METHOD]).must_equal "test-method"
      _(span.labels[Google::Cloud::Trace::LabelKey::HTTP_URL]).must_equal "full-url"
      _(span.labels[Google::Cloud::Trace::LabelKey::RPC_REQUEST_SIZE]).must_equal "body".bytesize.to_s
    end

    it "doesn't set request size if request is sent already" do
      env = OpenStruct.new url: Object.new, body: "body", status: "200"
      env.define_singleton_method(:method) { "test-method" }
      env.url.define_singleton_method(:to_s) { "full-url" }

      span = OpenStruct.new labels: {}

      middleware.send :add_request_labels, span, env

      _(span.labels[Google::Cloud::Trace::LabelKey::RPC_REQUEST_SIZE]).must_be_nil
    end
  end

  describe "#add_response_labels" do
    it "sets all the labels" do
      env = OpenStruct.new response: OpenStruct.new(status: 42, body: "body",
                                                    headers: {location: "new-url"})
      span = OpenStruct.new labels: {}

      middleware.send :add_response_labels, span, env

      _(span.labels[Google::Cloud::Trace::LabelKey::HTTP_STATUS_CODE]).must_equal "42"
      _(span.labels[Google::Cloud::Trace::LabelKey::RPC_RESPONSE_SIZE]).must_equal "body".bytesize.to_s
    end
  end

  describe "#add_trace_context_header" do
    let(:middleware) { Google::Cloud::Trace::FaradayMiddleware.new app, enable_cross_project_tracing: true }
    let(:trace_context) { Stackdriver::Core::TraceContext.new trace_id: "0123456789abcdef0123456789abcdef" }

    before do
      Stackdriver::Core::TraceContext.set(trace_context)
    end

    after do
      Stackdriver::Core::TraceContext.set(nil)
    end

    it "sets trace context header when enable_cross_project_tracing is set to true" do
      env = OpenStruct.new headers: {location: "new-url"}, request_headers: {}

      middleware.send :add_trace_context_header, env

      _(env[:request_headers]["X-Cloud-Trace-Context"]).must_equal trace_context.to_string
    end
  end
end
