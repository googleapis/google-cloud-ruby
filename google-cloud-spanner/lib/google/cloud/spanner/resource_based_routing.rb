# Copyright 2020 Google LLC
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


module Google
  module Cloud
    module Spanner
      ##
      # @private Helper module for resource based routing client.
      module ResourceBasedRouting
        # Check resource based routing is enabled or not.
        #
        # @return [Boolean]
        def resource_based_routing_enabled?
          return true if @enable_resource_based_routing

          ["TRUE", "true"].include? \
            ENV["GOOGLE_CLOUD_SPANNER_ENABLE_RESOURCE_BASED_ROUTING"]
        end

        protected

        # Returns a Service that uses the first endpoint uri for the instance.
        #
        # @return [Spanner::Service, nil] Returns service instance if instance
        #   endpoint uris present.
        def resource_based_routing_service
          instance = @project.instance @instance_id, fields: ["endpoint_uris"]
          return if instance.nil? || instance.endpoint_uris.empty?

          Spanner::Service.new \
            @project.project_id,
            @project.service.credentials,
            host: instance.endpoint_uris.first,
            timeout: @project.service.timeout,
            client_config: @project.service.client_config
        rescue Google::Cloud::PermissionDeniedError
          warn <<~WARN
            The client library attempted to connect to an endpoint
            closer to your Cloud Spanner data but was unable to do so.
            The client library will fallback and route requests to the
            endpoint given in the client options, which may result in
            increased latency. We recommend including the scope
            https://www.googleapis.com/auth/spanner.admin so that
            the client library can get an instance-specific endpoint
            and efficiently route requests.
          WARN
        end
      end
    end
  end
end
