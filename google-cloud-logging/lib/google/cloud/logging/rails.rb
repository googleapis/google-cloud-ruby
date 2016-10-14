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

        initializer "Stackdriver.Logging", before: :initialize_logger do |app|
          if self.class.use_logging? app.config
            gcp_config = app.config.google_cloud
            log_config = gcp_config.logging

            project_id = log_config.project_id || gcp_config.project_id
            keyfile = log_config.keyfile || gcp_config.keyfile

            logging = Google::Cloud::Logging.new project: project_id,
                                                 keyfile: keyfile
            resource = self.class.build_monitoring_resource
            log_name = log_config.log_name || DEFAULT_LOG_NAME

            app.config.logger = Google::Cloud::Logging::Logger.new logging,
                                                                   log_name,
                                                                   resource
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
        # @param config The Rails.application.config
        #
        # @return [Boolean]
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
            warn "Unable to initialize Google::Cloud::Logging due " \
              "to authorization error: #{e.message}"
            return false
          end

          project_id = gcp_config.logging.project_id || gcp_config.project_id ||
                       Google::Cloud::Logging::Project.default_project
          if project_id.to_s.empty?
            warn "Unable to initialize Google::Cloud::Logging with empty " \
              "project_id"
            return false
          end

          # Otherwise default to true if Rails is running in production or
          # config.stackdriver.use_logging is explicitly true
          Rails.env.production? ||
            (gcp_config.key?(:use_logging) && gcp_config.use_logging)
        end

        ##
        # @private Extract information from current environment and construct
        # the correct monitoring resource types and labels.
        #
        # If running from GAE, return resource:
        # {
        #   type: "gae_app", {
        #     module_id: [GAE module name],
        #     version_id: [GAE module version]
        #   }
        # }
        # If running from GKE, return resource:
        # {
        #   type: "container", {
        #     cluster_name: [GKE cluster name],
        #     namespace_id: [GKE namespace_id]
        #   }
        # }
        # If running from GCE, return resource:
        # {
        #   type: "gce_instance", {
        #     instance_id: [GCE VM instance id],
        #     zone: [GCE vm group zone]
        #   }
        # }
        # Otherwise default to { type: "global" }, which means not associated
        # with GCP.
        #
        # Reference https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
        # for a full list of monitoring resources
        #
        # @return [Google::Cloud::Logging::Resource] An Resource object with
        #   correct type and labels
        def self.build_monitoring_resource
          type, labels =
            if Core::Environment.gae?
              ["gae_app", {
                module_id: Core::Environment.gae_module_id,
                version_id: Core::Environment.gae_module_version }]
            elsif Core::Environment.gke?
              ["container", {
                cluster_name: Core::Environment.gke_cluster_name,
                namespace_id: Core::Environment.gke_namespace_id || "default" }]
            elsif Core::Environment.gce?
              ["gce_instance", {
                instance_id: Core::Environment.instance_id,
                zone: Core::Environment.instance_zone }]
            else
              ["global", {}]
            end

          Google::Cloud::Logging::Resource.new.tap do |r|
            r.type = type
            r.labels = labels
          end
        end
      end
    end
  end
end
