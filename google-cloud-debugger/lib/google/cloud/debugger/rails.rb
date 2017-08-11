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
      # The Middleware is only added when the
      # `Google::Cloud.configure.use_debugger` setting is true or Rails is
      # in the production environment.
      #
      # When loaded, the Google::Cloud::Debugger::Middleware will be inserted
      # after the Rack::ETag Middleware, which is top of the Rack stack, closest
      # to the application code.
      #
      # The Railtie should also initialize a debugger to be used by the
      # Middleware. See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
      # on how to configure the Railtie and Middleware.
      #
      class Railtie < ::Rails::Railtie
        config.google_cloud = ::ActiveSupport::OrderedOptions.new unless
          config.respond_to? :google_cloud
        config.google_cloud[:debugger] = ::ActiveSupport::OrderedOptions.new
        config.google_cloud.define_singleton_method :debugger do
          self[:debugger]
        end

        initializer "Stackdriver.Debugger" do |app|
          self.class.consolidate_rails_config app.config

          self.class.init_middleware app if Cloud.configure.use_debugger
        end

        ##
        # @private Init Debugger integration for Rails. Setup configuration and
        # insert the Middleware.
        def self.init_middleware app
          app.middleware.insert_after Rack::ETag,
                                      Google::Cloud::Debugger::Middleware
        end

        ##
        # @private Consolidate Rails configuration into Debugger instrumentation
        # configuration. Also consolidate the `use_debugger` setting by
        # verifying credentials and Rails environment. The `use_debugger`
        # setting will be true if credentials are valid, and the setting is
        # manually set to true or Rails is in the production environment.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        def self.consolidate_rails_config config
          merge_rails_config config

          init_default_config

          # Done if Google::Cloud.configure.use_debugger is explicitly
          # false
          return if Google::Cloud.configure.use_debugger == false

          # Verify credentials and set use_debugger to false if
          # credentials are invalid
          unless valid_credentials? Debugger.configure.project_id,
                                    Debugger.configure.keyfile
            Cloud.configure.use_debugger = false
            return
          end

          # Otherwise set use_debugger to true if Rails is running in
          # the production environment
          Google::Cloud.configure.use_debugger ||= Rails.env.production?
        end

        ##
        # @private Merge Rails configuration into Debugger instrumentation
        # configuration.
        def self.merge_rails_config rails_config
          gcp_config = rails_config.google_cloud
          dbg_config = gcp_config.debugger

          Cloud.configure.use_debugger ||= gcp_config.use_debugger
          Debugger.configure do |config|
            config.project_id ||= dbg_config.project_id || gcp_config.project_id
            config.keyfile ||= dbg_config.keyfile || gcp_config.keyfile
            config.module_name ||= dbg_config.module_name
            config.module_version ||= dbg_config.module_version
          end
        end

        ##
        # Fallback to default config values if config parameters not provided.
        def self.init_default_config
          config = Debugger.configure
          config.project_id ||= Debugger::Project.default_project
          config.module_name ||= Debugger::Project.default_module_name
          config.module_version ||= Debugger::Project.default_module_version
        end

        ##
        # @private Verify credentials
        def self.valid_credentials? project_id, keyfile
          begin
            Debugger::Credentials.credentials_with_scope keyfile
          rescue => e
            STDOUT.puts "Note: Google::Cloud::Debugger is disabled because " \
              "it failed to authorize with the service. (#{e.message})"
            return false
          end

          if project_id.to_s.empty?
            STDOUT.puts "Note: Google::Cloud::Debugger is disabled because " \
              "the project ID could not be determined."
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
