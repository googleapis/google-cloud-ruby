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

      span.labels[Google::Cloud::Trace::LabelKey::HTTP_METHOD].must_equal "test-method"
      span.labels[Google::Cloud::Trace::LabelKey::HTTP_URL].must_equal "full-url"
      span.labels[Google::Cloud::Trace::LabelKey::RPC_REQUEST_SIZE].must_equal "body".bytesize.to_s
    end

    it "doesn't set request size if request is sent already" do
      env = OpenStruct.new url: Object.new, body: "body", status: "200"
      env.define_singleton_method(:method) { "test-method" }
      env.url.define_singleton_method(:to_s) { "full-url" }

      span = OpenStruct.new labels: {}

      middleware.send :add_request_labels, span, env

      span.labels[Google::Cloud::Trace::LabelKey::RPC_REQUEST_SIZE].must_be_nil
    end
  end

  describe "#add_response_labels" do
    it "sets all the labels" do
      env = OpenStruct.new response: OpenStruct.new(status: 42, body: "body",
                                                    headers: {location: "new-url"})
      span = OpenStruct.new labels: {}

      middleware.send :add_response_labels, span, env

      span.labels[Google::Cloud::Trace::LabelKey::HTTP_STATUS_CODE].must_equal "42"
      span.labels[Google::Cloud::Trace::LabelKey::RPC_RESPONSE_SIZE].must_equal "body".bytesize.to_s
    end
  end
end
