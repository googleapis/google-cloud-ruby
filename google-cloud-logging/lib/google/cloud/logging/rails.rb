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
      # Railtie
      #
      # Adds the {Google::Cloud::Logging::Middleware} to Rack in a Rails
      # environment. The middleware will set `env['rack.logger']` to a
      # {Google::Cloud::Logging::Logger} instance to be used by the Rails
      # application.
      #
      # The Middleware is only added when certain conditions are met. See
      # {use_logging?} for details.
      #
      # When loaded, the {Google::Cloud::Logging::Middleware} will be inserted
      # before the `Rails::Rack::Logger Middleware`, which allows it to set the
      # `env['rack.logger']` in place of Rails's default logger. The Railtie
      # will also initialize the logger with correct GCP `project_id`
      # and `keyfile` if they are defined in the Rails `environment.rb` file as
      # follows:
      #
      # ```ruby
      # config.google_cloud.logging.project_id = "my-gcp-project"
      # config.google_cloud.logging.keyfile = "/path/to/secret.json"
      # ```
      #
      # or
      #
      # ```ruby
      # config.google_cloud.project_id = "my-gcp-project"
      # config.google_cloud.keyfile = "/path/to/secret.json"
      # ```
      #
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
            logging_config = Railtie.parse_rails_config config

            project_id = logging_config[:project_id]
            keyfile = logging_config[:keyfile]
            resource_type = logging_config[:resource_type]
            resource_labels = logging_config[:resource_labels]
            log_name = logging_config[:log_name]

            logging = Google::Cloud::Logging.new project: project_id,
                                                 keyfile: keyfile
            resource =
              Logging::Middleware.build_monitored_resource resource_type,
                                                           resource_labels

            app.config.logger = logging.logger log_name, resource
            app.middleware.insert_before Rails::Rack::Logger,
                                         Google::Cloud::Logging::Middleware,
                                         logger: app.config.logger
          end
        end

        ##
        # Determine whether to use Stackdriver Logging or not.
        #
        # Returns `true` if Stackdriver Logging is enabled for this application.
        # That is, if all of the following are true:
        #
        # * A valid GCP `project_id` is available, either because the
        #   application is hosted on Google Cloud or because it is set in the
        #   configuration.
        # * The API is able to authenticate, again either because the
        #   application is hosted on Google Cloud or because an appropriate
        #   keyfile is provided in the configuration.
        # * Either the Rails environment is set to `production` or the
        #   `config.google_cloud.use_logging` configuration is explicitly set to
        #   `true`.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   `Rails.application.config`
        #
        # @return [Boolean] Whether to use Stackdriver Logging
        #
        def self.use_logging? config
          logging_config = Railtie.parse_rails_config config

          # Return false if config.google_cloud.use_logging is explicitly false
          use_logging = logging_config[:use_logging]
          return false if !use_logging.nil? && !use_logging

          project_id = logging_config[:project_id] ||
                       Google::Cloud::Logging::Project.default_project
          keyfile = logging_config[:keyfile]

          # Try authenticate authorize client API. Return false if unable to
          # authorize.
          begin
            Google::Cloud::Logging::Credentials.credentials_with_scope keyfile
          rescue Exception => e
            warn "Google::Cloud::Logging is not activated due to " \
              "authorization error: #{e.message}\nFalling back to default " \
              "logger"
            return false
          end

          if project_id.to_s.empty?
            warn "Google::Cloud::Logging is not activated due to empty " \
              "project_id; falling back to default logger"
            return false
          end

          # Otherwise default to true if Rails is running in production or
          # config.google_cloud.use_logging is true
          Rails.env.production? || use_logging
        end

        ##
        # @private Helper method to parse rails config into a flattened hash
        def self.parse_rails_config config
          gcp_config = config.google_cloud
          logging_config = gcp_config[:logging]
          use_logging =
            gcp_config.key?(:use_logging) ? gcp_config.use_logging : nil
          {
            project_id: logging_config.project_id || gcp_config.project_id,
            keyfile: logging_config.keyfile || gcp_config.keyfile,
            resource_type: logging_config.monitored_resource.type,
            resource_labels: logging_config.monitored_resource.labels,
            log_name: logging_config.log_name || Middleware::DEFAULT_LOG_NAME,
            use_logging: use_logging
          }
        end
      end
    end
  end
end
