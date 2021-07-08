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
# https://github.com/googleapis/googleapis/blob/master/google/area120/tables/v1alpha1/tables.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/area120/tables/v1alpha1/tables_pb"
require "google/cloud/area120/tables/v1alpha1/credentials"

module Google
  module Cloud
    module Area120
      module Tables
        module V1alpha1
          # The Tables Service provides an API for reading and updating tables.
          # It defines the following resource model:
          #
          # * The API has a collection of {Google::Area120::Tables::V1alpha1::Table Table}
          #   resources, named `tables/*`
          #
          # * Each Table has a collection of {Google::Area120::Tables::V1alpha1::Row Row}
          #   resources, named `tables/*/rows/*`
          #
          # * The API has a collection of
          #   {Google::Area120::Tables::V1alpha1::Workspace Workspace}
          #   resources, named `workspaces/*`.
          #
          # @!attribute [r] tables_service_stub
          #   @return [Google::Area120::Tables::V1alpha1::TablesService::Stub]
          class TablesServiceClient
            attr_reader :tables_service_stub

            # The default address of the service.
            SERVICE_ADDRESS = "area120tables.googleapis.com".freeze

            # The default port of the service.
            DEFAULT_SERVICE_PORT = 443

            # The default set of gRPC interceptors.
            GRPC_INTERCEPTORS = []

            DEFAULT_TIMEOUT = 30

            PAGE_DESCRIPTORS = {
              "list_tables" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "tables"),
              "list_workspaces" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "workspaces"),
              "list_rows" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "rows")
            }.freeze

            private_constant :PAGE_DESCRIPTORS

            # The scopes needed to make gRPC calls to all of the methods defined in
            # this service.
            ALL_SCOPES = [
              "https://www.googleapis.com/auth/drive",
              "https://www.googleapis.com/auth/drive.file",
              "https://www.googleapis.com/auth/drive.readonly",
              "https://www.googleapis.com/auth/spreadsheets",
              "https://www.googleapis.com/auth/spreadsheets.readonly",
              "https://www.googleapis.com/auth/tables"
            ].freeze


            ROW_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "tables/{table}/rows/{row}"
            )

            private_constant :ROW_PATH_TEMPLATE

            TABLE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "tables/{table}"
            )

            private_constant :TABLE_PATH_TEMPLATE

            WORKSPACE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "workspaces/{workspace}"
            )

            private_constant :WORKSPACE_PATH_TEMPLATE

            # Returns a fully-qualified row resource name string.
            # @param table [String]
            # @param row [String]
            # @return [String]
            def self.row_path table, row
              ROW_PATH_TEMPLATE.render(
                :"table" => table,
                :"row" => row
              )
            end

            # Returns a fully-qualified table resource name string.
            # @param table [String]
            # @return [String]
            def self.table_path table
              TABLE_PATH_TEMPLATE.render(
                :"table" => table
              )
            end

            # Returns a fully-qualified workspace resource name string.
            # @param workspace [String]
            # @return [String]
            def self.workspace_path workspace
              WORKSPACE_PATH_TEMPLATE.render(
                :"workspace" => workspace
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
              require "google/area120/tables/v1alpha1/tables_services_pb"

              credentials ||= Google::Cloud::Area120::Tables::V1alpha1::Credentials.default

              if credentials.is_a?(String) || credentials.is_a?(Hash)
                updater_proc = Google::Cloud::Area120::Tables::V1alpha1::Credentials.new(credentials).updater_proc
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

              package_version = Gem.loaded_specs['google-cloud-area120-tables'].version.version

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
                "tables_service_client_config.json"
              )
              defaults = client_config_file.open do |f|
                Google::Gax.construct_settings(
                  "google.area120.tables.v1alpha1.TablesService",
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
              @tables_service_stub = Google::Gax::Grpc.create_stub(
                service_path,
                port,
                chan_creds: chan_creds,
                channel: channel,
                updater_proc: updater_proc,
                scopes: scopes,
                interceptors: interceptors,
                &Google::Area120::Tables::V1alpha1::TablesService::Stub.method(:new)
              )

              @get_table = Google::Gax.create_api_call(
                @tables_service_stub.method(:get_table),
                defaults["get_table"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_tables = Google::Gax.create_api_call(
                @tables_service_stub.method(:list_tables),
                defaults["list_tables"],
                exception_transformer: exception_transformer
              )
              @get_workspace = Google::Gax.create_api_call(
                @tables_service_stub.method(:get_workspace),
                defaults["get_workspace"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_workspaces = Google::Gax.create_api_call(
                @tables_service_stub.method(:list_workspaces),
                defaults["list_workspaces"],
                exception_transformer: exception_transformer
              )
              @get_row = Google::Gax.create_api_call(
                @tables_service_stub.method(:get_row),
                defaults["get_row"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_rows = Google::Gax.create_api_call(
                @tables_service_stub.method(:list_rows),
                defaults["list_rows"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @create_row = Google::Gax.create_api_call(
                @tables_service_stub.method(:create_row),
                defaults["create_row"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @batch_create_rows = Google::Gax.create_api_call(
                @tables_service_stub.method(:batch_create_rows),
                defaults["batch_create_rows"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @update_row = Google::Gax.create_api_call(
                @tables_service_stub.method(:update_row),
                defaults["update_row"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'row.name' => request.row.name}
                end
              )
              @batch_update_rows = Google::Gax.create_api_call(
                @tables_service_stub.method(:batch_update_rows),
                defaults["batch_update_rows"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @delete_row = Google::Gax.create_api_call(
                @tables_service_stub.method(:delete_row),
                defaults["delete_row"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @batch_delete_rows = Google::Gax.create_api_call(
                @tables_service_stub.method(:batch_delete_rows),
                defaults["batch_delete_rows"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
            end

            # Service calls

            # Gets a table. Returns NOT_FOUND if the table does not exist.
            #
            # @param name [String]
            #   Required. The name of the table to retrieve.
            #   Format: tables/{table}
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::Table]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::Table]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #   formatted_name = Google::Cloud::Area120::Tables::V1alpha1::TablesServiceClient.table_path("[TABLE]")
            #   response = tables_client.get_table(formatted_name)

            def get_table \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::GetTableRequest)
              @get_table.call(req, options, &block)
            end

            # Lists tables for the user.
            #
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
            # @yieldparam result [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Table>]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Table>]
            #   An enumerable of Google::Area120::Tables::V1alpha1::Table instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # Iterate over all results.
            #   tables_client.list_tables.each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   tables_client.list_tables.each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_tables \
                page_size: nil,
                options: nil,
                &block
              req = {
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::ListTablesRequest)
              @list_tables.call(req, options, &block)
            end

            # Gets a workspace. Returns NOT_FOUND if the workspace does not exist.
            #
            # @param name [String]
            #   Required. The name of the workspace to retrieve.
            #   Format: workspaces/{workspace}
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::Workspace]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::Workspace]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #   formatted_name = Google::Cloud::Area120::Tables::V1alpha1::TablesServiceClient.workspace_path("[WORKSPACE]")
            #   response = tables_client.get_workspace(formatted_name)

            def get_workspace \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::GetWorkspaceRequest)
              @get_workspace.call(req, options, &block)
            end

            # Lists workspaces for the user.
            #
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
            # @yieldparam result [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Workspace>]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Workspace>]
            #   An enumerable of Google::Area120::Tables::V1alpha1::Workspace instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # Iterate over all results.
            #   tables_client.list_workspaces.each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   tables_client.list_workspaces.each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_workspaces \
                page_size: nil,
                options: nil,
                &block
              req = {
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::ListWorkspacesRequest)
              @list_workspaces.call(req, options, &block)
            end

            # Gets a row. Returns NOT_FOUND if the row does not exist in the table.
            #
            # @param name [String]
            #   Required. The name of the row to retrieve.
            #   Format: tables/{table}/rows/{row}
            # @param view [Google::Area120::Tables::V1alpha1::View]
            #   Optional. Column key to use for values in the row.
            #   Defaults to user entered name.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::Row]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::Row]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #   formatted_name = Google::Cloud::Area120::Tables::V1alpha1::TablesServiceClient.row_path("[TABLE]", "[ROW]")
            #   response = tables_client.get_row(formatted_name)

            def get_row \
                name,
                view: nil,
                options: nil,
                &block
              req = {
                name: name,
                view: view
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::GetRowRequest)
              @get_row.call(req, options, &block)
            end

            # Lists rows in a table. Returns NOT_FOUND if the table does not exist.
            #
            # @param parent [String]
            #   Required. The parent table.
            #   Format: tables/{table}
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param view [Google::Area120::Tables::V1alpha1::View]
            #   Optional. Column key to use for values in the row.
            #   Defaults to user entered name.
            # @param filter [String]
            #   Optional. Raw text query to search for in rows of the table.
            #   Special characters must be escaped. Logical operators and field specific
            #   filtering not supported.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Row>]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Gax::PagedEnumerable<Google::Area120::Tables::V1alpha1::Row>]
            #   An enumerable of Google::Area120::Tables::V1alpha1::Row instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # TODO: Initialize `parent`:
            #   parent = ''
            #
            #   # Iterate over all results.
            #   tables_client.list_rows(parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   tables_client.list_rows(parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_rows \
                parent,
                page_size: nil,
                view: nil,
                filter: nil,
                options: nil,
                &block
              req = {
                parent: parent,
                page_size: page_size,
                view: view,
                filter: filter
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::ListRowsRequest)
              @list_rows.call(req, options, &block)
            end

            # Creates a row.
            #
            # @param parent [String]
            #   Required. The parent table where this row will be created.
            #   Format: tables/{table}
            # @param row [Google::Area120::Tables::V1alpha1::Row | Hash]
            #   Required. The row to create.
            #   A hash of the same form as `Google::Area120::Tables::V1alpha1::Row`
            #   can also be provided.
            # @param view [Google::Area120::Tables::V1alpha1::View]
            #   Optional. Column key to use for values in the row.
            #   Defaults to user entered name.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::Row]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::Row]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # TODO: Initialize `parent`:
            #   parent = ''
            #
            #   # TODO: Initialize `row`:
            #   row = {}
            #   response = tables_client.create_row(parent, row)

            def create_row \
                parent,
                row,
                view: nil,
                options: nil,
                &block
              req = {
                parent: parent,
                row: row,
                view: view
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::CreateRowRequest)
              @create_row.call(req, options, &block)
            end

            # Creates multiple rows.
            #
            # @param parent [String]
            #   Required. The parent table where the rows will be created.
            #   Format: tables/{table}
            # @param requests [Array<Google::Area120::Tables::V1alpha1::CreateRowRequest | Hash>]
            #   Required. The request message specifying the rows to create.
            #
            #   A maximum of 500 rows can be created in a single batch.
            #   A hash of the same form as `Google::Area120::Tables::V1alpha1::CreateRowRequest`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::BatchCreateRowsResponse]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::BatchCreateRowsResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # TODO: Initialize `parent`:
            #   parent = ''
            #
            #   # TODO: Initialize `requests`:
            #   requests = []
            #   response = tables_client.batch_create_rows(parent, requests)

            def batch_create_rows \
                parent,
                requests,
                options: nil,
                &block
              req = {
                parent: parent,
                requests: requests
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::BatchCreateRowsRequest)
              @batch_create_rows.call(req, options, &block)
            end

            # Updates a row.
            #
            # @param row [Google::Area120::Tables::V1alpha1::Row | Hash]
            #   Required. The row to update.
            #   A hash of the same form as `Google::Area120::Tables::V1alpha1::Row`
            #   can also be provided.
            # @param update_mask [Google::Protobuf::FieldMask | Hash]
            #   The list of fields to update.
            #   A hash of the same form as `Google::Protobuf::FieldMask`
            #   can also be provided.
            # @param view [Google::Area120::Tables::V1alpha1::View]
            #   Optional. Column key to use for values in the row.
            #   Defaults to user entered name.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::Row]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::Row]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # TODO: Initialize `row`:
            #   row = {}
            #   response = tables_client.update_row(row)

            def update_row \
                row,
                update_mask: nil,
                view: nil,
                options: nil,
                &block
              req = {
                row: row,
                update_mask: update_mask,
                view: view
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::UpdateRowRequest)
              @update_row.call(req, options, &block)
            end

            # Updates multiple rows.
            #
            # @param parent [String]
            #   Required. The parent table shared by all rows being updated.
            #   Format: tables/{table}
            # @param requests [Array<Google::Area120::Tables::V1alpha1::UpdateRowRequest | Hash>]
            #   Required. The request messages specifying the rows to update.
            #
            #   A maximum of 500 rows can be modified in a single batch.
            #   A hash of the same form as `Google::Area120::Tables::V1alpha1::UpdateRowRequest`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Area120::Tables::V1alpha1::BatchUpdateRowsResponse]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Area120::Tables::V1alpha1::BatchUpdateRowsResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #
            #   # TODO: Initialize `parent`:
            #   parent = ''
            #
            #   # TODO: Initialize `requests`:
            #   requests = []
            #   response = tables_client.batch_update_rows(parent, requests)

            def batch_update_rows \
                parent,
                requests,
                options: nil,
                &block
              req = {
                parent: parent,
                requests: requests
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::BatchUpdateRowsRequest)
              @batch_update_rows.call(req, options, &block)
            end

            # Deletes a row.
            #
            # @param name [String]
            #   Required. The name of the row to delete.
            #   Format: tables/{table}/rows/{row}
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result []
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #   formatted_name = Google::Cloud::Area120::Tables::V1alpha1::TablesServiceClient.row_path("[TABLE]", "[ROW]")
            #   tables_client.delete_row(formatted_name)

            def delete_row \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::DeleteRowRequest)
              @delete_row.call(req, options, &block)
              nil
            end

            # Deletes multiple rows.
            #
            # @param parent [String]
            #   Required. The parent table shared by all rows being deleted.
            #   Format: tables/{table}
            # @param names [Array<String>]
            #   Required. The names of the rows to delete. All rows must belong to the parent table
            #   or else the entire batch will fail. A maximum of 500 rows can be deleted
            #   in a batch.
            #   Format: tables/{table}/rows/{row}
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result []
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/area120/tables"
            #
            #   tables_client = Google::Cloud::Area120::Tables.new(version: :v1alpha1)
            #   formatted_parent = Google::Cloud::Area120::Tables::V1alpha1::TablesServiceClient.table_path("[TABLE]")
            #
            #   # TODO: Initialize `formatted_names`:
            #   formatted_names = []
            #   tables_client.batch_delete_rows(formatted_parent, formatted_names)

            def batch_delete_rows \
                parent,
                names,
                options: nil,
                &block
              req = {
                parent: parent,
                names: names
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Area120::Tables::V1alpha1::BatchDeleteRowsRequest)
              @batch_delete_rows.call(req, options, &block)
              nil
            end
          end
        end
      end
    end
  end
end
