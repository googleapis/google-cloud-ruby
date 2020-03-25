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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/monitoring/v3/service_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/monitoring/v3/service_service_pb"
require "google/cloud/monitoring/v3/credentials"
require "google/cloud/monitoring/version"

module Google
  module Cloud
    module Monitoring
      module V3
        # The Cloud Monitoring Service-Oriented Monitoring API has endpoints for
        # managing and querying aspects of a workspace's services. These include the
        # `Service`'s monitored resources, its Service-Level Objectives, and a taxonomy
        # of categorized Health Metrics.
        #
        # @!attribute [r] service_monitoring_service_stub
        #   @return [Google::Monitoring::V3::ServiceMonitoringService::Stub]
        class ServiceMonitoringServiceClient
          # @private
          attr_reader :service_monitoring_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "monitoring.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_services" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "services"),
            "list_service_level_objectives" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "service_level_objectives")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/monitoring.read",
            "https://www.googleapis.com/auth/monitoring.write"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          SERVICE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/services/{service}"
          )

          private_constant :SERVICE_PATH_TEMPLATE

          SERVICE_LEVEL_OBJECTIVE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/services/{service}/serviceLevelObjectives/{service_level_objective}"
          )

          private_constant :SERVICE_LEVEL_OBJECTIVE_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified service resource name string.
          # @param project [String]
          # @param service [String]
          # @return [String]
          def self.service_path project, service
            SERVICE_PATH_TEMPLATE.render(
              :"project" => project,
              :"service" => service
            )
          end

          # Returns a fully-qualified service_level_objective resource name string.
          # @param project [String]
          # @param service [String]
          # @param service_level_objective [String]
          # @return [String]
          def self.service_level_objective_path project, service, service_level_objective
            SERVICE_LEVEL_OBJECTIVE_PATH_TEMPLATE.render(
              :"project" => project,
              :"service" => service,
              :"service_level_objective" => service_level_objective
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/monitoring/v3/service_service_services_pb"

            credentials ||= Google::Cloud::Monitoring::V3::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Monitoring::V3::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Google::Cloud::Monitoring::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "service_monitoring_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.monitoring.v3.ServiceMonitoringService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @service_monitoring_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Monitoring::V3::ServiceMonitoringService::Stub.method(:new)
            )

            @create_service = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:create_service),
              defaults["create_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_service = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:get_service),
              defaults["get_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_services = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:list_services),
              defaults["list_services"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_service = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:update_service),
              defaults["update_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'service.name' => request.service.name}
              end
            )
            @delete_service = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:delete_service),
              defaults["delete_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_service_level_objective = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:create_service_level_objective),
              defaults["create_service_level_objective"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_service_level_objective = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:get_service_level_objective),
              defaults["get_service_level_objective"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_service_level_objectives = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:list_service_level_objectives),
              defaults["list_service_level_objectives"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_service_level_objective = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:update_service_level_objective),
              defaults["update_service_level_objective"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'service_level_objective.name' => request.service_level_objective.name}
              end
            )
            @delete_service_level_objective = Google::Gax.create_api_call(
              @service_monitoring_service_stub.method(:delete_service_level_objective),
              defaults["delete_service_level_objective"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Create a `Service`.
          #
          # @param parent [String]
          #   Required. Resource name of the parent workspace. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]
          # @param service [Google::Monitoring::V3::Service | Hash]
          #   Required. The `Service` to create.
          #   A hash of the same form as `Google::Monitoring::V3::Service`
          #   can also be provided.
          # @param service_id [String]
          #   Optional. The Service id to use for this Service. If omitted, an id will be
          #   generated instead. Must match the pattern `[a-z0-9\-]+`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Service]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Service]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `service`:
          #   service = {}
          #   response = service_monitoring_client.create_service(formatted_parent, service)

          def create_service \
              parent,
              service,
              service_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              service: service,
              service_id: service_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateServiceRequest)
            @create_service.call(req, options, &block)
          end

          # Get the named `Service`.
          #
          # @param name [String]
          #   Required. Resource name of the `Service`. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Service]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Service]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
          #   response = service_monitoring_client.get_service(formatted_name)

          def get_service \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetServiceRequest)
            @get_service.call(req, options, &block)
          end

          # List `Service`s for this workspace.
          #
          # @param parent [String]
          #   Required. Resource name of the parent containing the listed services, either a
          #   project or a Monitoring Workspace. The formats are:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]
          #       workspaces/[HOST_PROJECT_ID_OR_NUMBER]
          # @param filter [String]
          #   A filter specifying what `Service`s to return. The filter currently
          #   supports the following fields:
          #
          #   * `identifier_case`
          #     * `app_engine.module_id`
          #       * `cloud_endpoints.service`
          #       * `cluster_istio.location`
          #       * `cluster_istio.cluster_name`
          #       * `cluster_istio.service_namespace`
          #       * `cluster_istio.service_name`
          #
          #       `identifier_case` refers to which option in the identifier oneof is
          #       populated. For example, the filter `identifier_case = "CUSTOM"` would match
          #       all services with a value for the `custom` field. Valid options are
          #       "CUSTOM", "APP_ENGINE", "CLOUD_ENDPOINTS", and "CLUSTER_ISTIO".
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::Service>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::Service>]
          #   An enumerable of Google::Monitoring::V3::Service instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   service_monitoring_client.list_services(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   service_monitoring_client.list_services(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_services \
              parent,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListServicesRequest)
            @list_services.call(req, options, &block)
          end

          # Update this `Service`.
          #
          # @param service [Google::Monitoring::V3::Service | Hash]
          #   Required. The `Service` to draw updates from.
          #   The given `name` specifies the resource to update.
          #   A hash of the same form as `Google::Monitoring::V3::Service`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   A set of field paths defining which fields to use for the update.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::Service]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::Service]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #
          #   # TODO: Initialize `service`:
          #   service = {}
          #   response = service_monitoring_client.update_service(service)

          def update_service \
              service,
              update_mask: nil,
              options: nil,
              &block
            req = {
              service: service,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::UpdateServiceRequest)
            @update_service.call(req, options, &block)
          end

          # Soft delete this `Service`.
          #
          # @param name [String]
          #   Required. Resource name of the `Service` to delete. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
          #   service_monitoring_client.delete_service(formatted_name)

          def delete_service \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteServiceRequest)
            @delete_service.call(req, options, &block)
            nil
          end

          # Create a `ServiceLevelObjective` for the given `Service`.
          #
          # @param parent [String]
          #   Required. Resource name of the parent `Service`. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]
          # @param service_level_objective [Google::Monitoring::V3::ServiceLevelObjective | Hash]
          #   Required. The `ServiceLevelObjective` to create.
          #   The provided `name` will be respected if no `ServiceLevelObjective` exists
          #   with this name.
          #   A hash of the same form as `Google::Monitoring::V3::ServiceLevelObjective`
          #   can also be provided.
          # @param service_level_objective_id [String]
          #   Optional. The ServiceLevelObjective id to use for this
          #   ServiceLevelObjective. If omitted, an id will be generated instead. Must
          #   match the pattern `[a-z0-9\-]+`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::ServiceLevelObjective]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::ServiceLevelObjective]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
          #
          #   # TODO: Initialize `service_level_objective`:
          #   service_level_objective = {}
          #   response = service_monitoring_client.create_service_level_objective(formatted_parent, service_level_objective)

          def create_service_level_objective \
              parent,
              service_level_objective,
              service_level_objective_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              service_level_objective: service_level_objective,
              service_level_objective_id: service_level_objective_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateServiceLevelObjectiveRequest)
            @create_service_level_objective.call(req, options, &block)
          end

          # Get a `ServiceLevelObjective` by name.
          #
          # @param name [String]
          #   Required. Resource name of the `ServiceLevelObjective` to get. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]/serviceLevelObjectives/[SLO_NAME]
          # @param view [Google::Monitoring::V3::ServiceLevelObjective::View]
          #   View of the `ServiceLevelObjective` to return. If `DEFAULT`, return the
          #   `ServiceLevelObjective` as originally defined. If `EXPLICIT` and the
          #   `ServiceLevelObjective` is defined in terms of a `BasicSli`, replace the
          #   `BasicSli` with a `RequestBasedSli` spelling out how the SLI is computed.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::ServiceLevelObjective]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::ServiceLevelObjective]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")
          #   response = service_monitoring_client.get_service_level_objective(formatted_name)

          def get_service_level_objective \
              name,
              view: nil,
              options: nil,
              &block
            req = {
              name: name,
              view: view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetServiceLevelObjectiveRequest)
            @get_service_level_objective.call(req, options, &block)
          end

          # List the `ServiceLevelObjective`s for the given `Service`.
          #
          # @param parent [String]
          #   Required. Resource name of the parent containing the listed SLOs, either a
          #   project or a Monitoring Workspace. The formats are:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]
          #       workspaces/[HOST_PROJECT_ID_OR_NUMBER]/services/-
          # @param filter [String]
          #   A filter specifying what `ServiceLevelObjective`s to return.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param view [Google::Monitoring::V3::ServiceLevelObjective::View]
          #   View of the `ServiceLevelObjective`s to return. If `DEFAULT`, return each
          #   `ServiceLevelObjective` as originally defined. If `EXPLICIT` and the
          #   `ServiceLevelObjective` is defined in terms of a `BasicSli`, replace the
          #   `BasicSli` with a `RequestBasedSli` spelling out how the SLI is computed.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::ServiceLevelObjective>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::ServiceLevelObjective>]
          #   An enumerable of Google::Monitoring::V3::ServiceLevelObjective instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
          #
          #   # Iterate over all results.
          #   service_monitoring_client.list_service_level_objectives(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   service_monitoring_client.list_service_level_objectives(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_service_level_objectives \
              parent,
              filter: nil,
              page_size: nil,
              view: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size,
              view: view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListServiceLevelObjectivesRequest)
            @list_service_level_objectives.call(req, options, &block)
          end

          # Update the given `ServiceLevelObjective`.
          #
          # @param service_level_objective [Google::Monitoring::V3::ServiceLevelObjective | Hash]
          #   Required. The `ServiceLevelObjective` to draw updates from.
          #   The given `name` specifies the resource to update.
          #   A hash of the same form as `Google::Monitoring::V3::ServiceLevelObjective`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   A set of field paths defining which fields to use for the update.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Monitoring::V3::ServiceLevelObjective]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Monitoring::V3::ServiceLevelObjective]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #
          #   # TODO: Initialize `service_level_objective`:
          #   service_level_objective = {}
          #   response = service_monitoring_client.update_service_level_objective(service_level_objective)

          def update_service_level_objective \
              service_level_objective,
              update_mask: nil,
              options: nil,
              &block
            req = {
              service_level_objective: service_level_objective,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::UpdateServiceLevelObjectiveRequest)
            @update_service_level_objective.call(req, options, &block)
          end

          # Delete the given `ServiceLevelObjective`.
          #
          # @param name [String]
          #   Required. Resource name of the `ServiceLevelObjective` to delete. The format is:
          #
          #       projects/[PROJECT_ID_OR_NUMBER]/services/[SERVICE_ID]/serviceLevelObjectives/[SLO_NAME]
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   service_monitoring_client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")
          #   service_monitoring_client.delete_service_level_objective(formatted_name)

          def delete_service_level_objective \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteServiceLevelObjectiveRequest)
            @delete_service_level_objective.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
