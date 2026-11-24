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
require "rack"
require "rack/runtime"
require "rails"
require "rails/railtie"
require "active_support/ordered_options"
require "google/cloud/trace/rails"

describe Google::Cloud::Trace::Railtie do
  let(:a_test_generator) { Proc.new { 0 } }
  let(:another_generator) { Proc.new { 1 } }
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.trace = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.credentials = "test/keyfile"
    config.google_cloud.trace.capture_stack = true
    config.google_cloud.trace.notifications = ["foo", "boo"]
    config.google_cloud.trace.max_data_length = 123
    config.google_cloud.trace.sampler = "test-sampler"
    config.google_cloud.trace.span_id_generator = a_test_generator
    config
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::Trace::V1::TraceService::Client.configure.endpoint = nil
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = nil
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::Trace::V1::TraceService::Client.configure.endpoint = nil
    Google::Cloud::Trace::V1::TraceService::Client.configure.universe_domain = nil
  end

  describe ".consolidate_rails_config" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.capture_stack).must_equal true
          _(config.notifications).must_equal ["foo", "boo"]
          _(config.max_data_length).must_equal 123
          _(config.sampler).must_equal "test-sampler"
          _(config.span_id_generator).must_equal a_test_generator
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Trace.configure do |config|
        config.project_id = "another-test-project"
        config.credentials = "/another/test/keyfile"
        config.capture_stack = false
        config.notifications = ["blah"]
        config.max_data_length = 345
        config.sampler = "another-test-sampler"
        config.span_id_generator = another_generator
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.capture_stack).must_equal false
          _(config.notifications).must_equal ["blah"]
          _(config.max_data_length).must_equal 345
          _(config.sampler).must_equal "another-test-sampler"
          _(config.span_id_generator).must_equal another_generator
        end
      end
    end

    it "Set use_trace to false if credentials aren't valid" do
      Google::Cloud.configure.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_trace).must_equal false
      end
    end

    it "Set use_trace to true if Rails is in production" do
      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_trace).must_be_nil
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_trace).must_equal true
        end
      end
    end

    it "returns true if use_trace is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_trace).must_equal true
        end
      end
    end

    it "merges endpoint and universe_domain with trace.universe_domain taking precedence" do
      rails_config.google_cloud.trace.endpoint = "custom.example.com"
      rails_config.google_cloud.universe_domain = "fallback.example.com"
      rails_config.google_cloud.trace.universe_domain = "myuniverse.com"

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.endpoint).must_equal "custom.example.com"
          _(config.universe_domain).must_equal "myuniverse.com"
        end
      end
    end

    it "falls back to config.google_cloud.universe_domain when trace.universe_domain is unset" do
      rails_config.google_cloud.universe_domain = "myuniverse.com"

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        _(Google::Cloud::Trace.configure.universe_domain).must_equal "myuniverse.com"
      end
    end

    it "doesn't merge config.google_cloud.endpoint" do
      rails_config.google_cloud.endpoint = "shared-endpoint.example.com"

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        _(Google::Cloud::Trace.configure.endpoint).must_be :nil?
      end
    end

    it "doesn't override Trace.configure endpoint or universe_domain" do
      Google::Cloud::Trace.configure do |config|
        config.endpoint = "configured.example.com"
        config.universe_domain = "configured.myuniverse.com"
      end

      rails_config.google_cloud.trace.endpoint = "rails.example.com"
      rails_config.google_cloud.universe_domain = "rails-gcp.myuniverse.com"
      rails_config.google_cloud.trace.universe_domain = "rails-trace.myuniverse.com"

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.endpoint).must_equal "configured.example.com"
          _(config.universe_domain).must_equal "configured.myuniverse.com"
        end
      end
    end
  end

  describe ".init_middleware" do
    let(:rack_app) { ->(_env) { ["200", {}, ["ok"]] } }
    let(:fake_app) do
      inserted = []
      middleware_stack = Object.new
      middleware_stack.define_singleton_method(:insert_before) do |*args, **kwargs|
        inserted << [args, kwargs]
      end
      app = OpenStruct.new middleware: middleware_stack
      app.define_singleton_method(:inserted) { inserted }
      app
    end

    it "forwards endpoint and universe_domain from consolidated Rails config to Middleware" do
      custom_universe = "myuniverse.com"
      custom_endpoint = "custom.example.com"
      creds = TraceTestHelpers.build_trace_credentials project_id: "test-project", universe_domain: custom_universe

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.trace.endpoint = custom_endpoint
      rails_config.google_cloud.trace.universe_domain = custom_universe
      rails_config.google_cloud.trace.notifications = []
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
      _(Google::Cloud.configure.use_trace).must_equal true

      Google::Cloud::Trace::Railtie.init_middleware fake_app

      _(fake_app.inserted.size).must_equal 1
      args, kwargs = fake_app.inserted.first
      _(args).must_equal [Rack::Runtime, Google::Cloud::Trace::Middleware]
      _(kwargs).must_be :empty?

      middleware = Google::Cloud::Trace::Middleware.new rack_app, **kwargs
      reporter = middleware.instance_variable_get :@service
      _(reporter).must_be_kind_of Google::Cloud::Trace::AsyncReporter

      service = reporter.service
      _(service.universe_domain).must_equal custom_universe
      _(service.host).must_equal custom_endpoint

      v1_client = service.lowlevel_client
      _(v1_client.universe_domain).must_equal custom_universe
      _(v1_client.trace_service_stub.universe_domain).must_equal custom_universe
      _(v1_client.trace_service_stub.endpoint).must_equal custom_endpoint
    ensure
      reporter&.stop!
    end

    it "resolves Trace.configure.universe_domain set in an initializer after init_middleware and before Middleware.new" do
      custom_universe = "myuniverse.com"
      creds = TraceTestHelpers.build_trace_credentials project_id: "test-project", universe_domain: custom_universe

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.trace.notifications = []
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
      Google::Cloud::Trace::Railtie.init_middleware fake_app

      Google::Cloud::Trace.configure.universe_domain = custom_universe

      args, kwargs = fake_app.inserted.first
      middleware = args.last.new rack_app, **kwargs
      reporter = middleware.instance_variable_get :@service
      service = reporter.service

      _(service.universe_domain).must_equal custom_universe
      v1_client = service.lowlevel_client
      _(v1_client.universe_domain).must_equal custom_universe
      _(v1_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
    ensure
      reporter&.stop!
    end

    it "resolves Trace.configure.universe_domain set after Middleware.new before lazy lowlevel_client init" do
      custom_universe = "myuniverse.com"
      creds = TraceTestHelpers.build_trace_credentials project_id: "test-project", universe_domain: custom_universe

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.trace.notifications = []
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
      Google::Cloud::Trace::Railtie.init_middleware fake_app

      args, kwargs = fake_app.inserted.first
      middleware = args.last.new rack_app, **kwargs

      Google::Cloud::Trace.configure.universe_domain = custom_universe

      reporter = middleware.instance_variable_get :@service
      service = reporter.service

      _(service.universe_domain).must_equal custom_universe
      v1_client = service.lowlevel_client
      _(v1_client.universe_domain).must_equal custom_universe
      _(v1_client.trace_service_stub.endpoint).must_equal "cloudtrace.#{custom_universe}"
    ensure
      reporter&.stop!
    end
  end

  describe ".consolidate_rails_config with old project and keyfile values" do
    let(:rails_config) do
      config = ::ActiveSupport::OrderedOptions.new
      config.google_cloud = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.trace = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.project = "test-project"
      config.google_cloud.keyfile = "test/keyfile"
      config.google_cloud.trace.capture_stack = true
      config.google_cloud.trace.notifications = ["foo", "boo"]
      config.google_cloud.trace.max_data_length = 123
      config.google_cloud.trace.sampler = "test-sampler"
      config.google_cloud.trace.span_id_generator = a_test_generator
      config
    end

    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.capture_stack).must_equal true
          _(config.notifications).must_equal ["foo", "boo"]
          _(config.max_data_length).must_equal 123
          _(config.sampler).must_equal "test-sampler"
          _(config.span_id_generator).must_equal a_test_generator
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Trace.configure do |config|
        config.project = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.capture_stack = false
        config.notifications = ["blah"]
        config.max_data_length = 345
        config.sampler = "another-test-sampler"
        config.span_id_generator = another_generator
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.capture_stack).must_equal false
          _(config.notifications).must_equal ["blah"]
          _(config.max_data_length).must_equal 345
          _(config.sampler).must_equal "another-test-sampler"
          _(config.span_id_generator).must_equal another_generator
        end
      end
    end

    it "Set use_trace to false if credentials aren't valid" do
      Google::Cloud.configure.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_trace).must_equal false
      end
    end

    it "Set use_trace to true if Rails is in production" do
      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_trace).must_be_nil
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_trace).must_equal true
        end
      end
    end

    it "Set use_trace to false if explicitly disabled in production" do
      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_trace = false
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_trace).must_equal false
        end
      end
    end

    it "returns true if use_trace is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_trace).must_equal true
        end
      end
    end
  end
end
