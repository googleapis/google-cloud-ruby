# Copyright 2017, Google Inc. All rights reserved.
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/bigtable/admin/v2/bigtable_instance_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/bigtable/admin/v2/bigtable_instance_admin_pb"
require "google/cloud/bigtable/admin/credentials"

module Google
  module Cloud
    module Bigtable
      module Admin
        module V2
          # Service for creating, configuring, and deleting Cloud Bigtable Instances and
          # Clusters. Provides access to the Instance and Cluster schemas only, not the
          # tables' metadata or data stored in those tables.
          #
          # @!attribute [r] bigtable_instance_admin_stub
          #   @return [Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub]
          class BigtableInstanceAdminClient
            attr_reader :bigtable_instance_admin_stub

            # The default address of the service.
            SERVICE_ADDRESS = "bigtableadmin.googleapis.com".freeze

            # The default port of the service.
            DEFAULT_SERVICE_PORT = 443

            DEFAULT_TIMEOUT = 30

            # The scopes needed to make gRPC calls to all of the methods defined in
            # this service.
            ALL_SCOPES = [
              "https://www.googleapis.com/auth/bigtable.admin",
              "https://www.googleapis.com/auth/bigtable.admin.cluster",
              "https://www.googleapis.com/auth/bigtable.admin.instance",
              "https://www.googleapis.com/auth/bigtable.admin.table",
              "https://www.googleapis.com/auth/cloud-bigtable.admin",
              "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
              "https://www.googleapis.com/auth/cloud-bigtable.admin.table",
              "https://www.googleapis.com/auth/cloud-platform",
              "https://www.googleapis.com/auth/cloud-platform.read-only"
            ].freeze

            PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}"
            )

            private_constant :PROJECT_PATH_TEMPLATE

            INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}"
            )

            private_constant :INSTANCE_PATH_TEMPLATE

            CLUSTER_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}/clusters/{cluster}"
            )

            private_constant :CLUSTER_PATH_TEMPLATE

            LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/locations/{location}"
            )

            private_constant :LOCATION_PATH_TEMPLATE

            # Returns a fully-qualified project resource name string.
            # @param project [String]
            # @return [String]
            def self.project_path project
              PROJECT_PATH_TEMPLATE.render(
                :"project" => project
              )
            end

            # Returns a fully-qualified instance resource name string.
            # @param project [String]
            # @param instance [String]
            # @return [String]
            def self.instance_path project, instance
              INSTANCE_PATH_TEMPLATE.render(
                :"project" => project,
                :"instance" => instance
              )
            end

            # Returns a fully-qualified cluster resource name string.
            # @param project [String]
            # @param instance [String]
            # @param cluster [String]
            # @return [String]
            def self.cluster_path project, instance, cluster
              CLUSTER_PATH_TEMPLATE.render(
                :"project" => project,
                :"instance" => instance,
                :"cluster" => cluster
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
            def initialize \
                service_path: SERVICE_ADDRESS,
                port: DEFAULT_SERVICE_PORT,
                channel: nil,
                chan_creds: nil,
                updater_proc: nil,
                credentials: nil,
                scopes: ALL_SCOPES,
                client_config: {},
                timeout: DEFAULT_TIMEOUT,
                lib_name: nil,
                lib_version: ""
              # These require statements are intentionally placed here to initialize
              # the gRPC module only when it's required.
              # See https://github.com/googleapis/toolkit/issues/446
              require "google/gax/grpc"
              require "google/bigtable/admin/v2/bigtable_instance_admin_services_pb"

              if channel || chan_creds || updater_proc
                warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                  "on 2017/09/08"
                credentials ||= channel
                credentials ||= chan_creds
                credentials ||= updater_proc
              end
              if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
                warn "`service_path` and `port` parameters are deprecated and will be removed"
              end

              credentials ||= Google::Cloud::Bigtable::Admin::Credentials.default

              @operations_client = Google::Longrunning::OperationsClient.new(
                service_path: service_path,
                credentials: credentials,
                scopes: scopes,
                client_config: client_config,
                timeout: timeout,
                lib_name: lib_name,
                lib_version: lib_version,
              )

              if credentials.is_a?(String) || credentials.is_a?(Hash)
                updater_proc = Google::Cloud::Bigtable::Admin::Credentials.new(credentials).updater_proc
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

              google_api_client = "gl-ruby/#{RUBY_VERSION}"
              google_api_client << " #{lib_name}/#{lib_version}" if lib_name
              google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
              google_api_client << " grpc/#{GRPC::VERSION}"
              google_api_client.freeze

              headers = { :"x-goog-api-client" => google_api_client }
              client_config_file = Pathname.new(__dir__).join(
                "bigtable_instance_admin_client_config.json"
              )
              defaults = client_config_file.open do |f|
                Google::Gax.construct_settings(
                  "google.bigtable.admin.v2.BigtableInstanceAdmin",
                  JSON.parse(f.read),
                  client_config,
                  Google::Gax::Grpc::STATUS_CODE_NAMES,
                  timeout,
                  errors: Google::Gax::Grpc::API_ERRORS,
                  kwargs: headers
                )
              end
              @bigtable_instance_admin_stub = Google::Gax::Grpc.create_stub(
                service_path,
                port,
                chan_creds: chan_creds,
                channel: channel,
                updater_proc: updater_proc,
                scopes: scopes,
                &Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.method(:new)
              )

              @create_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:create_instance),
                defaults["create_instance"]
              )
              @get_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_instance),
                defaults["get_instance"]
              )
              @list_instances = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:list_instances),
                defaults["list_instances"]
              )
              @update_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:update_instance),
                defaults["update_instance"]
              )
              @delete_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:delete_instance),
                defaults["delete_instance"]
              )
              @create_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:create_cluster),
                defaults["create_cluster"]
              )
              @get_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_cluster),
                defaults["get_cluster"]
              )
              @list_clusters = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:list_clusters),
                defaults["list_clusters"]
              )
              @update_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:update_cluster),
                defaults["update_cluster"]
              )
              @delete_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:delete_cluster),
                defaults["delete_cluster"]
              )
            end

            # Service calls

            # Create an instance within a project.
            #
            # @param parent [String]
            #   The unique name of the project in which to create the new instance.
            #   Values are of the form +projects/<project>+.
            # @param instance_id [String]
            #   The ID to be used when referring to the new instance within its project,
            #   e.g., just +myinstance+ rather than
            #   +projects/myproject/instances/myinstance+.
            # @param instance [Google::Bigtable::Admin::V2::Instance | Hash]
            #   The instance to create.
            #   Fields marked +OutputOnly+ must be left blank.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::Instance`
            #   can also be provided.
            # @param clusters [Hash{String => Google::Bigtable::Admin::V2::Cluster | Hash}]
            #   The clusters to be created within the instance, mapped by desired
            #   cluster ID, e.g., just +mycluster+ rather than
            #   +projects/myproject/instances/myinstance/clusters/mycluster+.
            #   Fields marked +OutputOnly+ must be left blank.
            #   Currently exactly one cluster must be specified.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::Cluster`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")
            #   instance_id = ''
            #   instance = {}
            #   clusters = {}
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.create_instance(formatted_parent, instance_id, instance, clusters) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def create_instance \
                parent,
                instance_id,
                instance,
                clusters,
                options: nil
              req = {
                parent: parent,
                instance_id: instance_id,
                instance: instance,
                clusters: clusters
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CreateInstanceRequest)
              operation = Google::Gax::Operation.new(
                @create_instance.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::Instance,
                Google::Bigtable::Admin::V2::CreateInstanceMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Gets information about an instance.
            #
            # @param name [String]
            #   The unique name of the requested instance. Values are of the form
            #   +projects/<project>/instances/<instance>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Instance]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   response = bigtable_instance_admin_client.get_instance(formatted_name)

            def get_instance \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GetInstanceRequest)
              @get_instance.call(req, options)
            end

            # Lists information about instances in a project.
            #
            # @param parent [String]
            #   The unique name of the project for which a list of instances is requested.
            #   Values are of the form +projects/<project>+.
            # @param page_token [String]
            #   The value of +next_page_token+ returned by a previous call.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::ListInstancesResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")
            #   response = bigtable_instance_admin_client.list_instances(formatted_parent)

            def list_instances \
                parent,
                page_token: nil,
                options: nil
              req = {
                parent: parent,
                page_token: page_token
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ListInstancesRequest)
              @list_instances.call(req, options)
            end

            # Updates an instance within a project.
            #
            # @param name [String]
            #   (+OutputOnly+)
            #   The unique name of the instance. Values are of the form
            #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.
            # @param display_name [String]
            #   The descriptive name for this instance as it appears in UIs.
            #   Can be changed at any time, but should be kept globally unique
            #   to avoid confusion.
            # @param type [Google::Bigtable::Admin::V2::Instance::Type]
            #   The type of the instance. Defaults to +PRODUCTION+.
            # @param state [Google::Bigtable::Admin::V2::Instance::State]
            #   (+OutputOnly+)
            #   The current state of the instance.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Instance]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   display_name = ''
            #   type = :TYPE_UNSPECIFIED
            #   response = bigtable_instance_admin_client.update_instance(formatted_name, display_name, type)

            def update_instance \
                name,
                display_name,
                type,
                state: nil,
                options: nil
              req = {
                name: name,
                display_name: display_name,
                type: type,
                state: state
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::Instance)
              @update_instance.call(req, options)
            end

            # Delete an instance from a project.
            #
            # @param name [String]
            #   The unique name of the instance to be deleted.
            #   Values are of the form +projects/<project>/instances/<instance>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   bigtable_instance_admin_client.delete_instance(formatted_name)

            def delete_instance \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DeleteInstanceRequest)
              @delete_instance.call(req, options)
              nil
            end

            # Creates a cluster within an instance.
            #
            # @param parent [String]
            #   The unique name of the instance in which to create the new cluster.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>+.
            # @param cluster_id [String]
            #   The ID to be used when referring to the new cluster within its instance,
            #   e.g., just +mycluster+ rather than
            #   +projects/myproject/instances/myinstance/clusters/mycluster+.
            # @param cluster [Google::Bigtable::Admin::V2::Cluster | Hash]
            #   The cluster to be created.
            #   Fields marked +OutputOnly+ must be left blank.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::Cluster`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   cluster_id = ''
            #   cluster = {}
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.create_cluster(formatted_parent, cluster_id, cluster) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def create_cluster \
                parent,
                cluster_id,
                cluster,
                options: nil
              req = {
                parent: parent,
                cluster_id: cluster_id,
                cluster: cluster
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CreateClusterRequest)
              operation = Google::Gax::Operation.new(
                @create_cluster.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::Cluster,
                Google::Bigtable::Admin::V2::CreateClusterMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Gets information about a cluster.
            #
            # @param name [String]
            #   The unique name of the requested cluster. Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Cluster]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
            #   response = bigtable_instance_admin_client.get_cluster(formatted_name)

            def get_cluster \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GetClusterRequest)
              @get_cluster.call(req, options)
            end

            # Lists information about clusters in an instance.
            #
            # @param parent [String]
            #   The unique name of the instance for which a list of clusters is requested.
            #   Values are of the form +projects/<project>/instances/<instance>+.
            #   Use +<instance> = '-'+ to list Clusters for all Instances in a project,
            #   e.g., +projects/myproject/instances/-+.
            # @param page_token [String]
            #   The value of +next_page_token+ returned by a previous call.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::ListClustersResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   response = bigtable_instance_admin_client.list_clusters(formatted_parent)

            def list_clusters \
                parent,
                page_token: nil,
                options: nil
              req = {
                parent: parent,
                page_token: page_token
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ListClustersRequest)
              @list_clusters.call(req, options)
            end

            # Updates a cluster within an instance.
            #
            # @param name [String]
            #   (+OutputOnly+)
            #   The unique name of the cluster. Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/[a-z][-a-z0-9]*+.
            # @param location [String]
            #   (+CreationOnly+)
            #   The location where this cluster's nodes and storage reside. For best
            #   performance, clients should be located as close as possible to this cluster.
            #   Currently only zones are supported, so values should be of the form
            #   +projects/<project>/locations/<zone>+.
            # @param serve_nodes [Integer]
            #   The number of nodes allocated to this cluster. More nodes enable higher
            #   throughput and more consistent performance.
            # @param default_storage_type [Google::Bigtable::Admin::V2::StorageType]
            #   (+CreationOnly+)
            #   The type of storage used by this cluster to serve its
            #   parent instance's tables, unless explicitly overridden.
            # @param state [Google::Bigtable::Admin::V2::Cluster::State]
            #   (+OutputOnly+)
            #   The current state of the cluster.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
            #   location = ''
            #   serve_nodes = 0
            #   default_storage_type = :STORAGE_TYPE_UNSPECIFIED
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.update_cluster(formatted_name, location, serve_nodes, default_storage_type) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def update_cluster \
                name,
                location,
                serve_nodes,
                default_storage_type,
                state: nil,
                options: nil
              req = {
                name: name,
                location: location,
                serve_nodes: serve_nodes,
                default_storage_type: default_storage_type,
                state: state
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::Cluster)
              operation = Google::Gax::Operation.new(
                @update_cluster.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::Cluster,
                Google::Bigtable::Admin::V2::UpdateClusterMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Deletes a cluster from an instance.
            #
            # @param name [String]
            #   The unique name of the cluster to be deleted. Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
            #   bigtable_instance_admin_client.delete_cluster(formatted_name)

            def delete_cluster \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DeleteClusterRequest)
              @delete_cluster.call(req, options)
              nil
            end
          end
        end
      end
    end
  end
end
