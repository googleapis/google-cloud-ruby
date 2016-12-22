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

require "google/cloud/debugger"

module Google
  module Cloud
    module Debugger
      class Railtie < ::Rails::Railtie
        config.google_cloud = ::ActiveSupport::OrderedOptions.new unless
          config.respond_to? :google_cloud
        config.google_cloud.debugger = ::ActiveSupport::OrderedOptions.new

        debugger = Google::Cloud::Debugger.new
        initializer "Stackdriver.Debugger" do |app|
          if self.class.use_debugger? app.config
            app.middleware.insert_after Rack::ETag,
                                        Google::Cloud::Debugger::Middleware,
                                        debugger: debugger
          end
        end

        ##
        # Determine whether to use Stackdriver Logging or not.
        #
        # Returns true if valid GCP project_id is provided and underneath API is
        # able to authenticate. Also either Rails needs to be in "production"
        # environment or config.stackdriver.use_logging is explicitly true.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        # @return [Boolean] Whether to use Stackdriver Logging
        #
        def self.use_debugger? config
          return true

          gcp_config = config.google_cloud
          # Return false if config.stackdriver.use_logging is explicitly false
          return false if gcp_config.key?(:use_logging) &&
                          !gcp_config.use_logging

          # Try authenticate authorize client API. Return false if unable to
          # authorize.
          keyfile = gcp_config.logging.keyfile || gcp_config.keyfile
          begin
            Google::Cloud::Logging::Credentials.credentials_with_scope keyfile
          rescue Exception => e
            warn "Google::Cloud::Logging is not activated due to " \
              "authorization error: #{e.message}\nFalling back to default " \
              "logger"
            return false
          end

          project_id = gcp_config.logging.project_id || gcp_config.project_id ||
                       Google::Cloud::Logging::Project.default_project
          if project_id.to_s.empty?
            warn "Google::Cloud::Logging is not activated due to empty " \
              "project_id; falling back to default logger"
            return false
          end

          # Otherwise default to true if Rails is running in production or
          # config.stackdriver.use_logging is true
          Rails.env.production? || gcp_config.use_logging
        end
      end
    end
  end
end
