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
require "minitest/mock"
require "minitest/rg"
require "ostruct"
require "json"
require "google/cloud/error_reporting"
require "gapic/universe_domain_concerns"
require "grpc"

module ErrorReportingTestHelpers
  def self.rsa_key
    @rsa_key ||= begin
      require "openssl"
      OpenSSL::PKey::RSA.new 2048
    end
  end

  def self.sa_key_hash project_id: "test", universe_domain: "googleapis.com"
    {
      "type" => "service_account",
      "project_id" => project_id,
      "private_key_id" => "key-id",
      "private_key" => rsa_key.to_pem,
      "client_email" => "test-sa@#{project_id}.iam.gserviceaccount.com",
      "client_id" => "1234567890",
      "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
      "token_uri" => "https://oauth2.#{universe_domain}/token",
      "universe_domain" => universe_domain
    }
  end

  def self.build_sa_credentials project_id: "test", universe_domain: "googleapis.com",
                                scope: Google::Cloud::ErrorReporting.configure.scope
    require "stringio"
    json = JSON.generate sa_key_hash(project_id: project_id, universe_domain: universe_domain)
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(json),
      scope: scope
    )
  end

  def self.build_error_reporting_credentials project_id: "test", universe_domain: "googleapis.com",
                                             scope: Google::Cloud::ErrorReporting.configure.scope
    sa_creds = build_sa_credentials(
      project_id: project_id,
      universe_domain: universe_domain,
      scope: scope
    )
    Google::Cloud::ErrorReporting::Credentials.new sa_creds
  end

  def self.reset_default_reporter!
    reporter = Google::Cloud::ErrorReporting.instance_variable_get :@default_reporter
    reporter.stop! if reporter.respond_to? :stop!
    Google::Cloud::ErrorReporting.instance_variable_set :@default_reporter, nil
  end

  def self.reset_v1beta1_client_configs!
    require "google/cloud/error_reporting/v1beta1"
    [
      Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client,
      Google::Cloud::ErrorReporting::V1beta1::ErrorGroupService::Client,
      Google::Cloud::ErrorReporting::V1beta1::ErrorStatsService::Client
    ].each do |klass|
      klass.configure.endpoint = nil
      klass.configure.universe_domain = nil
    end
  end
end

class MockErrorReporting < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:error_reporting) {
    Google::Cloud::ErrorReporting::Project.new(
      Google::Cloud::ErrorReporting::Service.new(
        project, credentials
      )
    )
  }

  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_error_reporting
  end

  def random_error_event_hash
    timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
    {
      event_time: {
        seconds: timestamp.to_i,
        nanos: timestamp.nsec
      },
      message: "error message",
      service_context: random_service_context_hash,
      context: random_error_context_hash,
    }
  end

  def random_service_context_hash
    {
      service: "default",
      version: "v1"
    }
  end

  def random_error_context_hash
    {
      user: "testerson",
      http_request: random_http_request_context_hash,
      report_location: random_source_location_hash,
    }
  end

  def random_http_request_context_hash
    {
      method: "GET",
      url: "http://test.local/foo?bar=baz",
      user_agent: "google-cloud/1.0.0",
      referrer: "http://test/local/referrer",
      response_status_code: 200,
      remote_ip: "127.0.0.1",
    }
  end

  def random_source_location_hash
    {
      file_path: "/path/to/file.txt",
      line_number: 5,
      function_name: "testee"
    }
  end
end

##
# Helper method to loop until block yields true or timeout.
def wait_until_true timeout = 5
  begin_t = Time.now

  until yield
    return :timeout if Time.now - begin_t > timeout
    sleep 0.1
  end

  :completed
end
