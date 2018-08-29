# Copyright 2018 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/container/v1/cluster_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/container/v1/cluster_service_pb"
require "google/cloud/container/v1/credentials"

module Google
  module Cloud
    module Container
      module V1
        # Google Container Engine Cluster Manager v1
        #
        # @!attribute [r] cluster_manager_stub
        #   @return [Google::Container::V1::ClusterManager::Stub]
        class ClusterManagerClient
          # @private
          attr_reader :cluster_manager_stub

          # The default address of the service.
          SERVICE_ADDRESS = "container.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


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
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/container/v1/cluster_service_services_pb"

            credentials ||= Google::Cloud::Container::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Container::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-container'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "cluster_manager_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.container.v1.ClusterManager",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @cluster_manager_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Container::V1::ClusterManager::Stub.method(:new)
            )

            @list_clusters = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_clusters),
              defaults["list_clusters"],
              exception_transformer: exception_transformer
            )
            @get_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_cluster),
              defaults["get_cluster"],
              exception_transformer: exception_transformer
            )
            @create_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:create_cluster),
              defaults["create_cluster"],
              exception_transformer: exception_transformer
            )
            @update_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_cluster),
              defaults["update_cluster"],
              exception_transformer: exception_transformer
            )
            @update_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_node_pool),
              defaults["update_node_pool"],
              exception_transformer: exception_transformer
            )
            @set_node_pool_autoscaling = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_autoscaling),
              defaults["set_node_pool_autoscaling"],
              exception_transformer: exception_transformer
            )
            @set_logging_service = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_logging_service),
              defaults["set_logging_service"],
              exception_transformer: exception_transformer
            )
            @set_monitoring_service = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_monitoring_service),
              defaults["set_monitoring_service"],
              exception_transformer: exception_transformer
            )
            @set_addons_config = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_addons_config),
              defaults["set_addons_config"],
              exception_transformer: exception_transformer
            )
            @set_locations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_locations),
              defaults["set_locations"],
              exception_transformer: exception_transformer
            )
            @update_master = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_master),
              defaults["update_master"],
              exception_transformer: exception_transformer
            )
            @set_master_auth = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_master_auth),
              defaults["set_master_auth"],
              exception_transformer: exception_transformer
            )
            @delete_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:delete_cluster),
              defaults["delete_cluster"],
              exception_transformer: exception_transformer
            )
            @list_operations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_operations),
              defaults["list_operations"],
              exception_transformer: exception_transformer
            )
            @get_operation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_operation),
              defaults["get_operation"],
              exception_transformer: exception_transformer
            )
            @cancel_operation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:cancel_operation),
              defaults["cancel_operation"],
              exception_transformer: exception_transformer
            )
            @get_server_config = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_server_config),
              defaults["get_server_config"],
              exception_transformer: exception_transformer
            )
            @list_node_pools = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_node_pools),
              defaults["list_node_pools"],
              exception_transformer: exception_transformer
            )
            @get_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_node_pool),
              defaults["get_node_pool"],
              exception_transformer: exception_transformer
            )
            @create_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:create_node_pool),
              defaults["create_node_pool"],
              exception_transformer: exception_transformer
            )
            @delete_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:delete_node_pool),
              defaults["delete_node_pool"],
              exception_transformer: exception_transformer
            )
            @rollback_node_pool_upgrade = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:rollback_node_pool_upgrade),
              defaults["rollback_node_pool_upgrade"],
              exception_transformer: exception_transformer
            )
            @set_node_pool_management = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_management),
              defaults["set_node_pool_management"],
              exception_transformer: exception_transformer
            )
            @set_labels = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_labels),
              defaults["set_labels"],
              exception_transformer: exception_transformer
            )
            @set_legacy_abac = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_legacy_abac),
              defaults["set_legacy_abac"],
              exception_transformer: exception_transformer
            )
            @start_ip_rotation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:start_ip_rotation),
              defaults["start_ip_rotation"],
              exception_transformer: exception_transformer
            )
            @complete_ip_rotation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:complete_ip_rotation),
              defaults["complete_ip_rotation"],
              exception_transformer: exception_transformer
            )
            @set_node_pool_size = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_size),
              defaults["set_node_pool_size"],
              exception_transformer: exception_transformer
            )
            @set_network_policy = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_network_policy),
              defaults["set_network_policy"],
              exception_transformer: exception_transformer
            )
            @set_maintenance_policy = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_maintenance_policy),
              defaults["set_maintenance_policy"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists all clusters owned by a project in either the specified zone or all
          # zones.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides, or "-" for all zones.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::ListClustersResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::ListClustersResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #   response = cluster_manager_client.list_clusters(project_id, zone)

          def list_clusters \
              project_id,
              zone,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::ListClustersRequest)
            @list_clusters.call(req, options, &block)
          end

          # Gets the details of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to retrieve.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Cluster]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Cluster]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #   response = cluster_manager_client.get_cluster(project_id, zone, cluster_id)

          def get_cluster \
              project_id,
              zone,
              cluster_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::GetClusterRequest)
            @get_cluster.call(req, options, &block)
          end

          # Creates a cluster, consisting of the specified number and type of Google
          # Compute Engine instances.
          #
          # By default, the cluster is created in the project's
          # [default network](https://cloud.google.com/compute/docs/networks-and-firewalls#networks).
          #
          # One firewall is added for the cluster. After cluster creation,
          # the cluster creates routes for each node to allow the containers
          # on that node to communicate with all other instances in the
          # cluster.
          #
          # Finally, an entry is added to the project's global metadata indicating
          # which CIDR range is being used by the cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster [Google::Container::V1::Cluster | Hash]
          #   A [cluster
          #   resource](/container-engine/reference/rest/v1/projects.zones.clusters)
          #   A hash of the same form as `Google::Container::V1::Cluster`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster+:
          #   cluster = {}
          #   response = cluster_manager_client.create_cluster(project_id, zone, cluster)

          def create_cluster \
              project_id,
              zone,
              cluster,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster: cluster
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::CreateClusterRequest)
            @create_cluster.call(req, options, &block)
          end

          # Updates the settings of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param update [Google::Container::V1::ClusterUpdate | Hash]
          #   A description of the update.
          #   A hash of the same form as `Google::Container::V1::ClusterUpdate`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +update+:
          #   update = {}
          #   response = cluster_manager_client.update_cluster(project_id, zone, cluster_id, update)

          def update_cluster \
              project_id,
              zone,
              cluster_id,
              update,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              update: update
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::UpdateClusterRequest)
            @update_cluster.call(req, options, &block)
          end

          # Updates the version and/or image type of a specific node pool.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param node_pool_id [String]
          #   The name of the node pool to upgrade.
          # @param node_version [String]
          #   The Kubernetes version to change the nodes to (typically an
          #   upgrade). Use +-+ to upgrade to the latest version supported by
          #   the server.
          # @param image_type [String]
          #   The desired image type for the node pool.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize +node_version+:
          #   node_version = ''
          #
          #   # TODO: Initialize +image_type+:
          #   image_type = ''
          #   response = cluster_manager_client.update_node_pool(project_id, zone, cluster_id, node_pool_id, node_version, image_type)

          def update_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              node_version,
              image_type,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              node_version: node_version,
              image_type: image_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::UpdateNodePoolRequest)
            @update_node_pool.call(req, options, &block)
          end

          # Sets the autoscaling settings of a specific node pool.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param node_pool_id [String]
          #   The name of the node pool to upgrade.
          # @param autoscaling [Google::Container::V1::NodePoolAutoscaling | Hash]
          #   Autoscaling configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1::NodePoolAutoscaling`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize +autoscaling+:
          #   autoscaling = {}
          #   response = cluster_manager_client.set_node_pool_autoscaling(project_id, zone, cluster_id, node_pool_id, autoscaling)

          def set_node_pool_autoscaling \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              autoscaling,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              autoscaling: autoscaling
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetNodePoolAutoscalingRequest)
            @set_node_pool_autoscaling.call(req, options, &block)
          end

          # Sets the logging service of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param logging_service [String]
          #   The logging service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "logging.googleapis.com" - the Google Cloud Logging service
          #   * "none" - no metrics will be exported from the cluster
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +logging_service+:
          #   logging_service = ''
          #   response = cluster_manager_client.set_logging_service(project_id, zone, cluster_id, logging_service)

          def set_logging_service \
              project_id,
              zone,
              cluster_id,
              logging_service,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              logging_service: logging_service
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetLoggingServiceRequest)
            @set_logging_service.call(req, options, &block)
          end

          # Sets the monitoring service of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param monitoring_service [String]
          #   The monitoring service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "monitoring.googleapis.com" - the Google Cloud Monitoring service
          #   * "none" - no metrics will be exported from the cluster
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +monitoring_service+:
          #   monitoring_service = ''
          #   response = cluster_manager_client.set_monitoring_service(project_id, zone, cluster_id, monitoring_service)

          def set_monitoring_service \
              project_id,
              zone,
              cluster_id,
              monitoring_service,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              monitoring_service: monitoring_service
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetMonitoringServiceRequest)
            @set_monitoring_service.call(req, options, &block)
          end

          # Sets the addons of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param addons_config [Google::Container::V1::AddonsConfig | Hash]
          #   The desired configurations for the various addons available to run in the
          #   cluster.
          #   A hash of the same form as `Google::Container::V1::AddonsConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +addons_config+:
          #   addons_config = {}
          #   response = cluster_manager_client.set_addons_config(project_id, zone, cluster_id, addons_config)

          def set_addons_config \
              project_id,
              zone,
              cluster_id,
              addons_config,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              addons_config: addons_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetAddonsConfigRequest)
            @set_addons_config.call(req, options, &block)
          end

          # Sets the locations of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param locations [Array<String>]
          #   The desired list of Google Compute Engine
          #   [locations](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
          #   should be located. Changing the locations a cluster is in will result
          #   in nodes being either created or removed from the cluster, depending on
          #   whether locations are being added or removed.
          #
          #   This list must always include the cluster's primary zone.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +locations+:
          #   locations = []
          #   response = cluster_manager_client.set_locations(project_id, zone, cluster_id, locations)

          def set_locations \
              project_id,
              zone,
              cluster_id,
              locations,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              locations: locations
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetLocationsRequest)
            @set_locations.call(req, options, &block)
          end

          # Updates the master of a specific cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param master_version [String]
          #   The Kubernetes version to change the master to. The only valid value is the
          #   latest supported version. Use "-" to have the server automatically select
          #   the latest version.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +master_version+:
          #   master_version = ''
          #   response = cluster_manager_client.update_master(project_id, zone, cluster_id, master_version)

          def update_master \
              project_id,
              zone,
              cluster_id,
              master_version,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              master_version: master_version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::UpdateMasterRequest)
            @update_master.call(req, options, &block)
          end

          # Used to set master auth materials. Currently supports :-
          # Changing the admin password of a specific cluster.
          # This can be either via password generation or explicitly set the password.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to upgrade.
          # @param action [Google::Container::V1::SetMasterAuthRequest::Action]
          #   The exact form of action to be taken on the master auth.
          # @param update [Google::Container::V1::MasterAuth | Hash]
          #   A description of the update.
          #   A hash of the same form as `Google::Container::V1::MasterAuth`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +action+:
          #   action = :UNKNOWN
          #
          #   # TODO: Initialize +update+:
          #   update = {}
          #   response = cluster_manager_client.set_master_auth(project_id, zone, cluster_id, action, update)

          def set_master_auth \
              project_id,
              zone,
              cluster_id,
              action,
              update,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              action: action,
              update: update
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetMasterAuthRequest)
            @set_master_auth.call(req, options, &block)
          end

          # Deletes the cluster, including the Kubernetes endpoint and all worker
          # nodes.
          #
          # Firewalls and routes that were configured during cluster creation
          # are also deleted.
          #
          # Other Google Compute Engine resources that might be in use by the cluster
          # (e.g. load balancer resources) will not be deleted if they weren't present
          # at the initial create time.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #   response = cluster_manager_client.delete_cluster(project_id, zone, cluster_id)

          def delete_cluster \
              project_id,
              zone,
              cluster_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::DeleteClusterRequest)
            @delete_cluster.call(req, options, &block)
          end

          # Lists all operations in a project in a specific zone or all zones.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine [zone](https://cloud.google.com/compute/docs/zones#available)
          #   to return operations for, or +-+ for all zones.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::ListOperationsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::ListOperationsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #   response = cluster_manager_client.list_operations(project_id, zone)

          def list_operations \
              project_id,
              zone,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::ListOperationsRequest)
            @list_operations.call(req, options, &block)
          end

          # Gets the specified operation.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param operation_id [String]
          #   The server-assigned +name+ of the operation.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +operation_id+:
          #   operation_id = ''
          #   response = cluster_manager_client.get_operation(project_id, zone, operation_id)

          def get_operation \
              project_id,
              zone,
              operation_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              operation_id: operation_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::GetOperationRequest)
            @get_operation.call(req, options, &block)
          end

          # Cancels the specified operation.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the operation resides.
          # @param operation_id [String]
          #   The server-assigned +name+ of the operation.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +operation_id+:
          #   operation_id = ''
          #   cluster_manager_client.cancel_operation(project_id, zone, operation_id)

          def cancel_operation \
              project_id,
              zone,
              operation_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              operation_id: operation_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::CancelOperationRequest)
            @cancel_operation.call(req, options, &block)
            nil
          end

          # Returns configuration info about the Container Engine service.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine [zone](https://cloud.google.com/compute/docs/zones#available)
          #   to return operations for.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::ServerConfig]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::ServerConfig]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #   response = cluster_manager_client.get_server_config(project_id, zone)

          def get_server_config \
              project_id,
              zone,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::GetServerConfigRequest)
            @get_server_config.call(req, options, &block)
          end

          # Lists the node pools for a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::ListNodePoolsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::ListNodePoolsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #   response = cluster_manager_client.list_node_pools(project_id, zone, cluster_id)

          def list_node_pools \
              project_id,
              zone,
              cluster_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::ListNodePoolsRequest)
            @list_node_pools.call(req, options, &block)
          end

          # Retrieves the node pool requested.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param node_pool_id [String]
          #   The name of the node pool.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::NodePool]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::NodePool]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #   response = cluster_manager_client.get_node_pool(project_id, zone, cluster_id, node_pool_id)

          def get_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::GetNodePoolRequest)
            @get_node_pool.call(req, options, &block)
          end

          # Creates a node pool for a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param node_pool [Google::Container::V1::NodePool | Hash]
          #   The node pool to create.
          #   A hash of the same form as `Google::Container::V1::NodePool`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool+:
          #   node_pool = {}
          #   response = cluster_manager_client.create_node_pool(project_id, zone, cluster_id, node_pool)

          def create_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool: node_pool
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::CreateNodePoolRequest)
            @create_node_pool.call(req, options, &block)
          end

          # Deletes a node pool from a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param node_pool_id [String]
          #   The name of the node pool to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #   response = cluster_manager_client.delete_node_pool(project_id, zone, cluster_id, node_pool_id)

          def delete_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::DeleteNodePoolRequest)
            @delete_node_pool.call(req, options, &block)
          end

          # Roll back the previously Aborted or Failed NodePool upgrade.
          # This will be an no-op if the last upgrade successfully completed.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to rollback.
          # @param node_pool_id [String]
          #   The name of the node pool to rollback.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #   response = cluster_manager_client.rollback_node_pool_upgrade(project_id, zone, cluster_id, node_pool_id)

          def rollback_node_pool_upgrade \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::RollbackNodePoolUpgradeRequest)
            @rollback_node_pool_upgrade.call(req, options, &block)
          end

          # Sets the NodeManagement options for a node pool.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to update.
          # @param node_pool_id [String]
          #   The name of the node pool to update.
          # @param management [Google::Container::V1::NodeManagement | Hash]
          #   NodeManagement configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1::NodeManagement`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize +management+:
          #   management = {}
          #   response = cluster_manager_client.set_node_pool_management(project_id, zone, cluster_id, node_pool_id, management)

          def set_node_pool_management \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              management,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              management: management
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetNodePoolManagementRequest)
            @set_node_pool_management.call(req, options, &block)
          end

          # Sets labels on a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param resource_labels [Hash{String => String}]
          #   The labels to set for that cluster.
          # @param label_fingerprint [String]
          #   The fingerprint of the previous set of labels for this resource,
          #   used to detect conflicts. The fingerprint is initially generated by
          #   Container Engine and changes after every request to modify or update
          #   labels. You must always provide an up-to-date fingerprint hash when
          #   updating or changing labels. Make a <code>get()</code> request to the
          #   resource to get the latest fingerprint.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +resource_labels+:
          #   resource_labels = {}
          #
          #   # TODO: Initialize +label_fingerprint+:
          #   label_fingerprint = ''
          #   response = cluster_manager_client.set_labels(project_id, zone, cluster_id, resource_labels, label_fingerprint)

          def set_labels \
              project_id,
              zone,
              cluster_id,
              resource_labels,
              label_fingerprint,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              resource_labels: resource_labels,
              label_fingerprint: label_fingerprint
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetLabelsRequest)
            @set_labels.call(req, options, &block)
          end

          # Enables or disables the ABAC authorization mechanism on a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to update.
          # @param enabled [true, false]
          #   Whether ABAC authorization will be enabled in the cluster.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +enabled+:
          #   enabled = false
          #   response = cluster_manager_client.set_legacy_abac(project_id, zone, cluster_id, enabled)

          def set_legacy_abac \
              project_id,
              zone,
              cluster_id,
              enabled,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              enabled: enabled
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetLegacyAbacRequest)
            @set_legacy_abac.call(req, options, &block)
          end

          # Start master IP rotation.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #   response = cluster_manager_client.start_ip_rotation(project_id, zone, cluster_id)

          def start_ip_rotation \
              project_id,
              zone,
              cluster_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::StartIPRotationRequest)
            @start_ip_rotation.call(req, options, &block)
          end

          # Completes master IP rotation.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #   response = cluster_manager_client.complete_ip_rotation(project_id, zone, cluster_id)

          def complete_ip_rotation \
              project_id,
              zone,
              cluster_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::CompleteIPRotationRequest)
            @complete_ip_rotation.call(req, options, &block)
          end

          # Sets the size of a specific node pool.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to update.
          # @param node_pool_id [String]
          #   The name of the node pool to update.
          # @param node_count [Integer]
          #   The desired node count for the pool.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +node_pool_id+:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize +node_count+:
          #   node_count = 0
          #   response = cluster_manager_client.set_node_pool_size(project_id, zone, cluster_id, node_pool_id, node_count)

          def set_node_pool_size \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              node_count,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              node_count: node_count
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetNodePoolSizeRequest)
            @set_node_pool_size.call(req, options, &block)
          end

          # Enables/Disables Network Policy for a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster.
          # @param network_policy [Google::Container::V1::NetworkPolicy | Hash]
          #   Configuration options for the NetworkPolicy feature.
          #   A hash of the same form as `Google::Container::V1::NetworkPolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +network_policy+:
          #   network_policy = {}
          #   response = cluster_manager_client.set_network_policy(project_id, zone, cluster_id, network_policy)

          def set_network_policy \
              project_id,
              zone,
              cluster_id,
              network_policy,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              network_policy: network_policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetNetworkPolicyRequest)
            @set_network_policy.call(req, options, &block)
          end

          # Sets the maintenance policy for a cluster.
          #
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to update.
          # @param maintenance_policy [Google::Container::V1::MaintenancePolicy | Hash]
          #   The maintenance policy to be set for the cluster. An empty field
          #   clears the existing maintenance policy.
          #   A hash of the same form as `Google::Container::V1::MaintenancePolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +zone+:
          #   zone = ''
          #
          #   # TODO: Initialize +cluster_id+:
          #   cluster_id = ''
          #
          #   # TODO: Initialize +maintenance_policy+:
          #   maintenance_policy = {}
          #   response = cluster_manager_client.set_maintenance_policy(project_id, zone, cluster_id, maintenance_policy)

          def set_maintenance_policy \
              project_id,
              zone,
              cluster_id,
              maintenance_policy,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              maintenance_policy: maintenance_policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1::SetMaintenancePolicyRequest)
            @set_maintenance_policy.call(req, options, &block)
          end
        end
      end
    end
  end
end
