# frozen_string_literal: true

require "google/gax"
require "google/cloud/bigtable/v2"
require "google/cloud/bigtable/chunk_reader"
require "google/cloud/bigtable/flat_row"
require "google/cloud/bigtable/mutation_entry"
require "google/cloud/bigtable/rows_reader"

module Google
  module Cloud
    module Bigtable
      GRPC_RETRYABLE_ERRORS = [
        GRPC::DeadlineExceeded,
        GRPC::Aborted,
        GRPC::Unavailable,
        GRPC::Core::CallError
      ].freeze

      DEFAULT_READ_RETRY_COUNT = 3

      class TableDataOperations
        attr_reader :client, :table_path, :app_profile_id

        def initialize client, table_path, app_profile_id = nil
          @client = client
          @table_path = table_path
          @app_profile_id = app_profile_id
        end

        # Read rows
        #
        # @param rows [Google::Bigtable::V2::RowSet | Hash]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   A hash of the same form as `Google::Bigtable::V2::RowSet`
        #   can also be provided.
        # @param filter [Google::Bigtable::V2::RowFilter | Hash]
        #   The filter to apply to the contents of the specified row(s). If unset,
        #   reads the entirety of each row.
        #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
        #   can also be provided.
        # @param rows_limit [Integer]
        #   The read will terminate after committing to N rows' worth of results.
        #   The default (zero) is to return all results.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Array<Google::Cloud::Bigtable::FlatRow> | :yields: row]
        #   Array of row or yield block for each processed row.
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(instance_id: "instance-id")
        #
        #   table = client.table("table-name")
        #
        #   table.read_rows(rows_limit: 100) do |row|
        #     p row
        #   end
        #
        #   # OR - without block
        #   rows = table.read_rows(rows_limit: 100)
        #
        #   # With row keys
        #   rows_set = Google::Bigtable::V2::RowSet.new
        #   row_set.row_keys << "user01"
        #   row_set.row_keys << "user02"
        #
        #   row_range = Google::Bigtable::V2::RowRange.new({
        #     start_key_closed: "user00",
        #     end_key_closed: "user10"
        #   )

        #   row_set.row_ranges << row_range
        #
        #   table.read_rows(rows: rows_set) do |row|
        #     p row
        #   end

        def read_rows \
            rows: nil,
            filter: nil,
            rows_limit: nil,
            options: nil,
            &block
          max_retries = DEFAULT_READ_RETRY_COUNT
          if options && options[:max_retries].to_i.positive?
            max_retries = options[:max_retries]
          end

          retry_count = 0
          req_row_set = build_row_set(rows)
          req_rows_limit = rows_limit
          rows_reader = RowsReader.new(
            client,
            table_path,
            app_profile_id,
            options
          )

          begin
            retry_count = 0
            rows_reader.read(
              rows: req_row_set,
              filter: filter,
              rows_limit: req_rows_limit,
              &block
            )
          rescue *GRPC_RETRYABLE_ERRORS => e
            raise e if retry_count >= max_retries

            retry_count += 1
            req_rows_limit, req_row_set =
              rows_reader.retry_options(rows_limit, req_row_set)
            retry
          end
        end

        # Read single row
        #
        # @param row_key [String]
        #   The row keys and/or ranges to read.
        #   If not specified, reads from all rows.
        #   A hash of the same form as `Google::Bigtable::V2::RowSet`
        #   can also be provided.
        # @param filter [Google::Bigtable::V2::RowFilter | Hash]
        #   The filter to apply to the contents of the specified row(s). If unset,
        #   reads the entirety of each row.
        #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
        #   can also be provided.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Cloud::Bigtable::FlatRow]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud::Bigtable.new(instance_id: "instance-id")
        #
        #   table = client.table("table-name")
        #
        #   row = table.read_row("user01")

        def read_row \
          row_key,
          filter: nil,
          options: nil

          row_set = Google::Bigtable::V2::RowSet.new(row_keys: [row_key])

          rows = read_rows(
            rows: row_set,
            filter: filter,
            rows_limit: 1,
            options: options
          )
          rows.first
        end

        # Read sample row keys
        #
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Enumerable<Google::Bigtable::V2::SampleRowKeysResponse>]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud.bigtable(instance_id: "instance_id")
        #
        #   table = client.table("table-name")
        #
        #   table.sample_row_keys

        def sample_row_keys options: nil
          client.sample_row_keys(
            table_path,
            app_profile_id: app_profile_id,
            options: options
          )
        end

        # Mutates a row atomically. Cells already present in the row are left
        # unchanged unless explicitly changed by +mutation+.
        #
        # @param entry [Google::Cloud::Bigtable::MutationEntry]
        #   entry has key of the row to which the mutation should be applied and
        #   list mutations are changes to be atomically applied to the specified row.
        #   Mutation entries are applied in order, meaning that earlier mutations can be
        #   masked by later ones.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Bigtable::V2::MutateRowResponse]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud.bigtable(instance_id: "instance_id")
        #
        #   table = client.table("table-name")
        #
        #   entry = Google::Cloud::Bigtable::MutationEntry.new(row_key: "user01")
        #   entry.set_cell({
        #     family_name: "cf1",
        #     column_qualifier: "field01",
        #     timestamp_micros: Time.now.to_i * 1000,
        #     value: "XYZ"
        #   }).delete_from_column({
        #     family_name: "cf2",
        #     column_qualifier: "fiel01",
        #     time_range: {
        #       start_timestamp_micros: (Time.now - 1.day).to_i * 1000,
        #       end_timestamp_micros: Time.now.to_i * 1000
        #     }
        #   }).delete_from_family("cf3").delete_from_row
        #
        #   table.mutate_row(entry)

        def mutate_row \
            entry,
            options: nil
          client.mutate_row(
            table_path,
            entry.row_key,
            entry.mutations,
            app_profile_id: app_profile_id,
            options: options
          )
        end

        # Mutates multiple rows in a batch. Each individual row is mutated
        # atomically as in MutateRow, but the entire batch is not executed
        # atomically.
        #
        # @param entries [Array<Google::Cloud::Bigtable::MutationEntry>]
        #   The row keys and corresponding mutations to be applied in bulk.
        #   Each entry is applied as an atomic mutation, but the entries may be
        #   applied in arbitrary order (even between entries for the same row).
        #   At least one entry must be specified, and in total the entries can
        #   contain at most 100000 mutations.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Enumerable<Google::Bigtable::V2::MutateRowsResponse>]
        #   An enumerable of Google::Bigtable::V2::MutateRowsResponse instances.
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud.bigtable(instance_id: "instance_id")
        #
        #   table = client.table("table-name")
        #
        #   entry1 = Google::Cloud::Bigtable::MutationEntry.new(row_key: "user01")
        #   entry1.set_cell({
        #     family_name: "cf1",
        #     column_qualifier: "field01",
        #     timestamp_micros: Time.now.to_i * 1000,
        #     value: "XYZ"
        #   }).delete_from_column({
        #     family_name: "cf2",
        #     column_qualifier: "fiel01"
        #     time_range: {
        #       start_timestamp_micros: (Time.now - 1.day).to_i * 1000,
        #       end_timestamp_micros: Time.now.to_i * 1000
        #     }
        #   }).delete_from_family("cf3").delete_from_row
        #
        #   entry2 = Google::Cloud::Bigtable::MutationEntry.new(row_key: "user02")
        #   entry2.delete_from_row
        #
        #   table.mutate_row([entry1, entry2]).each do |res|
        #     p res
        #   end

        def mutate_rows \
            entries,
            options: nil
          req_entries = entries.map do |e|
            Google::Bigtable::V2::MutateRowsRequest::Entry.new(
              row_key: e.row_key,
              mutations: e.mutations
            )
          end

          client.mutate_rows(
            table_path,
            req_entries,
            app_profile_id: app_profile_id,
            options: options
          )
        end

        # Mutates a row atomically based on the output of a predicate Reader filter.
        #
        # @param row_key [String]
        #   The key of the row to which the conditional mutation should be applied.
        # @param predicate_filter [Google::Bigtable::V2::RowFilter | Hash]
        #   The filter to be applied to the contents of the specified row. Depending
        #   on whether or not any results are yielded, either +true_mutations+ or
        #   +false_mutations+ will be executed. If unset, checks that the row contains
        #   any values at all.
        #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
        #   can also be provided.
        #   Use alias of `Bigtable::RowFilter` of `Google::Bigtable::V2::RowFilter`
        # @param true_mutations [Google::Cloud::Bigtable::MutationEntry]
        #   Changes to be atomically applied to the specified row if +predicate_filter+
        #   yields at least one cell when applied to +row_key+. Entries are applied in
        #   order, meaning that earlier mutations can be masked by later ones.
        #   Must contain at least one entry if +false_mutations+ is empty, and at most
        #   100000.
        #   A hash of the same form as `Google::Bigtable::V2::Mutation`
        #   can also be provided.
        # @param false_mutations [Google::Cloud::Bigtable::MutationEntry]
        #   Changes to be atomically applied to the specified row if +predicate_filter+
        #   does not yield any cells when applied to +row_key+. Entries are applied in
        #   order, meaning that earlier mutations can be masked by later ones.
        #   Must contain at least one entry if +true_mutations+ is empty, and at most
        #   100000.
        #   A hash of the same form as `Google::Bigtable::V2::Mutation`
        #   can also be provided.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Boolean]
        #   Predicate match or not status
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud.bigtable(instance_id: "instance_id")
        #
        #   table = client.table("table-id")
        #
        #   predicate_filter = Google::Bigtable::V2::RowFilter.new(sink: true)
        #   true_mutations = Google::Cloud::Bigtable::MutationEntry.new
        #   entry.set_cell({
        #     family_name: "cf1",
        #     column_qualifier: "field01",
        #     timestamp_micros: Time.now.to_i * 1000,
        #     value: "XYZ"
        #   }).delete_from_column({
        #     family_name: "cf2",
        #     column_qualifier: "fiel01",
        #     time_range: {
        #       start_timestamp_micros: (Time.now - 1.day).to_i * 1000,
        #       end_timestamp_micros: Time.now.to_i * 1000
        #     }
        #   })
        #
        #   false_mutations = Google::Cloud::Bigtable::MutationEntry.new
        #   false_mutations.delete_from_family("cf3")
        #
        #   response = table.check_and_mutate_row(
        #     "user01",
        #     predicate_filter: predicate_filter,
        #     true_mutations: true_mutations,
        #     false_mutations: false_mutations
        #   )
        #
        #   if response
        #     puts "All predicates matched"
        #   end
        #

        def check_and_mutate_row \
            row_key,
            predicate_filter: nil,
            true_mutations: nil,
            false_mutations: nil,
            options: nil
          req_true_mutations = true_mutations.mutations if true_mutations
          req_false_mutations = false_mutations.mutations if false_mutations

          response = client.check_and_mutate_row(
            table_path,
            row_key,
            app_profile_id: app_profile_id,
            predicate_filter: predicate_filter,
            true_mutations: req_true_mutations,
            false_mutations: req_false_mutations,
            options: options
          )

          response.predicate_matched
        end

        # Modifies a row atomically on the server. The method reads the latest
        # existing timestamp and value from the specified columns and writes a new
        # entry based on pre-defined read/modify/write rules. The new value for the
        # timestamp is the greater of the existing timestamp or the current server
        # time. The method returns the new contents of all modified cells.
        #
        # @param row_key [String]
        #   The key of the row to which the read/modify/write rules should be applied.
        # @param rules [Array<Google::Bigtable::V2::ReadModifyWriteRule | Hash>]
        #   Rules specifying how the specified row's contents are to be transformed
        #   into writes. Entries are applied in order, meaning that earlier rules will
        #   affect the results of later ones.
        #   A hash of the same form as `Google::Bigtable::V2::ReadModifyWriteRule`
        #   can also be provided.
        #   Use protobuf alias `Bigtable::ReadModifyWriteRule` of
        #   `Google::Bigtable::V2::ReadModifyWriteRule`
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Cloud::Bigtable::FlatRow]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   client = Google::Cloud.bigtable(instance_id: "instance_id")
        #
        #   table = client.table("table-name")
        #
        #   rule1 = Google::Bigtable::V2::ReadModifyWriteRule.new({
        #     family_name: "cf1",
        #     column_qualifier: "c_qual",
        #     increment_amount: 1
        #   })
        #
        #   rule2 = Google::Bigtable::V2::ReadModifyWriteRule.new({
        #     family_name: "cf2",
        #     column_qualifier: "c_qual",
        #     append_value: "Extra Data"
        #   })
        #
        #   row = table.read_modify_write_row("user01", [rule1, rule2])
        #
        #   puts row.key
        #   puts row.column_families

        def read_modify_write_row \
            row_key,
            rules,
            options: nil
          response = client.read_modify_write_row(
            table_path,
            row_key,
            rules,
            app_profile_id: app_profile_id,
            options: options
          )

          flat_row = FlatRow.new(response.row.key)

          response.row.families.each do |family|
            family.columns.each do |column|
              column.cells.each do |cell|
                flat_row_cell = FlatRow::Cell.new(
                  family.name,
                  column.qualifier,
                  cell.timestamp_micros,
                  cell.value,
                  cell.labels
                )
                flat_row.cells[family.name] << flat_row_cell
              end
            end
          end

          flat_row
        end

        private

        # Build row set object for retryable read row operation.
        #
        # @param rows [Google::Bigtable::V2::RowSet | Hash]
        # @return [Google::Bigtable::V2::RowSet]

        def build_row_set rows
          return Google::Bigtable::V2::RowSet.new unless rows

          if rows.is_a?(Hash)
            return Google::Bigtable::V2::RowSet.new(
              row_keys: rows[:row_keys] || [],
              row_ranges: rows[:row_ranges] || []
            )
          end

          Google::Bigtable::V2::RowSet.new(
            row_keys: rows.row_keys.to_a,
            row_ranges: rows.row_ranges.map(&:clone)
          )
        end
      end
    end
  end
end
