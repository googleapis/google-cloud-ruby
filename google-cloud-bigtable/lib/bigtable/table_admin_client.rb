# frozen_string_literal: true

require "google/cloud/bigtable/admin/v2"
require "google/bigtable/admin/v2/table_pb"
require "google/bigtable/admin/v2/bigtable_table_admin_pb"

module Bigtable
  # Protobuf structure references
  Table = Google::Bigtable::Admin::V2::Table
  ColumnFamily = Google::Bigtable::Admin::V2::ColumnFamily
  GcRule = Google::Bigtable::Admin::V2::GcRule
  ColumnFamilyModification =
    Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification

  class TableAdminError < StandardError; end # :nodoc:

  class TableAdminClient
    # Client for table admin operations
    #
    # @example
    #   Bigtable::TableAdminClient.new(
    #     "project-id-xyz",
    #     "instance-id-abc"
    #     credentials: "keyfile.json"
    #   )
    #
    # Or if google project default credentials set on server
    #
    #  Bigtable::TableAdminClient.new("project-id-xyz", "instance-id-abc")
    #

    attr_reader :options, :project_id, :instance_id

    # @param project_id [String]
    # @param instance_id [String]
    # @param options [Hash]
    def initialize project_id, instance_id, options = {}
      @project_id = project_id
      @instance_id = instance_id
      @options = options
    end

    # Create table
    # @param table [Bigtable::Table | Hash]
    #   The Table to create. Valid fields are name, timestamp granularity,
    #   column families
    # @param initial_splits [Array<String>]
    # @example
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   column_families = {
    #     "cf1" => Bigtable::ColumnFamily.new gc_rule: { max_num_versions: 1 }
    #   }
    #
    #   table = Bigtable::Table.new({
    #     name: "table-1",
    #     column_families: column_families,
    #   })
    #
    #   initial_split_keys = ["customer_1", "customer_2", "other"]
    #
    #   client.create_table table, initial_splits
    #

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
    # @param view [Bigtable::Table::View]
    #   The view to be applied to the returned table's fields.
    #   Defaults to +SCHEMA_VIEW+ if unspecified.
    # @example
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   client.table "table-1"
    #
    #   # Or using view type
    #   client.table "table-1", view :SCHEMA_VIEW

    def table table_id, view: nil
      client.get_table(
        table_path(table_id),
        view: view
      )
    end

    # List all tables information
    # @param view [Bigtable::Table::View]
    #   The view to be applied to the returned table's fields.
    #   Defaults to +SCHEMA_VIEW+ if unspecified.
    # @return [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::Table>]
    #   An enumerable of Google::Bigtable::Admin::V2::Table instances.
    #   See Google::Gax::PagedEnumerable documentation for other
    #   operations such as per-page iteration or access to the response
    #   object.
    # @example
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   client.tables
    #
    #   # Or using view type
    #   client.tables view :SCHEMA_VIEW

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
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   client.delete_table "table-1"

    def delete_table table_id
      client.delete_table(
        table_path(table_id)
      )
    end

    # Modify column falmilies
    # @param table_id [String]
    #   Existing table id
    # @param modifications [Array<Bigtable::ColumnFamilyModification | Hash>]
    #   Modifications to be atomically applied to the specified table's families
    #   Entries are applied in order, meaning that earlier modifications can be
    #   masked by later ones.
    # @return [Google::Bigtable::Admin::V2::Table]
    # @example
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   modifications = [
    #     Bigtable::ColumnFamilyModification.new({
    #       id: 'cf1',
    #       create: Bigtable::ColumnFamily.new(gc_rule: { max_num_versions: 1 })
    #     }),
    #     Bigtable::ColumnFamilyModification.new({
    #       id: 'cf2',
    #       drop: true
    #     })
    #   ]
    #
    #   client.modify_column_families "table-1", modifications

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
    #   client = Bigtable.table_admin_client("project-id", "instance-id")
    #
    #   client.drop_row_range "table_1", row_key_prefix: "user"
    #
    #   # Or delete all data
    #   client.drop_row_range "table_1", delete_all_data_from_table: true

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

    private

    # Create table admin client or return existing client object
    # @return [Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient]
    def client
      @client ||=
        Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin.new(
          options
        )
    end

    # Created formatted instance path
    # @return [String]
    #   Formatted instance path
    #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.
    def instance_path
      Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient
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
      Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient
        .table_path(
          project_id,
          instance_id,
          table_id
        )
    end
  end
end
