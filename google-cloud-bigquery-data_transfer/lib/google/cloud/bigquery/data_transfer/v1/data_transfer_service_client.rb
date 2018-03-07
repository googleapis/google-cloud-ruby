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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/bigquery/datatransfer/v1/datatransfer.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/bigquery/datatransfer/v1/datatransfer_pb"
require "google/cloud/bigquery/data_transfer/credentials"

module Google
  module Cloud
    module Bigquery
      module DataTransfer
        module V1
          # The Google BigQuery Data Transfer Service API enables BigQuery users to
          # configure the transfer of their data from other Google Products into BigQuery.
          # This service contains methods that are end user exposed. It backs up the
          # frontend.
          #
          # @!attribute [r] data_transfer_service_stub
          #   @return [Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub]
          class DataTransferServiceClient
            attr_reader :data_transfer_service_stub

            # The default address of the service.
            SERVICE_ADDRESS = "bigquerydatatransfer.googleapis.com".freeze

            # The default port of the service.
            DEFAULT_SERVICE_PORT = 443

            DEFAULT_TIMEOUT = 30

            PAGE_DESCRIPTORS = {
              "list_data_sources" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "data_sources"),
              "list_transfer_configs" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "transfer_configs"),
              "list_transfer_runs" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "transfer_runs"),
              "list_transfer_logs" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "transfer_messages")
            }.freeze

            private_constant :PAGE_DESCRIPTORS

            # The scopes needed to make gRPC calls to all of the methods defined in
            # this service.
            ALL_SCOPES = [
              "https://www.googleapis.com/auth/cloud-platform"
            ].freeze


            PROJECT_DATA_SOURCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/dataSources/{data_source}"
            )

            private_constant :PROJECT_DATA_SOURCE_PATH_TEMPLATE

            PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}"
            )

            private_constant :PROJECT_PATH_TEMPLATE

            PROJECT_TRANSFER_CONFIG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/transferConfigs/{transfer_config}"
            )

            private_constant :PROJECT_TRANSFER_CONFIG_PATH_TEMPLATE

            PROJECT_RUN_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/transferConfigs/{transfer_config}/runs/{run}"
            )

            private_constant :PROJECT_RUN_PATH_TEMPLATE

            # Returns a fully-qualified project_data_source resource name string.
            # @param project [String]
            # @param data_source [String]
            # @return [String]
            def self.project_data_source_path project, data_source
              PROJECT_DATA_SOURCE_PATH_TEMPLATE.render(
                :"project" => project,
                :"data_source" => data_source
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

            # Returns a fully-qualified project_transfer_config resource name string.
            # @param project [String]
            # @param transfer_config [String]
            # @return [String]
            def self.project_transfer_config_path project, transfer_config
              PROJECT_TRANSFER_CONFIG_PATH_TEMPLATE.render(
                :"project" => project,
                :"transfer_config" => transfer_config
              )
            end

            # Returns a fully-qualified project_run resource name string.
            # @param project [String]
            # @param transfer_config [String]
            # @param run [String]
            # @return [String]
            def self.project_run_path project, transfer_config, run
              PROJECT_RUN_PATH_TEMPLATE.render(
                :"project" => project,
                :"transfer_config" => transfer_config,
                :"run" => run
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
              require "google/cloud/bigquery/datatransfer/v1/datatransfer_services_pb"

              credentials ||= Google::Cloud::Bigquery::DataTransfer::Credentials.default

              if credentials.is_a?(String) || credentials.is_a?(Hash)
                updater_proc = Google::Cloud::Bigquery::DataTransfer::Credentials.new(credentials).updater_proc
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

              package_version = Gem.loaded_specs['google-cloud-bigquery-data_transfer'].version.version

              google_api_client = "gl-ruby/#{RUBY_VERSION}"
              google_api_client << " #{lib_name}/#{lib_version}" if lib_name
              google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
              google_api_client << " grpc/#{GRPC::VERSION}"
              google_api_client.freeze

              headers = { :"x-goog-api-client" => google_api_client }
              client_config_file = Pathname.new(__dir__).join(
                "data_transfer_service_client_config.json"
              )
              defaults = client_config_file.open do |f|
                Google::Gax.construct_settings(
                  "google.cloud.bigquery.datatransfer.v1.DataTransferService",
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
              @data_transfer_service_stub = Google::Gax::Grpc.create_stub(
                service_path,
                port,
                chan_creds: chan_creds,
                channel: channel,
                updater_proc: updater_proc,
                scopes: scopes,
                &Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.method(:new)
              )

              @get_data_source = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:get_data_source),
                defaults["get_data_source"]
              )
              @list_data_sources = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:list_data_sources),
                defaults["list_data_sources"]
              )
              @create_transfer_config = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:create_transfer_config),
                defaults["create_transfer_config"]
              )
              @update_transfer_config = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:update_transfer_config),
                defaults["update_transfer_config"]
              )
              @delete_transfer_config = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:delete_transfer_config),
                defaults["delete_transfer_config"]
              )
              @get_transfer_config = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:get_transfer_config),
                defaults["get_transfer_config"]
              )
              @list_transfer_configs = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:list_transfer_configs),
                defaults["list_transfer_configs"]
              )
              @schedule_transfer_runs = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:schedule_transfer_runs),
                defaults["schedule_transfer_runs"]
              )
              @get_transfer_run = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:get_transfer_run),
                defaults["get_transfer_run"]
              )
              @delete_transfer_run = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:delete_transfer_run),
                defaults["delete_transfer_run"]
              )
              @list_transfer_runs = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:list_transfer_runs),
                defaults["list_transfer_runs"]
              )
              @list_transfer_logs = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:list_transfer_logs),
                defaults["list_transfer_logs"]
              )
              @check_valid_creds = Google::Gax.create_api_call(
                @data_transfer_service_stub.method(:check_valid_creds),
                defaults["check_valid_creds"]
              )
            end

            # Service calls

            # Retrieves a supported data source and returns its settings,
            # which can be used for UI rendering.
            #
            # @param name [String]
            #   The field will contain name of the resource requested, for example:
            #   +projects/{project_id}/dataSources/{data_source_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::DataSource]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_data_source_path("[PROJECT]", "[DATA_SOURCE]")
            #   response = data_transfer_service_client.get_data_source(formatted_name)

            def get_data_source \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::GetDataSourceRequest)
              @get_data_source.call(req, options)
            end

            # Lists supported data sources and returns their settings,
            # which can be used for UI rendering.
            #
            # @param parent [String]
            #   The BigQuery project id for which data sources should be returned.
            #   Must be in the form: +projects/{project_id}+
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Cloud::Bigquery::Datatransfer::V1::DataSource>]
            #   An enumerable of Google::Cloud::Bigquery::Datatransfer::V1::DataSource instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path("[PROJECT]")
            #
            #   # Iterate over all results.
            #   data_transfer_service_client.list_data_sources(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   data_transfer_service_client.list_data_sources(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_data_sources \
                parent,
                page_size: nil,
                options: nil
              req = {
                parent: parent,
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::ListDataSourcesRequest)
              @list_data_sources.call(req, options)
            end

            # Creates a new data transfer configuration.
            #
            # @param parent [String]
            #   The BigQuery project id where the transfer configuration should be created.
            #   Must be in the format /projects/{project_id}/locations/{location_id}
            #   If specified location and location of the destination bigquery dataset
            #   do not match - the request will fail.
            # @param transfer_config [Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig | Hash]
            #   Data transfer configuration to create.
            #   A hash of the same form as `Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig`
            #   can also be provided.
            # @param authorization_code [String]
            #   Optional OAuth2 authorization code to use with this transfer configuration.
            #   This is required if new credentials are needed, as indicated by
            #   +CheckValidCreds+.
            #   In order to obtain authorization_code, please make a
            #   request to
            #   https://www.gstatic.com/bigquerydatatransfer/oauthz/auth?client_id=<datatransferapiclientid>&scope=<data_source_scopes>&redirect_uri=<redirect_uri>
            #
            #   * client_id should be OAuth client_id of BigQuery DTS API for the given
            #     data source returned by ListDataSources method.
            #   * data_source_scopes are the scopes returned by ListDataSources method.
            #   * redirect_uri is an optional parameter. If not specified, then
            #     authorization code is posted to the opener of authorization flow window.
            #     Otherwise it will be sent to the redirect uri. A special value of
            #     urn:ietf:wg:oauth:2.0:oob means that authorization code should be
            #     returned in the title bar of the browser, with the page text prompting
            #     the user to copy the code and paste it in the application.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path("[PROJECT]")
            #
            #   # TODO: Initialize +transfer_config+:
            #   transfer_config = {}
            #   response = data_transfer_service_client.create_transfer_config(formatted_parent, transfer_config)

            def create_transfer_config \
                parent,
                transfer_config,
                authorization_code: nil,
                options: nil
              req = {
                parent: parent,
                transfer_config: transfer_config,
                authorization_code: authorization_code
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::CreateTransferConfigRequest)
              @create_transfer_config.call(req, options)
            end

            # Updates a data transfer configuration.
            # All fields must be set, even if they are not updated.
            #
            # @param transfer_config [Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig | Hash]
            #   Data transfer configuration to create.
            #   A hash of the same form as `Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig`
            #   can also be provided.
            # @param update_mask [Google::Protobuf::FieldMask | Hash]
            #   Required list of fields to be updated in this request.
            #   A hash of the same form as `Google::Protobuf::FieldMask`
            #   can also be provided.
            # @param authorization_code [String]
            #   Optional OAuth2 authorization code to use with this transfer configuration.
            #   If it is provided, the transfer configuration will be associated with the
            #   authorizing user.
            #   In order to obtain authorization_code, please make a
            #   request to
            #   https://www.gstatic.com/bigquerydatatransfer/oauthz/auth?client_id=<datatransferapiclientid>&scope=<data_source_scopes>&redirect_uri=<redirect_uri>
            #
            #   * client_id should be OAuth client_id of BigQuery DTS API for the given
            #     data source returned by ListDataSources method.
            #   * data_source_scopes are the scopes returned by ListDataSources method.
            #   * redirect_uri is an optional parameter. If not specified, then
            #     authorization code is posted to the opener of authorization flow window.
            #     Otherwise it will be sent to the redirect uri. A special value of
            #     urn:ietf:wg:oauth:2.0:oob means that authorization code should be
            #     returned in the title bar of the browser, with the page text prompting
            #     the user to copy the code and paste it in the application.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #
            #   # TODO: Initialize +transfer_config+:
            #   transfer_config = {}
            #
            #   # TODO: Initialize +update_mask+:
            #   update_mask = {}
            #   response = data_transfer_service_client.update_transfer_config(transfer_config, update_mask)

            def update_transfer_config \
                transfer_config,
                update_mask,
                authorization_code: nil,
                options: nil
              req = {
                transfer_config: transfer_config,
                update_mask: update_mask,
                authorization_code: authorization_code
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::UpdateTransferConfigRequest)
              @update_transfer_config.call(req, options)
            end

            # Deletes a data transfer configuration,
            # including any associated transfer runs and logs.
            #
            # @param name [String]
            #   The field will contain name of the resource requested, for example:
            #   +projects/{project_id}/transferConfigs/{config_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_transfer_config_path("[PROJECT]", "[TRANSFER_CONFIG]")
            #   data_transfer_service_client.delete_transfer_config(formatted_name)

            def delete_transfer_config \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferConfigRequest)
              @delete_transfer_config.call(req, options)
              nil
            end

            # Returns information about a data transfer config.
            #
            # @param name [String]
            #   The field will contain name of the resource requested, for example:
            #   +projects/{project_id}/transferConfigs/{config_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_transfer_config_path("[PROJECT]", "[TRANSFER_CONFIG]")
            #   response = data_transfer_service_client.get_transfer_config(formatted_name)

            def get_transfer_config \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::GetTransferConfigRequest)
              @get_transfer_config.call(req, options)
            end

            # Returns information about all data transfers in the project.
            #
            # @param parent [String]
            #   The BigQuery project id for which data sources
            #   should be returned: +projects/{project_id}+.
            # @param data_source_ids [Array<String>]
            #   When specified, only configurations of requested data sources are returned.
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig>]
            #   An enumerable of Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path("[PROJECT]")
            #
            #   # Iterate over all results.
            #   data_transfer_service_client.list_transfer_configs(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   data_transfer_service_client.list_transfer_configs(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_transfer_configs \
                parent,
                data_source_ids: nil,
                page_size: nil,
                options: nil
              req = {
                parent: parent,
                data_source_ids: data_source_ids,
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferConfigsRequest)
              @list_transfer_configs.call(req, options)
            end

            # Creates transfer runs for a time range [start_time, end_time].
            # For each date - or whatever granularity the data source supports - in the
            # range, one transfer run is created.
            # Note that runs are created per UTC time in the time range.
            #
            # @param parent [String]
            #   Transfer configuration name in the form:
            #   +projects/{project_id}/transferConfigs/{config_id}+.
            # @param start_time [Google::Protobuf::Timestamp | Hash]
            #   Start time of the range of transfer runs. For example,
            #   +"2017-05-25T00:00:00+00:00"+.
            #   A hash of the same form as `Google::Protobuf::Timestamp`
            #   can also be provided.
            # @param end_time [Google::Protobuf::Timestamp | Hash]
            #   End time of the range of transfer runs. For example,
            #   +"2017-05-30T00:00:00+00:00"+.
            #   A hash of the same form as `Google::Protobuf::Timestamp`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::ScheduleTransferRunsResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_transfer_config_path("[PROJECT]", "[TRANSFER_CONFIG]")
            #
            #   # TODO: Initialize +start_time+:
            #   start_time = {}
            #
            #   # TODO: Initialize +end_time+:
            #   end_time = {}
            #   response = data_transfer_service_client.schedule_transfer_runs(formatted_parent, start_time, end_time)

            def schedule_transfer_runs \
                parent,
                start_time,
                end_time,
                options: nil
              req = {
                parent: parent,
                start_time: start_time,
                end_time: end_time
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::ScheduleTransferRunsRequest)
              @schedule_transfer_runs.call(req, options)
            end

            # Returns information about the particular transfer run.
            #
            # @param name [String]
            #   The field will contain name of the resource requested, for example:
            #   +projects/{project_id}/transferConfigs/{config_id}/runs/{run_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::TransferRun]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_run_path("[PROJECT]", "[TRANSFER_CONFIG]", "[RUN]")
            #   response = data_transfer_service_client.get_transfer_run(formatted_name)

            def get_transfer_run \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::GetTransferRunRequest)
              @get_transfer_run.call(req, options)
            end

            # Deletes the specified transfer run.
            #
            # @param name [String]
            #   The field will contain name of the resource requested, for example:
            #   +projects/{project_id}/transferConfigs/{config_id}/runs/{run_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_run_path("[PROJECT]", "[TRANSFER_CONFIG]", "[RUN]")
            #   data_transfer_service_client.delete_transfer_run(formatted_name)

            def delete_transfer_run \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferRunRequest)
              @delete_transfer_run.call(req, options)
              nil
            end

            # Returns information about running and completed jobs.
            #
            # @param parent [String]
            #   Name of transfer configuration for which transfer runs should be retrieved.
            #   Format of transfer configuration resource name is:
            #   +projects/{project_id}/transferConfigs/{config_id}+.
            # @param states [Array<Google::Cloud::Bigquery::Datatransfer::V1::TransferState>]
            #   When specified, only transfer runs with requested states are returned.
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param run_attempt [Google::Cloud::Bigquery::Datatransfer::V1::ListTransferRunsRequest::RunAttempt]
            #   Indicates how run attempts are to be pulled.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Cloud::Bigquery::Datatransfer::V1::TransferRun>]
            #   An enumerable of Google::Cloud::Bigquery::Datatransfer::V1::TransferRun instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_transfer_config_path("[PROJECT]", "[TRANSFER_CONFIG]")
            #
            #   # Iterate over all results.
            #   data_transfer_service_client.list_transfer_runs(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   data_transfer_service_client.list_transfer_runs(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_transfer_runs \
                parent,
                states: nil,
                page_size: nil,
                run_attempt: nil,
                options: nil
              req = {
                parent: parent,
                states: states,
                page_size: page_size,
                run_attempt: run_attempt
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferRunsRequest)
              @list_transfer_runs.call(req, options)
            end

            # Returns user facing log messages for the data transfer run.
            #
            # @param parent [String]
            #   Transfer run name in the form:
            #   +projects/{project_id}/transferConfigs/{config_Id}/runs/{run_id}+.
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param message_types [Array<Google::Cloud::Bigquery::Datatransfer::V1::TransferMessage::MessageSeverity>]
            #   Message types to return. If not populated - INFO, WARNING and ERROR
            #   messages are returned.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Cloud::Bigquery::Datatransfer::V1::TransferMessage>]
            #   An enumerable of Google::Cloud::Bigquery::Datatransfer::V1::TransferMessage instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_run_path("[PROJECT]", "[TRANSFER_CONFIG]", "[RUN]")
            #
            #   # Iterate over all results.
            #   data_transfer_service_client.list_transfer_logs(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   data_transfer_service_client.list_transfer_logs(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_transfer_logs \
                parent,
                page_size: nil,
                message_types: nil,
                options: nil
              req = {
                parent: parent,
                page_size: page_size,
                message_types: message_types
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferLogsRequest)
              @list_transfer_logs.call(req, options)
            end

            # Returns true if valid credentials exist for the given data source and
            # requesting user.
            # Some data sources doesn't support service account, so we need to talk to
            # them on behalf of the end user. This API just checks whether we have OAuth
            # token for the particular user, which is a pre-requisite before user can
            # create a transfer config.
            #
            # @param name [String]
            #   The data source in the form:
            #   +projects/{project_id}/dataSources/{data_source_id}+
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Cloud::Bigquery::Datatransfer::V1::CheckValidCredsResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigquery/data_transfer/v1"
            #
            #   data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer::V1.new
            #   formatted_name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_data_source_path("[PROJECT]", "[DATA_SOURCE]")
            #   response = data_transfer_service_client.check_valid_creds(formatted_name)

            def check_valid_creds \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Cloud::Bigquery::Datatransfer::V1::CheckValidCredsRequest)
              @check_valid_creds.call(req, options)
            end
          end
        end
      end
    end
  end
end
