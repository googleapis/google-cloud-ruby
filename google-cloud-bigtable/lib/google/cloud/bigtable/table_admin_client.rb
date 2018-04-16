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


require "google/cloud/bigtable/admin/v2"

module Google
  module Cloud
    module Bigtable
      # TableAdminClient
      #
      # Table admin operation client for create,delete table, list tables,
      # drop row range and add/update/delete column families.
      class TableAdminClient
        # @private
        attr_reader :options, :project_id, :instance_id

        # @private
        #
        # @param project_id [String]
        # @param instance_id [String]
        # @param options [Hash]
        def initialize project_id, instance_id, options = {}
          @project_id = project_id
          @instance_id = instance_id
          @options = options
        end

        # Create table
        #
        # @param table [Google::Bigtable::Admin::V2::Table | Hash]
        #   The Table to create. Valid fields are name, timestamp granularity,
        #   column families
        # @param initial_splits [Array<String>]
        #   List of row keys that will be used to initially split the
        #   table into several tablets. (tablets are similar to HBase regions)
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   column_family = Google::Bigtable::Admin::V2::ColumnFamily.new({
        #     gc_rule: { max_num_versions: 1 }
        #   })
        #
        #   table = Google::Bigtable::Admin::V2::Table({
        #     name: "table-1",
        #     column_families: { "cf1" => column_family }
        #   })
        #
        #   initial_split_keys = ["customer_1", "customer_2", "other"]
        #
        #   client.create_table(table, initial_splits: initial_split_keys)

        def create_table table, initial_splits: []
          req_table = table.clone
          req_table.name = ""
          client.create_table(
            instance_path,
            table.name,
            req_table,
            initial_splits: initial_splits
          )
        end

        # Get table information
        # @param table_id [String]
        #   Existing table id
        # @param view [Google::Bigtable::Admin::V2::Table::View]
        #   The view to be applied to the returned table's fields.
        #   Defaults to +SCHEMA_VIEW+ if unspecified.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   client.table("table-1")
        #
        #   # Using view type
        #   client.table("table-1", view :SCHEMA_VIEW)

        def table table_id, view: nil
          client.get_table(
            table_path(table_id),
            view: view
          )
        end

        # List all tables information
        #
        # @param view [Google::Bigtable::Admin::V2::Table::View]
        #   The view to be applied to the returned table's fields.
        #   Defaults to +SCHEMA_VIEW+ if unspecified.
        # @return [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::Table>]
        #   An enumerable of Google::Bigtable::Admin::V2::Table instances.
        #   See Google::Gax::PagedEnumerable documentation for other
        #   operations such as per-page iteration or access to the response
        #   object.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   tables = client.tables
        #
        #   # Using view type
        #   tables = client.tables(view :FULL)

        def tables view: nil
          client.list_tables(
            instance_path,
            view: view
          )
        end

        # Delete table
        # @param table_id [String]
        #   Existing table id
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   client.delete_table("table-1")

        def delete_table table_id
          client.delete_table(
            table_path(table_id)
          )
        end

        # Modify column falmilies
        #
        # @param table_id [String]
        #   Existing table id
        # @param modifications [Array<Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification | Hash>]
        #   Modifications to be atomically applied to the specified table's families
        #   Entries are applied in order, meaning that earlier modifications can be
        #   masked by later ones.
        # @return [Google::Bigtable::Admin::V2::Table]
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   modifications = []
        #
        #   modifications << {
        #     id: "cf1",
        #     create: { gc_rule: { max_num_versions: 3 } }
        #   }
        #
        #   modifications << { id: "cf2", drop: true }
        #
        #   modifications << {
        #     id: "cf3",
        #     update: { gc_rule: { max_age: { seconds: 3600 } } }
        #   }
        #
        #   client.modify_column_families("table-1", modifications)

        def modify_column_families table_id, modifications
          client.modify_column_families(
            table_path(table_id),
            modifications
          )
        end

        # Drop row range
        # Permanently drop/delete a row range from a specified table.
        # The request can specify whether to delete all rows in a table,
        # or only those that match a particular prefix.
        # @param table_id [String]
        #   Existing table id
        # @param row_key_prefix [String]
        #   Delete all rows that start with this row key prefix. Prefix cannot be
        #   zero length.
        # @param delete_all_data_from_table [true, false]
        #   Delete all rows in the table. Setting this to false is a no-op.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   client.drop_row_range("table-1", row_key_prefix: "user")
        #
        #   # Delete all data
        #   client.drop_row_range("table-1", delete_all_data_from_table: true)

        def drop_row_range \
            table_id,
            row_key_prefix: nil,
            delete_all_data_from_table: nil
          client.drop_row_range(
            table_path(table_id),
            row_key_prefix: row_key_prefix,
            delete_all_data_from_table: delete_all_data_from_table
          )
        end

        # This is a private alpha release of Cloud Bigtable snapshots. This feature
        # is not currently available to most Cloud Bigtable customers. This feature
        # might be changed in backward-incompatible ways and is not recommended for
        # production use. It is not subject to any SLA or deprecation policy.
        #
        # Creates a new snapshot in the specified cluster from the specified
        # source table. The cluster and the table must be in the same instance.
        #
        # @param table_id [String]
        #   The unique name of the table to have the snapshot taken.
        # @param cluster_id [String]
        #   The name of the cluster where the snapshot will be created in.
        # @param snapshot_id [String]
        #   The ID by which the new snapshot should be referred to within the parent
        #   cluster, e.g., +mysnapshot+ of the form: +[_a-zA-Z0-9][-_.a-zA-Z0-9]*+
        # @param description [String]
        #   Description of the snapshot.
        # @param ttl [Integer]
        #   The amount of time in seconds that the new snapshot can stay active
        #   after it is created. Once 'ttl' expires, the snapshot will get
        #   deleted. The maximum amount of time a snapshot can stay active is
        #   7 days. If 'ttl' is not specified, the default value of 24 hours
        #   will be used.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Longrunning::Operation]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   response = client.create_snapshot(
        #     "table-1",
        #     "cluster-1",
        #     "mysnapshot",
        #     "table-1 snapshot on cluster-1 with 1 day ttl",
        #     ttl: 1800 # 30 minutes
        #   )

        def create_snapshot \
            table_id,
            cluster_id,
            snapshot_id,
            description,
            ttl: nil,
            options: nil
          ttl = Google::Protobuf::Duration.new(seconds: ttl) if ttl
          client.snapshot_table(
            table_path(table_id),
            cluster_path(cluster_id),
            snapshot_id,
            description,
            ttl: ttl,
            options: options
          )
        end

        # This is a private alpha release of Cloud Bigtable snapshots. This feature
        # is not currently available to most Cloud Bigtable customers. This feature
        # might be changed in backward-incompatible ways and is not recommended for
        # production use. It is not subject to any SLA or deprecation policy.
        #
        # Creates a new table from the specified snapshot. The target table must
        # not exist. The snapshot and the table must be in the same instance.
        #
        # @param table_id [String]
        #   The name by which the new table should be referred to within the
        #   instance, e.g., +foobar+.
        # @param cluster_id [String]
        #   Cluster id in which snapshot exists. e.g., +cluster-users+
        # @param source_snapshot_id [String]
        #   The unique name of the snapshot from which to restore the table. The
        #   snapshot and the table must be in the same instance.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Gax::Operation]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   # Register a callback during the method call.
        #   operation = client.create_table_from_snapshot(
        #     "new-table",
        #     "cluster-1",
        #     "users-snapshot"
        #   ) do |op|
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
            table_id,
            cluster_id,
            source_snapshot_id,
            options: nil
          client.create_table_from_snapshot(
            instance_path,
            table_id,
            snapshot_path(cluster_id, source_snapshot_id),
            options: options
          )
        end

        # This is a private alpha release of Cloud Bigtable snapshots. This feature
        # is not currently available to most Cloud Bigtable customers. This feature
        # might be changed in backward-incompatible ways and is not recommended for
        # production use. It is not subject to any SLA or deprecation policy.
        #
        # Gets metadata information about the specified snapshot.
        #
        # @param snapshot_id [String]
        #   The unique name of the requested snapshot.
        # @param cluster_id [String]
        #   Cluster id in which snapshot exists. e.g., +cluster-users+
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Bigtable::Admin::V2::Snapshot]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   snapshot = client.snapshot("users-snapshot")

        def snapshot \
            snapshot_id,
            cluster_id,
            options: nil
          client.get_snapshot(
            snapshot_path(cluster_id, snapshot_id),
            options: options
          )
        end

        # This is a private alpha release of Cloud Bigtable snapshots. This feature
        # is not currently available to most Cloud Bigtable customers. This feature
        # might be changed in backward-incompatible ways and is not recommended for
        # production use. It is not subject to any SLA or deprecation policy.
        #
        # Lists all snapshots associated with the specified cluster.
        #
        # @param cluster_id [String]
        #   The unique name of the cluster for which snapshots should be listed.
        #   Default value is +'-'+ which list snapshots for all clusters in
        #   an instance
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
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   client.snapshots(cluster_id: "cluster-1").each do |snapshot|
        #     # Process snapshot
        #     p snapshot
        #   end
        #
        #   # Or iterate over results one page at a time.
        #   client.snapshots(cluster_id: "cluster-1").each_page do |page|
        #     # Process each page at a time.
        #     page.each do |snapshot|
        #       # Process snapshot.
        #       p snapshot
        #     end
        #   end
        #
        #   # List all snapshots from all clusters
        #   client.snapshots.each do |snapshot|
        #     # Process snapshot
        #     p snapshot
        #   end

        def snapshots \
            cluster_id = "-",
            page_size: nil,
            options: nil
          client.list_snapshots(
            cluster_path(cluster_id),
            page_size: page_size,
            options: options
          )
        end

        # This is a private alpha release of Cloud Bigtable snapshots. This feature
        # is not currently available to most Cloud Bigtable customers. This feature
        # might be changed in backward-incompatible ways and is not recommended for
        # production use. It is not subject to any SLA or deprecation policy.
        #
        # Permanently deletes the specified snapshot.
        #
        # @param cluster_id [String]
        #   Cluster id in which snapshot exists.
        # @param snapshot_id [String]
        #   The unique name of the snapshot to be deleted from cluster.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Boolean]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(
        #     client_type: :table,
        #     instance_id: "instance-id"
        #   )
        #
        #   client.delete_snapshot("cluster-1", "users-snapshot")


        def delete_snapshot \
            cluster_id,
            snapshot_id,
            options: nil
          client.delete_snapshot(
            snapshot_path(cluster_id, snapshot_id),
            options: options
          )
          true
        end

        private

        # Create table admin client or return existing client object
        # @return [Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient]

        def client
          @client ||= begin
            if options[:credentials].is_a?(String)
              options[:credentials] =
                Admin::Credentials.new(
                  options[:credentials],
                  scopes: options[:scopes]
                )
            end

            Admin::V2::BigtableTableAdmin.new options
          end
        end

        # Created formatted instance path
        # @return [String]
        #   Formatted instance path
        #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.

        def instance_path
          Admin::V2::BigtableTableAdminClient
            .instance_path(
              project_id,
              instance_id
            )
        end

        # Created formatted table path
        # @param table_id [String]
        # @return [String]
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+

        def table_path table_id
          Admin::V2::BigtableTableAdminClient
            .table_path(
              project_id,
              instance_id,
              table_id
            )
        end

        # Created formatted cluster path
        # @param cluster_id [String]
        # @return [String]
        #   Formatted cluster path
        #   +projects/<project>/instances/<instance>/clusters/<cluster>+.

        def cluster_path cluster_id
          Admin::V2::BigtableTableAdminClient
            .cluster_path(
              project_id,
              instance_id,
              cluster_id
            )
        end

        # Created formatted snapshot path
        # @param cluster_id [String]
        # @param snapshot_id [String]
        # @return [String]
        #   Formatted snapshot path
        #   +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/mysnapshot+.

        def snapshot_path cluster_id, snapshot_id
          Admin::V2::BigtableTableAdminClient
            .snapshot_path(
              project_id,
              instance_id,
              cluster_id,
              snapshot_id
            )
        end
      end
    end
  end
end
