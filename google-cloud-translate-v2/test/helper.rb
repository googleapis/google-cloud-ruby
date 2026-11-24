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

require "simplecov"

gem "minitest"

if ENV["CI"] || ENV["KOKORO_JOB_NAME"]
  # Load JUnit XML formatter from googleapis/ruby-common-tools to write tmp/reports/sponge_log.xml for Kokoro/TestGrid.
  begin
    require "gapic/minitest_junit_preloader"
  rescue LoadError
    # Do nothing if preloader is not available (e.g. local runs)
  end
end

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "openssl"
require "jwt"
require "stringio"
require "google/cloud/translate/v2"

module TranslateTestFixtures
  TEST_RSA_KEY = OpenSSL::PKey::RSA.new 2048

  module_function

  def service_account_hash project_id: "test-project", universe_domain: nil, quota_project_id: nil
    hash = {
      "type" => "service_account",
      "project_id" => project_id,
      "private_key_id" => "key-id-1",
      "private_key" => TEST_RSA_KEY.to_pem,
      "client_email" => "translate-sa@#{project_id}.iam.gserviceaccount.com",
      "client_id" => "1234567890"
    }
    hash["universe_domain"] = universe_domain unless universe_domain.nil?
    hash["quota_project_id"] = quota_project_id unless quota_project_id.nil?
    hash
  end

  def build_service_account_creds scope: nil,
                                  enable_self_signed_jwt: nil,
                                  universe_domain: nil,
                                  project_id: "test-project"
    sa_hash = service_account_hash project_id: project_id, universe_domain: universe_domain
    opts = { json_key_io: StringIO.new(sa_hash.to_json) }
    opts[:scope] = scope unless scope.nil?
    opts[:enable_self_signed_jwt] = enable_self_signed_jwt unless enable_self_signed_jwt.nil?
    Google::Auth::ServiceAccountCredentials.make_creds opts
  end

  def build_v2_credentials universe_domain: nil,
                           enable_self_signed_jwt: true,
                           scope: nil,
                           project_id: "test-project",
                           quota_project_id: nil
    sa_hash = service_account_hash(
      project_id: project_id,
      universe_domain: universe_domain,
      quota_project_id: quota_project_id
    )
    Google::Cloud::Translate::V2::Credentials.new(
      sa_hash,
      scope: scope,
      enable_self_signed_jwt: enable_self_signed_jwt
    )
  end

  def build_faraday_test_connection url
    stubs = Faraday::Adapter::Test::Stubs.new
    yield stubs if block_given?
    conn = Faraday.new url: url do |builder|
      builder.adapter :test, stubs
    end
    [conn, stubs]
  end
end

class MockTranslate < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:translate) { Google::Cloud::Translate::V2::Api.new(Google::Cloud::Translate::V2::Service.new(project, credentials)) }

  # Register this spec type for when :mock_translate is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_translate
  end
end

class MockHttp
  attr_reader :request_count, :last_request

  def initialize
    @request_count = 0
    @last_request = nil
  end

  def stub_response(status, body)
    @stub_status = status
    @stub_body = body
  end

  def post(*_)
    @last_request = OpenStruct.new headers: {}, body: ""
    yield @last_request if block_given?
    @request_count += 1
    Faraday::Response.new.tap do |response|
      response.finish(status: @stub_status, body: @stub_body)
    end
  end
end
