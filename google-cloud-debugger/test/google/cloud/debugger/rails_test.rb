# Copyright 2017 Google Inc. All rights reserved.
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
require "google/cloud/debugger/rails"

describe Google::Cloud::Debugger::Railtie do
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.debugger = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.keyfile = "test/keyfile"
    config.google_cloud.debugger.service_name = "test-module"
    config.google_cloud.debugger.service_version = "test-version"
    config
  end

  after {
    Google::Cloud::Debugger.configure.instance_variable_get(:@configs).clear
    Google::Cloud.configure.delete :use_debugger
  }

  describe ".consolidate_rails_config" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Debugger::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Debugger.configure do |config|
          config.project_id.must_equal "test-project"
          config.keyfile.must_equal "test/keyfile"
          config.service_name.must_equal "test-module"
          config.service_version.must_equal "test-version"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Debugger.configure do |config|
        config.project_id = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.service_name = "another-test-module"
        config.service_version = "another-test-version"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Debugger::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Debugger.configure do |config|
          config.project_id.must_equal "another-test-project"
          config.keyfile.must_equal "/another/test/keyfile"
          config.service_name.must_equal "another-test-module"
          config.service_version.must_equal "another-test-version"
        end
      end
    end

    it "Set use_debugger to false if credentials aren't valid" do
      Google::Cloud.configure.use_debugger = true

      Google::Cloud::Debugger::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Debugger::Railtie.send :consolidate_rails_config, rails_config
        Google::Cloud.configure.use_debugger.must_equal false
      end
    end

    it "Set use_debugger to true if Rails is in production" do
      Google::Cloud::Debugger::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_debugger.must_be_nil
          Google::Cloud::Debugger::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_debugger.must_equal true
        end
      end
    end

    it "returns true if use_debugger is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_debugger = true

      Google::Cloud::Debugger::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Debugger::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_debugger.must_equal true
        end
      end
    end
  end
end
