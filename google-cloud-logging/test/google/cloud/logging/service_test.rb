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

describe Google::Cloud::Logging::Service do
  let(:project) { "test" }
  let(:credentials) { :this_channel_is_insecure }
  let(:default_universe) { "googleapis.com" }
  let(:custom_universe) { "myuniverse.com" }
  let(:other_universe) { "otheruniverse.com" }
  let(:custom_endpoint) { "custom.example.com" }
  let(:timeout) { 123 }
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::Logging::VERSION }
  let(:expected_metadata) { { "google-cloud-resource-prefix" => "projects/#{project}" } }

  def assert_v2_clients service, expected_universe:, expected_config_endpoint:,
                        expected_stub_endpoint:, expected_config_universe: nil
    clients = [
      [service.logging, Google::Cloud::Logging::V2::LoggingService::Client,
       service.logging.logging_service_stub, true],
      [service.sinks, Google::Cloud::Logging::V2::ConfigService::Client,
       service.sinks.config_service_stub, true],
      [service.sinks.operations_client, Google::Cloud::Logging::V2::ConfigService::Operations,
       service.sinks.operations_client.operations_stub, false],
      [service.metrics, Google::Cloud::Logging::V2::MetricsService::Client,
       service.metrics.metrics_service_stub, true]
    ]
    clients.each do |client, klass, stub, has_gccl_metadata|
      _(client).must_be_kind_of klass
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
      if has_gccl_metadata
        _(config.lib_name).must_equal lib_name
        _(config.lib_version).must_equal lib_version
        _(config.metadata).must_equal expected_metadata
      end
      _(client.universe_domain).must_equal expected_universe
      _(stub.universe_domain).must_equal expected_universe
      _(stub.endpoint).must_equal expected_stub_endpoint
    end
  end

  def reset_v2_client_configs!
    [
      Google::Cloud::Logging::V2::LoggingService::Client,
      Google::Cloud::Logging::V2::ConfigService::Client,
      Google::Cloud::Logging::V2::ConfigService::Operations,
      Google::Cloud::Logging::V2::MetricsService::Client
    ].each do |klass|
      klass.configure.endpoint = nil
      klass.configure.universe_domain = nil
    end
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
    reset_v2_client_configs!
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
    reset_v2_client_configs!
  end

  it "configures all V2 clients with default universe_domain and nil endpoint" do
    service = Google::Cloud::Logging::Service.new project, credentials, timeout: timeout

    _(service.project).must_equal project
    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal default_universe
    _(service.timeout).must_equal timeout

    assert_v2_clients service,
                      expected_universe: default_universe,
                      expected_config_endpoint: nil,
                      expected_config_universe: nil,
                      expected_stub_endpoint: "logging.googleapis.com"
    _(service.logging.configure.timeout).must_equal timeout
    _(service.sinks.configure.timeout).must_equal timeout
    _(service.metrics.configure.timeout).must_equal timeout
  end

  it "configures all V2 clients with universe_domain argument" do
    service = Google::Cloud::Logging::Service.new project, credentials, universe_domain: custom_universe

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v2_clients service,
                      expected_universe: custom_universe,
                      expected_config_endpoint: nil,
                      expected_config_universe: custom_universe,
                      expected_stub_endpoint: "logging.#{custom_universe}"
  end

  it "configures all V2 clients with Logging.configure.universe_domain" do
    Google::Cloud::Logging.configure.universe_domain = custom_universe
    custom_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    logging = Google::Cloud::Logging.new project_id: project, credentials: custom_creds
    service = logging.service

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v2_clients service,
                      expected_universe: custom_universe,
                      expected_config_endpoint: nil,
                      expected_config_universe: custom_universe,
                      expected_stub_endpoint: "logging.#{custom_universe}"
  end

  it "configures all V2 clients with ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

    service = Google::Cloud::Logging::Service.new project, credentials

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v2_clients service,
                      expected_universe: custom_universe,
                      expected_config_endpoint: nil,
                      expected_config_universe: nil,
                      expected_stub_endpoint: "logging.#{custom_universe}"
  end

  it "gives Logging.configure.universe_domain precedence over ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = other_universe
    Google::Cloud::Logging.configure.universe_domain = custom_universe
    custom_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    logging = Google::Cloud::Logging.new project_id: project, credentials: custom_creds
    _(logging.universe_domain).must_equal custom_universe
    _(logging.service.logging.universe_domain).must_equal custom_universe
  end

  it "gives explicit universe_domain argument precedence over Logging.configure and ENV" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = other_universe
    Google::Cloud::Logging.configure.universe_domain = custom_universe
    arg_universe = "arg.example.com"
    arg_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: arg_universe

    logging = Google::Cloud::Logging.new project_id: project,
                                         credentials: arg_creds,
                                         universe_domain: arg_universe
    _(logging.universe_domain).must_equal arg_universe
    _(logging.service.logging.universe_domain).must_equal arg_universe
  end

  it "preserves per-V2-client universe_domain config when Service universe_domain is unset" do
    Google::Cloud::Logging::V2::ConfigService::Client.configure.universe_domain = custom_universe
    service = Google::Cloud::Logging::Service.new project, credentials

    _(service.sinks.universe_domain).must_equal custom_universe
    _(service.sinks.config_service_stub.endpoint).must_equal "logging.#{custom_universe}"
    _(service.sinks.operations_client.universe_domain).must_equal custom_universe
    _(service.logging.universe_domain).must_equal default_universe
    _(service.metrics.universe_domain).must_equal default_universe
  end

  # Guards against Google::Cloud::Logging.configure.endpoint polluting V2 @parent_config.
  it "resolves direct V2 clients endpoints under ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

    logging_client = Google::Cloud::Logging::V2::LoggingService::Client.new do |config|
      config.credentials = credentials
    end
    _(logging_client.configure.endpoint).must_be :nil?
    _(logging_client.universe_domain).must_equal custom_universe
    _(logging_client.logging_service_stub.endpoint).must_equal "logging.#{custom_universe}"

    config_client = Google::Cloud::Logging::V2::ConfigService::Client.new do |config|
      config.credentials = credentials
    end
    _(config_client.configure.endpoint).must_be :nil?
    _(config_client.universe_domain).must_equal custom_universe
    _(config_client.config_service_stub.endpoint).must_equal "logging.#{custom_universe}"
    _(config_client.operations_client.universe_domain).must_equal custom_universe
    _(config_client.operations_client.operations_stub.endpoint).must_equal "logging.#{custom_universe}"

    metrics_client = Google::Cloud::Logging::V2::MetricsService::Client.new do |config|
      config.credentials = credentials
    end
    _(metrics_client.configure.endpoint).must_be :nil?
    _(metrics_client.universe_domain).must_equal custom_universe
    _(metrics_client.metrics_service_stub.endpoint).must_equal "logging.#{custom_universe}"
  end

  it "uses host as endpoint without inferring universe_domain" do
    service = Google::Cloud::Logging::Service.new project, credentials, host: custom_endpoint

    _(service.host).must_equal custom_endpoint
    _(service.universe_domain).must_equal default_universe
    assert_v2_clients service,
                      expected_universe: default_universe,
                      expected_config_endpoint: custom_endpoint,
                      expected_config_universe: nil,
                      expected_stub_endpoint: custom_endpoint
  end

  it "enforces default universe_domain credential check even when host is overridden" do
    custom_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe
    service = Google::Cloud::Logging::Service.new project, custom_creds, host: custom_endpoint

    expect do
      service.logging
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "uses host as endpoint while keeping custom universe_domain" do
    matching_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe
    service = Google::Cloud::Logging::Service.new project, matching_creds,
                                                  host: custom_endpoint,
                                                  universe_domain: custom_universe

    _(service.host).must_equal custom_endpoint
    _(service.universe_domain).must_equal custom_universe
    assert_v2_clients service,
                      expected_universe: custom_universe,
                      expected_config_endpoint: custom_endpoint,
                      expected_config_universe: custom_universe,
                      expected_stub_endpoint: custom_endpoint
  end

  it "enforces custom universe_domain credential check when host is also set" do
    mismatched_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: other_universe
    service = Google::Cloud::Logging::Service.new project, mismatched_creds,
                                                  host: custom_endpoint,
                                                  universe_domain: custom_universe

    expect do
      service.logging
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "accepts matching ServiceAccountCredentials through Service and Logging.new" do
    custom_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    service = Google::Cloud::Logging::Service.new project, custom_creds, universe_domain: custom_universe
    _(service.universe_domain).must_equal custom_universe
    _(service.logging.universe_domain).must_equal custom_universe

    logging = Google::Cloud::Logging.new project_id: project, credentials: custom_creds, universe_domain: custom_universe
    _(logging.universe_domain).must_equal custom_universe
    _(logging.service.logging.universe_domain).must_equal custom_universe
  end

  it "raises Gapic::UniverseDomainMismatch when ServiceAccountCredentials mismatch configured universe_domain" do
    custom_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    service = Google::Cloud::Logging::Service.new project, custom_creds, universe_domain: other_universe
    expect do
      service.logging
    end.must_raise Gapic::UniverseDomainMismatch

    logging = Google::Cloud::Logging.new project_id: project, credentials: custom_creds, universe_domain: other_universe
    expect do
      logging.service.logging
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "raises Gapic::UniverseDomainMismatch when ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN'] mismatches default SA credentials" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe
    default_creds = LoggingTestHelpers.build_sa_credentials project_id: project, universe_domain: default_universe

    logging = Google::Cloud::Logging.new project_id: project, credentials: default_creds
    expect do
      logging.service.logging
    end.must_raise Gapic::UniverseDomainMismatch
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
      service = Google::Cloud::Logging::Service.new project, direct_creds, universe_domain: custom_universe
      _(service.logging.universe_domain).must_equal custom_universe

      wrapped_base = Google::Auth::GCECredentials.new
      wrapped_base.disable_universe_domain_check = false
      wrapped_creds = Google::Cloud::Logging::Credentials.new wrapped_base
      logging = Google::Cloud::Logging.new project_id: project, credentials: wrapped_creds, universe_domain: custom_universe
      _(logging.service.logging.universe_domain).must_equal custom_universe
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
      service = Google::Cloud::Logging::Service.new project, direct_creds, universe_domain: other_universe
      expect do
        service.logging
      end.must_raise Gapic::UniverseDomainMismatch

      wrapped_base = Google::Auth::GCECredentials.new
      wrapped_base.disable_universe_domain_check = false
      wrapped_creds = Google::Cloud::Logging::Credentials.new wrapped_base
      logging = Google::Cloud::Logging.new project_id: project, credentials: wrapped_creds, universe_domain: other_universe
      expect do
        logging.service.logging
      end.must_raise Gapic::UniverseDomainMismatch
    end
  end

  it "allows GCECredentials with custom universe_domain when disable_universe_domain_check is true" do
    gce_creds = Google::Auth::GCECredentials.new
    gce_creds.disable_universe_domain_check = true
    service = Google::Cloud::Logging::Service.new project, gce_creds, universe_domain: custom_universe
    _(service.logging.universe_domain).must_equal custom_universe

    wrapped_base = Google::Auth::GCECredentials.new
    wrapped_base.disable_universe_domain_check = true
    wrapped_creds = Google::Cloud::Logging::Credentials.new wrapped_base
    logging = Google::Cloud::Logging.new project_id: project, credentials: wrapped_creds, universe_domain: custom_universe
    _(logging.service.logging.universe_domain).must_equal custom_universe
  end
end
