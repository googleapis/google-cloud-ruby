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


require "google/cloud/error_reporting"
require "google/cloud/error_reporting/middleware"

module Google
  module Cloud
    module ErrorReporting
      ##
      # Railtie
      #
      # Google::Cloud::ErrorReporting::Railtie automatically add the
      # Google::Cloud::ErrorReporting::Middleware to Rack in a Rails
      # environment. It will automatically capture Exceptions from the Rails app
      # and report them to Stackdriver Error Reporting.
      #
      # The Middleware is only added when certain conditions are met. See
      # {Railtie.use_error_reporting?} for detail.
      #
      # When loaded, the Google::Cloud::ErrorReporting::Middleware will be
      # inserted after ::ActionDispatch::DebugExceptions Middleware, which
      # allows it to actually rescue all Exceptions and throw it back up. The
      # middleware should also be initialized with correct gcp project_id,
      # keyfile, service_name, and service_version if they are defined in
      # Rails environment files as follow:
      #   config.google_cloud.project_id = "my-gcp-project"
      #   config.google_cloud.keyfile = "/path/to/secret.json"
      # or
      #   config.google_cloud.error_reporting.project_id = "my-gcp-project"
      #   config.google_cloud.error_reporting.keyfile = "/path/to/secret.json"
      #   config.google_cloud.error_reporting.service_name = "my-service-name"
      #   config.google_cloud.error_reporting.service_version = "v1"
      #
      class Railtie < ::Rails::Railtie
        config.google_cloud = ActiveSupport::OrderedOptions.new unless
                                config.respond_to? :google_cloud
        config.google_cloud.error_reporting = ActiveSupport::OrderedOptions.new

        initializer "Google.Cloud.ErrorReporting" do |app|
          use_error_reporting = self.class.use_error_reporting? app.config
          if use_error_reporting
            er_config = Railtie.parse_rails_config app.config

            project_id = er_config[:project_id]
            keyfile = er_config[:keyfile]
            service_name = er_config[:service_name]
            service_version = er_config[:service_version]

            # In later versions of Rails, ActionDispatch::DebugExceptions is
            # responsible for catching exceptions. But it didn't exist until
            # Rails 3.2. So we use ShowExceptions as pivot for earlier Rails.
            rails_exception_middleware =
              if defined? ::ActionDispatch::DebugExceptions
                ::ActionDispatch::DebugExceptions
              else
                ::ActionDispatch::ShowExceptions
              end

            error_reporting = ErrorReporting.new project: project_id,
                                                 keyfile: keyfile

            app.middleware.insert_after rails_exception_middleware,
                                        Middleware,
                                        project_id: project_id,
                                        keyfile: keyfile,
                                        error_reporting: error_reporting,
                                        service_name: service_name,
                                        service_version: service_version
          end

          Google::Cloud.configure.use_error_reporting = use_error_reporting
        end

        ##
        # Determine whether to use Stackdriver Error Reporting or not.
        #
        # Returns true if valid GCP project_id and keyfile are provided and
        # either Rails is in "production" environment or \
        # config.google_cloud.use_error_reporting is explicitly true. Otherwise
        # false.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        # @return [Boolean] Whether to use Stackdriver Error Reporting
        #
        def self.use_error_reporting? config
          er_config = Railtie.parse_rails_config config

          # Return false if config.google_cloud.use_error_reporting is
          # explicitly false
          use_error_reporting = er_config[:use_error_reporting]
          return false if use_error_reporting == false

          project_id = er_config[:project_id] ||
                       ErrorReporting::Project.default_project
          keyfile = er_config[:keyfile]

          # Check credentialing. Returns false if authorization errors are
          # rescued.
          begin
            ErrorReporting::Credentials.credentials_with_scope keyfile
          rescue StandardError => e
            STDOUT.puts "Note: Google::Cloud::ErrorReporting is disabled " \
              "because it failed to authorize with the service. (#{e.message})"
            return false
          end

          if project_id.to_s.empty?
            STDOUT.puts "Note: Google::Cloud::ErrorReporting is disabled " \
              "because the project ID could not be determined."
            return false
          end

          # Otherwise return true if Rails is running in production or
          # config.google_cloud.use_error_reporting is explicitly true
          Rails.env.production? || use_error_reporting || false
        end

        ##
        # @private Helper method to parse rails config into a flattened hash
        def self.parse_rails_config config
          gcp_config = config.google_cloud
          er_config = gcp_config.error_reporting
          if gcp_config.key?(:use_error_reporting)
            use_error_reporting = gcp_config.use_error_reporting
          else
            use_error_reporting = nil
          end

          {
            project_id: er_config.project_id || gcp_config.project_id,
            keyfile: er_config.keyfile || gcp_config.keyfile,
            service_name: er_config.service_name,
            service_version: er_config.service_version,
            use_error_reporting: use_error_reporting
          }
        end
      end
    end
  end
end
