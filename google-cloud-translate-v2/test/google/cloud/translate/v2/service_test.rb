# Copyright 2020 Google LLC
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

# Conforms to the usage of `Google::Cloud::Translate::V2::Service#sign_http_request!`
class FakeClient
  def expires_within? _
    false
  end

  def access_token
    :token
  end

  def generate_authenticated_request request:
  end
end

describe Google::Cloud::Translate::V2::Service, :service do
  let(:project) { "test" }
  let(:quota_project) { "test2" }
  let(:credentials) { OpenStruct.new client: FakeClient.new, quota_project_id: quota_project }
  let(:service) { Google::Cloud::Translate::V2::Service.new(project, credentials, retries: 1) }
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

    _(mock_http.request_count).must_equal(1)
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

    _(mock_http.request_count).must_equal(2)
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

    _(mock_http.request_count).must_equal(2)
  end

  it "retries when the response status 500" do
    mock_http.stub_response(500, '')

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::InternalError; end
    end

    _(mock_http.request_count).must_equal(2)
  end

  it "retries when the response status 503" do
    mock_http.stub_response(503, '')

    service.stub(:http, mock_http) do
      begin
        service.detect('hello')
      rescue Google::Cloud::UnavailableError; end
    end

    _(mock_http.request_count).must_equal(2)
  end

  it "sends x-goog-user-project header" do
    mock_http.stub_response(200, "{}")
    service.stub(:http, mock_http) do
      service.detect("hello")
      _(mock_http.last_request.headers["x-goog-user-project"]).must_equal(quota_project)
    end
  end
end
