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
require "rails"
require "rails/railtie"
require "active_support/ordered_options"
require "google/cloud/logging/rails"

describe Google::Cloud::Logging::Railtie do
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.logging = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.logging.monitored_resource = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.credentials = "test/keyfile"
    config.google_cloud.logging.log_name = "test-log-name"
    config.google_cloud.logging.log_name_map = { "test-path" => "log-name" }
    config.google_cloud.logging.monitored_resource.type = "test-type"
    config.google_cloud.logging.monitored_resource.labels = { test: "label" }
    config
  end

  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud::Logging::Middleware.logger = nil
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
  end

  after do
    Google::Cloud::Logging::Middleware.logger&.writer&.stop!
    Google::Cloud::Logging::Middleware.logger = nil
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
  end

  describe ".consolidate_rails_config?" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.log_name).must_equal "test-log-name"
          _(config.log_name_map).must_equal "test-path" => "log-name"
          _(config.monitored_resource.type).must_equal "test-type"
          _(config.monitored_resource.labels).must_equal test: "label"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Logging.configure do |config|
        config.project_id = "another-test-project"
        config.credentials = "/another/test/keyfile"
        config.log_name = "another-test-log-name"
        config.log_name_map = {"test-path" => "another-log-name"}
        config.monitored_resource.type = "another-test-type"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.log_name).must_equal  "another-test-log-name"
          _(config.log_name_map).must_equal "test-path" => "another-log-name"
          _(config.monitored_resource.type).must_equal "another-test-type"
        end
      end
    end

    it "Set use_logging to false if credentials aren't valid" do
      Google::Cloud.configure.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_logging).must_equal false
      end
    end

    it "Set use_logging to true if Rails is in production" do
      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_logging).must_be_nil
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_logging).must_equal true
        end
      end
    end

    it "returns true if config.google_cloud.use_logging is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_logging).must_equal true
        end
      end
    end

    it "merges endpoint and universe_domain with logging.universe_domain taking precedence" do
      rails_config.google_cloud.logging.endpoint = "custom.example.com"
      rails_config.google_cloud.universe_domain = "fallback.example.com"
      rails_config.google_cloud.logging.universe_domain = "myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::Logging::Railtie.consolidate_rails_config rails_config

        Google::Cloud::Logging.configure do |config|
          _(config.endpoint).must_equal "custom.example.com"
          _(config.universe_domain).must_equal "myuniverse.com"
        end
      end
    end

    it "falls back to config.google_cloud.universe_domain when logging.universe_domain is unset" do
      rails_config.google_cloud.universe_domain = "myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::Logging::Railtie.consolidate_rails_config rails_config

        _(Google::Cloud::Logging.configure.universe_domain).must_equal "myuniverse.com"
      end
    end

    it "doesn't override Logging.configure endpoint or universe_domain" do
      Google::Cloud::Logging.configure do |config|
        config.endpoint = "configured.example.com"
        config.universe_domain = "configured.myuniverse.com"
      end

      rails_config.google_cloud.logging.endpoint = "rails.example.com"
      rails_config.google_cloud.universe_domain = "rails-gcp.myuniverse.com"
      rails_config.google_cloud.logging.universe_domain = "rails-logging.myuniverse.com"

      $stdout.stub :puts, nil do
        Google::Cloud::Logging::Railtie.consolidate_rails_config rails_config

        Google::Cloud::Logging.configure do |config|
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
      middleware_stack.define_singleton_method(:insert_before) do |*args, **kwargs|
        inserted << [args, kwargs]
      end
      app = OpenStruct.new middleware: middleware_stack
      app.define_singleton_method(:inserted) { inserted }
      app
    end

    it "forwards endpoint and universe_domain from consolidated Rails config to Middleware.logger" do
      custom_universe = "myuniverse.com"
      custom_endpoint = "custom.example.com"
      creds = LoggingTestHelpers.build_logging_credentials project_id: "test-project", universe_domain: custom_universe

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.logging.endpoint = custom_endpoint
      rails_config.google_cloud.logging.universe_domain = custom_universe
      rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Railtie.consolidate_rails_config rails_config
      _(Google::Cloud.configure.use_logging).must_equal true

      Google::Cloud::Logging::Railtie.init_middleware fake_app

      _(fake_app.inserted.size).must_equal 1
      args, kwargs = fake_app.inserted.first
      _(args).must_equal [Rails::Rack::Logger, Google::Cloud::Logging::Middleware]
      _(kwargs[:logger]).must_equal Google::Cloud::Logging::Middleware.logger

      project_client = Google::Cloud::Logging::Middleware.logger.writer.logging
      _(project_client.universe_domain).must_equal custom_universe
      _(project_client.service.host).must_equal custom_endpoint
      _(project_client.service.logging.universe_domain).must_equal custom_universe
      _(project_client.service.logging.logging_service_stub.endpoint).must_equal custom_endpoint
    end

    it "resolves Logging.configure.universe_domain set in an initializer after init_middleware" do
      custom_universe = "myuniverse.com"
      creds = LoggingTestHelpers.build_logging_credentials project_id: "test-project", universe_domain: custom_universe

      rails_config.google_cloud.credentials = creds
      rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Railtie.consolidate_rails_config rails_config
      Google::Cloud::Logging::Railtie.init_middleware fake_app

      Google::Cloud::Logging.configure.universe_domain = custom_universe

      project_client = Google::Cloud::Logging::Middleware.logger.writer.logging
      _(project_client.universe_domain).must_equal custom_universe
      v2_client = project_client.service.logging
      _(v2_client.universe_domain).must_equal custom_universe
      _(v2_client.logging_service_stub.endpoint).must_equal "logging.#{custom_universe}"
    end
  end

  describe ".consolidate_rails_config with old project and keyfile values" do
    let(:rails_config) do
      config = ::ActiveSupport::OrderedOptions.new
      config.google_cloud = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.logging = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.logging.monitored_resource = ::ActiveSupport::OrderedOptions.new
      config.google_cloud.project = "test-project"
      config.google_cloud.keyfile = "test/keyfile"
      config.google_cloud.logging.log_name = "test-log-name"
      config.google_cloud.logging.log_name_map = { "test-path" => "log-name" }
      config.google_cloud.logging.monitored_resource.type = "test-type"
      config.google_cloud.logging.monitored_resource.labels = { test: "label" }
      config
    end

    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          _(config.project_id).must_equal "test-project"
          _(config.credentials).must_equal "test/keyfile"
          _(config.log_name).must_equal "test-log-name"
          _(config.log_name_map).must_equal "test-path" => "log-name"
          _(config.monitored_resource.type).must_equal "test-type"
          _(config.monitored_resource.labels).must_equal test: "label"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Logging.configure do |config|
        config.project = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.log_name = "another-test-log-name"
        config.log_name_map = {"test-path" => "another-log-name"}
        config.monitored_resource.type = "another-test-type"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          _(config.project_id).must_equal "another-test-project"
          _(config.credentials).must_equal "/another/test/keyfile"
          _(config.log_name).must_equal  "another-test-log-name"
          _(config.log_name_map).must_equal "test-path" => "another-log-name"
          _(config.monitored_resource.type).must_equal "another-test-type"
        end
      end
    end

    it "Set use_logging to false if credentials aren't valid" do
      Google::Cloud.configure.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
        _(Google::Cloud.configure.use_logging).must_equal false
      end
    end

    it "Set use_logging to true if Rails is in production" do
      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          _(Google::Cloud.configure.use_logging).must_be_nil
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_logging).must_equal true
        end
      end
    end

    it "Set use_error_reporting to false if explicitly disabled in production" do
      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_logging = false
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_logging).must_equal false
        end
      end
    end

    it "returns true if config.google_cloud.use_logging is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          _(Google::Cloud.configure.use_logging).must_equal true
        end
      end
    end
  end
end
