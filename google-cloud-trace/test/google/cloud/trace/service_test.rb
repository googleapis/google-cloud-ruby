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
require "google/cloud/trace/v2"

describe Google::Cloud::Trace::Service do
  let(:project) { "test-project" }
  let(:credentials) { :this_channel_is_insecure }
  let(:default_universe) { "googleapis.com" }
  let(:custom_universe) { "myuniverse.com" }
  let(:other_universe) { "otheruniverse.com" }
  let(:custom_endpoint) { "custom.example.com" }
  let(:timeout) { 123 }
  let(:lib_name) { "gccl" }
  let(:lib_version) { Google::Cloud::Trace::VERSION }

  def assert_v1_client service, expected_universe:, expected_config_endpoint:,
                       expected_stub_endpoint:, expected_config_universe: nil
    client = service.lowlevel_client
    _(client).must_be_kind_of Google::Cloud::Trace::V1::TraceService::Client

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
    _(client.trace_service_stub.universe_domain).must_equal expected_universe
    _(client.trace_service_stub.endpoint).must_equal expected_stub_endpoint
  end

  def reset_client_configs!
    [
      Google::Cloud::Trace::V1::TraceService::Client,
      Google::Cloud::Trace::V1::TraceService::Rest::Client,
      Google::Cloud::Trace::V2::TraceService::Client,
      Google::Cloud::Trace::V2::TraceService::Rest::Client
    ].each do |klass|
      klass.configure.endpoint = nil
      klass.configure.universe_domain = nil
    end
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
    reset_client_configs!
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
    reset_client_configs!
  end

  it "configures V1 client with default universe_domain and nil endpoint" do
    service = Google::Cloud::Trace::Service.new project, credentials, timeout: timeout

    _(service.project).must_equal project
    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal default_universe
    _(service.timeout).must_equal timeout

    assert_v1_client service,
                     expected_universe: default_universe,
                     expected_config_endpoint: nil,
                     expected_config_universe: nil,
                     expected_stub_endpoint: "cloudtrace.googleapis.com"
    _(service.lowlevel_client.configure.timeout).must_equal timeout
  end

  it "configures V1 client with universe_domain argument" do
    service = Google::Cloud::Trace::Service.new project, credentials, universe_domain: custom_universe

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v1_client service,
                     expected_universe: custom_universe,
                     expected_config_endpoint: nil,
                     expected_config_universe: custom_universe,
                     expected_stub_endpoint: "cloudtrace.#{custom_universe}"
  end

  it "configures V1 client with Trace.configure.universe_domain" do
    Google::Cloud::Trace.configure.universe_domain = custom_universe
    custom_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    trace = Google::Cloud::Trace.new project_id: project, credentials: custom_creds
    service = trace.service

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v1_client service,
                     expected_universe: custom_universe,
                     expected_config_endpoint: nil,
                     expected_config_universe: custom_universe,
                     expected_stub_endpoint: "cloudtrace.#{custom_universe}"
  end

  it "configures V1 client with ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

    service = Google::Cloud::Trace::Service.new project, credentials

    _(service.host).must_be :nil?
    _(service.universe_domain).must_equal custom_universe

    assert_v1_client service,
                     expected_universe: custom_universe,
                     expected_config_endpoint: nil,
                     expected_config_universe: nil,
                     expected_stub_endpoint: "cloudtrace.#{custom_universe}"
  end

  it "gives Trace.configure.universe_domain precedence over ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = other_universe
    Google::Cloud::Trace.configure.universe_domain = custom_universe
    custom_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    trace = Google::Cloud::Trace.new project_id: project, credentials: custom_creds
    _(trace.universe_domain).must_equal custom_universe
    _(trace.service.lowlevel_client.universe_domain).must_equal custom_universe
    _(trace.service.lowlevel_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
  end

  it "gives explicit universe_domain argument precedence over Trace.configure and ENV" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = other_universe
    Google::Cloud::Trace.configure.universe_domain = custom_universe
    arg_universe = "arg.example.com"
    arg_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: arg_universe

    trace = Google::Cloud::Trace.new project_id: project,
                                     credentials: arg_creds,
                                     universe_domain: arg_universe
    _(trace.universe_domain).must_equal arg_universe
    _(trace.service.lowlevel_client.universe_domain).must_equal arg_universe
    _(trace.service.lowlevel_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{arg_universe}"
  end

  it "reads V1::TraceService::Client.configure.universe_domain when Service universe_domain is unset" do
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = custom_universe
    service = Google::Cloud::Trace::Service.new project, credentials
    project_client = Google::Cloud::Trace::Project.new service

    _(service.universe_domain).must_equal custom_universe
    _(project_client.universe_domain).must_equal custom_universe

    _(service.lowlevel_client.universe_domain).must_equal custom_universe
    _(service.lowlevel_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
    _(service.universe_domain).must_equal custom_universe
    _(project_client.universe_domain).must_equal custom_universe
  end

  it "keeps universe_domain consistent with memoized lowlevel_client when config or ENV changes" do
    service = Google::Cloud::Trace::Service.new project, credentials
    project_client = Google::Cloud::Trace::Project.new service
    v1_client = service.lowlevel_client
    _(v1_client.universe_domain).must_equal default_universe

    Google::Cloud::Trace.configure.universe_domain = custom_universe
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = other_universe
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env.example.com"

    _(service.universe_domain).must_equal v1_client.universe_domain
    _(project_client.universe_domain).must_equal v1_client.universe_domain
  end

  it "propagates Trace.configure.universe_domain even if V1 client was configured before Trace" do
    v1_config = Google::Cloud::Trace::V1::TraceService::Client.configure
    original_parent = v1_config.instance_variable_get :@parent_config
    v1_config.instance_variable_set :@parent_config, Google::Cloud.configure

    service = Google::Cloud::Trace::Service.new project, credentials
    Google::Cloud::Trace.configure.universe_domain = custom_universe

    _(service.universe_domain).must_equal custom_universe
    _(service.lowlevel_client.universe_domain).must_equal custom_universe
    _(service.lowlevel_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
  ensure
    v1_config.instance_variable_set :@parent_config, original_parent
  end

  # Guards against Google::Cloud::Trace.configure.endpoint polluting V1 and V2 @parent_config.
  it "resolves direct V1 and V2 clients endpoints under ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN']" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe

    [
      Google::Cloud::Trace::V1::TraceService::Client,
      Google::Cloud::Trace::V1::TraceService::Rest::Client,
      Google::Cloud::Trace::V2::TraceService::Client,
      Google::Cloud::Trace::V2::TraceService::Rest::Client
    ].each do |klass|
      client = klass.new do |config|
        config.credentials = credentials
      end
      _(client.configure.endpoint).must_be :nil?
      _(client.universe_domain).must_equal custom_universe
      _(client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
    end
  end

  it "uses host as endpoint without inferring universe_domain" do
    service = Google::Cloud::Trace::Service.new project, credentials, host: custom_endpoint

    _(service.host).must_equal custom_endpoint
    _(service.universe_domain).must_equal default_universe
    assert_v1_client service,
                     expected_universe: default_universe,
                     expected_config_endpoint: custom_endpoint,
                     expected_config_universe: nil,
                     expected_stub_endpoint: custom_endpoint
  end

  it "enforces default universe_domain credential check even when host is overridden" do
    custom_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe
    service = Google::Cloud::Trace::Service.new project, custom_creds, host: custom_endpoint

    expect do
      service.lowlevel_client
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "uses host as endpoint while keeping custom universe_domain" do
    matching_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe
    service = Google::Cloud::Trace::Service.new project, matching_creds,
                                                host: custom_endpoint,
                                                universe_domain: custom_universe

    _(service.host).must_equal custom_endpoint
    _(service.universe_domain).must_equal custom_universe
    assert_v1_client service,
                     expected_universe: custom_universe,
                     expected_config_endpoint: custom_endpoint,
                     expected_config_universe: custom_universe,
                     expected_stub_endpoint: custom_endpoint
  end

  it "enforces custom universe_domain credential check when host is also set" do
    mismatched_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: other_universe
    service = Google::Cloud::Trace::Service.new project, mismatched_creds,
                                                host: custom_endpoint,
                                                universe_domain: custom_universe

    expect do
      service.lowlevel_client
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "accepts matching ServiceAccountCredentials and Trace::Credentials through Service and Trace.new" do
    custom_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    service = Google::Cloud::Trace::Service.new project, custom_creds, universe_domain: custom_universe
    _(service.universe_domain).must_equal custom_universe
    _(service.lowlevel_client.universe_domain).must_equal custom_universe

    wrapped_creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: custom_universe
    trace = Google::Cloud::Trace.new project_id: project, credentials: wrapped_creds, universe_domain: custom_universe
    _(trace.universe_domain).must_equal custom_universe
    _(trace.service.lowlevel_client.universe_domain).must_equal custom_universe
  end

  it "raises Gapic::UniverseDomainMismatch when ServiceAccountCredentials or Trace::Credentials mismatch universe_domain" do
    custom_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: custom_universe

    service = Google::Cloud::Trace::Service.new project, custom_creds, universe_domain: other_universe
    expect do
      service.lowlevel_client
    end.must_raise Gapic::UniverseDomainMismatch

    wrapped_creds = TraceTestHelpers.build_trace_credentials project_id: project, universe_domain: custom_universe
    trace = Google::Cloud::Trace.new project_id: project, credentials: wrapped_creds, universe_domain: other_universe
    expect do
      trace.service.lowlevel_client
    end.must_raise Gapic::UniverseDomainMismatch
  end

  it "raises Gapic::UniverseDomainMismatch when ENV['GOOGLE_CLOUD_UNIVERSE_DOMAIN'] mismatches default SA credentials" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = custom_universe
    default_creds = TraceTestHelpers.build_sa_credentials project_id: project, universe_domain: default_universe

    trace = Google::Cloud::Trace.new project_id: project, credentials: default_creds
    expect do
      trace.service.lowlevel_client
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
      service = Google::Cloud::Trace::Service.new project, direct_creds, universe_domain: custom_universe
      _(service.lowlevel_client.universe_domain).must_equal custom_universe

      wrapped_base = Google::Auth::GCECredentials.new
      wrapped_base.disable_universe_domain_check = false
      wrapped_creds = Google::Cloud::Trace::Credentials.new wrapped_base, project_id: project
      trace = Google::Cloud::Trace.new project_id: project, credentials: wrapped_creds, universe_domain: custom_universe
      _(trace.service.lowlevel_client.universe_domain).must_equal custom_universe
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
      service = Google::Cloud::Trace::Service.new project, direct_creds, universe_domain: other_universe
      expect do
        service.lowlevel_client
      end.must_raise Gapic::UniverseDomainMismatch

      wrapped_base = Google::Auth::GCECredentials.new
      wrapped_base.disable_universe_domain_check = false
      wrapped_creds = Google::Cloud::Trace::Credentials.new wrapped_base, project_id: project
      trace = Google::Cloud::Trace.new project_id: project, credentials: wrapped_creds, universe_domain: other_universe
      expect do
        trace.service.lowlevel_client
      end.must_raise Gapic::UniverseDomainMismatch
    end
  end

  it "allows GCECredentials with custom universe_domain when disable_universe_domain_check is true" do
    gce_creds = Google::Auth::GCECredentials.new
    gce_creds.disable_universe_domain_check = true
    service = Google::Cloud::Trace::Service.new project, gce_creds, universe_domain: custom_universe
    _(service.lowlevel_client.universe_domain).must_equal custom_universe

    wrapped_base = Google::Auth::GCECredentials.new
    wrapped_base.disable_universe_domain_check = true
    wrapped_creds = Google::Cloud::Trace::Credentials.new wrapped_base, project_id: project
    trace = Google::Cloud::Trace.new project_id: project, credentials: wrapped_creds, universe_domain: custom_universe
    _(trace.service.lowlevel_client.universe_domain).must_equal custom_universe
  end
end
