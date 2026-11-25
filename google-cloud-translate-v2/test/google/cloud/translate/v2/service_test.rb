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
  def apply! a_hash, _opts = {}
    a_hash[:authorization] = "Bearer fake-token"
  end
end

describe Google::Cloud::Translate::V2::Service, :service do
  let(:project) { "test" }
  let(:quota_project) { "test2" }
  let(:credentials) { OpenStruct.new client: FakeClient.new, quota_project_id: quota_project }
  let(:service) { Google::Cloud::Translate::V2::Service.new(project, credentials, retries: 1) }
  let(:mock_http) { MockHttp.new }

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
  end

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
      _(mock_http.last_request.headers["Authorization"]).must_equal("Bearer fake-token")
    end
  end

  it "defaults universe_domain to googleapis.com and builds default URL" do
    svc = Google::Cloud::Translate::V2::Service.new project, credentials
    _(svc.universe_domain).must_equal "googleapis.com"
    _(svc.instance_variable_get(:@url)).must_equal "https://translate.googleapis.com"
  end

  it "resolves universe_domain from explicit argument and builds endpoint URL" do
    tpc_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "mydomain1.com"
    svc = Google::Cloud::Translate::V2::Service.new project, tpc_creds, universe_domain: "mydomain1.com"
    _(svc.universe_domain).must_equal "mydomain1.com"
    _(svc.instance_variable_get(:@url)).must_equal "https://translate.mydomain1.com"
  end

  it "resolves universe_domain from GOOGLE_CLOUD_UNIVERSE_DOMAIN" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "mydomain2.com"
    tpc_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "mydomain2.com"
    svc = Google::Cloud::Translate::V2::Service.new project, tpc_creds
    _(svc.universe_domain).must_equal "mydomain2.com"
    _(svc.instance_variable_get(:@url)).must_equal "https://translate.mydomain2.com"
  end

  it "treats blank GOOGLE_CLOUD_UNIVERSE_DOMAIN as unset" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "   "
    gdu_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "googleapis.com"
    svc = Google::Cloud::Translate::V2::Service.new project, gdu_creds
    _(svc.universe_domain).must_equal "googleapis.com"
    _(svc.instance_variable_get(:@url)).must_equal "https://translate.googleapis.com"
  end

  it "raises ArgumentError when explicit universe_domain is empty or whitespace" do
    _(proc {
      Google::Cloud::Translate::V2::Service.new project, credentials, universe_domain: ""
    }).must_raise ArgumentError

    _(proc {
      Google::Cloud::Translate::V2::Service.new project, credentials, universe_domain: "   "
    }).must_raise ArgumentError
  end

  it "allows custom host override while still preserving and validating universe_domain" do
    tpc_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "mydomain3.com"
    svc = Google::Cloud::Translate::V2::Service.new(
      project,
      tpc_creds,
      host: "custom-translate.example.com",
      universe_domain: "mydomain3.com"
    )
    _(svc.universe_domain).must_equal "mydomain3.com"
    _(svc.instance_variable_get(:@url)).must_equal "https://custom-translate.example.com"

    svc_scheme = Google::Cloud::Translate::V2::Service.new(
      project,
      tpc_creds,
      host: "https://custom-translate.example.com/",
      universe_domain: "mydomain3.com"
    )
    _(svc_scheme.instance_variable_get(:@url)).must_equal "https://custom-translate.example.com"

    gdu_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "googleapis.com"
    _(proc {
      Google::Cloud::Translate::V2::Service.new(
        project,
        gdu_creds,
        host: "custom-translate.example.com",
        universe_domain: "mydomain3.com"
      )
    }).must_raise Google::Cloud::Error
  end

  it "raises Google::Cloud::Error when credentials universe_domain mismatches in either direction" do
    gdu_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "googleapis.com"
    err1 = _(proc {
      Google::Cloud::Translate::V2::Service.new project, gdu_creds, universe_domain: "wronguniverse.com"
    }).must_raise Google::Cloud::Error
    _(err1.message).must_include "Universe domain is wronguniverse.com but credentials are in googleapis.com"

    tpc_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "mydomain4.com"
    err2 = _(proc {
      Google::Cloud::Translate::V2::Service.new project, tpc_creds
    }).must_raise Google::Cloud::Error
    _(err2.message).must_include "Universe domain is googleapis.com but credentials are in mydomain4.com"
  end

  it "skips universe_domain check when disable_universe_domain_check is true" do
    gce_creds = Google::Cloud::Translate::V2::Credentials.new Google::Auth::GCECredentials.new
    svc = Google::Cloud::Translate::V2::Service.new project, gce_creds, universe_domain: "mydomain5.com"
    _(svc.universe_domain).must_equal "mydomain5.com"
  end

  it "signs requests with self-signed JWT via apply! without calling fetch_access_token! for scoped SA credentials" do
    v2_creds = TranslateTestFixtures.build_v2_credentials(
      universe_domain: "mydomain6.com",
      enable_self_signed_jwt: true
    )
    sa_client = v2_creds.client
    sa_client.stub :fetch_access_token!, ->(*_) { flunk "fetch_access_token! must not be called" } do
      svc = Google::Cloud::Translate::V2::Service.new project, v2_creds, universe_domain: "mydomain6.com"
      captured_env = nil
      conn, stubs = TranslateTestFixtures.build_faraday_test_connection(svc.instance_variable_get(:@url)) do |stub|
        stub.post("/language/translate/v2") do |env|
          captured_env = env
          [200, { "Content-Type" => "application/json" }, { data: { translations: [{ translatedText: "Hola" }] } }.to_json]
        end
      end

      svc.stub :http, conn do
        result = svc.translate "Hello", to: "es"
        _(result["translations"].first["translatedText"]).must_equal "Hola"
      end

      stubs.verify_stubbed_calls
      _(captured_env.url.to_s).must_equal "https://translate.mydomain6.com/language/translate/v2"
      _(TranslateTestFixtures.lowercase_header_names(captured_env.request_headers)).wont_include "jwt_aud_uri"
      auth_header = captured_env.request_headers["Authorization"]
      _(auth_header).must_match(/\ABearer /)
      payload, = JWT.decode(
        auth_header.sub("Bearer ", ""),
        TranslateTestFixtures::TEST_RSA_KEY.public_key,
        true,
        algorithm: "RS256"
      )
      _(payload["iss"]).must_equal "translate-sa@test-project.iam.gserviceaccount.com"
      _(payload["scope"]).must_include "https://www.googleapis.com/auth/cloud-platform"
    end
  end

  it "signs requests with audience-based self-signed JWT when scope-less ServiceAccountCredentials are used" do
    scopeless_sa = TranslateTestFixtures.build_service_account_creds universe_domain: "mydomain7.com"
    wrapped = Google::Cloud::Translate::V2::Credentials.new scopeless_sa
    scopeless_sa.stub :fetch_access_token!, ->(*_) { flunk "fetch_access_token! must not be called" } do
      svc = Google::Cloud::Translate::V2::Service.new project, wrapped, universe_domain: "mydomain7.com"
      captured_env = nil
      conn, stubs = TranslateTestFixtures.build_faraday_test_connection(svc.instance_variable_get(:@url)) do |stub|
        stub.post("/language/translate/v2/detect") do |env|
          captured_env = env
          [200, { "Content-Type" => "application/json" }, { data: { detections: [[{ language: "en" }]] } }.to_json]
        end
      end

      svc.stub :http, conn do
        result = svc.detect "Hello"
        _(result["detections"].first.first["language"]).must_equal "en"
      end

      stubs.verify_stubbed_calls
      _(captured_env.url.to_s).must_equal "https://translate.mydomain7.com/language/translate/v2/detect"
      _(TranslateTestFixtures.lowercase_header_names(captured_env.request_headers)).wont_include "jwt_aud_uri"
      auth_header = captured_env.request_headers["Authorization"]
      _(auth_header).must_match(/\ABearer /)
      payload, = JWT.decode(
        auth_header.sub("Bearer ", ""),
        TranslateTestFixtures::TEST_RSA_KEY.public_key,
        true,
        algorithm: "RS256",
        aud: "https://translate.mydomain7.com/",
        verify_aud: true
      )
      _(payload["aud"]).must_equal "https://translate.mydomain7.com/"
    end
  end

  it "refreshes OAuth2 bearer tokens via Signet apply! without leaking jwt_aud_uri header" do
    oauth_client = Signet::OAuth2::Client.new universe_domain: "googleapis.com"
    refresh_calls = 0
    oauth_client.define_singleton_method :fetch_access_token! do |_opts = {}|
      refresh_calls += 1
      self.access_token = "refreshed-oauth-token"
      self.expires_in = 3600
    end
    wrapped = Google::Cloud::Translate::V2::Credentials.new oauth_client
    svc = Google::Cloud::Translate::V2::Service.new project, wrapped

    captured_env = nil
    conn, stubs = TranslateTestFixtures.build_faraday_test_connection(svc.instance_variable_get(:@url)) do |stub|
      stub.post("/language/translate/v2/languages") do |env|
        captured_env = env
        [200, { "Content-Type" => "application/json" }, { data: { languages: [{ language: "en" }] } }.to_json]
      end
    end

    svc.stub :http, conn do
      svc.languages "en"
    end

    stubs.verify_stubbed_calls
    _(refresh_calls).must_equal 1
    _(captured_env.request_headers["Authorization"]).must_equal "Bearer refreshed-oauth-token"
    _(TranslateTestFixtures.lowercase_header_names(captured_env.request_headers)).wont_include "jwt_aud_uri"
  end

  it "routes API key requests to the configured universe_domain endpoint" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "mydomain8.com"
    svc = Google::Cloud::Translate::V2::Service.new project, nil, key: "tpc-api-key"
    _(svc.universe_domain).must_equal "mydomain8.com"

    captured_env = nil
    conn, stubs = TranslateTestFixtures.build_faraday_test_connection(svc.instance_variable_get(:@url)) do |stub|
      stub.post("/language/translate/v2") do |env|
        captured_env = env
        [200, { "Content-Type" => "application/json" }, { data: { translations: [{ translatedText: "Bonjour" }] } }.to_json]
      end
    end

    svc.stub :http, conn do
      result = svc.translate "Hello", to: "fr"
      _(result["translations"].first["translatedText"]).must_equal "Bonjour"
    end

    stubs.verify_stubbed_calls
    _(captured_env.url.to_s).must_equal "https://translate.mydomain8.com/language/translate/v2?key=tpc-api-key"
  end
end
