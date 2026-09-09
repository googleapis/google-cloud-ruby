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

describe Google::Cloud::Logging::Entry::HttpRequest, :mock_logging do
  let(:http_request_grpc) { Google::Cloud::Logging::Type::HttpRequest.new random_http_request_hash }
  let(:http_request) { Google::Cloud::Logging::Entry::HttpRequest.from_grpc http_request_grpc }

  it "has attributes" do
    _(http_request.request_method).must_equal "GET"
    _(http_request.url).must_equal "http://test.local/foo?bar=baz"
    _(http_request.size).must_equal 123
    _(http_request.status).must_equal 200
    _(http_request.response_size).must_equal 456
    _(http_request.user_agent).must_equal "google-cloud/1.0.0"
    _(http_request.remote_ip).must_equal "127.0.0.1"
    _(http_request.referer).must_equal "http://test.local/referer"
    _(http_request.cache_hit).must_equal false
    _(http_request.validated).must_equal false
  end

  it "method alias (deprecated)" do
    _(http_request.request_method).must_equal "GET"
    _(http_request.method).must_equal http_request.request_method

    http_request.method = "POST"

    _(http_request.request_method).must_equal "POST"
    _(http_request.method).must_equal http_request.request_method
  end

  it "method alias doesn't stomp on Object#method" do
    actual_method = http_request.method :validated=
    _(actual_method).must_be_kind_of Method
    _(actual_method.name).must_equal :validated=

    # This is the real method object, which can be used.
    _(http_request.validated).must_equal false
    actual_method.to_proc.call true
    _(http_request.validated).must_equal true
  end

  it "method alias being passed nil calls Object#method" do
    _(http_request.request_method).must_equal "GET"
    _(http_request.method).must_equal http_request.request_method

    err = expect do
      http_request.method nil
    end.must_raise TypeError
    _(err.message).must_include "nil is not a symbol"
  end
end
