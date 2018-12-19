# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
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
      DEFAULT_LOG_NAME = Middleware::DEFAULT_LOG_NAME

      ##
      # Railtie
      #
      # Adds the {Google::Cloud::Logging::Middleware} to Rack in a Rails
      # environment. The middleware will set `env['rack.logger']` to a
      # {Google::Cloud::Logging::Logger} instance to be used by the Rails
      # application.
      #
      # The middleware is loaded only when certain conditions are met. These
      # conditions are when the configuration
      # `Google::Cloud.configure.use_logging` (also available as
      # `Rails.application.config.google_cloud.use_logging` for a Rails
      # application) is set to `true`, or, if the configuration is left unset
      # but `Rails.env.production?` is `true`.
      #
      # When loaded, the {Google::Cloud::Logging::Middleware} will be inserted
      # before the `Rails::Rack::Logger Middleware`, which allows it to set the
      # `env['rack.logger']` in place of Rails's default logger.
      # See the [Configuration
      # Guide](https://googleapis.github.io/google-cloud-ruby/docs/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION)
      # on how to configure the Railtie and Middleware.
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
          self.class.consolidate_rails_config app.config

          self.class.init_middleware app if Cloud.configure.use_logging
        end

        ##
        # @private Init Logging integration for Rails. Setup configuration and
        # insert the Middleware.
        def self.init_middleware app
          project_id = Logging.configure.project_id
          credentials = Logging.configure.credentials
          resource_type = Logging.configure.monitored_resource.type
          resource_labels = Logging.configure.monitored_resource.labels
          log_name = Logging.configure.log_name
          labels = Logging.configure.labels

          logging = Google::Cloud::Logging.new project_id: project_id,
                                               credentials: credentials
          resource =
            Logging::Middleware.build_monitored_resource resource_type,
                                                         resource_labels

          Middleware.logger = logging.logger log_name, resource, labels
          # Set the default Rails logger
          if Logging.configure.set_default_logger_on_rails_init
            set_default_logger
          end
          app.middleware.insert_before Rails::Rack::Logger,
                                       Google::Cloud::Logging::Middleware,
                                       logger: Middleware.logger
        end

        ##
        # This should be called once the application determines that it is safe
        # to start background threads and open gRPC connections. It informs the
        # middleware system that it is safe to use Google Cloud Logging. This is
        # called during Rails initialization when the
        # `set_default_logger_on_rails_init` configuration is set.
        #
        # Generally, this matters if the application forks worker processes;
        # this method should be called only after workers are forked, since
        # threads and network connections interact badly with fork. For example,
        # when running Puma in [clustered
        # mode](https://github.com/puma/puma#clustered-mode), this method should
        # be called in an `on_worker_boot` block.
        #
        # If the application does no forking, this method can be called any time
        # early in the application initialization process. Or by setting the
        # `set_default_logger_on_rails_init` configuration.
        #
        # If the `set_default_logger_on_rails_init` configuration is not set,
        # and {Railtie.set_default_logger} is not called in a post-fork hook,
        # the default Rails logger object will not be set to use the Google
        # Cloud Logging Logger object. For best results, an application should
        # call this method at the appropriate time, such as a post-fork hook.
        #
        def self.set_default_logger
          return if Middleware.logger.nil?
          return if Rails.logger.is_a? Google::Cloud::Logging::Logger

          # configure the Middleware logger to use the same settings as Rails
          Middleware.logger.level = Rails.logger.level
          # TODO: are there more settings to be set here?

          # Replace the Rails default logger
          Rails.app.config.logger = Middleware.logger
          Rails.logger = Middleware.logger
        end

        ##
        # @private Consolidate Rails configuration into Logging instrumentation
        # configuration. Also consolidate the `use_logging` setting by verifying
        # credentials and Rails environment. The `use_logging` setting will be
        # true if credentials are valid, and the setting is manually set to true
        # or Rails is in production environment.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        def self.consolidate_rails_config config
          merge_rails_config config

          init_default_config

          # Done if Google::Cloud.configure.use_logging is explicitly false
          return if Google::Cloud.configure.use_logging == false

          # Verify credentials and set use_logging to false if
          # credentials are invalid
          unless valid_credentials? Logging.configure.project_id,
                                    Logging.configure.keyfile
            Cloud.configure.use_logging = false
            return
          end

          # Otherwise set use_logging to true if Rails is running in production
          Google::Cloud.configure.use_logging ||= Rails.env.production?
        end

        ##
        # @private Merge Rails configuration into Logging instrumentation
        # configuration.
        def self.merge_rails_config rails_config # rubocop:disable AbcSize
          gcp_config = rails_config.google_cloud
          log_config = gcp_config.logging

          if Cloud.configure.use_logging.nil?
            Cloud.configure.use_logging = gcp_config.use_logging
          end
          Logging.configure do |config|
            config.project_id ||= config.project
            config.project_id ||= log_config.project_id || log_config.project
            config.project_id ||= gcp_config.project_id || gcp_config.project
            config.credentials ||= config.keyfile
            config.credentials ||= log_config.credentials || log_config.keyfile
            config.credentials ||= gcp_config.credentials || gcp_config.keyfile
            config.log_name ||= log_config.log_name
            config.labels ||= log_config.labels
            config.log_name_map ||= log_config.log_name_map
            config.monitored_resource.type ||=
              log_config.monitored_resource.type
            config.monitored_resource.labels ||=
              log_config.monitored_resource.labels.to_h
            if config.set_default_logger_on_rails_init.nil?
              config.set_default_logger_on_rails_init = \
                log_config.set_default_logger_on_rails_init
            end
          end
        end

        ##
        # Fallback to default config values if config parameters not provided.
        def self.init_default_config
          Logging.configure.project_id ||= Logging.default_project_id
          Logging.configure.log_name ||= Middleware::DEFAULT_LOG_NAME
        end

        ##
        # @private Verify credentials
        def self.valid_credentials? project_id, credentials
          # Try authenticate authorize client API. Return false if unable to
          # authorize.
          begin
            # if credentials is nil, get default
            credentials ||= Logging::Credentials.default
            # only create a new Credentials object if the val isn't one already
            unless credentials.is_a? Google::Auth::Credentials
              # if credentials is not a Credentials object, create one
              Logging::Credentials.new credentials
            end
          rescue Exception => e
            STDOUT.puts "Note: Google::Cloud::Logging is disabled because " \
              "it failed to authorize with the service. (#{e.message}) " \
              "Falling back to the default Rails logger."
            return false
          end

          if project_id.to_s.empty?
            STDOUT.puts "Note: Google::Cloud::Logging is disabled because " \
              "the project ID could not be determined. " \
              "Falling back to the default Rails logger."
            return false
          end

          true
        end

        private_class_method :merge_rails_config,
                             :init_default_config,
                             :valid_credentials?
      end
    end
  end
end
