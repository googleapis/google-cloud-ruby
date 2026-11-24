# Copyright 2026 Google LLC
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
require "signet/oauth_2/client"
require "google/cloud/error_reporting/v1beta1"

describe Google::Cloud::ErrorReporting::Service do # rubocop:disable Metrics/BlockLength
  let(:project) { "test-project" }
  let(:insecure_credentials) { :this_channel_is_insecure }
  let(:default_universe) { "googleapis.com" }
  let(:custom_universe) { "myuniverse.com" }
  let(:other_universe) { "otheruniverse.com" }
  let(:custom_endpoint) { "custom.example.com" }
  let(:timeout) { 123 }
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::ErrorReporting::VERSION }
  let :credentials do
    creds = Signet::OAuth2::Client.new
    def creds.quota_project_id
      "credentials-quota-project"
    end

    def creds.disable_universe_domain_check
      true
    end
    creds
  end

  def assert_v1beta1_client service, expected_universe:, expected_config_endpoint:,
                            expected_stub_endpoint:, expected_config_universe: nil
    client = service.error_reporting
    stub = client.report_errors_service_stub
    _(client).must_be_kind_of Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client

    config = client.configure
    if expected_config_endpoint.nil?
      _(config.endpoint).must_be :nil?
    else
      _(config.endpoint).must_equal expected_config_endpoint
    end
    if expected_config_universe.nil?
      _(config.universe_domain).must_be :nil?
    else
      _(config.universe_domain).must_equal expected_config_universe
    end
    _(config.lib_name).must_equal lib_name
    _(config.lib_version).must_equal lib_version
    _(client.universe_domain).must_equal expected_universe
    _(stub.universe_domain).must_equal expected_universe
    _(stub.endpoint).must_equal expected_stub_endpoint
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
    Google::Cloud::ErrorReporting.configure.reset!
    ErrorReportingTestHelpers.reset_v1beta1_client_configs!
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
    Google::Cloud::ErrorReporting.configure.reset!
    ErrorReportingTestHelpers.reset_v1beta1_client_configs!
  end

  describe ".new" do
    it "sets project and credentials" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials
      _(service.project).must_equal project
      _(service.credentials).must_equal credentials
    end

    it "accepts quota_project" do
      quota_project = "test-quota-project"
      service = Google::Cloud::ErrorReporting::Service.new project, credentials, quota_project: quota_project
      _(service.quota_project).must_equal quota_project
    end

    it "falls back to credentials quota_project_id if not explicitly passed" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials
      _(service.quota_project).must_equal "credentials-quota-project"
    end
  end

  describe "#error_reporting" do
    it "configures the gRPC client with quota_project" do
      quota_project = "test-quota-project"
      service = Google::Cloud::ErrorReporting::Service.new project, credentials, quota_project: quota_project

      client = service.error_reporting
      _(client.configure.quota_project).must_equal quota_project
    end

    it "configures the gRPC client with credentials quota_project" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials

      client = service.error_reporting
      _(client.configure.quota_project).must_equal "credentials-quota-project"
    end
  end

  describe "universe_domain" do
    it "configures V1beta1 client with default universe_domain and nil endpoint" do
      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials, timeout: timeout

      _(service.project).must_equal project
      _(service.host).must_be :nil?
      _(service.universe_domain).must_equal default_universe
      _(service.timeout).must_equal timeout

      assert_v1beta1_client service,
                            expected_universe: default_universe,
                            expected_config_endpoint: nil,
                            expected_config_universe: nil,
                            expected_stub_endpoint: "clouderrorreporting.googleapis.com"
      _(service.error_reporting.configure.timeout).must_equal timeout
    end

    it "configures V1beta1 client with universe_domain argument" do
      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials,
                                                            universe_domain: custom_universe

      _(service.host).must_be :nil?
      _(service.universe_domain).must_equal custom_universe

      assert_v1beta1_client service,
                            expected_universe: custom_universe,
                            expected_config_endpoint: nil,
                            expected_config_universe: custom_universe,
                            expected_stub_endpoint: "clouderrorreporting.#{custom_universe}"
    end

    it "configures V1beta1 client with ErrorReporting.configure.universe_domain" do
      Google::Cloud::ErrorReporting.configure.universe_domain = custom_universe
      custom_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                    universe_domain: custom_universe

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project, credentials: custom_creds
      service = error_reporting.service

      _(service.host).must_be :nil?
      _(service.universe_domain).must_equal custom_universe

      assert_v1beta1_client service,
                            expected_universe: custom_universe,
                            expected_config_endpoint: nil,
                            expected_config_universe: custom_universe,
                            expected_stub_endpoint: "clouderrorreporting.#{custom_universe}"
    end

    it "configures V1beta1 client with ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials

      _(service.host).must_be :nil?
      _(service.universe_domain).must_equal custom_universe

      assert_v1beta1_client service,
                            expected_universe: custom_universe,
                            expected_config_endpoint: nil,
                            expected_config_universe: nil,
                            expected_stub_endpoint: "clouderrorreporting.#{custom_universe}"
    end

    it "gives ErrorReporting.configure.universe_domain precedence over ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = other_universe
      Google::Cloud::ErrorReporting.configure.universe_domain = custom_universe
      custom_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                    universe_domain: custom_universe

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project, credentials: custom_creds
      _(error_reporting.universe_domain).must_equal custom_universe
      _(error_reporting.service.error_reporting.universe_domain).must_equal custom_universe
      _(error_reporting.service.error_reporting.report_errors_service_stub.endpoint).must_equal(
        "clouderrorreporting.#{custom_universe}"
      )
    end

    it "gives V1beta1::ReportErrorsService::Client.configure.universe_domain precedence over ErrorReporting.configure and ENV" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env.example.com"
      Google::Cloud::ErrorReporting.configure.universe_domain = other_universe
      Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client.configure.universe_domain = custom_universe

      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials
      project_client = Google::Cloud::ErrorReporting::Project.new service

      _(service.universe_domain).must_equal custom_universe
      _(project_client.universe_domain).must_equal custom_universe
      _(service.error_reporting.universe_domain).must_equal custom_universe
      _(service.error_reporting.report_errors_service_stub.endpoint).must_equal "clouderrorreporting.#{custom_universe}"
    end

    it "gives explicit universe_domain argument precedence over V1beta1 Client.configure, ErrorReporting.configure, and ENV" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env.example.com"
      Google::Cloud::ErrorReporting.configure.universe_domain = other_universe
      Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client.configure.universe_domain = custom_universe
      arg_universe = "arg.example.com"
      arg_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project, universe_domain: arg_universe

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                          credentials: arg_creds,
                                                          universe_domain: arg_universe
      _(error_reporting.universe_domain).must_equal arg_universe
      _(error_reporting.service.error_reporting.universe_domain).must_equal arg_universe
      _(error_reporting.service.error_reporting.report_errors_service_stub.endpoint).must_equal(
        "clouderrorreporting.#{arg_universe}"
      )
    end

    it "keeps universe_domain consistent with memoized error_reporting client when config or ENV changes" do
      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials
      project_client = Google::Cloud::ErrorReporting::Project.new service
      v1_client = service.error_reporting
      _(v1_client.universe_domain).must_equal default_universe

      Google::Cloud::ErrorReporting.configure.universe_domain = custom_universe
      Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client.configure.universe_domain = other_universe
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env.example.com"

      _(service.universe_domain).must_equal v1_client.universe_domain
      _(project_client.universe_domain).must_equal v1_client.universe_domain
    end

    it "resolves universe_domain safely when mocked_error_reporting is set" do
      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials
      mocked_client = Minitest::Mock.new
      service.mocked_error_reporting = mocked_client

      _(service.universe_domain).must_equal default_universe
      mocked_client.verify
    end

    # Guards against Google::Cloud::ErrorReporting.configure.endpoint polluting V1beta1 @parent_config.
    it "resolves direct V1beta1 clients endpoints under ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

      report_client = Google::Cloud::ErrorReporting::V1beta1::ReportErrorsService::Client.new do |config|
        config.credentials = insecure_credentials
      end
      _(report_client.configure.endpoint).must_be :nil?
      _(report_client.universe_domain).must_equal custom_universe
      _(report_client.report_errors_service_stub.endpoint).must_equal "clouderrorreporting.#{custom_universe}"

      group_client = Google::Cloud::ErrorReporting::V1beta1::ErrorGroupService::Client.new do |config|
        config.credentials = insecure_credentials
      end
      _(group_client.configure.endpoint).must_be :nil?
      _(group_client.universe_domain).must_equal custom_universe
      _(group_client.error_group_service_stub.endpoint).must_equal "clouderrorreporting.#{custom_universe}"

      stats_client = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsService::Client.new do |config|
        config.credentials = insecure_credentials
      end
      _(stats_client.configure.endpoint).must_be :nil?
      _(stats_client.universe_domain).must_equal custom_universe
      _(stats_client.error_stats_service_stub.endpoint).must_equal "clouderrorreporting.#{custom_universe}"
    end

    it "uses host as endpoint without inferring universe_domain" do
      service = Google::Cloud::ErrorReporting::Service.new project, insecure_credentials, host: custom_endpoint

      _(service.host).must_equal custom_endpoint
      _(service.universe_domain).must_equal default_universe
      assert_v1beta1_client service,
                            expected_universe: default_universe,
                            expected_config_endpoint: custom_endpoint,
                            expected_config_universe: nil,
                            expected_stub_endpoint: custom_endpoint
    end

    it "enforces default universe_domain credential check even when host is overridden" do
      custom_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                    universe_domain: custom_universe
      service = Google::Cloud::ErrorReporting::Service.new project, custom_creds, host: custom_endpoint

      expect do
        service.error_reporting
      end.must_raise Gapic::UniverseDomainMismatch
    end

    it "uses host as endpoint while keeping custom universe_domain" do
      matching_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                      universe_domain: custom_universe
      service = Google::Cloud::ErrorReporting::Service.new project, matching_creds,
                                                            host: custom_endpoint,
                                                            universe_domain: custom_universe

      _(service.host).must_equal custom_endpoint
      _(service.universe_domain).must_equal custom_universe
      assert_v1beta1_client service,
                            expected_universe: custom_universe,
                            expected_config_endpoint: custom_endpoint,
                            expected_config_universe: custom_universe,
                            expected_stub_endpoint: custom_endpoint
    end

    it "enforces custom universe_domain credential check when host is also set" do
      mismatched_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                        universe_domain: other_universe
      service = Google::Cloud::ErrorReporting::Service.new project, mismatched_creds,
                                                            host: custom_endpoint,
                                                            universe_domain: custom_universe

      expect do
        service.error_reporting
      end.must_raise Gapic::UniverseDomainMismatch
    end

    it "accepts matching ServiceAccountCredentials through Service and ErrorReporting.new" do
      custom_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                    universe_domain: custom_universe

      service = Google::Cloud::ErrorReporting::Service.new project, custom_creds, universe_domain: custom_universe
      _(service.universe_domain).must_equal custom_universe
      _(service.error_reporting.universe_domain).must_equal custom_universe

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                          credentials: custom_creds,
                                                          universe_domain: custom_universe
      _(error_reporting.universe_domain).must_equal custom_universe
      _(error_reporting.service.error_reporting.universe_domain).must_equal custom_universe
    end

    it "raises Gapic::UniverseDomainMismatch synchronously when ServiceAccountCredentials mismatch universe_domain" do
      custom_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                    universe_domain: custom_universe

      service = Google::Cloud::ErrorReporting::Service.new project, custom_creds, universe_domain: other_universe
      expect do
        service.error_reporting
      end.must_raise Gapic::UniverseDomainMismatch

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                          credentials: custom_creds,
                                                          universe_domain: other_universe
      report_err = expect do
        error_reporting.report error_reporting.error_event("test error message")
      end.must_raise Gapic::UniverseDomainMismatch
      _(report_err.message).wont_be :empty?

      expect do
        error_reporting.report_exception StandardError.new("boom")
      end.must_raise Gapic::UniverseDomainMismatch
    end

    it "raises Gapic::UniverseDomainMismatch when ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN'] mismatches default SA credentials" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe
      default_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                     universe_domain: default_universe

      error_reporting = Google::Cloud::ErrorReporting.new project_id: project, credentials: default_creds
      expect do
        error_reporting.service.error_reporting
      end.must_raise Gapic::UniverseDomainMismatch
    end

    it "delivers ErrorReporterError to AsyncErrorReporter on_error callbacks on credential universe mismatch" do
      mismatched_creds = ErrorReportingTestHelpers.build_sa_credentials project_id: project,
                                                                        universe_domain: custom_universe
      project_client = Google::Cloud::ErrorReporting.new project_id: project,
                                                         credentials: mismatched_creds,
                                                         universe_domain: other_universe
      reporter = Google::Cloud::ErrorReporting::AsyncErrorReporter.new project_client
      captured_errors = []
      reporter.on_error { |error| captured_errors << error }

      reporter.report project_client.error_event("test error message")
      reporter.stop! 10

      _(captured_errors.size).must_equal 1
      _(captured_errors.first).must_be_kind_of Google::Cloud::ErrorReporting::ErrorReporterError
      _(captured_errors.first.message).must_include "universe"
    end

    it "accepts matching GCECredentials when disable_universe_domain_check is false" do
      overrides = Google::Cloud::Env::ComputeMetadata::Overrides.new
      overrides.add "instance/service-accounts/default/token",
                    JSON.generate("access_token" => "test-token", "token_type" => "Bearer", "expires_in" => 3600),
                    headers: { "content-type" => "application/json" }
      overrides.add "universe/universe-domain", custom_universe

      Google::Cloud.env.compute_metadata.with_overrides overrides do
        direct_creds = Google::Auth::GCECredentials.new
        direct_creds.disable_universe_domain_check = false
        service = Google::Cloud::ErrorReporting::Service.new project, direct_creds, universe_domain: custom_universe
        _(service.error_reporting.universe_domain).must_equal custom_universe

        wrapped_base = Google::Auth::GCECredentials.new
        wrapped_base.disable_universe_domain_check = false
        wrapped_creds = Google::Cloud::ErrorReporting::Credentials.new wrapped_base
        error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                            credentials: wrapped_creds,
                                                            universe_domain: custom_universe
        _(error_reporting.service.error_reporting.universe_domain).must_equal custom_universe
      end
    end

    it "raises Gapic::UniverseDomainMismatch for mismatched GCECredentials when disable_universe_domain_check is false" do
      overrides = Google::Cloud::Env::ComputeMetadata::Overrides.new
      overrides.add "instance/service-accounts/default/token",
                    JSON.generate("access_token" => "test-token", "token_type" => "Bearer", "expires_in" => 3600),
                    headers: { "content-type" => "application/json" }
      overrides.add "universe/universe-domain", custom_universe

      Google::Cloud.env.compute_metadata.with_overrides overrides do
        direct_creds = Google::Auth::GCECredentials.new
        direct_creds.disable_universe_domain_check = false
        service = Google::Cloud::ErrorReporting::Service.new project, direct_creds, universe_domain: other_universe
        expect do
          service.error_reporting
        end.must_raise Gapic::UniverseDomainMismatch

        wrapped_base = Google::Auth::GCECredentials.new
        wrapped_base.disable_universe_domain_check = false
        wrapped_creds = Google::Cloud::ErrorReporting::Credentials.new wrapped_base
        error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                            credentials: wrapped_creds,
                                                            universe_domain: other_universe
        expect do
          error_reporting.service.error_reporting
        end.must_raise Gapic::UniverseDomainMismatch
      end
    end

    it "allows GCECredentials with custom universe_domain when disable_universe_domain_check is true" do
      gce_creds = Google::Auth::GCECredentials.new
      gce_creds.disable_universe_domain_check = true
      service = Google::Cloud::ErrorReporting::Service.new project, gce_creds, universe_domain: custom_universe
      _(service.error_reporting.universe_domain).must_equal custom_universe

      wrapped_base = Google::Auth::GCECredentials.new
      wrapped_base.disable_universe_domain_check = true
      wrapped_creds = Google::Cloud::ErrorReporting::Credentials.new wrapped_base
      error_reporting = Google::Cloud::ErrorReporting.new project_id: project,
                                                          credentials: wrapped_creds,
                                                          universe_domain: custom_universe
      _(error_reporting.service.error_reporting.universe_domain).must_equal custom_universe
    end
  end
end
