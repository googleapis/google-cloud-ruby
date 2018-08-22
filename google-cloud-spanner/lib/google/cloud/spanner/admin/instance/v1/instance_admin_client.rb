# Copyright 2017 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/spanner/admin/instance/v1/spanner_instance_admin.proto,
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

require "google/spanner/admin/instance/v1/spanner_instance_admin_pb"
require "google/cloud/spanner/admin/instance/credentials"

module Google
  module Cloud
    module Spanner
      module Admin
        module Instance
          module V1
            # Cloud Spanner Instance Admin API
            #
            # The Cloud Spanner Instance Admin API can be used to create, delete,
            # modify and list instances. Instances are dedicated Cloud Spanner serving
            # and storage resources to be used by Cloud Spanner databases.
            #
            # Each instance has a "configuration", which dictates where the
            # serving resources for the Cloud Spanner instance are located (e.g.,
            # US-central, Europe). Configurations are created by Google based on
            # resource availability.
            #
            # Cloud Spanner billing is based on the instances that exist and their
            # sizes. After an instance exists, there are no additional
            # per-database or per-operation charges for use of the instance
            # (though there may be additional network bandwidth charges).
            # Instances offer isolation: problems with databases in one instance
            # will not affect other instances. However, within an instance
            # databases can affect each other. For example, if one database in an
            # instance receives a lot of requests and consumes most of the
            # instance resources, fewer resources are available for other
            # databases in that instance, and their performance may suffer.
            #
            # @!attribute [r] instance_admin_stub
            #   @return [Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub]
            class InstanceAdminClient
              attr_reader :instance_admin_stub

              # The default address of the service.
              SERVICE_ADDRESS = "spanner.googleapis.com".freeze

              # The default port of the service.
              DEFAULT_SERVICE_PORT = 443

              DEFAULT_TIMEOUT = 30

              PAGE_DESCRIPTORS = {
                "list_instance_configs" => Google::Gax::PageDescriptor.new(
                  "page_token",
                  "next_page_token",
                  "instance_configs"),
                "list_instances" => Google::Gax::PageDescriptor.new(
                  "page_token",
                  "next_page_token",
                  "instances")
              }.freeze

              private_constant :PAGE_DESCRIPTORS

              # The scopes needed to make gRPC calls to all of the methods defined in
              # this service.
              ALL_SCOPES = [
                "https://www.googleapis.com/auth/cloud-platform",
                "https://www.googleapis.com/auth/spanner.admin"
              ].freeze

              # @private
              class OperationsClient < Google::Longrunning::OperationsClient
                SERVICE_ADDRESS = SERVICE_ADDRESS
              end

              PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}"
              )

              private_constant :PROJECT_PATH_TEMPLATE

              INSTANCE_CONFIG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instanceConfigs/{instance_config}"
              )

              private_constant :INSTANCE_CONFIG_PATH_TEMPLATE

              INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instances/{instance}"
              )

              private_constant :INSTANCE_PATH_TEMPLATE

              # Returns a fully-qualified project resource name string.
              # @param project [String]
              # @return [String]
              def self.project_path project
                PROJECT_PATH_TEMPLATE.render(
                  :"project" => project
                )
              end

              # Returns a fully-qualified instance_config resource name string.
              # @param project [String]
              # @param instance_config [String]
              # @return [String]
              def self.instance_config_path project, instance_config
                INSTANCE_CONFIG_PATH_TEMPLATE.render(
                  :"project" => project,
                  :"instance_config" => instance_config
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
                require "google/spanner/admin/instance/v1/spanner_instance_admin_services_pb"

                credentials ||= Google::Cloud::Spanner::Admin::Instance::Credentials.default

                @operations_client = OperationsClient.new(
                  credentials: credentials,
                  scopes: scopes,
                  client_config: client_config,
                  timeout: timeout,
                  lib_name: lib_name,
                  lib_version: lib_version,
                )

                if credentials.is_a?(String) || credentials.is_a?(Hash)
                  updater_proc = Google::Cloud::Spanner::Admin::Instance::Credentials.new(credentials).updater_proc
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

                package_version = Gem.loaded_specs['google-cloud-spanner'].version.version

                google_api_client = "gl-ruby/#{RUBY_VERSION}"
                google_api_client << " #{lib_name}/#{lib_version}" if lib_name
                google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
                google_api_client << " grpc/#{GRPC::VERSION}"
                google_api_client.freeze

                headers = { :"x-goog-api-client" => google_api_client }
                client_config_file = Pathname.new(__dir__).join(
                  "instance_admin_client_config.json"
                )
                defaults = client_config_file.open do |f|
                  Google::Gax.construct_settings(
                    "google.spanner.admin.instance.v1.InstanceAdmin",
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
                @instance_admin_stub = Google::Gax::Grpc.create_stub(
                  service_path,
                  port,
                  chan_creds: chan_creds,
                  channel: channel,
                  updater_proc: updater_proc,
                  scopes: scopes,
                  &Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.method(:new)
                )

                @list_instance_configs = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:list_instance_configs),
                  defaults["list_instance_configs"]
                )
                @get_instance_config = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:get_instance_config),
                  defaults["get_instance_config"]
                )
                @list_instances = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:list_instances),
                  defaults["list_instances"]
                )
                @get_instance = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:get_instance),
                  defaults["get_instance"]
                )
                @create_instance = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:create_instance),
                  defaults["create_instance"]
                )
                @update_instance = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:update_instance),
                  defaults["update_instance"]
                )
                @delete_instance = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:delete_instance),
                  defaults["delete_instance"]
                )
                @set_iam_policy = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:set_iam_policy),
                  defaults["set_iam_policy"]
                )
                @get_iam_policy = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:get_iam_policy),
                  defaults["get_iam_policy"]
                )
                @test_iam_permissions = Google::Gax.create_api_call(
                  @instance_admin_stub.method(:test_iam_permissions),
                  defaults["test_iam_permissions"]
                )
              end

              # Service calls

              # Lists the supported instance configurations for a given project.
              #
              # @param parent [String]
              #   Required. The name of the project for which a list of supported instance
              #   configurations is requested. Values are of the form
              #   +projects/<project>+.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Instance::V1::InstanceConfig>]
              #   An enumerable of Google::Spanner::Admin::Instance::V1::InstanceConfig instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
              #
              #   # Iterate over all results.
              #   instance_admin_client.list_instance_configs(formatted_parent).each do |element|
              #     # Process element.
              #   end
              #
              #   # Or iterate over results one page at a time.
              #   instance_admin_client.list_instance_configs(formatted_parent).each_page do |page|
              #     # Process each page at a time.
              #     page.each do |element|
              #       # Process element.
              #     end
              #   end

              def list_instance_configs \
                  parent,
                  page_size: nil,
                  options: nil
                req = {
                  parent: parent,
                  page_size: page_size
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::ListInstanceConfigsRequest)
                @list_instance_configs.call(req, options)
              end

              # Gets information about a particular instance configuration.
              #
              # @param name [String]
              #   Required. The name of the requested instance configuration. Values are of
              #   the form +projects/<project>/instanceConfigs/<config>+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Instance::V1::InstanceConfig]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_config_path("[PROJECT]", "[INSTANCE_CONFIG]")
              #   response = instance_admin_client.get_instance_config(formatted_name)

              def get_instance_config \
                  name,
                  options: nil
                req = {
                  name: name
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::GetInstanceConfigRequest)
                @get_instance_config.call(req, options)
              end

              # Lists all instances in the given project.
              #
              # @param parent [String]
              #   Required. The name of the project for which a list of instances is
              #   requested. Values are of the form +projects/<project>+.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param filter [String]
              #   An expression for filtering the results of the request. Filter rules are
              #   case insensitive. The fields eligible for filtering are:
              #
              #   * +name+
              #     * +display_name+
              #     * +labels.key+ where key is the name of a label
              #
              #     Some examples of using filters are:
              #
              #     * +name:*+ --> The instance has a name.
              #     * +name:Howl+ --> The instance's name contains the string "howl".
              #     * +name:HOWL+ --> Equivalent to above.
              #     * +NAME:howl+ --> Equivalent to above.
              #     * +labels.env:*+ --> The instance has the label "env".
              #     * +labels.env:dev+ --> The instance has the label "env" and the value of
              #       the label contains the string "dev".
              #     * +name:howl labels.env:dev+ --> The instance's name contains "howl" and
              #       it has the label "env" with its value
              #       containing "dev".
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Instance::V1::Instance>]
              #   An enumerable of Google::Spanner::Admin::Instance::V1::Instance instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
              #
              #   # Iterate over all results.
              #   instance_admin_client.list_instances(formatted_parent).each do |element|
              #     # Process element.
              #   end
              #
              #   # Or iterate over results one page at a time.
              #   instance_admin_client.list_instances(formatted_parent).each_page do |page|
              #     # Process each page at a time.
              #     page.each do |element|
              #       # Process element.
              #     end
              #   end

              def list_instances \
                  parent,
                  page_size: nil,
                  filter: nil,
                  options: nil
                req = {
                  parent: parent,
                  page_size: page_size,
                  filter: filter
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::ListInstancesRequest)
                @list_instances.call(req, options)
              end

              # Gets information about a particular instance.
              #
              # @param name [String]
              #   Required. The name of the requested instance. Values are of the form
              #   +projects/<project>/instances/<instance>+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Instance::V1::Instance]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #   response = instance_admin_client.get_instance(formatted_name)

              def get_instance \
                  name,
                  options: nil
                req = {
                  name: name
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::GetInstanceRequest)
                @get_instance.call(req, options)
              end

              # Creates an instance and begins preparing it to begin serving. The
              # returned {Google::Longrunning::Operation long-running operation}
              # can be used to track the progress of preparing the new
              # instance. The instance name is assigned by the caller. If the
              # named instance already exists, +CreateInstance+ returns
              # +ALREADY_EXISTS+.
              #
              # Immediately upon completion of this request:
              #
              # * The instance is readable via the API, with all requested attributes
              #   but no allocated resources. Its state is +CREATING+.
              #
              # Until completion of the returned operation:
              #
              # * Cancelling the operation renders the instance immediately unreadable
              #   via the API.
              #   * The instance can be deleted.
              #   * All other attempts to modify the instance are rejected.
              #
              #   Upon completion of the returned operation:
              #
              #   * Billing for all successfully-allocated resources begins (some types
              #     may have lower than the requested levels).
              #   * Databases can be created in the instance.
              #   * The instance's allocated resource levels are readable via the API.
              #   * The instance's state becomes +READY+.
              #
              #   The returned {Google::Longrunning::Operation long-running operation} will
              #   have a name of the format +<instance_name>/operations/<operation_id>+ and
              #   can be used to track creation of the instance.  The
              #   {Google::Longrunning::Operation#metadata metadata} field type is
              #   {Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata CreateInstanceMetadata}.
              #   The {Google::Longrunning::Operation#response response} field type is
              #   {Google::Spanner::Admin::Instance::V1::Instance Instance}, if successful.
              #
              # @param parent [String]
              #   Required. The name of the project in which to create the instance. Values
              #   are of the form +projects/<project>+.
              # @param instance_id [String]
              #   Required. The ID of the instance to create.  Valid identifiers are of the
              #   form +[a-z][-a-z0-9]*[a-z0-9]+ and must be between 6 and 30 characters in
              #   length.
              # @param instance [Google::Spanner::Admin::Instance::V1::Instance | Hash]
              #   Required. The instance to create.  The name may be omitted, but if
              #   specified must be +<parent>/instances/<instance_id>+.
              #   A hash of the same form as `Google::Spanner::Admin::Instance::V1::Instance`
              #   can also be provided.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
              #   instance_id = ''
              #   instance = {}
              #
              #   # Register a callback during the method call.
              #   operation = instance_admin_client.create_instance(formatted_parent, instance_id, instance) do |op|
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
                  options: nil
                req = {
                  parent: parent,
                  instance_id: instance_id,
                  instance: instance
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::CreateInstanceRequest)
                operation = Google::Gax::Operation.new(
                  @create_instance.call(req, options),
                  @operations_client,
                  Google::Spanner::Admin::Instance::V1::Instance,
                  Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata,
                  call_options: options
                )
                operation.on_done { |operation| yield(operation) } if block_given?
                operation
              end

              # Updates an instance, and begins allocating or releasing resources
              # as requested. The returned [long-running
              # operation][google.longrunning.Operation] can be used to track the
              # progress of updating the instance. If the named instance does not
              # exist, returns +NOT_FOUND+.
              #
              # Immediately upon completion of this request:
              #
              # * For resource types for which a decrease in the instance's allocation
              #   has been requested, billing is based on the newly-requested level.
              #
              # Until completion of the returned operation:
              #
              # * Cancelling the operation sets its metadata's
              #   {Google::Spanner::Admin::Instance::V1::UpdateInstanceMetadata#cancel_time cancel_time}, and begins
              #   restoring resources to their pre-request values. The operation
              #   is guaranteed to succeed at undoing all resource changes,
              #   after which point it terminates with a +CANCELLED+ status.
              #   * All other attempts to modify the instance are rejected.
              #   * Reading the instance via the API continues to give the pre-request
              #     resource levels.
              #
              #   Upon completion of the returned operation:
              #
              #   * Billing begins for all successfully-allocated resources (some types
              #     may have lower than the requested levels).
              #   * All newly-reserved resources are available for serving the instance's
              #     tables.
              #   * The instance's new resource levels are readable via the API.
              #
              #   The returned {Google::Longrunning::Operation long-running operation} will
              #   have a name of the format +<instance_name>/operations/<operation_id>+ and
              #   can be used to track the instance modification.  The
              #   {Google::Longrunning::Operation#metadata metadata} field type is
              #   {Google::Spanner::Admin::Instance::V1::UpdateInstanceMetadata UpdateInstanceMetadata}.
              #   The {Google::Longrunning::Operation#response response} field type is
              #   {Google::Spanner::Admin::Instance::V1::Instance Instance}, if successful.
              #
              # Authorization requires +spanner.instances.update+ permission on
              # resource {Google::Spanner::Admin::Instance::V1::Instance#name name}.
              #
              # @param instance [Google::Spanner::Admin::Instance::V1::Instance | Hash]
              #   Required. The instance to update, which must always include the instance
              #   name.  Otherwise, only fields mentioned in [][google.spanner.admin.instance.v1.UpdateInstanceRequest.field_mask] need be included.
              #   A hash of the same form as `Google::Spanner::Admin::Instance::V1::Instance`
              #   can also be provided.
              # @param field_mask [Google::Protobuf::FieldMask | Hash]
              #   Required. A mask specifying which fields in [][google.spanner.admin.instance.v1.UpdateInstanceRequest.instance] should be updated.
              #   The field mask must always be specified; this prevents any future fields in
              #   [][google.spanner.admin.instance.v1.Instance] from being erased accidentally by clients that do not know
              #   about them.
              #   A hash of the same form as `Google::Protobuf::FieldMask`
              #   can also be provided.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   instance = {}
              #   field_mask = {}
              #
              #   # Register a callback during the method call.
              #   operation = instance_admin_client.update_instance(instance, field_mask) do |op|
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

              def update_instance \
                  instance,
                  field_mask,
                  options: nil
                req = {
                  instance: instance,
                  field_mask: field_mask
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::UpdateInstanceRequest)
                operation = Google::Gax::Operation.new(
                  @update_instance.call(req, options),
                  @operations_client,
                  Google::Spanner::Admin::Instance::V1::Instance,
                  Google::Spanner::Admin::Instance::V1::UpdateInstanceMetadata,
                  call_options: options
                )
                operation.on_done { |operation| yield(operation) } if block_given?
                operation
              end

              # Deletes an instance.
              #
              # Immediately upon completion of the request:
              #
              # * Billing ceases for all of the instance's reserved resources.
              #
              # Soon afterward:
              #
              # * The instance and *all of its databases* immediately and
              #   irrevocably disappear from the API. All data in the databases
              #   is permanently deleted.
              #
              # @param name [String]
              #   Required. The name of the instance to be deleted. Values are of the form
              #   +projects/<project>/instances/<instance>+
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #   instance_admin_client.delete_instance(formatted_name)

              def delete_instance \
                  name,
                  options: nil
                req = {
                  name: name
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Instance::V1::DeleteInstanceRequest)
                @delete_instance.call(req, options)
                nil
              end

              # Sets the access control policy on an instance resource. Replaces any
              # existing policy.
              #
              # Authorization requires +spanner.instances.setIamPolicy+ on
              # {Google::Iam::V1::SetIamPolicyRequest#resource resource}.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy is being specified.
              #   +resource+ is usually specified as a path. For example, a Project
              #   resource is specified as +projects/\\{project}+.
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
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #   policy = {}
              #   response = instance_admin_client.set_iam_policy(formatted_resource, policy)

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

              # Gets the access control policy for an instance resource. Returns an empty
              # policy if an instance exists but does not have a policy set.
              #
              # Authorization requires +spanner.instances.getIamPolicy+ on
              # {Google::Iam::V1::GetIamPolicyRequest#resource resource}.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy is being requested.
              #   +resource+ is usually specified as a path. For example, a Project
              #   resource is specified as +projects/\\{project}+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Iam::V1::Policy]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #   response = instance_admin_client.get_iam_policy(formatted_resource)

              def get_iam_policy \
                  resource,
                  options: nil
                req = {
                  resource: resource
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
                @get_iam_policy.call(req, options)
              end

              # Returns permissions that the caller has on the specified instance resource.
              #
              # Attempting this RPC on a non-existent Cloud Spanner instance resource will
              # result in a NOT_FOUND error if the user has +spanner.instances.list+
              # permission on the containing Google Cloud Project. Otherwise returns an
              # empty set of permissions.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy detail is being requested.
              #   +resource+ is usually specified as a path. For example, a Project
              #   resource is specified as +projects/\\{project}+.
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
              #   require "google/cloud/spanner/admin/instance/v1"
              #
              #   instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1.new
              #   formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #   permissions = []
              #   response = instance_admin_client.test_iam_permissions(formatted_resource, permissions)

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
end
