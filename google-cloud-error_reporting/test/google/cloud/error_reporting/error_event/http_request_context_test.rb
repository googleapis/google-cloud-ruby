# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::ErrorReporting::ErrorEvent::HttpRequestContext, :mock_error_reporting do
  let(:http_request_context_json) { random_http_request_context_hash.to_json}
  let(:http_request_context_grpc) {
    Google::Devtools::Clouderrorreporting::V1beta1::HttpRequestContext.decode_json http_request_context_json
  }
  let(:http_request_context) {
    Google::Cloud::ErrorReporting::ErrorEvent::HttpRequestContext.from_grpc http_request_context_grpc
  }

  it "has_attributes" do
    http_request_context.method.must_equal "GET"
    http_request_context.url.must_equal "http://test.local/foo?bar=baz"
    http_request_context.user_agent.must_equal "google-cloud/1.0.0"
    http_request_context.referrer.must_equal "http://test/local/referrer"
    http_request_context.status.must_equal 200
    http_request_context.remote_ip.must_equal "127.0.0.1"
  end

  it "to_grpc returns a different grpc object with same attributes" do
    new_http_request_context_grpc = http_request_context.to_grpc

    new_http_request_context_grpc.must_equal http_request_context_grpc
    assert !new_http_request_context_grpc.equal?(http_request_context_grpc)
  end
end