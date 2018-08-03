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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/redis/v1beta1/cloud_redis.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/redis/v1beta1/cloud_redis_pb"
require "google/cloud/redis/v1beta1/credentials"

module Google
  module Cloud
    module Redis
      module V1beta1
        # Configures and manages Cloud Memorystore for Redis instances
        #
        # Google Cloud Memorystore for Redis v1beta1
        #
        # The +redis.googleapis.com+ service implements the Google Cloud Memorystore
        # for Redis API and defines the following resource model for managing Redis
        # instances:
        # * The service works with a collection of cloud projects, named: +/projects/*+
        # * Each project has a collection of available locations, named: +/locations/*+
        # * Each location has a collection of Redis instances, named: +/instances/*+
        # * As such, Redis instances are resources of the form:
        #   +/projects/{project_id}/locations/{location_id}/instances/{instance_id}+
        #
        # Note that location_id must be refering to a GCP +region+; for example:
        # * +projects/redpepper-1290/locations/us-central1/instances/my-redis+
        #
        # @!attribute [r] cloud_redis_stub
        #   @return [Google::Cloud::Redis::V1beta1::CloudRedis::Stub]
        class CloudRedisClient
          attr_reader :cloud_redis_stub

          # The default address of the service.
          SERVICE_ADDRESS = "redis.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_instances" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "instances")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = CloudRedisClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = CloudRedisClient::GRPC_INTERCEPTORS
          end

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/instances/{instance}"
          )

          private_constant :INSTANCE_PATH_TEMPLATE

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

          # Returns a fully-qualified instance resource name string.
          # @param project [String]
          # @param location [String]
          # @param instance [String]
          # @return [String]
          def self.instance_path project, location, instance
            INSTANCE_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
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
            require "google/cloud/redis/v1beta1/cloud_redis_services_pb"

            credentials ||= Google::Cloud::Redis::V1beta1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Redis::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-redis'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "cloud_redis_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.redis.v1beta1.CloudRedis",
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
            @cloud_redis_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Redis::V1beta1::CloudRedis::Stub.method(:new)
            )

            @list_instances = Google::Gax.create_api_call(
              @cloud_redis_stub.method(:list_instances),
              defaults["list_instances"],
              exception_transformer: exception_transformer
            )
            @get_instance = Google::Gax.create_api_call(
              @cloud_redis_stub.method(:get_instance),
              defaults["get_instance"],
              exception_transformer: exception_transformer
            )
            @create_instance = Google::Gax.create_api_call(
              @cloud_redis_stub.method(:create_instance),
              defaults["create_instance"],
              exception_transformer: exception_transformer
            )
            @update_instance = Google::Gax.create_api_call(
              @cloud_redis_stub.method(:update_instance),
              defaults["update_instance"],
              exception_transformer: exception_transformer
            )
            @delete_instance = Google::Gax.create_api_call(
              @cloud_redis_stub.method(:delete_instance),
              defaults["delete_instance"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists all Redis instances owned by a project in either the specified
          # location (region) or all locations.
          #
          # The location should have the following format:
          # * +projects/{project_id}/locations/{location_id}+
          #
          # If +location_id+ is specified as +-+ (wildcard), then all regions
          # available to the project are queried, and the results are aggregated.
          #
          # @param parent [String]
          #   Required. The resource name of the instance location using the form:
          #       +projects/{project_id}/locations/{location_id}+
          #   where +location_id+ refers to a GCP region
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Redis::V1beta1::Instance>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Redis::V1beta1::Instance>]
          #   An enumerable of Google::Cloud::Redis::V1beta1::Instance instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/redis"
          #
          #   cloud_redis_client = Google::Cloud::Redis.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   cloud_redis_client.list_instances(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cloud_redis_client.list_instances(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_instances \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Redis::V1beta1::ListInstancesRequest)
            @list_instances.call(req, options, &block)
          end

          # Gets the details of a specific Redis instance.
          #
          # @param name [String]
          #   Required. Redis instance resource name using the form:
          #       +projects/{project_id}/locations/{location_id}/instances/{instance_id}+
          #   where +location_id+ refers to a GCP region
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Redis::V1beta1::Instance]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Redis::V1beta1::Instance]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/redis"
          #
          #   cloud_redis_client = Google::Cloud::Redis.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")
          #   response = cloud_redis_client.get_instance(formatted_name)

          def get_instance \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Redis::V1beta1::GetInstanceRequest)
            @get_instance.call(req, options, &block)
          end

          # Creates a Redis instance based on the specified tier and memory size.
          #
          # By default, the instance is peered to the project's
          # [default network](https://cloud.google.com/compute/docs/networks-and-firewalls#networks).
          #
          # The creation is executed asynchronously and callers may check the returned
          # operation to track its progress. Once the operation is completed the Redis
          # instance will be fully functional. Completed longrunning.Operation will
          # contain the new instance object in the response field.
          #
          # The returned operation is automatically deleted after a few hours, so there
          # is no need to call DeleteOperation.
          #
          # @param parent [String]
          #   Required. The resource name of the instance location using the form:
          #       +projects/{project_id}/locations/{location_id}+
          #   where +location_id+ refers to a GCP region
          # @param instance_id [String]
          #   Required. The logical name of the Redis instance in the customer project
          #   with the following restrictions:
          #
          #   * Must contain only lowercase letters, numbers, and hyphens.
          #   * Must start with a letter.
          #   * Must be between 1-40 characters.
          #   * Must end with a number or a letter.
          #   * Must be unique within the customer project / location
          # @param instance [Google::Cloud::Redis::V1beta1::Instance | Hash]
          #   Required. A Redis [Instance] resource
          #   A hash of the same form as `Google::Cloud::Redis::V1beta1::Instance`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/redis"
          #
          #   cloud_redis_client = Google::Cloud::Redis.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")
          #   instance_id = "test_instance"
          #   tier = :BASIC
          #   memory_size_gb = 1
          #   instance = { tier: tier, memory_size_gb: memory_size_gb }
          #
          #   # Register a callback during the method call.
          #   operation = cloud_redis_client.create_instance(formatted_parent, instance_id, instance) do |op|
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
            req = Google::Gax::to_proto(req, Google::Cloud::Redis::V1beta1::CreateInstanceRequest)
            operation = Google::Gax::Operation.new(
              @create_instance.call(req, options),
              @operations_client,
              Google::Cloud::Redis::V1beta1::Instance,
              Google::Protobuf::Any,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Updates the metadata and configuration of a specific Redis instance.
          #
          # Completed longrunning.Operation will contain the new instance object
          # in the response field. The returned operation is automatically deleted
          # after a few hours, so there is no need to call DeleteOperation.
          #
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required. Mask of fields to update. At least one path must be supplied in
          #   this field. The elements of the repeated paths field may only include these
          #   fields from {CloudRedis::Instance Instance}:
          #   * +display_name+
          #   * +labels+
          #   * +memory_size_gb+
          #   * +redis_config+
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param instance [Google::Cloud::Redis::V1beta1::Instance | Hash]
          #   Required. Update description.
          #   Only fields specified in update_mask are updated.
          #   A hash of the same form as `Google::Cloud::Redis::V1beta1::Instance`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/redis"
          #
          #   cloud_redis_client = Google::Cloud::Redis.new(version: :v1beta1)
          #   paths_element = "display_name"
          #   paths_element_2 = "memory_size_gb"
          #   paths = [paths_element, paths_element_2]
          #   update_mask = { paths: paths }
          #   display_name = "UpdatedDisplayName"
          #   memory_size_gb = 4
          #   instance = { display_name: display_name, memory_size_gb: memory_size_gb }
          #
          #   # Register a callback during the method call.
          #   operation = cloud_redis_client.update_instance(update_mask, instance) do |op|
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
              update_mask,
              instance,
              options: nil
            req = {
              update_mask: update_mask,
              instance: instance
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Redis::V1beta1::UpdateInstanceRequest)
            operation = Google::Gax::Operation.new(
              @update_instance.call(req, options),
              @operations_client,
              Google::Cloud::Redis::V1beta1::Instance,
              Google::Protobuf::Any,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Deletes a specific Redis instance.  Instance stops serving and data is
          # deleted.
          #
          # @param name [String]
          #   Required. Redis instance resource name using the form:
          #       +projects/{project_id}/locations/{location_id}/instances/{instance_id}+
          #   where +location_id+ refers to a GCP region
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/redis"
          #
          #   cloud_redis_client = Google::Cloud::Redis.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")
          #
          #   # Register a callback during the method call.
          #   operation = cloud_redis_client.delete_instance(formatted_name) do |op|
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

          def delete_instance \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Redis::V1beta1::DeleteInstanceRequest)
            operation = Google::Gax::Operation.new(
              @delete_instance.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Protobuf::Any,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end
        end
      end
    end
  end
end
