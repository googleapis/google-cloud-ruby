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

describe Google::Cloud::Translate::Service, :service do
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:service) { Google::Cloud::Translate::Service.new(project, credentials, retries: 1) }
  let(:mock_http) { MockHttp.new }

  it "does not retry on other errors" do
    body = {
      "error" => {
        "errors" => [
          {
            "reason" => "otherError"
          }
        ]
      }
    }.to_json
    mock_http.stub_response(403, body)

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::PermissionDeniedError; end
    end

    mock_http.request_count.must_equal(1)
  end

  it "retries when there is rateLimitExceeded error" do
    body = {
      "error" => {
        "errors" => [
          {
            "reason" => "rateLimitExceeded"
          }
        ]
      }
    }.to_json
    mock_http.stub_response(403, body)

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::PermissionDeniedError; end
    end

    mock_http.request_count.must_equal(2)
  end

  it "retries when there is userRateLimitExceeded error" do
    body = {
      "error" => {
        "errors" => [
          {
            "reason" => "userRateLimitExceeded"
          }
        ]
      }
    }.to_json
    mock_http.stub_response(403, body)

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::PermissionDeniedError; end
    end

    mock_http.request_count.must_equal(2)
  end

  it "retries when the response status 500" do
    mock_http.stub_response(500, '')

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::InternalError; end
    end

    mock_http.request_count.must_equal(2)
  end

  it "retries when the response status 503" do
    mock_http.stub_response(503, '')

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::UnavailableError; end
    end

    mock_http.request_count.must_equal(2)
  end
end
