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

require "google/cloud/debugger"

module Google
  module Cloud
    module Debugger
      ##
      # # Railtie
      #
      # Google::Cloud::Debugger::Railtie automatically adds the
      # Google::Cloud::Debugger::Middleware to Rack in a Rails environment.
      #
      # The Middleware is only added when certain conditions are met. See
      # {Railtie.use_debugger?} for detail.
      #
      # When loaded, the Google::Cloud::Debugger::Middleware will be inserted
      # after the Rack::ETag Middleware, which is top of the Rack stack, closest
      # to the application code.
      #
      # The Railtie should also initialize a debugger to be used by the
      # middleware. The debugger can be configured using the following Rails
      # configuration:
      # ```ruby
      # # Explicitly enable or disable Stackdriver Debugger Agent
      # config.google_cloud.use_debugger = true
      # # Shared Google Cloud Platform project identifier
      # config.google_cloud.project_id = "gcloud-project"
      # # Google Cloud Platform project identifier for Stackdriver Debugger only
      # config.google_cloud.debugger.project_id = "debugger-project"
      # # Share Google Cloud authentication json file
      # config.google_cloud.keyfile = "/path/to/keyfile.json"
      # # Google Cloud authentication json file for Stackdriver Debugger only
      # config.google_cloud.debugger.keyfile = "/path/to/debugger/keyfile.json"
      # # Stackdriver Debugger Agent module name identifier
      # config.google_cloud.debugger.module_name = "my-ruby-app"
      # # Stackdriver Debugger Agent module version identifier
      # config.google_cloud.debugger.module_version = "v1"
      # ```
      #
      class Railtie < ::Rails::Railtie
        config.google_cloud = ::ActiveSupport::OrderedOptions.new unless
          config.key? :google_cloud
        config.google_cloud[:debugger] = ::ActiveSupport::OrderedOptions.new
        config.google_cloud.define_singleton_method :debugger do
          self[:debugger]
        end

        initializer "Stackdriver.Debugger" do |app|
          debugger_config = Railtie.parse_rails_config config

          project_id = debugger_config[:project_id]
          keyfile = debugger_config[:keyfile]
          module_name = debugger_config[:module_name]
          module_version = debugger_config[:module_version]

          debugger = Google::Cloud::Debugger.new project: project_id,
                                                 keyfile: keyfile,
                                                 module_name: module_name,
                                                 module_version: module_version

          if self.class.use_debugger? app.config
            app.middleware.insert_after Rack::ETag,
                                        Google::Cloud::Debugger::Middleware,
                                        debugger: debugger
          end
        end

        ##
        # Determine whether to use Stackdriver Debugger or not.
        #
        # Returns true if valid GCP project_id is provided and underneath API is
        # able to authenticate. Also either Rails needs to be in "production"
        # environment or config.stackdriver.use_debugger is explicitly true.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        # @return [Boolean] Whether to use Stackdriver Debugger
        #
        def self.use_debugger? config
          debugger_config = parse_rails_config config

          # Return false if config.stackdriver.use_debugger is explicitly false
          use_debugger = debugger_config[:use_debugger]
          return false if !use_debugger.nil? && !use_debugger

          # Try authenticate authorize client API. Return false if unable to
          # authorize.
          begin
            Google::Cloud::Debugger::Credentials.credentials_with_scope(
              debugger_config[:keyfile])
          rescue => e
            Rails.log "Google::Cloud::Debugger is not activated due to " \
              "authorization error: #{e.message}"
            return false
          end

          project_id = debugger_config[:project_id] ||
                       Google::Cloud::Debugger::Project.default_project
          if project_id.to_s.empty?
            Rails.log "Google::Cloud::Debugger is not activated due to empty " \
              "project_id"
            return false
          end

          # Otherwise default to true if Rails is running in production or
          # config.stackdriver.use_debugger is true
          Rails.env.production? || use_debugger
        end

        ##
        # @private Helper method to parse rails config into a flattened hash
        def self.parse_rails_config config
          gcp_config = config.google_cloud
          debugger_config = gcp_config[:debugger]
          use_debugger =
            gcp_config.key?(:use_debugger) ? gcp_config.use_debugger : nil
          {
            project_id: debugger_config.project_id || gcp_config.project_id,
            keyfile: debugger_config.keyfile || gcp_config.keyfile,
            module_name: debugger_config.module_name,
            module_version: debugger_config.module_version,
            use_debugger: use_debugger
          }
        end
      end
    end
  end
end
