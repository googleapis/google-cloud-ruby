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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/asset/v1/asset_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/asset/v1/asset_service_pb"
require "google/cloud/asset/v1/credentials"
require "google/cloud/asset/version"

module Google
  module Cloud
    module Asset
      module V1
        # Asset service definition.
        #
        # @!attribute [r] asset_service_stub
        #   @return [Google::Cloud::Asset::V1::AssetService::Stub]
        class AssetServiceClient
          # @private
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

          # @private
          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = AssetServiceClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = AssetServiceClient::GRPC_INTERCEPTORS
          end

          FEED_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/feeds/{feed}"
          )

          private_constant :FEED_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified feed resource name string.
          # @param project [String]
          # @param feed [String]
          # @return [String]
          def self.feed_path project, feed
            FEED_PATH_TEMPLATE.render(
              :"project" => project,
              :"feed" => feed
            )
          end

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
            require "google/cloud/asset/v1/asset_service_services_pb"

            credentials ||= Google::Cloud::Asset::V1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version,
              metadata: metadata,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Asset::V1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Asset::VERSION

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
              "asset_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.asset.v1.AssetService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @asset_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Asset::V1::AssetService::Stub.method(:new)
            )

            @export_assets = Google::Gax.create_api_call(
              @asset_service_stub.method(:export_assets),
              defaults["export_assets"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @batch_get_assets_history = Google::Gax.create_api_call(
              @asset_service_stub.method(:batch_get_assets_history),
              defaults["batch_get_assets_history"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_feed = Google::Gax.create_api_call(
              @asset_service_stub.method(:create_feed),
              defaults["create_feed"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_feed = Google::Gax.create_api_call(
              @asset_service_stub.method(:get_feed),
              defaults["get_feed"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_feeds = Google::Gax.create_api_call(
              @asset_service_stub.method(:list_feeds),
              defaults["list_feeds"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_feed = Google::Gax.create_api_call(
              @asset_service_stub.method(:update_feed),
              defaults["update_feed"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'feed.name' => request.feed.name}
              end
            )
            @delete_feed = Google::Gax.create_api_call(
              @asset_service_stub.method(:delete_feed),
              defaults["delete_feed"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Exports assets with time and resource types to a given Cloud Storage
          # location. The output format is newline-delimited JSON.
          # This API implements the {Google::Longrunning::Operation} API allowing you
          # to keep track of the export.
          #
          # @param parent [String]
          #   Required. The relative name of the root asset. This can only be an
          #   organization number (such as "organizations/123"), a project ID (such as
          #   "projects/my-project-id"), or a project number (such as "projects/12345"),
          #   or a folder number (such as "folders/123").
          # @param output_config [Google::Cloud::Asset::V1::OutputConfig | Hash]
          #   Required. Output configuration indicating where the results will be output
          #   to. All results will be in newline delimited JSON format.
          #   A hash of the same form as `Google::Cloud::Asset::V1::OutputConfig`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Timestamp to take an asset snapshot. This can only be set to a timestamp
          #   between 2018-10-02 UTC (inclusive) and the current time. If not specified,
          #   the current time will be used. Due to delays in resource data collection
          #   and indexing, there is a volatile window during which running the same
          #   query may get different results.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param asset_types [Array<String>]
          #   A list of asset types of which to take a snapshot for. For example:
          #   "compute.googleapis.com/Disk". If specified, only matching assets will be
          #   returned. See [Introduction to Cloud Asset
          #   Inventory](https://cloud.google.com/resource-manager-inventory/docs/overview)
          #   for all supported asset types.
          # @param content_type [Google::Cloud::Asset::V1::ContentType]
          #   Asset content type. If not specified, no content but the asset name will be
          #   returned.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = asset_client.export_assets(parent, output_config) do |op|
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
              output_config,
              read_time: nil,
              asset_types: nil,
              content_type: nil,
              options: nil
            req = {
              parent: parent,
              output_config: output_config,
              read_time: read_time,
              asset_types: asset_types,
              content_type: content_type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::ExportAssetsRequest)
            operation = Google::Gax::Operation.new(
              @export_assets.call(req, options),
              @operations_client,
              Google::Cloud::Asset::V1::ExportAssetsResponse,
              Google::Cloud::Asset::V1::ExportAssetsRequest,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Batch gets the update history of assets that overlap a time window.
          # For RESOURCE content, this API outputs history with asset in both
          # non-delete or deleted status.
          # For IAM_POLICY content, this API outputs history when the asset and its
          # attached IAM POLICY both exist. This can create gaps in the output history.
          # If a specified asset does not exist, this API returns an INVALID_ARGUMENT
          # error.
          #
          # @param parent [String]
          #   Required. The relative name of the root asset. It can only be an
          #   organization number (such as "organizations/123"), a project ID (such as
          #   "projects/my-project-id")", or a project number (such as "projects/12345").
          # @param content_type [Google::Cloud::Asset::V1::ContentType]
          #   Optional. The content type.
          # @param read_time_window [Google::Cloud::Asset::V1::TimeWindow | Hash]
          #   Optional. The time window for the asset history. Both start_time and
          #   end_time are optional and if set, it must be after 2018-10-02 UTC. If
          #   end_time is not set, it is default to current timestamp. If start_time is
          #   not set, the snapshot of the assets at end_time will be returned. The
          #   returned results contain all temporal assets whose time window overlap with
          #   read_time_window.
          #   A hash of the same form as `Google::Cloud::Asset::V1::TimeWindow`
          #   can also be provided.
          # @param asset_names [Array<String>]
          #   A list of the full names of the assets. For example:
          #   `//compute.googleapis.com/projects/my_project_123/zones/zone1/instances/instance1`.
          #   See [Resource
          #   Names](https://cloud.google.com/apis/design/resource_names#full_resource_name)
          #   and [Resource Name
          #   Format](https://cloud.google.com/resource-manager-inventory/docs/resource-name-format)
          #   for more info.
          #
          #   The request becomes a no-op if the asset name list is empty, and the max
          #   size of the asset name list is 100 in one request.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1::BatchGetAssetsHistoryResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1::BatchGetAssetsHistoryResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # TODO: Initialize `content_type`:
          #   content_type = :CONTENT_TYPE_UNSPECIFIED
          #
          #   # TODO: Initialize `read_time_window`:
          #   read_time_window = {}
          #   response = asset_client.batch_get_assets_history(parent, content_type, read_time_window)

          def batch_get_assets_history \
              parent,
              content_type,
              read_time_window,
              asset_names: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              content_type: content_type,
              read_time_window: read_time_window,
              asset_names: asset_names
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::BatchGetAssetsHistoryRequest)
            @batch_get_assets_history.call(req, options, &block)
          end

          # Creates a feed in a parent project/folder/organization to listen to its
          # asset updates.
          #
          # @param parent [String]
          #   Required. The name of the project/folder/organization where this feed
          #   should be created in. It can only be an organization number (such as
          #   "organizations/123"), a folder number (such as "folders/123"), a project ID
          #   (such as "projects/my-project-id")", or a project number (such as
          #   "projects/12345").
          # @param feed_id [String]
          #   Required. This is the client-assigned asset feed identifier and it needs to
          #   be unique under a specific parent project/folder/organization.
          # @param feed [Google::Cloud::Asset::V1::Feed | Hash]
          #   Required. The feed details. The field `name` must be empty and it will be generated
          #   in the format of:
          #   projects/project_number/feeds/feed_id
          #   folders/folder_number/feeds/feed_id
          #   organizations/organization_number/feeds/feed_id
          #   A hash of the same form as `Google::Cloud::Asset::V1::Feed`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1::Feed]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1::Feed]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # TODO: Initialize `feed_id`:
          #   feed_id = ''
          #
          #   # TODO: Initialize `feed`:
          #   feed = {}
          #   response = asset_client.create_feed(parent, feed_id, feed)

          def create_feed \
              parent,
              feed_id,
              feed,
              options: nil,
              &block
            req = {
              parent: parent,
              feed_id: feed_id,
              feed: feed
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::CreateFeedRequest)
            @create_feed.call(req, options, &block)
          end

          # Gets details about an asset feed.
          #
          # @param name [String]
          #   Required. The name of the Feed and it must be in the format of:
          #   projects/project_number/feeds/feed_id
          #   folders/folder_number/feeds/feed_id
          #   organizations/organization_number/feeds/feed_id
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1::Feed]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1::Feed]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #   formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")
          #   response = asset_client.get_feed(formatted_name)

          def get_feed \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::GetFeedRequest)
            @get_feed.call(req, options, &block)
          end

          # Lists all asset feeds in a parent project/folder/organization.
          #
          # @param parent [String]
          #   Required. The parent project/folder/organization whose feeds are to be
          #   listed. It can only be using project/folder/organization number (such as
          #   "folders/12345")", or a project ID (such as "projects/my-project-id").
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1::ListFeedsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1::ListFeedsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #   response = asset_client.list_feeds(parent)

          def list_feeds \
              parent,
              options: nil,
              &block
            req = {
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::ListFeedsRequest)
            @list_feeds.call(req, options, &block)
          end

          # Updates an asset feed configuration.
          #
          # @param feed [Google::Cloud::Asset::V1::Feed | Hash]
          #   Required. The new values of feed details. It must match an existing feed and the
          #   field `name` must be in the format of:
          #   projects/project_number/feeds/feed_id or
          #   folders/folder_number/feeds/feed_id or
          #   organizations/organization_number/feeds/feed_id.
          #   A hash of the same form as `Google::Cloud::Asset::V1::Feed`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required. Only updates the `feed` fields indicated by this mask.
          #   The field mask must not be empty, and it must not contain fields that
          #   are immutable or only set by the server.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Asset::V1::Feed]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Asset::V1::Feed]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #
          #   # TODO: Initialize `feed`:
          #   feed = {}
          #
          #   # TODO: Initialize `update_mask`:
          #   update_mask = {}
          #   response = asset_client.update_feed(feed, update_mask)

          def update_feed \
              feed,
              update_mask,
              options: nil,
              &block
            req = {
              feed: feed,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::UpdateFeedRequest)
            @update_feed.call(req, options, &block)
          end

          # Deletes an asset feed.
          #
          # @param name [String]
          #   Required. The name of the feed and it must be in the format of:
          #   projects/project_number/feeds/feed_id
          #   folders/folder_number/feeds/feed_id
          #   organizations/organization_number/feeds/feed_id
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/asset"
          #
          #   asset_client = Google::Cloud::Asset.new(version: :v1)
          #   formatted_name = Google::Cloud::Asset::V1::AssetServiceClient.feed_path("[PROJECT]", "[FEED]")
          #   asset_client.delete_feed(formatted_name)

          def delete_feed \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Asset::V1::DeleteFeedRequest)
            @delete_feed.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
