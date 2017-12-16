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
require "google/cloud/trace/rails"

describe Google::Cloud::Trace::Railtie do
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.trace = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.project_id = "test-project"
    config.google_cloud.keyfile = "test/keyfile"
    config.google_cloud.trace.capture_stack = "true"
    config.google_cloud.trace.notifications = ["foo", "boo"]
    config.google_cloud.trace.max_data_length = 123
    config.google_cloud.trace.sampler = "test-sampler"
    config.google_cloud.trace.span_id_generator = "test-generator"
    config
  end

  after {
    Google::Cloud.configure.delete :use_trace
    Google::Cloud::Trace.configure.instance_variable_get(:@configs).clear
  }

  describe ".consolidate_rails_config" do
    it "merges configs from Rails configuration" do
      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          config.project_id.must_equal "test-project"
          config.keyfile.must_equal "test/keyfile"
          config.capture_stack.must_equal "true"
          config.notifications.must_equal ["foo", "boo"]
          config.max_data_length.must_equal 123
          config.sampler.must_equal "test-sampler"
          config.span_id_generator.must_equal "test-generator"
        end
      end
    end

    it "doesn't override instrumentation configs" do
      Google::Cloud::Trace.configure do |config|
        config.project_id = "another-test-project"
        config.keyfile = "/another/test/keyfile"
        config.capture_stack = "false"
        config.notifications = ["blah"]
        config.max_data_length = 345
        config.sampler = "another-test-sampler"
        config.span_id_generator = "another-test-generator"
      end

      STDOUT.stub :puts, nil do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config

        Google::Cloud::Trace.configure do |config|
          config.project_id.must_equal "another-test-project"
          config.keyfile.must_equal "/another/test/keyfile"
          config.capture_stack.must_equal "false"
          config.notifications.must_equal ["blah"]
          config.max_data_length.must_equal 345
          config.sampler.must_equal "another-test-sampler"
          config.span_id_generator.must_equal "another-test-generator"
        end
      end
    end

    it "Set use_trace to false if credentials aren't valid" do
      Google::Cloud.configure.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, false do
        Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
        Google::Cloud.configure.use_trace.must_equal false
      end
    end

    it "Set use_trace to true if Rails is in production" do
      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, true do
          Google::Cloud.configure.use_trace.must_be_nil
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_trace.must_equal true
        end
      end
    end

    it "returns true if use_trace is explicitly true even Rails is not in production" do
      rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Railtie.stub :valid_credentials?, true do
        Rails.env.stub :production?, false do
          Google::Cloud::Trace::Railtie.send :consolidate_rails_config, rails_config
          Google::Cloud.configure.use_trace.must_equal true
        end
      end
    end
  end
end
