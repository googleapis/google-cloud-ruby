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


require "helper"
require "rails"
require "rails/railtie"
require "action_dispatch"
require "active_support/ordered_options"
require "google/cloud/error_reporting/rails"

describe Google::Cloud::ErrorReporting::Railtie do
  let(:simple_ignore_classes) { [Integer] }
  let(:another_ignore_classes) { [String] }
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.error_reporting = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.credentials = "test/keyfile"
    config.google_cloud.error_reporting.service_name = "test-service"
    config.google_cloud.error_reporting.service_version = "test-version"
    config.google_cloud.error_reporting.ignore_classes = simple_ignore_classes
    config
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    ErrorReportingTestHelpers.reset_default_reporter!
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::ErrorReporting.configure.reset!
    ErrorReportingTestHelpers.reset_v1beta1_client_configs!
  end

  after do
    ErrorReportingTestHelpers.reset_default_reporter!
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::ErrorReporting.configure.reset!
    ErrorReportingTestHelpers.reset_v1beta1_client_configs!
  end

  describe ".consolidate_rails_config" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.service_name).must_equal "test-service"
          _(config.service_version).must_equal "test-version"
          _(config.ignore_classes).must_equal simple_ignore_classes
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project_id = "another-test-project"
        config.credentials = "/another/test/keyfile"
        config.service_name = "another-test-service"
        config.service_version = "another-test-version"
        config.ignore_classes = another_ignore_classes
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.service_name).must_equal "another-test-service"
          _(config.service_version).must_equal "another-test-version"
          _(config.ignore_classes).must_equal another_ignore_classes
        end
      end
    end

    it "Set use_error_reporting to false if credentials aren't valid" do
      Google::Cloud.configure.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, false do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_error_reporting).must_equal false
      end
    end

    it "Set use_error_reporting to true if Rails is in production" do
      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_error_reporting).must_be_nil
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_error_reporting).must_equal true
        end
      end
    end

    it "Set use_error_reporting to false if explicitly disabled in production" do
      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_error_reporting = false
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_error_reporting).must_equal false
        end
      end
    end

    it "returns true if use_error_reporting is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_error_reporting).must_equal true
        end
      end
    end

    it "merges endpoint and universe_domain with error_reporting.universe_domain taking precedence" do
      rails_config.google_cloud.error_reporting.endpoint = "custom.example.com"
      rails_config.google_cloud.universe_domain = "fallback.example.com"
      rails_config.google_cloud.error_reporting.universe_domain = "myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.endpoint).must_equal "custom.example.com"
          _(config.universe_domain).must_equal "myuniverse.com"
        end
      end
    end

    it "falls back to config.google_cloud.universe_domain when error_reporting.universe_domain is unset" do
      rails_config.google_cloud.universe_domain = "myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config

        _(Google::Cloud::ErrorReporting.configure.universe_domain).must_equal "myuniverse.com"
      end
    end

    it "does not inherit config.google_cloud.endpoint" do
      rails_config.google_cloud.endpoint = "gcp.example.com"

      $stdout.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config

        _(Google::Cloud::ErrorReporting.configure.endpoint).must_be :nil?
      end
    end

    it "doesn't override ErrorReporting.configure endpoint or universe_domain" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.endpoint = "configured.example.com"
        config.universe_domain = "configured.myuniverse.com"
      end

      rails_config.google_cloud.error_reporting.endpoint = "rails.example.com"
      rails_config.google_cloud.universe_domain = "rails-gcp.myuniverse.com"
      rails_config.google_cloud.error_reporting.universe_domain = "rails-er.myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.endpoint).must_equal "configured.example.com"
          _(config.universe_domain).must_equal "configured.myuniverse.com"
        end
      end
    end
  end

  describe ".init_middleware" do
    let(:fake_app) do
      inserted = []
      middleware_stack = Object.new
      middleware_stack.define_singleton_method :insert_after do |*args, **kwargs|
        inserted << [args, kwargs]
      end
      app = OpenStruct.new middleware: middleware_stack
      app.define_singleton_method(:inserted) { inserted }
      app
    end

    it "forwards endpoint and universe_domain from consolidated Rails config through Middleware.new" do
      custom_universe = "myuniverse.com"
      custom_endpoint = "custom.example.com"
      creds = ErrorReportingTestHelpers.build_error_reporting_credentials(
        project_id: "test-project",
        universe_domain: custom_universe
      )

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.error_reporting.endpoint = custom_endpoint
      rails_config.google_cloud.error_reporting.universe_domain = custom_universe
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config
      _(Google::Cloud.configure.use_error_reporting).must_equal true

      Google::Cloud::ErrorReporting::Railtie.init_middleware fake_app

      _(fake_app.inserted.size).must_equal 1
      args, kwargs = fake_app.inserted.first
      _(args).must_equal [ActionDispatch::DebugExceptions, Google::Cloud::ErrorReporting::Middleware]
      _(kwargs).must_be :empty?

      middleware = args.last.new fake_app
      project_client = middleware.error_reporting.error_reporting
      _(project_client.universe_domain).must_equal custom_universe
      _(project_client.service.host).must_equal custom_endpoint
      _(project_client.service.error_reporting.universe_domain).must_equal custom_universe
      _(project_client.service.error_reporting.report_errors_service_stub.endpoint).must_equal custom_endpoint
    ensure
      middleware&.error_reporting&.stop!
    end

    it "resolves ErrorReporting.configure.universe_domain set in an initializer after init_middleware" do
      custom_universe = "myuniverse.com"
      creds = ErrorReportingTestHelpers.build_error_reporting_credentials(
        project_id: "test-project",
        universe_domain: custom_universe
      )

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.consolidate_rails_config rails_config
      Google::Cloud::ErrorReporting::Railtie.init_middleware fake_app

      Google::Cloud::ErrorReporting.configure.universe_domain = custom_universe

      middleware_klass = fake_app.inserted.first.first.last
      middleware = middleware_klass.new fake_app
      project_client = middleware.error_reporting.error_reporting
      _(project_client.universe_domain).must_equal custom_universe
      v1_client = project_client.service.error_reporting
      _(v1_client.universe_domain).must_equal custom_universe
      _(v1_client.report_errors_service_stub.endpoint).must_equal "clouderrorreporting.#{custom_universe}"
    ensure
      middleware&.error_reporting&.stop!
    end
  end

  describe ".consolidate_rails_config with old project and keyfile values" do
    let(:rails_config) do
      config = ::ActiveSupport::OrderedOptions.new
      config.google_cloud = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.error_reporting = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.project = "test-project"
      config.google_cloud.keyfile = "test/keyfile"
      config.google_cloud.error_reporting.service_name = "test-service"
      config.google_cloud.error_reporting.service_version = "test-version"
      config.google_cloud.error_reporting.ignore_classes = simple_ignore_classes
      config
    end

    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.service_name).must_equal "test-service"
          _(config.service_version).must_equal "test-version"
          _(config.ignore_classes).must_equal simple_ignore_classes
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.service_name = "another-test-service"
        config.service_version = "another-test-version"
        config.ignore_classes = another_ignore_classes
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.service_name).must_equal "another-test-service"
          _(config.service_version).must_equal "another-test-version"
          _(config.ignore_classes).must_equal another_ignore_classes
        end
      end
    end

    it "Set use_error_reporting to false if credentials aren't valid" do
      Google::Cloud.configure.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, false do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_error_reporting).must_equal false
      end
    end

    it "Set use_error_reporting to true if Rails is in production" do
      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_error_reporting).must_be_nil
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_error_reporting).must_equal true
        end
      end
    end

    it "returns true if use_error_reporting is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_error_reporting).must_equal true
        end
      end
    end
  end
end
