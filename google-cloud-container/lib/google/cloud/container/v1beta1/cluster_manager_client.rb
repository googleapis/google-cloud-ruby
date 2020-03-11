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
# https://github.com/googleapis/googleapis/blob/master/google/container/v1beta1/cluster_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/container/v1beta1/cluster_service_pb"
require "google/cloud/container/v1beta1/credentials"
require "google/cloud/container/version"

module Google
  module Cloud
    module Container
      module V1beta1
        # Google Kubernetes Engine Cluster Manager v1beta1
        #
        # @!attribute [r] cluster_manager_stub
        #   @return [Google::Container::V1beta1::ClusterManager::Stub]
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

          PAGE_DESCRIPTORS = {
            "list_usable_subnetworks" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "subnetworks")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

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
            require "google/container/v1beta1/cluster_service_services_pb"

            credentials ||= Google::Cloud::Container::V1beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Container::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Container::VERSION

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
              "cluster_manager_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.container.v1beta1.ClusterManager",
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
            @cluster_manager_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Container::V1beta1::ClusterManager::Stub.method(:new)
            )

            @list_clusters = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_clusters),
              defaults["list_clusters"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_cluster),
              defaults["get_cluster"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:create_cluster),
              defaults["create_cluster"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_cluster),
              defaults["update_cluster"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_node_pool),
              defaults["update_node_pool"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_node_pool_autoscaling = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_autoscaling),
              defaults["set_node_pool_autoscaling"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_logging_service = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_logging_service),
              defaults["set_logging_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_monitoring_service = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_monitoring_service),
              defaults["set_monitoring_service"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_addons_config = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_addons_config),
              defaults["set_addons_config"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_locations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_locations),
              defaults["set_locations"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_master = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:update_master),
              defaults["update_master"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_master_auth = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_master_auth),
              defaults["set_master_auth"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @delete_cluster = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:delete_cluster),
              defaults["delete_cluster"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_operations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_operations),
              defaults["list_operations"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_operation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_operation),
              defaults["get_operation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @cancel_operation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:cancel_operation),
              defaults["cancel_operation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_server_config = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_server_config),
              defaults["get_server_config"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_node_pools = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_node_pools),
              defaults["list_node_pools"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:get_node_pool),
              defaults["get_node_pool"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:create_node_pool),
              defaults["create_node_pool"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_node_pool = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:delete_node_pool),
              defaults["delete_node_pool"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @rollback_node_pool_upgrade = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:rollback_node_pool_upgrade),
              defaults["rollback_node_pool_upgrade"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_node_pool_management = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_management),
              defaults["set_node_pool_management"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_labels = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_labels),
              defaults["set_labels"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_legacy_abac = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_legacy_abac),
              defaults["set_legacy_abac"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @start_ip_rotation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:start_ip_rotation),
              defaults["start_ip_rotation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @complete_ip_rotation = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:complete_ip_rotation),
              defaults["complete_ip_rotation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_node_pool_size = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_node_pool_size),
              defaults["set_node_pool_size"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_network_policy = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_network_policy),
              defaults["set_network_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_maintenance_policy = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:set_maintenance_policy),
              defaults["set_maintenance_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_usable_subnetworks = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_usable_subnetworks),
              defaults["list_usable_subnetworks"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_locations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_locations),
              defaults["list_locations"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
          end

          # Service calls

          # Lists all clusters owned by a project in either the specified zone or all
          # zones.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides, or "-" for all zones.
          #   This field has been deprecated and replaced by the parent field.
          # @param parent [String]
          #   The parent (project and location) where the clusters will be listed.
          #   Specified in the format 'projects/*/locations/*'.
          #   Location "-" matches all zones and all regions.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::ListClustersResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::ListClustersResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #   response = cluster_manager_client.list_clusters(project_id, zone)

          def list_clusters \
              project_id,
              zone,
              parent: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListClustersRequest)
            @list_clusters.call(req, options, &block)
          end

          # Gets the details for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to retrieve.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to retrieve.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Cluster]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Cluster]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #   response = cluster_manager_client.get_cluster(project_id, zone, cluster_id)

          def get_cluster \
              project_id,
              zone,
              cluster_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetClusterRequest)
            @get_cluster.call(req, options, &block)
          end

          # Creates a cluster, consisting of the specified number and type of Google
          # Compute Engine instances.
          #
          # By default, the cluster is created in the project's
          # [default network](https://cloud.google.com/compute/docs/networks-and-firewalls#networks).
          #
          # One firewall is added for the cluster. After cluster creation,
          # the Kubelet creates routes for each node to allow the containers
          # on that node to communicate with all other instances in the
          # cluster.
          #
          # Finally, an entry is added to the project's global metadata indicating
          # which CIDR range the cluster is using.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
          # @param cluster [Google::Container::V1beta1::Cluster | Hash]
          #   Required. A [cluster
          #   resource](/container-engine/reference/rest/v1beta1/projects.zones.clusters)
          #   A hash of the same form as `Google::Container::V1beta1::Cluster`
          #   can also be provided.
          # @param parent [String]
          #   The parent (project and location) where the cluster will be created.
          #   Specified in the format 'projects/*/locations/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster`:
          #   cluster = {}
          #   response = cluster_manager_client.create_cluster(project_id, zone, cluster)

          def create_cluster \
              project_id,
              zone,
              cluster,
              parent: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster: cluster,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CreateClusterRequest)
            @create_cluster.call(req, options, &block)
          end

          # Updates the settings for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param update [Google::Container::V1beta1::ClusterUpdate | Hash]
          #   Required. A description of the update.
          #   A hash of the same form as `Google::Container::V1beta1::ClusterUpdate`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to update.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `update`:
          #   update = {}
          #   response = cluster_manager_client.update_cluster(project_id, zone, cluster_id, update)

          def update_cluster \
              project_id,
              zone,
              cluster_id,
              update,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              update: update,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateClusterRequest)
            @update_cluster.call(req, options, &block)
          end

          # Updates the version and/or image type of a specific node pool.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param node_version [String]
          #   Required. The Kubernetes version to change the nodes to (typically an
          #   upgrade).
          #
          #   Users may specify either explicit versions offered by Kubernetes Engine or
          #   version aliases, which have the following behavior:
          #
          #   * "latest": picks the highest valid Kubernetes version
          #   * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
          #   * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
          #   * "1.X.Y-gke.N": picks an explicit Kubernetes version
          #   * "-": picks the Kubernetes master version
          # @param image_type [String]
          #   Required. The desired image type for the node pool.
          # @param workload_metadata_config [Google::Container::V1beta1::WorkloadMetadataConfig | Hash]
          #   The desired image type for the node pool.
          #   A hash of the same form as `Google::Container::V1beta1::WorkloadMetadataConfig`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster, node pool) of the node pool to
          #   update. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize `node_version`:
          #   node_version = ''
          #
          #   # TODO: Initialize `image_type`:
          #   image_type = ''
          #   response = cluster_manager_client.update_node_pool(project_id, zone, cluster_id, node_pool_id, node_version, image_type)

          def update_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              node_version,
              image_type,
              workload_metadata_config: nil,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              node_version: node_version,
              image_type: image_type,
              workload_metadata_config: workload_metadata_config,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateNodePoolRequest)
            @update_node_pool.call(req, options, &block)
          end

          # Sets the autoscaling settings of a specific node pool.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param autoscaling [Google::Container::V1beta1::NodePoolAutoscaling | Hash]
          #   Required. Autoscaling configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1beta1::NodePoolAutoscaling`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster, node pool) of the node pool to set
          #   autoscaler settings. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize `autoscaling`:
          #   autoscaling = {}
          #   response = cluster_manager_client.set_node_pool_autoscaling(project_id, zone, cluster_id, node_pool_id, autoscaling)

          def set_node_pool_autoscaling \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              autoscaling,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              autoscaling: autoscaling,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolAutoscalingRequest)
            @set_node_pool_autoscaling.call(req, options, &block)
          end

          # Sets the logging service for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param logging_service [String]
          #   Required. The logging service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "logging.googleapis.com" - the Google Cloud Logging service
          #   * "none" - no metrics will be exported from the cluster
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set logging.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `logging_service`:
          #   logging_service = ''
          #   response = cluster_manager_client.set_logging_service(project_id, zone, cluster_id, logging_service)

          def set_logging_service \
              project_id,
              zone,
              cluster_id,
              logging_service,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              logging_service: logging_service,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLoggingServiceRequest)
            @set_logging_service.call(req, options, &block)
          end

          # Sets the monitoring service for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param monitoring_service [String]
          #   Required. The monitoring service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "monitoring.googleapis.com" - the Google Cloud Monitoring service
          #   * "none" - no metrics will be exported from the cluster
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set monitoring.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `monitoring_service`:
          #   monitoring_service = ''
          #   response = cluster_manager_client.set_monitoring_service(project_id, zone, cluster_id, monitoring_service)

          def set_monitoring_service \
              project_id,
              zone,
              cluster_id,
              monitoring_service,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              monitoring_service: monitoring_service,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetMonitoringServiceRequest)
            @set_monitoring_service.call(req, options, &block)
          end

          # Sets the addons for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param addons_config [Google::Container::V1beta1::AddonsConfig | Hash]
          #   Required. The desired configurations for the various addons available to run in the
          #   cluster.
          #   A hash of the same form as `Google::Container::V1beta1::AddonsConfig`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set addons.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `addons_config`:
          #   addons_config = {}
          #   response = cluster_manager_client.set_addons_config(project_id, zone, cluster_id, addons_config)

          def set_addons_config \
              project_id,
              zone,
              cluster_id,
              addons_config,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              addons_config: addons_config,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetAddonsConfigRequest)
            @set_addons_config.call(req, options, &block)
          end

          # Sets the locations for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param locations [Array<String>]
          #   Required. The desired list of Google Compute Engine
          #   [zones](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
          #   should be located. Changing the locations a cluster is in will result
          #   in nodes being either created or removed from the cluster, depending on
          #   whether locations are being added or removed.
          #
          #   This list must always include the cluster's primary zone.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set locations.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `locations`:
          #   locations = []
          #   response = cluster_manager_client.set_locations(project_id, zone, cluster_id, locations)

          def set_locations \
              project_id,
              zone,
              cluster_id,
              locations,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              locations: locations,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLocationsRequest)
            @set_locations.call(req, options, &block)
          end

          # Updates the master for a specific cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param master_version [String]
          #   Required. The Kubernetes version to change the master to.
          #
          #   Users may specify either explicit versions offered by
          #   Kubernetes Engine or version aliases, which have the following behavior:
          #
          #   * "latest": picks the highest valid Kubernetes version
          #   * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
          #   * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
          #   * "1.X.Y-gke.N": picks an explicit Kubernetes version
          #   * "-": picks the default Kubernetes version
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to update.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `master_version`:
          #   master_version = ''
          #   response = cluster_manager_client.update_master(project_id, zone, cluster_id, master_version)

          def update_master \
              project_id,
              zone,
              cluster_id,
              master_version,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              master_version: master_version,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateMasterRequest)
            @update_master.call(req, options, &block)
          end

          # Sets master auth materials. Currently supports changing the admin password
          # or a specific cluster, either via password generation or explicitly setting
          # the password.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param action [Google::Container::V1beta1::SetMasterAuthRequest::Action]
          #   Required. The exact form of action to be taken on the master auth.
          # @param update [Google::Container::V1beta1::MasterAuth | Hash]
          #   Required. A description of the update.
          #   A hash of the same form as `Google::Container::V1beta1::MasterAuth`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set auth.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `action`:
          #   action = :UNKNOWN
          #
          #   # TODO: Initialize `update`:
          #   update = {}
          #   response = cluster_manager_client.set_master_auth(project_id, zone, cluster_id, action, update)

          def set_master_auth \
              project_id,
              zone,
              cluster_id,
              action,
              update,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              action: action,
              update: update,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetMasterAuthRequest)
            @set_master_auth.call(req, options, &block)
          end

          # Deletes the cluster, including the Kubernetes endpoint and all worker
          # nodes.
          #
          # Firewalls and routes that were configured during cluster creation
          # are also deleted.
          #
          # Other Google Compute Engine resources that might be in use by the cluster,
          # such as load balancer resources, are not deleted if they weren't present
          # when the cluster was initially created.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to delete.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to delete.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #   response = cluster_manager_client.delete_cluster(project_id, zone, cluster_id)

          def delete_cluster \
              project_id,
              zone,
              cluster_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::DeleteClusterRequest)
            @delete_cluster.call(req, options, &block)
          end

          # Lists all operations in a project in the specified zone or all zones.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for, or `-` for
          #   all zones. This field has been deprecated and replaced by the parent field.
          # @param parent [String]
          #   The parent (project and location) where the operations will be listed.
          #   Specified in the format 'projects/*/locations/*'.
          #   Location "-" matches all zones and all regions.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::ListOperationsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::ListOperationsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #   response = cluster_manager_client.list_operations(project_id, zone)

          def list_operations \
              project_id,
              zone,
              parent: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListOperationsRequest)
            @list_operations.call(req, options, &block)
          end

          # Gets the specified operation.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param operation_id [String]
          #   Required. Deprecated. The server-assigned `name` of the operation.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, operation id) of the operation to get.
          #   Specified in the format 'projects/*/locations/*/operations/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `operation_id`:
          #   operation_id = ''
          #   response = cluster_manager_client.get_operation(project_id, zone, operation_id)

          def get_operation \
              project_id,
              zone,
              operation_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              operation_id: operation_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetOperationRequest)
            @get_operation.call(req, options, &block)
          end

          # Cancels the specified operation.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the operation resides.
          #   This field has been deprecated and replaced by the name field.
          # @param operation_id [String]
          #   Required. Deprecated. The server-assigned `name` of the operation.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, operation id) of the operation to cancel.
          #   Specified in the format 'projects/*/locations/*/operations/*'.
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
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `operation_id`:
          #   operation_id = ''
          #   cluster_manager_client.cancel_operation(project_id, zone, operation_id)

          def cancel_operation \
              project_id,
              zone,
              operation_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              operation_id: operation_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CancelOperationRequest)
            @cancel_operation.call(req, options, &block)
            nil
          end

          # Returns configuration info about the Google Kubernetes Engine service.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project and location) of the server config to get,
          #   specified in the format 'projects/*/locations/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::ServerConfig]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::ServerConfig]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #   response = cluster_manager_client.get_server_config(project_id, zone)

          def get_server_config \
              project_id,
              zone,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetServerConfigRequest)
            @get_server_config.call(req, options, &block)
          end

          # Lists the node pools for a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the parent field.
          # @param parent [String]
          #   The parent (project, location, cluster id) where the node pools will be
          #   listed. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::ListNodePoolsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::ListNodePoolsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #   response = cluster_manager_client.list_node_pools(project_id, zone, cluster_id)

          def list_node_pools \
              project_id,
              zone,
              cluster_id,
              parent: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListNodePoolsRequest)
            @list_node_pools.call(req, options, &block)
          end

          # Retrieves the requested node pool.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to
          #   get. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::NodePool]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::NodePool]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #   response = cluster_manager_client.get_node_pool(project_id, zone, cluster_id, node_pool_id)

          def get_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetNodePoolRequest)
            @get_node_pool.call(req, options, &block)
          end

          # Creates a node pool for a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the parent field.
          # @param node_pool [Google::Container::V1beta1::NodePool | Hash]
          #   Required. The node pool to create.
          #   A hash of the same form as `Google::Container::V1beta1::NodePool`
          #   can also be provided.
          # @param parent [String]
          #   The parent (project, location, cluster id) where the node pool will be
          #   created. Specified in the format
          #   'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool`:
          #   node_pool = {}
          #   response = cluster_manager_client.create_node_pool(project_id, zone, cluster_id, node_pool)

          def create_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool,
              parent: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool: node_pool,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CreateNodePoolRequest)
            @create_node_pool.call(req, options, &block)
          end

          # Deletes a node pool from a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to delete.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to
          #   delete. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #   response = cluster_manager_client.delete_node_pool(project_id, zone, cluster_id, node_pool_id)

          def delete_node_pool \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::DeleteNodePoolRequest)
            @delete_node_pool.call(req, options, &block)
          end

          # Rolls back a previously Aborted or Failed NodePool upgrade.
          # This makes no changes if the last upgrade successfully completed.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to rollback.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to rollback.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node poll to
          #   rollback upgrade.
          #   Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #   response = cluster_manager_client.rollback_node_pool_upgrade(project_id, zone, cluster_id, node_pool_id)

          def rollback_node_pool_upgrade \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::RollbackNodePoolUpgradeRequest)
            @rollback_node_pool_upgrade.call(req, options, &block)
          end

          # Sets the NodeManagement options for a node pool.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to update.
          #   This field has been deprecated and replaced by the name field.
          # @param management [Google::Container::V1beta1::NodeManagement | Hash]
          #   Required. NodeManagement configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1beta1::NodeManagement`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to set
          #   management properties. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize `management`:
          #   management = {}
          #   response = cluster_manager_client.set_node_pool_management(project_id, zone, cluster_id, node_pool_id, management)

          def set_node_pool_management \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              management,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              management: management,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolManagementRequest)
            @set_node_pool_management.call(req, options, &block)
          end

          # Sets labels on a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param resource_labels [Hash{String => String}]
          #   Required. The labels to set for that cluster.
          # @param label_fingerprint [String]
          #   Required. The fingerprint of the previous set of labels for this resource,
          #   used to detect conflicts. The fingerprint is initially generated by
          #   Kubernetes Engine and changes after every request to modify or update
          #   labels. You must always provide an up-to-date fingerprint hash when
          #   updating or changing labels. Make a <code>get()</code> request to the
          #   resource to get the latest fingerprint.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set labels.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `resource_labels`:
          #   resource_labels = {}
          #
          #   # TODO: Initialize `label_fingerprint`:
          #   label_fingerprint = ''
          #   response = cluster_manager_client.set_labels(project_id, zone, cluster_id, resource_labels, label_fingerprint)

          def set_labels \
              project_id,
              zone,
              cluster_id,
              resource_labels,
              label_fingerprint,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              resource_labels: resource_labels,
              label_fingerprint: label_fingerprint,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLabelsRequest)
            @set_labels.call(req, options, &block)
          end

          # Enables or disables the ABAC authorization mechanism on a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
          # @param enabled [true, false]
          #   Required. Whether ABAC authorization will be enabled in the cluster.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set legacy abac.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `enabled`:
          #   enabled = false
          #   response = cluster_manager_client.set_legacy_abac(project_id, zone, cluster_id, enabled)

          def set_legacy_abac \
              project_id,
              zone,
              cluster_id,
              enabled,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              enabled: enabled,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLegacyAbacRequest)
            @set_legacy_abac.call(req, options, &block)
          end

          # Starts master IP rotation.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to start IP
          #   rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param rotate_credentials [true, false]
          #   Whether to rotate credentials during IP rotation.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #   response = cluster_manager_client.start_ip_rotation(project_id, zone, cluster_id)

          def start_ip_rotation \
              project_id,
              zone,
              cluster_id,
              name: nil,
              rotate_credentials: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              name: name,
              rotate_credentials: rotate_credentials
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::StartIPRotationRequest)
            @start_ip_rotation.call(req, options, &block)
          end

          # Completes master IP rotation.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to complete IP
          #   rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #   response = cluster_manager_client.complete_ip_rotation(project_id, zone, cluster_id)

          def complete_ip_rotation \
              project_id,
              zone,
              cluster_id,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CompleteIPRotationRequest)
            @complete_ip_rotation.call(req, options, &block)
          end

          # Sets the size for a specific node pool.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Required. Deprecated. The name of the node pool to update.
          #   This field has been deprecated and replaced by the name field.
          # @param node_count [Integer]
          #   Required. The desired node count for the pool.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to set
          #   size.
          #   Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `node_pool_id`:
          #   node_pool_id = ''
          #
          #   # TODO: Initialize `node_count`:
          #   node_count = 0
          #   response = cluster_manager_client.set_node_pool_size(project_id, zone, cluster_id, node_pool_id, node_count)

          def set_node_pool_size \
              project_id,
              zone,
              cluster_id,
              node_pool_id,
              node_count,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id,
              node_count: node_count,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolSizeRequest)
            @set_node_pool_size.call(req, options, &block)
          end

          # Enables or disables Network Policy for a cluster.
          #
          # @param project_id [String]
          #   Required. Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Required. Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Required. Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param network_policy [Google::Container::V1beta1::NetworkPolicy | Hash]
          #   Required. Configuration options for the NetworkPolicy feature.
          #   A hash of the same form as `Google::Container::V1beta1::NetworkPolicy`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set networking
          #   policy. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `network_policy`:
          #   network_policy = {}
          #   response = cluster_manager_client.set_network_policy(project_id, zone, cluster_id, network_policy)

          def set_network_policy \
              project_id,
              zone,
              cluster_id,
              network_policy,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              network_policy: network_policy,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNetworkPolicyRequest)
            @set_network_policy.call(req, options, &block)
          end

          # Sets the maintenance policy for a cluster.
          #
          # @param project_id [String]
          #   Required. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   Required. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   Required. The name of the cluster to update.
          # @param maintenance_policy [Google::Container::V1beta1::MaintenancePolicy | Hash]
          #   Required. The maintenance policy to be set for the cluster. An empty field
          #   clears the existing maintenance policy.
          #   A hash of the same form as `Google::Container::V1beta1::MaintenancePolicy`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set maintenance
          #   policy.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::Operation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `zone`:
          #   zone = ''
          #
          #   # TODO: Initialize `cluster_id`:
          #   cluster_id = ''
          #
          #   # TODO: Initialize `maintenance_policy`:
          #   maintenance_policy = {}
          #   response = cluster_manager_client.set_maintenance_policy(project_id, zone, cluster_id, maintenance_policy)

          def set_maintenance_policy \
              project_id,
              zone,
              cluster_id,
              maintenance_policy,
              name: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              maintenance_policy: maintenance_policy,
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetMaintenancePolicyRequest)
            @set_maintenance_policy.call(req, options, &block)
          end

          # Lists subnetworks that can be used for creating clusters in a project.
          #
          # @param parent [String]
          #   Required. The parent project where subnetworks are usable.
          #   Specified in the format 'projects/*'.
          # @param filter [String]
          #   Filtering currently only supports equality on the networkProjectId and must
          #   be in the form: "networkProjectId=[PROJECTID]", where `networkProjectId`
          #   is the project which owns the listed subnetworks. This defaults to the
          #   parent project ID.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Container::V1beta1::UsableSubnetwork>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Container::V1beta1::UsableSubnetwork>]
          #   An enumerable of Google::Container::V1beta1::UsableSubnetwork instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # Iterate over all results.
          #   cluster_manager_client.list_usable_subnetworks(parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cluster_manager_client.list_usable_subnetworks(parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_usable_subnetworks \
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
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListUsableSubnetworksRequest)
            @list_usable_subnetworks.call(req, options, &block)
          end

          # Fetches locations that offer Google Kubernetes Engine.
          #
          # @param parent [String]
          #   Required. Contains the name of the resource requested.
          #   Specified in the format 'projects/*'.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Container::V1beta1::ListLocationsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Container::V1beta1::ListLocationsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/container"
          #
          #   cluster_manager_client = Google::Cloud::Container.new(version: :v1beta1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #   response = cluster_manager_client.list_locations(parent)

          def list_locations \
              parent,
              options: nil,
              &block
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListLocationsRequest)
            @list_locations.call(req, options, &block)
          end
        end
      end
    end
  end
end
