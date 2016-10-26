# Copyright 2016 Google Inc. All rights reserved.
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
  describe ".use_trace?" do
    before do
      @rails_config = ::ActiveSupport::OrderedOptions.new
      @rails_config.google_cloud = ::ActiveSupport::OrderedOptions.new
      @rails_config.google_cloud.trace = ::ActiveSupport::OrderedOptions.new
    end

    it "returns false if config.google_cloud.use_trace is explicitly false" do
      @rails_config.google_cloud.use_trace = false

      Google::Cloud::Trace::Railtie.use_trace?(@rails_config).must_equal false
    end

    it "returns false if can't find non-empty project_id" do
      Google::Cloud::Trace::Credentials.stub :default, nil do
        Google::Cloud::Trace::Project.stub :default_project, nil do
          $stderr.stub :write, nil do
            Google::Cloud::Trace::Railtie.use_trace?(@rails_config).must_equal false
          end
        end
      end
    end

    it "returns true if config.google_cloud.use_trace is explicitly true even Rails is not in production" do
      @rails_config.google_cloud.trace.project_id = "test-project"
      @rails_config.google_cloud.use_trace = true

      Google::Cloud::Trace::Credentials.stub :default, nil do
        Rails.env.stub :production?, false do
          Google::Cloud::Trace::Railtie.use_trace?(@rails_config).must_equal true
        end
      end
    end
  end
end
