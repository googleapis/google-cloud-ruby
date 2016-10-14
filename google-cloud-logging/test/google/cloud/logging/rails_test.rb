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
require "google/cloud/logging/rails"

describe Google::Cloud::Logging::Railtie do
  describe ".use_logging?" do
    before do
      @rails_config = ::ActiveSupport::OrderedOptions.new
      @rails_config.google_cloud = ::ActiveSupport::OrderedOptions.new
      @rails_config.google_cloud.logging = ::ActiveSupport::OrderedOptions.new
    end

    it "returns false if config.google_cloud.use_logging is explicitly false" do
      @rails_config.google_cloud.use_logging = false

      Google::Cloud::Logging::Railtie.use_logging?(@rails_config).must_equal false
    end

    it "returns false if can't find non-empty project_id" do
      Google::Cloud::Logging::Credentials.stub :default, nil do
        Google::Cloud::Logging::Project.stub :default_project, nil do
          $stderr.stub :write, nil do
            Google::Cloud::Logging::Railtie.use_logging?(@rails_config).must_equal false
          end
        end
      end
    end

    it "returns true if config.google_cloud.use_logging is explicitly true even Rails is not in production" do
      @rails_config.google_cloud.logging.project_id = "test-project"
      @rails_config.google_cloud.use_logging = true

      Google::Cloud::Logging::Credentials.stub :default, nil do
        Rails.env.stub :production?, false do
          Google::Cloud::Logging::Railtie.use_logging?(@rails_config).must_equal true
        end
      end
    end
  end

  describe ".build_monitoring_resource" do
    it "returns resource of type gae_app if gae? is true" do
      Google::Cloud::Core::Environment.stub :gae?, true do
        Google::Cloud::Core::Environment.stub :gke?, false do
          Google::Cloud::Core::Environment.stub :gce?, false do
            rc = Google::Cloud::Logging::Railtie.build_monitoring_resource
            rc.type.must_equal "gae_app"
          end
        end
      end
    end

    it "returns resource of type container if gke? is true" do
      Google::Cloud::Core::Environment.stub :gae?, false do
        Google::Cloud::Core::Environment.stub :gke?, true do
          Google::Cloud::Core::Environment.stub :gce?, false do
            rc = Google::Cloud::Logging::Railtie.build_monitoring_resource
            rc.type.must_equal "container"
          end
        end
      end
    end

    it "returns resource of type gce_instance if gce? is true" do
      Google::Cloud::Core::Environment.stub :gae?, false do
        Google::Cloud::Core::Environment.stub :gke?, false do
          Google::Cloud::Core::Environment.stub :gce?, true do
            rc = Google::Cloud::Logging::Railtie.build_monitoring_resource
            rc.type.must_equal "gce_instance"
          end
        end
      end
    end

    it "returns resource of type global if not on GCP" do
      Google::Cloud::Core::Environment.stub :gae?, false do
        Google::Cloud::Core::Environment.stub :gke?, false do
          Google::Cloud::Core::Environment.stub :gce?, false do
            rc = Google::Cloud::Logging::Railtie.build_monitoring_resource
            rc.type.must_equal "global"
          end
        end
      end
    end
  end
end
