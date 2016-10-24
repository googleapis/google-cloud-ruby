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


module Google
  module Cloud
    module Logging
      class Middleware
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
        #   env["rack.logger"] to this assigned logger for accessing.
        #
        # @return [Google::Cloud::Logging::Middleware] A new
        #   Google::Cloud::Logging::Middleware instance
        #
        def initialize app, logger: nil
          @app = app
          @logger = logger
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
          trace_id = extract_trace_id(env)
          logger.add_trace_id trace_id

          begin
            @app.call env
          ensure
            logger.delete_trace_id
          end
        end

        ##
        # Extract the trace_id from HTTP request header
        # HTTP_X_CLOUD_TRACE_CONTEXT.
        #
        # @return [String] The trace_id or nil if trace_id is empty.
        def extract_trace_id env
          trace_context = env["HTTP_X_CLOUD_TRACE_CONTEXT"].to_s
          return nil if trace_context.empty?
          trace_context.sub(%r{/.*}, "")
        end

        ##
        # Construct monitoring resource based on given type and label (both are
        # present). Otherwise construct a default monitoring resource based on
        # current environment.
        #
        # If not given both type and label:
        #   If running from GAE, return resource:
        #   {
        #     type: "gae_app", {
        #       module_id: [GAE module name],
        #       version_id: [GAE module version]
        #     }
        #   }
        #   If running from GKE, return resource:
        #   {
        #     type: "container", {
        #       cluster_name: [GKE cluster name],
        #       namespace_id: [GKE namespace_id]
        #     }
        #   }
        #   If running from GCE, return resource:
        #   {
        #     type: "gce_instance", {
        #       instance_id: [GCE VM instance id],
        #       zone: [GCE vm group zone]
        #     }
        #   }
        #   Otherwise default to { type: "global" }, which means not associated
        #   with GCP.
        #
        # Reference https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
        # for a full list of monitoring resources
        #
        # @param [String] type Type of Google::Cloud::Logging::Resource
        # @param [Hash<String, String>] labels Metadata lebels of
        #   Google::Cloud::Logging::Resource
        #
        # @return [Google::Cloud::Logging::Resource] An Resource object with
        #   type and labels
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
        def self.default_monitored_resource
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

        private_class_method :default_monitored_resource
      end
    end
  end
end
