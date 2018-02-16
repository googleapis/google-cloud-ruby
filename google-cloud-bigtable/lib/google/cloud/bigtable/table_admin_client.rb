# frozen_string_literal: true

require "google/cloud/bigtable/admin/v2"

module Google
  module Cloud
    module Bigtable
      class TableAdminClient
        # Client for table admin operations

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
      end
    end
  end
end
