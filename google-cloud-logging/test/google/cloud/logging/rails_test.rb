# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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
    config.google_cloud.keyfile = "test/keyfile"
    config.google_cloud.logging.log_name = "test-log-name"
    config.google_cloud.logging.log_name_map = { "test-path" => "log-name" }
    config.google_cloud.logging.monitored_resource.type = "test-type"
    config.google_cloud.logging.monitored_resource.labels = { test: "label" }
    config
  end

  after {
    Google::Cloud::Logging.configure.delete :project_id
    Google::Cloud::Logging.configure.delete :keyfile
    Google::Cloud::Logging.configure.delete :log_name
    Google::Cloud::Logging.configure.delete :log_name_map
    Google::Cloud::Logging.configure.monitored_resource.delete :type
    Google::Cloud::Logging.configure.monitored_resource.delete :labels
    Google::Cloud.configure.delete :use_logging
  }

  describe ".consolidate_rails_config?" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          config.project_id.must_equal "test-project"
          config.keyfile.must_equal "test/keyfile"
          config.log_name.must_equal "test-log-name"
          config.log_name_map.must_equal "test-path" => "log-name"
          config.monitored_resource.type.must_equal "test-type"
          config.monitored_resource.labels.must_equal test: "label"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Logging.configure do |config|
        config.project_id = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.log_name = "another-test-log-name"
        config.log_name_map = {"test-path" => "another-log-name"}
        config.monitored_resource.type = "another-test-type"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Logging.configure do |config|
          config.project_id.must_equal "another-test-project"
          config.keyfile.must_equal "/another/test/keyfile"
          config.log_name.must_equal  "another-test-log-name"
          config.log_name_map.must_equal "test-path" => "another-log-name"
          config.monitored_resource.type.must_equal "another-test-type"
        end
      end
    end

    it "Set use_logging to false if credentials aren't valid" do
      Google::Cloud.configure.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
        Google::Cloud.configure.use_logging.must_equal false
      end
    end

    it "Set use_logging to true if Rails is in production" do
      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_logging.must_be_nil
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_logging.must_equal true
        end
      end
    end

    it "returns true if config.google_cloud.use_logging is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Logging::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_logging.must_equal true
        end
      end
    end
  end
end
