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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/asset/v1beta1/asset_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/asset/v1beta1/asset_service_pb"
require "google/cloud/asset/v1beta1/credentials"

module Google
  module Cloud
    module Asset
      module V1beta1
        # Asset service definition.
        #
        # @!attribute [r] asset_service_stub
        #   @return [Google::Cloud::Asset::V1beta1::AssetService::Stub]
        class AssetServiceClient
          attr_reader :asset_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "cloudasset.googleapis.com".freeze

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

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = AssetServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = AssetServiceClient::GRPC_INTERCEPTORS
          end

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
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
            require "google/cloud/asset/v1beta1/asset_service_services_pb"

            credentials ||= Google::Cloud::Asset::V1beta1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Asset::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-asset'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "asset_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.asset.v1beta1.AssetService",
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
            @asset_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Asset::V1beta1::AssetService::Stub.method(:new)
            )

            @export_assets = Google::Gax.create_api_call(
              @asset_service_stub.method(:export_assets),
              defaults["export_assets"],
              exception_transformer: exception_transformer
            )
            @batch_get_assets_history = Google::Gax.create_api_call(
              @asset_service_stub.method(:batch_get_assets_history),
              defaults["batch_get_assets_history"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Exports assets with time and resource types to a given Google Cloud Storage
          # location. The output format is newline delimited JSON.
          # This API implements the {Google::Longrunning::Operation} API allowing users
          # to keep track of the export.
          #
          # @param parent [String]
          #   Required. The relative name of the root asset. It can only be an
          #   organization number (e.g. "organizations/123") or a project number
          #   (e.g. "projects/12345").
          # @param content_types [Array<Google::Cloud::Asset::V1beta1::ContentType>]
          #   A list of asset content types. If specified, only matching content will be
          #   returned. Otherwise, no content but the asset name will be returned.
          # @param output_config [Google::Cloud::Asset::V1beta1::OutputConfig | Hash]
          #   Required. Output configuration indicating where the results will be output
          #   to. All results will be in newline delimited JSON format.
          #   A hash of the same form as `Google::Cloud::Asset::V1beta1::OutputConfig`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Timestamp to take an asset snapshot. This can only be current or past
          #   time. If not specified, the current time will be used. Due to delays in
          #   resource data collection and indexing, there is a volatile window during
          #   which running the same query may get different results.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param asset_types [Array<String>]
          #   A list of asset types to take a snapshot for. Example:
          #   "google.compute.disk". If specified, only matching assets will be returned.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_service_client = Google::Cloud::Asset.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Asset::V1beta1::AssetServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +content_types+:
          #   content_types = []
          #
          #   # TODO: Initialize +output_config+:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = asset_service_client.export_assets(formatted_parent, content_types, output_config) do |op|
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

          def export_assets \
              parent,
              content_types,
              output_config,
              read_time: nil,
              asset_types: nil,
              options: nil
            req = {
              parent: parent,
              content_types: content_types,
              output_config: output_config,
              read_time: read_time,
              asset_types: asset_types
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1beta1::ExportAssetsRequest)
            operation = Google::Gax::Operation.new(
              @export_assets.call(req, options),
              @operations_client,
              Google::Cloud::Asset::V1beta1::ExportAssetsResponse,
              Google::Cloud::Asset::V1beta1::ExportAssetsRequest,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Batch gets assets update history that overlaps a time window.
          # For RESOURCE content, this API outputs history with asset in both
          # non-delete or deleted status.
          # For IAM_POLICY content, this API only outputs history when asset and its
          # attached IAM POLICY both exist. So there may be gaps in the output history.
          #
          # @param parent [String]
          #   Required. The relative name of the root asset. It can only be an
          #   organization ID (e.g. "organizations/123") or a project ID
          #   (e.g. "projects/12345").
          # @param asset_names [Array<String>]
          #   A list of the full names of the assets. See:
          #   https://cloud.google.com/apis/design/resource_names#full_resource_name
          #   Example:
          #   "//compute.googleapis.com/projects/my_project_123/zones/zone1/instances/instance1".
          #
          #   The request becomes a no-op if the asset name list is empty.
          # @param content_type [Google::Cloud::Asset::V1beta1::ContentType]
          #   Required. The content type.
          # @param read_time_window [Google::Cloud::Asset::V1beta1::TimeWindow | Hash]
          #   Required. The time window for the asset history. The returned results
          #   contain all temporal assets whose time window overlap with
          #   read_time_window.
          #   A hash of the same form as `Google::Cloud::Asset::V1beta1::TimeWindow`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1beta1::BatchGetAssetsHistoryResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1beta1::BatchGetAssetsHistoryResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_service_client = Google::Cloud::Asset.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::Asset::V1beta1::AssetServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +asset_names+:
          #   asset_names = []
          #
          #   # TODO: Initialize +content_type+:
          #   content_type = :CONTENT_TYPE_UNSPECIFIED
          #
          #   # TODO: Initialize +read_time_window+:
          #   read_time_window = {}
          #   response = asset_service_client.batch_get_assets_history(formatted_parent, asset_names, content_type, read_time_window)

          def batch_get_assets_history \
              parent,
              asset_names,
              content_type,
              read_time_window,
              options: nil,
              &block
            req = {
              parent: parent,
              asset_names: asset_names,
              content_type: content_type,
              read_time_window: read_time_window
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1beta1::BatchGetAssetsHistoryRequest)
            @batch_get_assets_history.call(req, options, &block)
          end
        end
      end
    end
  end
end
