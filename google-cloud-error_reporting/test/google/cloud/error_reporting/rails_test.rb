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
require "google/cloud/error_reporting/rails"

describe Google::Cloud::ErrorReporting::Railtie do
  let(:rails_config) do
    config = ::ActiveSupport::OrderedOptions.new
    config.google_cloud = ::ActiveSupport::OrderedOptions.new
    config.google_cloud.error_reporting = ::ActiveSupport::OrderedOptions.new
    config
  end

  describe ".use_error_reporting?" do
    it "returns false if config.google_cloud.use_error_reporting is explicitly false" do
      rails_config.google_cloud.use_error_reporting = false

      Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(rails_config).must_equal false
    end

    it "returns false if empty project_id provided" do
      Google::Cloud::ErrorReporting::Credentials.stub :credentials_with_scope, nil do
        ENV.stub :[], nil do
          STDOUT.stub :puts, nil do
            Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(rails_config).must_equal false
          end
        end
      end
    end

    it "returns true if config.google_cloud.use_error_reporting is explicitly true even Rails is not in production" do
      rails_config.google_cloud.error_reporting.project_id = "test-project"
      rails_config.google_cloud.use_error_reporting = true

      Google::Cloud::ErrorReporting::Credentials.stub :credentials_with_scope, nil do
        Rails.env.stub :production?, nil do
          Google::Cloud::ErrorReporting::Railtie.use_error_reporting?(rails_config).must_equal true
        end
      end
    end
  end
end
