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


require "minitest/autorun"
require "minitest/rg"
require "minitest/focus"
require "rails"
require "rails/railtie"
require "active_support/ordered_options"
require "google/cloud/error_reporting/rails"

describe Google::Cloud::ErrorReporting::Railtie do
  before do
    @rails_config = ::ActiveSupport::OrderedOptions.new
    @rails_config.google_cloud = ::ActiveSupport::OrderedOptions.new
    @rails_config.google_cloud.error_reporting = ::ActiveSupport::OrderedOptions.new
  end

  describe ".use_error_reporting?" do
    it "returns false if config.google_cloud.use_error_reporting is explicitly false" do
      @rails_config.google_cloud.use_error_reporting = false

      Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(@rails_config).must_equal false
    end

    it "returns false if empty project_id provided" do
      Google::Cloud::ErrorReporting::Railtie.stub :grpc_channel, nil do
        Rails.logger = Object.new
        Rails.logger.stub :warn, nil do
          Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(@rails_config).must_equal false
        end
      end
    end

    it "returns true if config.google_cloud.use_error_reporting is explicitly true even Rails is not in production" do
      @rails_config.google_cloud.error_reporting.project_id = "test-project"
      @rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Railtie.stub :grpc_channel, nil do
        Rails.env.stub :production?, nil do
          Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(@rails_config).must_equal true
        end
      end
    end
  end
end
