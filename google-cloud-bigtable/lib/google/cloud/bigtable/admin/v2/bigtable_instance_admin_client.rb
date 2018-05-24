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
# https://github.com/googleapis/googleapis/blob/master/google/bigtable/admin/v2/bigtable_instance_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

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

            PAGE_DESCRIPTORS = {
              "list_app_profiles" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "app_profiles")
            }.freeze

            private_constant :PAGE_DESCRIPTORS

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

            class OperationsClient < Google::Longrunning::OperationsClient
              self::SERVICE_ADDRESS = BigtableInstanceAdminClient::SERVICE_ADDRESS
            end

            PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}"
            )

            private_constant :PROJECT_PATH_TEMPLATE

            INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}"
            )

            private_constant :INSTANCE_PATH_TEMPLATE

            APP_PROFILE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}/appProfiles/{app_profile}"
            )

            private_constant :APP_PROFILE_PATH_TEMPLATE

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

            # Returns a fully-qualified app_profile resource name string.
            # @param project [String]
            # @param instance [String]
            # @param app_profile [String]
            # @return [String]
            def self.app_profile_path project, instance, app_profile
              APP_PROFILE_PATH_TEMPLATE.render(
                :"project" => project,
                :"instance" => instance,
                :"app_profile" => app_profile
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

              credentials ||= Google::Cloud::Bigtable::Admin::Credentials.default

              @operations_client = OperationsClient.new(
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

              package_version = Gem.loaded_specs['google-cloud-bigtable'].version.version

              google_api_client = "gl-ruby/#{RUBY_VERSION}"
              google_api_client << " #{lib_name}/#{lib_version}" if lib_name
              google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
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
                  page_descriptors: PAGE_DESCRIPTORS,
                  errors: Google::Gax::Grpc::API_ERRORS,
                  kwargs: headers
                )
              end

              # Allow overriding the service path/port in subclasses.
              service_path = self.class::SERVICE_ADDRESS
              port = self.class::DEFAULT_SERVICE_PORT
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
                defaults["create_instance"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @get_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_instance),
                defaults["get_instance"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_instances = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:list_instances),
                defaults["list_instances"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @update_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:update_instance),
                defaults["update_instance"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @partial_update_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:partial_update_instance),
                defaults["partial_update_instance"],
                params_extractor: proc do |request|
                  {'instance.name' => request.instance.name}
                end
              )
              @delete_instance = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:delete_instance),
                defaults["delete_instance"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @create_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:create_cluster),
                defaults["create_cluster"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @get_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_cluster),
                defaults["get_cluster"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_clusters = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:list_clusters),
                defaults["list_clusters"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @update_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:update_cluster),
                defaults["update_cluster"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @delete_cluster = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:delete_cluster),
                defaults["delete_cluster"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @create_app_profile = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:create_app_profile),
                defaults["create_app_profile"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @get_app_profile = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_app_profile),
                defaults["get_app_profile"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_app_profiles = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:list_app_profiles),
                defaults["list_app_profiles"],
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @update_app_profile = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:update_app_profile),
                defaults["update_app_profile"],
                params_extractor: proc do |request|
                  {'app_profile.name' => request.app_profile.name}
                end
              )
              @delete_app_profile = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:delete_app_profile),
                defaults["delete_app_profile"],
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @get_iam_policy = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:get_iam_policy),
                defaults["get_iam_policy"],
                params_extractor: proc do |request|
                  {'resource' => request.resource}
                end
              )
              @set_iam_policy = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:set_iam_policy),
                defaults["set_iam_policy"],
                params_extractor: proc do |request|
                  {'resource' => request.resource}
                end
              )
              @test_iam_permissions = Google::Gax.create_api_call(
                @bigtable_instance_admin_stub.method(:test_iam_permissions),
                defaults["test_iam_permissions"],
                params_extractor: proc do |request|
                  {'resource' => request.resource}
                end
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
            #
            #   # TODO: Initialize +instance_id+:
            #   instance_id = ''
            #
            #   # TODO: Initialize +instance+:
            #   instance = {}
            #
            #   # TODO: Initialize +clusters+:
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
            # @param labels [Hash{String => String}]
            #   Labels are a flexible and lightweight mechanism for organizing cloud
            #   resources into groups that reflect a customer's organizational needs and
            #   deployment strategies. They can be used to filter resources and aggregate
            #   metrics.
            #
            #   * Label keys must be between 1 and 63 characters long and must conform to
            #     the regular expression: +[\p{Ll}\p{Lo}][\p{Ll}\p{Lo}\p{N}_-]{0,62}+.
            #   * Label values must be between 0 and 63 characters long and must conform to
            #     the regular expression: +[\p{Ll}\p{Lo}\p{N}_-]{0,63}+.
            #   * No more than 64 labels can be associated with a given resource.
            #   * Keys and values must both be under 128 bytes.
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
            #
            #   # TODO: Initialize +display_name+:
            #   display_name = ''
            #
            #   # TODO: Initialize +type+:
            #   type = :TYPE_UNSPECIFIED
            #
            #   # TODO: Initialize +labels+:
            #   labels = {}
            #   response = bigtable_instance_admin_client.update_instance(formatted_name, display_name, type, labels)

            def update_instance \
                name,
                display_name,
                type,
                labels,
                state: nil,
                options: nil
              req = {
                name: name,
                display_name: display_name,
                type: type,
                labels: labels,
                state: state
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::Instance)
              @update_instance.call(req, options)
            end

            # Partially updates an instance within a project.
            #
            # @param instance [Google::Bigtable::Admin::V2::Instance | Hash]
            #   The Instance which will (partially) replace the current value.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::Instance`
            #   can also be provided.
            # @param update_mask [Google::Protobuf::FieldMask | Hash]
            #   The subset of Instance fields which should be replaced.
            #   Must be explicitly set.
            #   A hash of the same form as `Google::Protobuf::FieldMask`
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
            #
            #   # TODO: Initialize +instance+:
            #   instance = {}
            #
            #   # TODO: Initialize +update_mask+:
            #   update_mask = {}
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.partial_update_instance(instance, update_mask) do |op|
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

            def partial_update_instance \
                instance,
                update_mask,
                options: nil
              req = {
                instance: instance,
                update_mask: update_mask
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::PartialUpdateInstanceRequest)
              operation = Google::Gax::Operation.new(
                @partial_update_instance.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::Instance,
                Google::Bigtable::Admin::V2::UpdateInstanceMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
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
            #
            #   # TODO: Initialize +cluster_id+:
            #   cluster_id = ''
            #
            #   # TODO: Initialize +cluster+:
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
            #   performance, clients should be located as close as possible to this
            #   cluster. Currently only zones are supported, so values should be of the
            #   form +projects/<project>/locations/<zone>+.
            # @param serve_nodes [Integer]
            #   The number of nodes allocated to this cluster. More nodes enable higher
            #   throughput and more consistent performance.
            # @param state [Google::Bigtable::Admin::V2::Cluster::State]
            #   (+OutputOnly+)
            #   The current state of the cluster.
            # @param default_storage_type [Google::Bigtable::Admin::V2::StorageType]
            #   (+CreationOnly+)
            #   The type of storage used by this cluster to serve its
            #   parent instance's tables, unless explicitly overridden.
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
            #
            #   # TODO: Initialize +location+:
            #   location = ''
            #
            #   # TODO: Initialize +serve_nodes+:
            #   serve_nodes = 0
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.update_cluster(formatted_name, location, serve_nodes) do |op|
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
                state: nil,
                default_storage_type: nil,
                options: nil
              req = {
                name: name,
                location: location,
                serve_nodes: serve_nodes,
                state: state,
                default_storage_type: default_storage_type
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

            # Creates an app profile within an instance.
            #
            # @param parent [String]
            #   The unique name of the instance in which to create the new app profile.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>+.
            # @param app_profile_id [String]
            #   The ID to be used when referring to the new app profile within its
            #   instance, e.g., just +myprofile+ rather than
            #   +projects/myproject/instances/myinstance/appProfiles/myprofile+.
            # @param app_profile [Google::Bigtable::Admin::V2::AppProfile | Hash]
            #   The app profile to be created.
            #   Fields marked +OutputOnly+ will be ignored.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::AppProfile`
            #   can also be provided.
            # @param ignore_warnings [true, false]
            #   If true, ignore safety checks when creating the app profile.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::AppProfile]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #
            #   # TODO: Initialize +app_profile_id+:
            #   app_profile_id = ''
            #
            #   # TODO: Initialize +app_profile+:
            #   app_profile = {}
            #   response = bigtable_instance_admin_client.create_app_profile(formatted_parent, app_profile_id, app_profile)

            def create_app_profile \
                parent,
                app_profile_id,
                app_profile,
                ignore_warnings: nil,
                options: nil
              req = {
                parent: parent,
                app_profile_id: app_profile_id,
                app_profile: app_profile,
                ignore_warnings: ignore_warnings
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CreateAppProfileRequest)
              @create_app_profile.call(req, options)
            end

            # Gets information about an app profile.
            #
            # @param name [String]
            #   The unique name of the requested app profile. Values are of the form
            #   +projects/<project>/instances/<instance>/appProfiles/<app_profile>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::AppProfile]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")
            #   response = bigtable_instance_admin_client.get_app_profile(formatted_name)

            def get_app_profile \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GetAppProfileRequest)
              @get_app_profile.call(req, options)
            end

            # Lists information about app profiles in an instance.
            #
            # @param parent [String]
            #   The unique name of the instance for which a list of app profiles is
            #   requested. Values are of the form
            #   +projects/<project>/instances/<instance>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::AppProfile>]
            #   An enumerable of Google::Bigtable::Admin::V2::AppProfile instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #
            #   # Iterate over all results.
            #   bigtable_instance_admin_client.list_app_profiles(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   bigtable_instance_admin_client.list_app_profiles(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_app_profiles \
                parent,
                options: nil
              req = {
                parent: parent
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ListAppProfilesRequest)
              @list_app_profiles.call(req, options)
            end

            # Updates an app profile within an instance.
            #
            # @param app_profile [Google::Bigtable::Admin::V2::AppProfile | Hash]
            #   The app profile which will (partially) replace the current value.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::AppProfile`
            #   can also be provided.
            # @param update_mask [Google::Protobuf::FieldMask | Hash]
            #   The subset of app profile fields which should be replaced.
            #   If unset, all fields will be replaced.
            #   A hash of the same form as `Google::Protobuf::FieldMask`
            #   can also be provided.
            # @param ignore_warnings [true, false]
            #   If true, ignore safety checks when updating the app profile.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #
            #   # TODO: Initialize +app_profile+:
            #   app_profile = {}
            #
            #   # TODO: Initialize +update_mask+:
            #   update_mask = {}
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_instance_admin_client.update_app_profile(app_profile, update_mask) do |op|
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

            def update_app_profile \
                app_profile,
                update_mask,
                ignore_warnings: nil,
                options: nil
              req = {
                app_profile: app_profile,
                update_mask: update_mask,
                ignore_warnings: ignore_warnings
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::UpdateAppProfileRequest)
              operation = Google::Gax::Operation.new(
                @update_app_profile.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::AppProfile,
                Google::Bigtable::Admin::V2::UpdateAppProfileMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Deletes an app profile from an instance.
            #
            # @param name [String]
            #   The unique name of the app profile to be deleted. Values are of the form
            #   +projects/<project>/instances/<instance>/appProfiles/<app_profile>+.
            # @param ignore_warnings [true, false]
            #   If true, ignore safety checks when deleting the app profile.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")
            #
            #   # TODO: Initialize +ignore_warnings+:
            #   ignore_warnings = false
            #   bigtable_instance_admin_client.delete_app_profile(formatted_name, ignore_warnings)

            def delete_app_profile \
                name,
                ignore_warnings,
                options: nil
              req = {
                name: name,
                ignore_warnings: ignore_warnings
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DeleteAppProfileRequest)
              @delete_app_profile.call(req, options)
              nil
            end

            # Gets the access control policy for an instance resource. Returns an empty
            # policy if an instance exists but does not have a policy set.
            #
            # @param resource [String]
            #   REQUIRED: The resource for which the policy is being requested.
            #   +resource+ is usually specified as a path. For example, a Project
            #   resource is specified as +projects/{project}+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Iam::V1::Policy]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   response = bigtable_instance_admin_client.get_iam_policy(formatted_resource)

            def get_iam_policy \
                resource,
                options: nil
              req = {
                resource: resource
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
              @get_iam_policy.call(req, options)
            end

            # Sets the access control policy on an instance resource. Replaces any
            # existing policy.
            #
            # @param resource [String]
            #   REQUIRED: The resource for which the policy is being specified.
            #   +resource+ is usually specified as a path. For example, a Project
            #   resource is specified as +projects/{project}+.
            # @param policy [Google::Iam::V1::Policy | Hash]
            #   REQUIRED: The complete policy to be applied to the +resource+. The size of
            #   the policy is limited to a few 10s of KB. An empty policy is a
            #   valid policy but certain Cloud Platform services (such as Projects)
            #   might reject them.
            #   A hash of the same form as `Google::Iam::V1::Policy`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Iam::V1::Policy]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #
            #   # TODO: Initialize +policy+:
            #   policy = {}
            #   response = bigtable_instance_admin_client.set_iam_policy(formatted_resource, policy)

            def set_iam_policy \
                resource,
                policy,
                options: nil
              req = {
                resource: resource,
                policy: policy
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
              @set_iam_policy.call(req, options)
            end

            # Returns permissions that the caller has on the specified instance resource.
            #
            # @param resource [String]
            #   REQUIRED: The resource for which the policy detail is being requested.
            #   +resource+ is usually specified as a path. For example, a Project
            #   resource is specified as +projects/{project}+.
            # @param permissions [Array<String>]
            #   The set of permissions to check for the +resource+. Permissions with
            #   wildcards (such as '*' or 'storage.*') are not allowed. For more
            #   information see
            #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Iam::V1::TestIamPermissionsResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_instance_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new
            #   formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #
            #   # TODO: Initialize +permissions+:
            #   permissions = []
            #   response = bigtable_instance_admin_client.test_iam_permissions(formatted_resource, permissions)

            def test_iam_permissions \
                resource,
                permissions,
                options: nil
              req = {
                resource: resource,
                permissions: permissions
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
              @test_iam_permissions.call(req, options)
            end
          end
        end
      end
    end
  end
end
