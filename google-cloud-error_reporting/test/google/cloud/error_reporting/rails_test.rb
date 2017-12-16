# Copyright 2017 Google LLC
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
require "google/cloud/error_reporting/rails"

describe Google::Cloud::ErrorReporting::Railtie do
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.error_reporting = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.keyfile = "test/keyfile"
    config.google_cloud.error_reporting.service_name = "test-service"
    config.google_cloud.error_reporting.service_version = "test-version"
    config.google_cloud.error_reporting.ignore_classes = "test class"
    config
  end

  after {
    Google::Cloud::ErrorReporting.configure.instance_variable_get(:@configs).clear
    Google::Cloud.configure.delete :use_error_reporting
  }

  describe ".consolidate_rails_config" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          config.project_id.must_equal "test-project"
          config.keyfile.must_equal "test/keyfile"
          config.service_name.must_equal "test-service"
          config.service_version.must_equal "test-version"
          config.ignore_classes.must_equal "test class"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project_id = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.service_name = "another-test-service"
        config.service_version = "another-test-version"
        config.ignore_classes = "another test class"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::ErrorReporting.configure do |config|
          config.project_id.must_equal "another-test-project"
          config.keyfile.must_equal "/another/test/keyfile"
          config.service_name.must_equal "another-test-service"
          config.service_version.must_equal "another-test-version"
          config.ignore_classes.must_equal "another test class"
        end
      end
    end

    it "Set use_error_reporting to false if credentials aren't valid" do
      Google::Cloud.configure.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, false do
        Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
        Google::Cloud.configure.use_error_reporting.must_equal false
      end
    end

    it "Set use_error_reporting to true if Rails is in production" do
      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_error_reporting.must_be_nil
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_error_reporting.must_equal true
        end
      end
    end

    it "returns true if use_error_reporting is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::ErrorReporting::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_error_reporting.must_equal true
        end
      end
    end
  end
end
