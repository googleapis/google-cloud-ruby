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
# https://github.com/googleapis/googleapis/blob/master/google/bigtable/admin/v2/bigtable_table_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/bigtable/admin/v2/bigtable_table_admin_pb"
require "google/cloud/bigtable/admin/credentials"

module Google
  module Cloud
    module Bigtable
      module Admin
        module V2
          # Service for creating, configuring, and deleting Cloud Bigtable tables.
          #
          #
          # Provides access to the table schemas only, not the data stored within
          # the tables.
          #
          # @!attribute [r] bigtable_table_admin_stub
          #   @return [Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub]
          class BigtableTableAdminClient
            attr_reader :bigtable_table_admin_stub

            # The default address of the service.
            SERVICE_ADDRESS = "bigtableadmin.googleapis.com".freeze

            # The default port of the service.
            DEFAULT_SERVICE_PORT = 443

            DEFAULT_TIMEOUT = 30

            PAGE_DESCRIPTORS = {
              "list_tables" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "tables"),
              "list_snapshots" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "snapshots")
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
              self::SERVICE_ADDRESS = BigtableTableAdminClient::SERVICE_ADDRESS
            end

            INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}"
            )

            private_constant :INSTANCE_PATH_TEMPLATE

            CLUSTER_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}/clusters/{cluster}"
            )

            private_constant :CLUSTER_PATH_TEMPLATE

            SNAPSHOT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}/clusters/{cluster}/snapshots/{snapshot}"
            )

            private_constant :SNAPSHOT_PATH_TEMPLATE

            TABLE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/instances/{instance}/tables/{table}"
            )

            private_constant :TABLE_PATH_TEMPLATE

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

            # Returns a fully-qualified snapshot resource name string.
            # @param project [String]
            # @param instance [String]
            # @param cluster [String]
            # @param snapshot [String]
            # @return [String]
            def self.snapshot_path project, instance, cluster, snapshot
              SNAPSHOT_PATH_TEMPLATE.render(
                :"project" => project,
                :"instance" => instance,
                :"cluster" => cluster,
                :"snapshot" => snapshot
              )
            end

            # Returns a fully-qualified table resource name string.
            # @param project [String]
            # @param instance [String]
            # @param table [String]
            # @return [String]
            def self.table_path project, instance, table
              TABLE_PATH_TEMPLATE.render(
                :"project" => project,
                :"instance" => instance,
                :"table" => table
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
              require "google/bigtable/admin/v2/bigtable_table_admin_services_pb"

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
                "bigtable_table_admin_client_config.json"
              )
              defaults = client_config_file.open do |f|
                Google::Gax.construct_settings(
                  "google.bigtable.admin.v2.BigtableTableAdmin",
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
              @bigtable_table_admin_stub = Google::Gax::Grpc.create_stub(
                service_path,
                port,
                chan_creds: chan_creds,
                channel: channel,
                updater_proc: updater_proc,
                scopes: scopes,
                &Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.method(:new)
              )

              @create_table = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:create_table),
                defaults["create_table"]
              )
              @create_table_from_snapshot = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:create_table_from_snapshot),
                defaults["create_table_from_snapshot"]
              )
              @list_tables = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:list_tables),
                defaults["list_tables"]
              )
              @get_table = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:get_table),
                defaults["get_table"]
              )
              @delete_table = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:delete_table),
                defaults["delete_table"]
              )
              @modify_column_families = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:modify_column_families),
                defaults["modify_column_families"]
              )
              @drop_row_range = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:drop_row_range),
                defaults["drop_row_range"]
              )
              @generate_consistency_token = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:generate_consistency_token),
                defaults["generate_consistency_token"]
              )
              @check_consistency = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:check_consistency),
                defaults["check_consistency"]
              )
              @snapshot_table = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:snapshot_table),
                defaults["snapshot_table"]
              )
              @get_snapshot = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:get_snapshot),
                defaults["get_snapshot"]
              )
              @list_snapshots = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:list_snapshots),
                defaults["list_snapshots"]
              )
              @delete_snapshot = Google::Gax.create_api_call(
                @bigtable_table_admin_stub.method(:delete_snapshot),
                defaults["delete_snapshot"]
              )
            end

            # Service calls

            # Creates a new table in the specified instance.
            # The table can be created with a full set of initial column families,
            # specified in the request.
            #
            # @param parent [String]
            #   The unique name of the instance in which to create the table.
            #   Values are of the form +projects/<project>/instances/<instance>+.
            # @param table_id [String]
            #   The name by which the new table should be referred to within the parent
            #   instance, e.g., +foobar+ rather than +<parent>/tables/foobar+.
            # @param table [Google::Bigtable::Admin::V2::Table | Hash]
            #   The Table to create.
            #   A hash of the same form as `Google::Bigtable::Admin::V2::Table`
            #   can also be provided.
            # @param initial_splits [Array<Google::Bigtable::Admin::V2::CreateTableRequest::Split | Hash>]
            #   The optional list of row keys that will be used to initially split the
            #   table into several tablets (tablets are similar to HBase regions).
            #   Given two split keys, +s1+ and +s2+, three tablets will be created,
            #   spanning the key ranges: +[, s1), [s1, s2), [s2, )+.
            #
            #   Example:
            #
            #   * Row keys := +["a", "apple", "custom", "customer_1", "customer_2",+
            #     +"other", "zz"]+
            #   * initial_split_keys := +["apple", "customer_1", "customer_2", "other"]+
            #   * Key assignment:
            #     * Tablet 1 +[, apple)                => {"a"}.+
            #       * Tablet 2 +[apple, customer_1)      => {"apple", "custom"}.+
            #       * Tablet 3 +[customer_1, customer_2) => {"customer_1"}.+
            #       * Tablet 4 +[customer_2, other)      => {"customer_2"}.+
            #       * Tablet 5 +[other, )                => {"other", "zz"}.+
            #   A hash of the same form as `Google::Bigtable::Admin::V2::CreateTableRequest::Split`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Table]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   table_id = ''
            #   table = {}
            #   response = bigtable_table_admin_client.create_table(formatted_parent, table_id, table)

            def create_table \
                parent,
                table_id,
                table,
                initial_splits: nil,
                options: nil
              req = {
                parent: parent,
                table_id: table_id,
                table: table,
                initial_splits: initial_splits
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CreateTableRequest)
              @create_table.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable snapshots. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Creates a new table from the specified snapshot. The target table must
            # not exist. The snapshot and the table must be in the same instance.
            #
            # @param parent [String]
            #   The unique name of the instance in which to create the table.
            #   Values are of the form +projects/<project>/instances/<instance>+.
            # @param table_id [String]
            #   The name by which the new table should be referred to within the parent
            #   instance, e.g., +foobar+ rather than +<parent>/tables/foobar+.
            # @param source_snapshot [String]
            #   The unique name of the snapshot from which to restore the table. The
            #   snapshot and the table must be in the same instance.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #   table_id = ''
            #   source_snapshot = ''
            #
            #   # Register a callback during the method call.
            #   operation = bigtable_table_admin_client.create_table_from_snapshot(formatted_parent, table_id, source_snapshot) do |op|
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

            def create_table_from_snapshot \
                parent,
                table_id,
                source_snapshot,
                options: nil
              req = {
                parent: parent,
                table_id: table_id,
                source_snapshot: source_snapshot
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest)
              operation = Google::Gax::Operation.new(
                @create_table_from_snapshot.call(req, options),
                @operations_client,
                Google::Bigtable::Admin::V2::Table,
                Google::Bigtable::Admin::V2::CreateTableFromSnapshotMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Lists all tables served from a specified instance.
            #
            # @param parent [String]
            #   The unique name of the instance for which tables should be listed.
            #   Values are of the form +projects/<project>/instances/<instance>+.
            # @param view [Google::Bigtable::Admin::V2::Table::View]
            #   The view to be applied to the returned tables' fields.
            #   Defaults to +NAME_ONLY+ if unspecified; no others are currently supported.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::Table>]
            #   An enumerable of Google::Bigtable::Admin::V2::Table instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
            #
            #   # Iterate over all results.
            #   bigtable_table_admin_client.list_tables(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   bigtable_table_admin_client.list_tables(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_tables \
                parent,
                view: nil,
                options: nil
              req = {
                parent: parent,
                view: view
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ListTablesRequest)
              @list_tables.call(req, options)
            end

            # Gets metadata information about the specified table.
            #
            # @param name [String]
            #   The unique name of the requested table.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param view [Google::Bigtable::Admin::V2::Table::View]
            #   The view to be applied to the returned table's fields.
            #   Defaults to +SCHEMA_VIEW+ if unspecified.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Table]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   response = bigtable_table_admin_client.get_table(formatted_name)

            def get_table \
                name,
                view: nil,
                options: nil
              req = {
                name: name,
                view: view
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GetTableRequest)
              @get_table.call(req, options)
            end

            # Permanently deletes a specified table and all of its data.
            #
            # @param name [String]
            #   The unique name of the table to be deleted.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   bigtable_table_admin_client.delete_table(formatted_name)

            def delete_table \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DeleteTableRequest)
              @delete_table.call(req, options)
              nil
            end

            # Performs a series of column family modifications on the specified table.
            # Either all or none of the modifications will occur before this method
            # returns, but data requests received prior to that point may see a table
            # where only some modifications have taken effect.
            #
            # @param name [String]
            #   The unique name of the table whose families should be modified.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param modifications [Array<Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification | Hash>]
            #   Modifications to be atomically applied to the specified table's families.
            #   Entries are applied in order, meaning that earlier modifications can be
            #   masked by later ones (in the case of repeated updates to the same family,
            #   for example).
            #   A hash of the same form as `Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Table]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   modifications = []
            #   response = bigtable_table_admin_client.modify_column_families(formatted_name, modifications)

            def modify_column_families \
                name,
                modifications,
                options: nil
              req = {
                name: name,
                modifications: modifications
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest)
              @modify_column_families.call(req, options)
            end

            # Permanently drop/delete a row range from a specified table. The request can
            # specify whether to delete all rows in a table, or only those that match a
            # particular prefix.
            #
            # @param name [String]
            #   The unique name of the table on which to drop a range of rows.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param row_key_prefix [String]
            #   Delete all rows that start with this row key prefix. Prefix cannot be
            #   zero length.
            # @param delete_all_data_from_table [true, false]
            #   Delete all rows in the table. Setting this to false is a no-op.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   bigtable_table_admin_client.drop_row_range(formatted_name)

            def drop_row_range \
                name,
                row_key_prefix: nil,
                delete_all_data_from_table: nil,
                options: nil
              req = {
                name: name,
                row_key_prefix: row_key_prefix,
                delete_all_data_from_table: delete_all_data_from_table
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DropRowRangeRequest)
              @drop_row_range.call(req, options)
              nil
            end

            # This is a private alpha release of Cloud Bigtable replication. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Generates a consistency token for a Table, which can be used in
            # CheckConsistency to check whether mutations to the table that finished
            # before this call started have been replicated. The tokens will be available
            # for 90 days.
            #
            # @param name [String]
            #   The unique name of the Table for which to create a consistency token.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::GenerateConsistencyTokenResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   response = bigtable_table_admin_client.generate_consistency_token(formatted_name)

            def generate_consistency_token \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GenerateConsistencyTokenRequest)
              @generate_consistency_token.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable replication. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Checks replication consistency based on a consistency token, that is, if
            # replication has caught up based on the conditions specified in the token
            # and the check request.
            #
            # @param name [String]
            #   The unique name of the Table for which to check replication consistency.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param consistency_token [String]
            #   The token created using GenerateConsistencyToken for the Table.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::CheckConsistencyResponse]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   consistency_token = ''
            #   response = bigtable_table_admin_client.check_consistency(formatted_name, consistency_token)

            def check_consistency \
                name,
                consistency_token,
                options: nil
              req = {
                name: name,
                consistency_token: consistency_token
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::CheckConsistencyRequest)
              @check_consistency.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable snapshots. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Creates a new snapshot in the specified cluster from the specified
            # source table. The cluster and the table must be in the same instance.
            #
            # @param name [String]
            #   The unique name of the table to have the snapshot taken.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/tables/<table>+.
            # @param cluster [String]
            #   The name of the cluster where the snapshot will be created in.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>+.
            # @param snapshot_id [String]
            #   The ID by which the new snapshot should be referred to within the parent
            #   cluster, e.g., +mysnapshot+ of the form: +[_a-zA-Z0-9][-_.a-zA-Z0-9]*+
            #   rather than
            #   +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/mysnapshot+.
            # @param description [String]
            #   Description of the snapshot.
            # @param ttl [Google::Protobuf::Duration | Hash]
            #   The amount of time that the new snapshot can stay active after it is
            #   created. Once 'ttl' expires, the snapshot will get deleted. The maximum
            #   amount of time a snapshot can stay active is 7 days. If 'ttl' is not
            #   specified, the default value of 24 hours will be used.
            #   A hash of the same form as `Google::Protobuf::Duration`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Longrunning::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
            #   cluster = ''
            #   snapshot_id = ''
            #   description = ''
            #   response = bigtable_table_admin_client.snapshot_table(formatted_name, cluster, snapshot_id, description)

            def snapshot_table \
                name,
                cluster,
                snapshot_id,
                description,
                ttl: nil,
                options: nil
              req = {
                name: name,
                cluster: cluster,
                snapshot_id: snapshot_id,
                description: description,
                ttl: ttl
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::SnapshotTableRequest)
              @snapshot_table.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable snapshots. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Gets metadata information about the specified snapshot.
            #
            # @param name [String]
            #   The unique name of the requested snapshot.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Bigtable::Admin::V2::Snapshot]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")
            #   response = bigtable_table_admin_client.get_snapshot(formatted_name)

            def get_snapshot \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::GetSnapshotRequest)
              @get_snapshot.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable snapshots. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Lists all snapshots associated with the specified cluster.
            #
            # @param parent [String]
            #   The unique name of the cluster for which snapshots should be listed.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>+.
            #   Use +<cluster> = '-'+ to list snapshots for all clusters in an instance,
            #   e.g., +projects/<project>/instances/<instance>/clusters/-+.
            # @param page_size [Integer]
            #   The maximum number of resources contained in the underlying API
            #   response. If page streaming is performed per-resource, this
            #   parameter does not affect the return value. If page streaming is
            #   performed per-page, this determines the maximum number of
            #   resources in a page.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::Snapshot>]
            #   An enumerable of Google::Bigtable::Admin::V2::Snapshot instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
            #
            #   # Iterate over all results.
            #   bigtable_table_admin_client.list_snapshots(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   bigtable_table_admin_client.list_snapshots(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_snapshots \
                parent,
                page_size: nil,
                options: nil
              req = {
                parent: parent,
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ListSnapshotsRequest)
              @list_snapshots.call(req, options)
            end

            # This is a private alpha release of Cloud Bigtable snapshots. This feature
            # is not currently available to most Cloud Bigtable customers. This feature
            # might be changed in backward-incompatible ways and is not recommended for
            # production use. It is not subject to any SLA or deprecation policy.
            #
            # Permanently deletes the specified snapshot.
            #
            # @param name [String]
            #   The unique name of the snapshot to be deleted.
            #   Values are of the form
            #   +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/bigtable/admin/v2"
            #
            #   bigtable_table_admin_client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new
            #   formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")
            #   bigtable_table_admin_client.delete_snapshot(formatted_name)

            def delete_snapshot \
                name,
                options: nil
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::DeleteSnapshotRequest)
              @delete_snapshot.call(req, options)
              nil
            end
          end
        end
      end
    end
  end
end
