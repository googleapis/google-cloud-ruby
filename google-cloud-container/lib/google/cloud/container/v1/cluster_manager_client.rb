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
# https://github.com/googleapis/googleapis/blob/master/google/container/v1beta1/cluster_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/container/v1beta1/cluster_service_pb"
require "google/cloud/container/v1/credentials"

module Google
  module Cloud
    module Container
      module V1
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


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          CLUSTER_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/clusters/{cluster}"
          )

          private_constant :CLUSTER_PATH_TEMPLATE

          NODE_POOL_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/clusters/{cluster}/nodePools/{node_pool}"
          )

          private_constant :NODE_POOL_PATH_TEMPLATE

          OPERATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/operations/{operation}"
          )

          private_constant :OPERATION_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified location resource name string.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def self.location_path project, location
            LOCATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location
            )
          end

          # Returns a fully-qualified cluster resource name string.
          # @param project [String]
          # @param location [String]
          # @param cluster [String]
          # @return [String]
          def self.cluster_path project, location, cluster
            CLUSTER_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"cluster" => cluster
            )
          end

          # Returns a fully-qualified node_pool resource name string.
          # @param project [String]
          # @param location [String]
          # @param cluster [String]
          # @param node_pool [String]
          # @return [String]
          def self.node_pool_path project, location, cluster, node_pool
            NODE_POOL_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"cluster" => cluster,
              :"node_pool" => node_pool
            )
          end

          # Returns a fully-qualified operation resource name string.
          # @param project [String]
          # @param location [String]
          # @param operation [String]
          # @return [String]
          def self.operation_path project, location, operation
            OPERATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"operation" => operation
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
            require "google/container/v1beta1/cluster_service_services_pb"

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
              &Google::Container::V1beta1::ClusterManager::Stub.method(:new)
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
            @list_usable_subnetworks = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_usable_subnetworks),
              defaults["list_usable_subnetworks"],
              exception_transformer: exception_transformer
            )
            @list_locations = Google::Gax.create_api_call(
              @cluster_manager_stub.method(:list_locations),
              defaults["list_locations"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists all clusters owned by a project in either the specified zone or all
          # zones.
          #
          # @param parent [String]
          #   The parent (project and location) where the clusters will be listed.
          #   Specified in the format 'projects/*/locations/*'.
          #   Location "-" matches all zones and all regions.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides, or "-" for all zones.
          #   This field has been deprecated and replaced by the parent field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = cluster_manager_client.list_clusters(formatted_parent)

          def list_clusters \
              parent,
              project_id: nil,
              zone: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListClustersRequest)
            @list_clusters.call(req, options, &block)
          end

          # Gets the details for a specific cluster.
          #
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to retrieve.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to retrieve.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.get_cluster(formatted_name)

          def get_cluster \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
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
          # the cluster creates routes for each node to allow the containers
          # on that node to communicate with all other instances in the
          # cluster.
          #
          # Finally, an entry is added to the project's global metadata indicating
          # which CIDR range is being used by the cluster.
          #
          # @param cluster [Google::Container::V1beta1::Cluster | Hash]
          #   A [cluster
          #   resource](/container-engine/reference/rest/v1beta1/projects.zones.clusters)
          #   A hash of the same form as `Google::Container::V1beta1::Cluster`
          #   can also be provided.
          # @param parent [String]
          #   The parent (project and location) where the cluster will be created.
          #   Specified in the format 'projects/*/locations/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `cluster`:
          #   cluster = {}
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = cluster_manager_client.create_cluster(cluster, formatted_parent)

          def create_cluster \
              cluster,
              parent,
              project_id: nil,
              zone: nil,
              options: nil,
              &block
            req = {
              cluster: cluster,
              parent: parent,
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CreateClusterRequest)
            @create_cluster.call(req, options, &block)
          end

          # Updates the settings for a specific cluster.
          #
          # @param update [Google::Container::V1beta1::ClusterUpdate | Hash]
          #   A description of the update.
          #   A hash of the same form as `Google::Container::V1beta1::ClusterUpdate`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to update.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `update`:
          #   update = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.update_cluster(update, formatted_name)

          def update_cluster \
              update,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              update: update,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateClusterRequest)
            @update_cluster.call(req, options, &block)
          end

          # Updates the version and/or image type of a specific node pool.
          #
          # @param node_version [String]
          #   The Kubernetes version to change the nodes to (typically an
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
          #   The desired image type for the node pool.
          # @param name [String]
          #   The name (project, location, cluster, node pool) of the node pool to
          #   update. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `node_version`:
          #   node_version = ''
          #
          #   # TODO: Initialize `image_type`:
          #   image_type = ''
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.update_node_pool(node_version, image_type, formatted_name)

          def update_node_pool \
              node_version,
              image_type,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              node_version: node_version,
              image_type: image_type,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateNodePoolRequest)
            @update_node_pool.call(req, options, &block)
          end

          # Sets the autoscaling settings of a specific node pool.
          #
          # @param autoscaling [Google::Container::V1beta1::NodePoolAutoscaling | Hash]
          #   Autoscaling configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1beta1::NodePoolAutoscaling`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster, node pool) of the node pool to set
          #   autoscaler settings. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `autoscaling`:
          #   autoscaling = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.set_node_pool_autoscaling(autoscaling, formatted_name)

          def set_node_pool_autoscaling \
              autoscaling,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              autoscaling: autoscaling,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolAutoscalingRequest)
            @set_node_pool_autoscaling.call(req, options, &block)
          end

          # Sets the logging service for a specific cluster.
          #
          # @param logging_service [String]
          #   The logging service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "logging.googleapis.com" - the Google Cloud Logging service
          #   * "none" - no metrics will be exported from the cluster
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set logging.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `logging_service`:
          #   logging_service = ''
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_logging_service(logging_service, formatted_name)

          def set_logging_service \
              logging_service,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              logging_service: logging_service,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLoggingServiceRequest)
            @set_logging_service.call(req, options, &block)
          end

          # Sets the monitoring service for a specific cluster.
          #
          # @param monitoring_service [String]
          #   The monitoring service the cluster should use to write metrics.
          #   Currently available options:
          #
          #   * "monitoring.googleapis.com" - the Google Cloud Monitoring service
          #   * "none" - no metrics will be exported from the cluster
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set monitoring.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `monitoring_service`:
          #   monitoring_service = ''
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_monitoring_service(monitoring_service, formatted_name)

          def set_monitoring_service \
              monitoring_service,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              monitoring_service: monitoring_service,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetMonitoringServiceRequest)
            @set_monitoring_service.call(req, options, &block)
          end

          # Sets the addons for a specific cluster.
          #
          # @param addons_config [Google::Container::V1beta1::AddonsConfig | Hash]
          #   The desired configurations for the various addons available to run in the
          #   cluster.
          #   A hash of the same form as `Google::Container::V1beta1::AddonsConfig`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set addons.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `addons_config`:
          #   addons_config = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_addons_config(addons_config, formatted_name)

          def set_addons_config \
              addons_config,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              addons_config: addons_config,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetAddonsConfigRequest)
            @set_addons_config.call(req, options, &block)
          end

          # Sets the locations for a specific cluster.
          #
          # @param locations [Array<String>]
          #   The desired list of Google Compute Engine
          #   [locations](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
          #   should be located. Changing the locations a cluster is in will result
          #   in nodes being either created or removed from the cluster, depending on
          #   whether locations are being added or removed.
          #
          #   This list must always include the cluster's primary zone.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set locations.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `locations`:
          #   locations = []
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_locations(locations, formatted_name)

          def set_locations \
              locations,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              locations: locations,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLocationsRequest)
            @set_locations.call(req, options, &block)
          end

          # Updates the master for a specific cluster.
          #
          # @param master_version [String]
          #   The Kubernetes version to change the master to.
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
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `master_version`:
          #   master_version = ''
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.update_master(master_version, formatted_name)

          def update_master \
              master_version,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              master_version: master_version,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::UpdateMasterRequest)
            @update_master.call(req, options, &block)
          end

          # Used to set master auth materials. Currently supports :-
          # Changing the admin password for a specific cluster.
          # This can be either via password generation or explicitly set.
          # Modify basic_auth.csv and reset the K8S API server.
          #
          # @param action [Google::Container::V1beta1::SetMasterAuthRequest::Action]
          #   The exact form of action to be taken on the master auth.
          # @param update [Google::Container::V1beta1::MasterAuth | Hash]
          #   A description of the update.
          #   A hash of the same form as `Google::Container::V1beta1::MasterAuth`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to set auth.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to upgrade.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `action`:
          #   action = :UNKNOWN
          #
          #   # TODO: Initialize `update`:
          #   update = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_master_auth(action, update, formatted_name)

          def set_master_auth \
              action,
              update,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              action: action,
              update: update,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
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
          # Other Google Compute Engine resources that might be in use by the cluster
          # (e.g. load balancer resources) will not be deleted if they weren't present
          # at the initial create time.
          #
          # @param name [String]
          #   The name (project, location, cluster) of the cluster to delete.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to delete.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.delete_cluster(formatted_name)

          def delete_cluster \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::DeleteClusterRequest)
            @delete_cluster.call(req, options, &block)
          end

          # Lists all operations in a project in a specific zone or all zones.
          #
          # @param parent [String]
          #   The parent (project and location) where the operations will be listed.
          #   Specified in the format 'projects/*/locations/*'.
          #   Location "-" matches all zones and all regions.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for, or `-` for
          #   all zones. This field has been deprecated and replaced by the parent field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = cluster_manager_client.list_operations(formatted_parent)

          def list_operations \
              parent,
              project_id: nil,
              zone: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListOperationsRequest)
            @list_operations.call(req, options, &block)
          end

          # Gets the specified operation.
          #
          # @param name [String]
          #   The name (project, location, operation id) of the operation to get.
          #   Specified in the format 'projects/*/locations/*/operations/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param operation_id [String]
          #   Deprecated. The server-assigned `name` of the operation.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.operation_path("[PROJECT]", "[LOCATION]", "[OPERATION]")
          #   response = cluster_manager_client.get_operation(formatted_name)

          def get_operation \
              name,
              project_id: nil,
              zone: nil,
              operation_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              operation_id: operation_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetOperationRequest)
            @get_operation.call(req, options, &block)
          end

          # Cancels the specified operation.
          #
          # @param name [String]
          #   The name (project, location, operation id) of the operation to cancel.
          #   Specified in the format 'projects/*/locations/*/operations/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the operation resides.
          #   This field has been deprecated and replaced by the name field.
          # @param operation_id [String]
          #   Deprecated. The server-assigned `name` of the operation.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.operation_path("[PROJECT]", "[LOCATION]", "[OPERATION]")
          #   cluster_manager_client.cancel_operation(formatted_name)

          def cancel_operation \
              name,
              project_id: nil,
              zone: nil,
              operation_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              operation_id: operation_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CancelOperationRequest)
            @cancel_operation.call(req, options, &block)
            nil
          end

          # Returns configuration info about the Kubernetes Engine service.
          #
          # @param name [String]
          #   The name (project and location) of the server config to get
          #   Specified in the format 'projects/*/locations/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.location_path("[PROJECT]", "[LOCATION]")
          #   response = cluster_manager_client.get_server_config(formatted_name)

          def get_server_config \
              name,
              project_id: nil,
              zone: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetServerConfigRequest)
            @get_server_config.call(req, options, &block)
          end

          # Lists the node pools for a cluster.
          #
          # @param parent [String]
          #   The parent (project, location, cluster id) where the node pools will be
          #   listed. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the parent field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.list_node_pools(formatted_parent)

          def list_node_pools \
              parent,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::ListNodePoolsRequest)
            @list_node_pools.call(req, options, &block)
          end

          # Retrieves the node pool requested.
          #
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to
          #   get. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.get_node_pool(formatted_name)

          def get_node_pool \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::GetNodePoolRequest)
            @get_node_pool.call(req, options, &block)
          end

          # Creates a node pool for a cluster.
          #
          # @param node_pool [Google::Container::V1beta1::NodePool | Hash]
          #   The node pool to create.
          #   A hash of the same form as `Google::Container::V1beta1::NodePool`
          #   can also be provided.
          # @param parent [String]
          #   The parent (project, location, cluster id) where the node pool will be
          #   created. Specified in the format
          #   'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the parent field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the parent field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the parent field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `node_pool`:
          #   node_pool = {}
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.create_node_pool(node_pool, formatted_parent)

          def create_node_pool \
              node_pool,
              parent,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              node_pool: node_pool,
              parent: parent,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CreateNodePoolRequest)
            @create_node_pool.call(req, options, &block)
          end

          # Deletes a node pool from a cluster.
          #
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to
          #   delete. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to delete.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.delete_node_pool(formatted_name)

          def delete_node_pool \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::DeleteNodePoolRequest)
            @delete_node_pool.call(req, options, &block)
          end

          # Roll back the previously Aborted or Failed NodePool upgrade.
          # This will be an no-op if the last upgrade successfully completed.
          #
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node poll to
          #   rollback upgrade.
          #   Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to rollback.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to rollback.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.rollback_node_pool_upgrade(formatted_name)

          def rollback_node_pool_upgrade \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::RollbackNodePoolUpgradeRequest)
            @rollback_node_pool_upgrade.call(req, options, &block)
          end

          # Sets the NodeManagement options for a node pool.
          #
          # @param management [Google::Container::V1beta1::NodeManagement | Hash]
          #   NodeManagement configuration for the node pool.
          #   A hash of the same form as `Google::Container::V1beta1::NodeManagement`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to set
          #   management properties. Specified in the format
          #   'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to update.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `management`:
          #   management = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.set_node_pool_management(management, formatted_name)

          def set_node_pool_management \
              management,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              management: management,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolManagementRequest)
            @set_node_pool_management.call(req, options, &block)
          end

          # Sets labels on a cluster.
          #
          # @param resource_labels [Hash{String => String}]
          #   The labels to set for that cluster.
          # @param label_fingerprint [String]
          #   The fingerprint of the previous set of labels for this resource,
          #   used to detect conflicts. The fingerprint is initially generated by
          #   Kubernetes Engine and changes after every request to modify or update
          #   labels. You must always provide an up-to-date fingerprint hash when
          #   updating or changing labels. Make a <code>get()</code> request to the
          #   resource to get the latest fingerprint.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set labels.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `resource_labels`:
          #   resource_labels = {}
          #
          #   # TODO: Initialize `label_fingerprint`:
          #   label_fingerprint = ''
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_labels(resource_labels, label_fingerprint, formatted_name)

          def set_labels \
              resource_labels,
              label_fingerprint,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              resource_labels: resource_labels,
              label_fingerprint: label_fingerprint,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLabelsRequest)
            @set_labels.call(req, options, &block)
          end

          # Enables or disables the ABAC authorization mechanism on a cluster.
          #
          # @param enabled [true, false]
          #   Whether ABAC authorization will be enabled in the cluster.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set legacy abac.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `enabled`:
          #   enabled = false
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_legacy_abac(enabled, formatted_name)

          def set_legacy_abac \
              enabled,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              enabled: enabled,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetLegacyAbacRequest)
            @set_legacy_abac.call(req, options, &block)
          end

          # Start master IP rotation.
          #
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to start IP
          #   rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param rotate_credentials [true, false]
          #   Whether to rotate credentials during IP rotation.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #
          #   # TODO: Initialize `rotate_credentials`:
          #   rotate_credentials = false
          #   response = cluster_manager_client.start_ip_rotation(formatted_name, rotate_credentials)

          def start_ip_rotation \
              name,
              rotate_credentials,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              rotate_credentials: rotate_credentials,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::StartIPRotationRequest)
            @start_ip_rotation.call(req, options, &block)
          end

          # Completes master IP rotation.
          #
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to complete IP
          #   rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.complete_ip_rotation(formatted_name)

          def complete_ip_rotation \
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::CompleteIPRotationRequest)
            @complete_ip_rotation.call(req, options, &block)
          end

          # Sets the size for a specific node pool.
          #
          # @param node_count [Integer]
          #   The desired node count for the pool.
          # @param name [String]
          #   The name (project, location, cluster, node pool id) of the node pool to set
          #   size.
          #   Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster to update.
          #   This field has been deprecated and replaced by the name field.
          # @param node_pool_id [String]
          #   Deprecated. The name of the node pool to update.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `node_count`:
          #   node_count = 0
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.node_pool_path("[PROJECT]", "[LOCATION]", "[CLUSTER]", "[NODE_POOL]")
          #   response = cluster_manager_client.set_node_pool_size(node_count, formatted_name)

          def set_node_pool_size \
              node_count,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              node_pool_id: nil,
              options: nil,
              &block
            req = {
              node_count: node_count,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id,
              node_pool_id: node_pool_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNodePoolSizeRequest)
            @set_node_pool_size.call(req, options, &block)
          end

          # Enables/Disables Network Policy for a cluster.
          #
          # @param network_policy [Google::Container::V1beta1::NetworkPolicy | Hash]
          #   Configuration options for the NetworkPolicy feature.
          #   A hash of the same form as `Google::Container::V1beta1::NetworkPolicy`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set networking
          #   policy. Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   Deprecated. The Google Developers Console [project ID or project
          #   number](https://developers.google.com/console/help/new/#projectnumber).
          #   This field has been deprecated and replaced by the name field.
          # @param zone [String]
          #   Deprecated. The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          #   This field has been deprecated and replaced by the name field.
          # @param cluster_id [String]
          #   Deprecated. The name of the cluster.
          #   This field has been deprecated and replaced by the name field.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `network_policy`:
          #   network_policy = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_network_policy(network_policy, formatted_name)

          def set_network_policy \
              network_policy,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              network_policy: network_policy,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetNetworkPolicyRequest)
            @set_network_policy.call(req, options, &block)
          end

          # Sets the maintenance policy for a cluster.
          #
          # @param maintenance_policy [Google::Container::V1beta1::MaintenancePolicy | Hash]
          #   The maintenance policy to be set for the cluster. An empty field
          #   clears the existing maintenance policy.
          #   A hash of the same form as `Google::Container::V1beta1::MaintenancePolicy`
          #   can also be provided.
          # @param name [String]
          #   The name (project, location, cluster id) of the cluster to set maintenance
          #   policy.
          #   Specified in the format 'projects/*/locations/*/clusters/*'.
          # @param project_id [String]
          #   The Google Developers Console [project ID or project
          #   number](https://support.google.com/cloud/answer/6158840).
          # @param zone [String]
          #   The name of the Google Compute Engine
          #   [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
          #   resides.
          # @param cluster_id [String]
          #   The name of the cluster to update.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #
          #   # TODO: Initialize `maintenance_policy`:
          #   maintenance_policy = {}
          #   formatted_name = Google::Cloud::Container::V1::ClusterManagerClient.cluster_path("[PROJECT]", "[LOCATION]", "[CLUSTER]")
          #   response = cluster_manager_client.set_maintenance_policy(maintenance_policy, formatted_name)

          def set_maintenance_policy \
              maintenance_policy,
              name,
              project_id: nil,
              zone: nil,
              cluster_id: nil,
              options: nil,
              &block
            req = {
              maintenance_policy: maintenance_policy,
              name: name,
              project_id: project_id,
              zone: zone,
              cluster_id: cluster_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Container::V1beta1::SetMaintenancePolicyRequest)
            @set_maintenance_policy.call(req, options, &block)
          end

          # Lists subnetworks that are usable for creating clusters in a project.
          #
          # @param parent [String]
          #   The parent project where subnetworks are usable.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `filter`:
          #   filter = ''
          #
          #   # Iterate over all results.
          #   cluster_manager_client.list_usable_subnetworks(formatted_parent, filter).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cluster_manager_client.list_usable_subnetworks(formatted_parent, filter).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_usable_subnetworks \
              parent,
              filter,
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

          # Used to fetch locations that offer GKE.
          #
          # @param parent [String]
          #   Contains the name of the resource requested.
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
          #   cluster_manager_client = Google::Cloud::Container::ClusterManager.new(version: :v1)
          #   formatted_parent = Google::Cloud::Container::V1::ClusterManagerClient.project_path("[PROJECT]")
          #   response = cluster_manager_client.list_locations(formatted_parent)

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
