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

require "google/cloud/logging"

module Google
  module Cloud
    module Logging
      ##
      # Default log name to be used for Stackdriver Logging
      DEFAULT_LOG_NAME = "ruby_app_log"

      ##
      # Railtie
      #
      # Google::Cloud::Logging::Railtie automatically add the
      # Google::Cloud::Logging::Middleware to Rack in a Rails environment.
      # The middleware will set env['rack.logger'] to a
      # Google::Cloud::Logging::Logger instance to be used by the Rails
      # application.
      #
      # The Middleware is only added when certain conditions are met. See
      # {use_logging?} for detail.
      #
      # When loaded, the Google::Cloud::Logging::Middleware will be inserted
      # before the Rails::Rack::Logger Middleware, which allows it to set the
      # env['rack.logger'] in place of Rails's default logger. The Railtie
      # should also initialize the logger with correct GCP project_id
      # and keyfile if they are defined in Rails environment.rb as follow:
      #   config.google_cloud.logging.project_id = "my-gcp-project"
      #   config.google_cloud.logging.keyfile = "/path/to/secret.json"
      # or
      #   config.google_cloud.project_id = "my-gcp-project"
      #   config.google_cloud.keyfile = "/path/to/secret.json"
      # If omitted, project_id will be initialized with default environment
      # variables.
      #
      class Railtie < ::Rails::Railtie
        config.google_cloud = ::ActiveSupport::OrderedOptions.new unless
          config.respond_to? :google_cloud
        config.google_cloud.logging = ::ActiveSupport::OrderedOptions.new
        config.google_cloud.logging.monitored_resource =
          ::ActiveSupport::OrderedOptions.new
        config.google_cloud.logging.monitored_resource.labels =
          ::ActiveSupport::OrderedOptions.new

        initializer "Stackdriver.Logging", before: :initialize_logger do |app|
          if self.class.use_logging? app.config
            gcp_config = app.config.google_cloud
            log_config = gcp_config.logging

            project_id = log_config.project_id || gcp_config.project_id
            keyfile = log_config.keyfile || gcp_config.keyfile
            resource_type = log_config.monitored_resource.type
            resource_labels = log_config.monitored_resource.labels

            logging = Google::Cloud::Logging.new project: project_id,
                                                 keyfile: keyfile
            resource =
              Logging::Middleware.build_monitored_resource resource_type,
                                                           resource_labels
            log_name = log_config.log_name || DEFAULT_LOG_NAME

            app.config.logger = logging.logger log_name, resource
            app.middleware.insert_before Rails::Rack::Logger,
                                         Google::Cloud::Logging::Middleware,
                                         logger: app.config.logger
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
        def self.use_logging? config
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
