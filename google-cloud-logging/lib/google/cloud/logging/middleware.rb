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


require "stackdriver/core"

module Google
  module Cloud
    module Logging
      class Middleware
        ##
        # The default log name used to instantiate the default logger if one
        # isn't provided.
        DEFAULT_LOG_NAME = "ruby_app_log".freeze

        ##
        # A default value for the log_name_map argument. Directs health check
        # logs to a separate log name so they don't spam the main log.
        DEFAULT_LOG_NAME_MAP =
          { "/_ah/health" => "ruby_health_check_log" }.freeze

        ##
        # The Google::Cloud::Logging::Logger instance
        attr_reader :logger

        ##
        # Create a new AppEngine logging Middleware.
        #
        # @param [Rack Application] app Rack application
        # @param [Google::Cloud::Logging::Logger] logger A logger to be used by
        #   this middleware. The middleware will be interacting with the logger
        #   to track Stackdriver request trace ID. It also properly sets
        #   env["rack.logger"] to this assigned logger for accessing. If not
        #   specified, a default logger with be used.
        # @param [Hash] *kwargs Hash of configuration settings. Used for
        #   backward API compatibility. See the [Configuration
        #   Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
        #   for the prefered way to set configuration parameters.
        #
        # @return [Google::Cloud::Logging::Middleware] A new
        #   Google::Cloud::Logging::Middleware instance
        #
        def initialize app, logger: nil, **kwargs
          @app = app

          load_config kwargs

          if logger
            @logger = logger
          else
            log_name = configuration.log_name
            logging = Logging.new project_id: configuration.project_id,
                                  credentials: configuration.credentials
            resource = Middleware.build_monitored_resource(
              configuration.monitored_resource.type,
              configuration.monitored_resource.labels
            )
            @logger = logging.logger log_name, resource
          end
        end

        ##
        # Rack middleware entry point. In most Rack based frameworks, a request
        # is served by one thread. So entry point, we associate the GCP request
        # trace_id with the current thread's object_id in logger. All the logs
        # written by logger beyond this point will carry this request's
        # trace_id. Untrack the trace_id with this thread upon exiting.
        #
        # @param [Hash] env Rack environment hash
        #
        # @return [Rack::Response] The response from downstream Rack app
        #
        def call env
          env["rack.logger"] = logger
          trace_id = get_trace_id env
          log_name = get_log_name env
          logger.add_request_info trace_id: trace_id, log_name: log_name,
                                  env: env
          begin
            @app.call env
          ensure
            logger.delete_request_info
          end
        end

        ##
        # Determine the trace ID for this request.
        #
        # @private
        # @param [Hash] env The Rack environment.
        # @return [String] The trace ID.
        #
        def get_trace_id env
          trace_context = Stackdriver::Core::TraceContext.parse_rack_env env
          trace_context.trace_id
        end

        ##
        # Determine the log name override for this request, if any.
        #
        # @private
        # @param [Hash] env The Rack environment.
        # @return [String, nil] The log name override, or `nil` if there is
        #     no override.
        #
        def get_log_name env
          log_name_map = configuration.log_name_map
          return nil unless log_name_map
          path = "#{env['SCRIPT_NAME']}#{env['PATH_INFO']}"
          path = "/#{path}" unless path.start_with? "/"
          log_name_map.each do |k, v|
            return v if k === path
          end
          nil
        end

        ##
        # Construct a monitored resource based on the given type and label if
        # both are provided. Otherwise, construct a default monitored resource
        # based on the current environment.
        #
        # @param [String] type Type of Google::Cloud::Logging::Resource
        # @param [Hash<String, String>] labels Metadata lebels of
        #   Google::Cloud::Logging::Resource
        #
        # @return [Google::Cloud::Logging::Resource] An Resource object with
        #   type and labels
        #
        # @see https://cloud.google.com/logging/docs/api/v2/resource-list
        #   Monitored Resources and Services
        #
        # @example If both type and labels are provided, it returns resource:
        #   rc = Google::Cloud::Logging::Middleware.build_monitored_resource(
        #          "aws_ec2_instance",
        #          {
        #            instance_id: "ec2-id",
        #            aws_account: "aws-id"
        #          }
        #        )
        #   rc.type   #=> "aws_ec2_instance"
        #   rc.labels #=> { instance_id: "ec2-id", aws_account: "aws-id" }
        #
        # @example If running from GAE, returns default resource:
        #   rc = Google::Cloud::Logging::Middleware.build_monitored_resource
        #   rc.type   #=> "gae_app"
        #   rc.labels # { module_id: [GAE module name],
        #             #   version_id: [GAE module version] }
        #
        # @example If running from GKE, returns default resource:
        #   rc = Google::Cloud::Logging::Middleware.build_monitored_resource
        #   rc.type   #=> "container"
        #   rc.labels # { cluster_name: [GKE cluster name],
        #             #   namespace_id: [GKE namespace_id] }
        #
        # @example If running from GCE, return default resource:
        #   rc = Google::Cloud::Logging::Middleware.build_monitored_resource
        #   rc.type   #=> "gce_instance"
        #   rc.labels # { instance_id: [GCE VM instance id],
        #             #   zone: [GCE vm group zone] }
        #
        # @example Otherwise default to generic "global" type:
        #   rc = Google::Cloud::Logging::Middleware.build_monitored_resource
        #   rc.type   #=> "global"
        #   rc.labels #=> {}
        #
        def self.build_monitored_resource type = nil, labels = nil
          if type && labels
            Google::Cloud::Logging::Resource.new.tap do |r|
              r.type = type
              r.labels = labels
            end
          else
            default_monitored_resource
          end
        end

        ##
        # @private Extract information from current environment and construct
        # the correct monitoring resource types and labels.
        #
        # @return [Google::Cloud::Logging::Resource] An Resource object with
        #   correct type and labels
        #
        # @see https://cloud.google.com/logging/docs/api/v2/resource-list
        #   Monitored Resources and Services
        #
        # @example If running from GAE, returns default resource:
        #   rc = Google::Cloud::Logging::Middleware.send \
        #          :default_monitored_resource
        #   rc.type   #=> "gae_app"
        #   rc.labels # { module_id: [GAE module name],
        #             #   version_id: [GAE module version] }
        #
        # @example If running from GKE, returns default resource:
        #   rc = Google::Cloud::Logging::Middleware.send \
        #          :default_monitored_resource
        #   rc.type   #=> "container"
        #   rc.labels # { cluster_name: [GKE cluster name],
        #             #   namespace_id: [GKE namespace_id] }
        #
        # @example If running from GCE, return default resource:
        #   rc = Google::Cloud::Logging::Middleware.send \
        #          :default_monitored_resource
        #   rc.type   #=> "gce_instance"
        #   rc.labels # { instance_id: [GCE VM instance id],
        #             #   zone: [GCE vm group zone] }
        #
        # @example Otherwise default to generic "global" type:
        #   rc = Google::Cloud::Logging::Middleware.send \
        #          :default_monitored_resource
        #   rc.type   #=> "global"
        #   rc.labels #=> {}
        #
        def self.default_monitored_resource
          type, labels =
            if Google::Cloud.env.app_engine?
              ["gae_app", {
                module_id: Google::Cloud.env.app_engine_service_id,
                version_id: Google::Cloud.env.app_engine_service_version
              }]
            elsif Google::Cloud.env.container_engine?
              ["container", {
                cluster_name: Google::Cloud.env.container_engine_cluster_name,
                namespace_id: \
                  Google::Cloud.env.container_engine_namespace_id || "default"
              }]
            elsif Google::Cloud.env.compute_engine?
              ["gce_instance", {
                instance_id: Google::Cloud.env.instance_name,
                zone: Google::Cloud.env.instance_zone
              }]
            else
              ["global", {}]
            end

          Google::Cloud::Logging::Resource.new.tap do |r|
            r.type = type
            r.labels = labels
          end
        end

        private_class_method :default_monitored_resource

        private

        ##
        # Consolidate configurations from various sources. Also set
        # instrumentation config parameters to default values if not set
        # already.
        #
        def load_config **kwargs
          configuration.project_id = kwargs[:project_id] ||
                                     kwargs[:project] ||
                                     configuration.project_id ||
                                     configuration.project
          configuration.credentials = kwargs[:credentials] ||
                                      kwargs[:keyfile] ||
                                      configuration.credentials ||
                                      configuration.keyfile
          configuration.log_name_map ||= kwargs[:log_name_map] ||
                                         configuration.log_name_map

          init_default_config
        end

        ##
        # Fallback to default configuration values if not defined already
        def init_default_config
          configuration.project_id ||= begin
            (Cloud.configure.project_id || Cloud.configure.project ||
             Logging.default_project_id)
          end
          configuration.credentials ||= \
            (Cloud.configure.credentials || Cloud.configure.keyfile)
          configuration.log_name ||= DEFAULT_LOG_NAME
          configuration.log_name_map ||= DEFAULT_LOG_NAME_MAP
        end

        ##
        # @private Get Google::Cloud::Logging.configure
        def configuration
          Google::Cloud::Logging.configure
        end
      end
    end
  end
end
