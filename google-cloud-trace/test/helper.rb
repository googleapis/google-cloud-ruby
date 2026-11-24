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
require "minitest/mock"
require "ostruct"
require "json"
require "base64"
require "google/cloud/trace"
require "gapic/universe_domain_concerns"
require "grpc"

module TraceTestHelpers
  def self.rsa_key
    @rsa_key ||= begin
      require "openssl"
      OpenSSL::PKey::RSA.new 2048
    end
  end

  def self.sa_key_hash project_id: "test-project", universe_domain: "googleapis.com"
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

  def self.build_sa_credentials project_id: "test-project", universe_domain: "googleapis.com",
                                scope: Google::Cloud::Trace.configure.scope
    require "stringio"
    json = JSON.generate sa_key_hash(project_id: project_id, universe_domain: universe_domain)
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(json),
      scope: scope
    )
  end

  def self.build_trace_credentials project_id: "test-project", universe_domain: "googleapis.com",
                                   scope: Google::Cloud::Trace.configure.scope
    sa_creds = build_sa_credentials(
      project_id: project_id,
      universe_domain: universe_domain,
      scope: scope
    )
    Google::Cloud::Trace::Credentials.new sa_creds
  end
end

class MockTrace < Minitest::Spec
  MockFrame = ::Struct.new :absolute_path, :lineno, :label

  def stack_frame absolute_path, lineno, label
    MockFrame.new absolute_path, lineno, label
  end

  let(:project) { "test-project" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:tracer) { Google::Cloud::Trace::Project.new(Google::Cloud::Trace::Service.new(project, credentials)) }


  # Register this spec type for when :mock_trace is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_trace
  end

  def project_path
    "projects/#{project}"
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

class StringChild < ::String; end;
