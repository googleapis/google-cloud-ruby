# Copyright 2017 Google LLC
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


require "google/cloud/error_reporting"

module Google
  module Cloud
    module ErrorReporting
      ##
      # # Railtie
      #
      # Google::Cloud::ErrorReporting::Railtie automatically add the
      # {Google::Cloud::ErrorReporting::Middleware} to Rack in a Rails
      # environment. It will automatically capture Exceptions from the Rails app
      # and report them to the Stackdriver Error Reporting service.
      #
      # The Middleware is only added when certain conditions are met. See
      # {Railtie.use_error_reporting?} for detail.
      #
      # When loaded, the {Google::Cloud::ErrorReporting::Middleware} will be
      # inserted after ActionDispatch::DebugExceptions or
      # ActionDispatch::ShowExceptions Middleware, which allows it to intercept
      # and handle all Exceptions without interfering with Rails's normal error
      # pages.
      # See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
      # on how to configure the Railtie and Middleware.
      #
      class Railtie < ::Rails::Railtie
        config.google_cloud = ActiveSupport::OrderedOptions.new unless
                                config.respond_to? :google_cloud
        config.google_cloud.error_reporting = ActiveSupport::OrderedOptions.new

        initializer "Google.Cloud.ErrorReporting" do |app|
          self.class.consolidate_rails_config app.config

          self.class.init_middleware app if Cloud.configure.use_error_reporting
        end

        ##
        # @private Init Error Reporting integration for Rails. Setup
        # configuration and insert the Middleware.
        def self.init_middleware app
          # In later versions of Rails, ActionDispatch::DebugExceptions is
          # responsible for catching exceptions. But it didn't exist until
          # Rails 3.2. So we use ShowExceptions as fallback for earlier Rails.
          rails_exception_middleware =
            if defined? ::ActionDispatch::DebugExceptions
              ::ActionDispatch::DebugExceptions
            else
              ::ActionDispatch::ShowExceptions
            end

          app.middleware.insert_after rails_exception_middleware,
                                      Google::Cloud::ErrorReporting::Middleware
        end

        ##
        # @private Consolidate Rails configuration into Error Reporting
        # instrumentation configuration. Also consolidate the
        # `use_error_reporting` setting by verifying credentials and Rails
        # environment. The `use_error_reporting` setting will be true if
        # credentials are valid, and the setting is manually set to true or
        # Rails is in production environment.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        def self.consolidate_rails_config config
          merge_rails_config config

          init_default_config

          # Done if Google::Cloud.configure.use_error_reporting is explicitly
          # false
          return if Google::Cloud.configure.use_error_reporting == false

          # Verify credentials and set use_error_reporting to false if
          # credentials are invalid
          unless valid_credentials? ErrorReporting.configure.project_id,
                                    ErrorReporting.configure.keyfile
            Cloud.configure.use_error_reporting = false
            return
          end

          # Otherwise set use_error_reporting to true if Rails is running in
          # production
          Google::Cloud.configure.use_error_reporting ||= Rails.env.production?
        end

        ##
        # @private Merge Rails configuration into Error Reporting
        # instrumentation configuration.
        def self.merge_rails_config rails_config
          gcp_config = rails_config.google_cloud
          er_config = gcp_config.error_reporting

          Cloud.configure.use_error_reporting ||= gcp_config.use_error_reporting
          ErrorReporting.configure do |config|
            config.project_id ||= er_config.project_id || gcp_config.project_id
            config.keyfile ||= er_config.keyfile || gcp_config.keyfile
            config.service_name ||= er_config.service_name
            config.service_version ||= er_config.service_version
            config.ignore_classes ||= er_config.ignore_classes
          end
        end

        ##
        # Fallback to default config values if config parameters not provided.
        def self.init_default_config
          config = ErrorReporting.configure
          config.project_id ||= ErrorReporting::Project.default_project_id
          config.service_name ||= ErrorReporting::Project.default_service_name
          config.service_version ||=
            ErrorReporting::Project.default_service_version
        end

        ##
        # @private Verify credentials
        def self.valid_credentials? project_id, credentials
          begin
            # if credentials is nil, get default
            credentials ||= ErrorReporting::Credentials.default
            # only create a new Credentials object if the val isn't one already
            unless credentials.is_a? Google::Auth::Credentials
              # if credentials is not a Credentials object, create one
              ErrorReporting::Credentials.new credentials
            end
          rescue => e
            STDOUT.puts "Note: Google::Cloud::ErrorReporting is disabled " \
              "because it failed to authorize with the service. (#{e.message})"
            return false
          end

          if project_id.to_s.empty?
            STDOUT.puts "Note: Google::Cloud::ErrorReporting is disabled " \
              "because the project ID could not be determined."
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
