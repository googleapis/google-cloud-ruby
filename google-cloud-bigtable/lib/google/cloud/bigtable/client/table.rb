# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/bigtable/mutation_entry"
require "google/cloud/bigtable/row"
require "google/cloud/bigtable/rows_mutator"
require "google/cloud/bigtable/read_modify_write_rule"

module Google
  module Cloud
    module Bigtable
      class Client
        # # Table
        #
        # A table is used to read and/or modify data in a Cloud Bigtable table.
        #
        # See {Google::Cloud::Bigtable::Client#table}.
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   client = bigtable.client "my-instance"
        #   table = client.table("my-table")
        #
        #   entry = table.new_mutation_entry("user-1")
        #   entry.set_cell("cf1", "field1", "XYZ")
        #   table.mutate_row(entry)
        #
        class Table
          # @return [Google::Cloud::Bigtable::V2::BigtableClient] gRPC client instance for data operations..
          attr_reader :client

          # @return [String] Formatted table path
          attr_reader :path

          # @return [String] App profile id for request routing.
          attr_reader :app_profile_id

          # @private
          # Creates a new Bigtable table client instance to perform data operations.
          #
          # @param client [Google::Cloud::Bigtable::V2::BigtableClient]
          # @param path [String] The unique identifier formated path for the table.
          #   i.e +projects/<project>/instances/<instance>/tables/<table>+
          # @param app_profile_id [String] The unique identifier for the app profile. Optional.
          #  This value specifies routing for replication. If not specified, the
          #  "default" application profile will be used.
          #
          def initialize client, path, app_profile_id: nil
            @client = client
            @path = path
            @app_profile_id = app_profile_id
          end

          # Mutate row.
          #
          # Mutates a row atomically. Cells already present in the row are left
          # unchanged unless explicitly changed by +mutation+.
          # Changes to be atomically applied to the specified row. Entries are applied
          # in order, meaning that earlier mutations can be masked by later ones.
          # Must contain at least one mutation entry and at most 100000.
          #
          # @param entry [Google::Cloud::Bigtable::MutationEntry]
          #   Mutation entry with row key and list of mutations.
          # @return [Boolean]
          # @example Single mutation on row.
          #   require "google/cloud"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #
          #   entry = table.new_mutation_entry.new("user-1")
          #   entry.set_cell("cf1", "field1", "XYZ")
          #   table.mutate_row(entry)
          #
          # @example Multiple mutations on row.
          #   require "google/cloud"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #
          #   entry = table.new_mutation_entry("user-1")
          #   entry.set_cell(
          #     "cf-1",
          #     "field-1",
          #     "XYZ"
          #     timestamp: Time.now.to_i * 1000 # Time stamp in milli seconds.
          #   ).delete_from_column("cf2", "field02")
          #
          #   table.mutate_row(entry)
          #
          def mutate_row entry
            @client.mutate_row(
              @path,
              entry.row_key,
              entry.mutations,
              app_profile_id: @app_profile_id
            )
            true
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
          # @return [Array<Google::Bigtable::V2::MutateRowsResponse::Entry>]
          #
          def mutate_rows entries
            RowsMutator.new(self, entries).apply_mutations
          end

          # Modifies a row atomically on the server. The method reads the latest
          # existing timestamp and value from the specified columns and writes a new
          # entry based on pre-defined read/modify/write rules. The new value for the
          # timestamp is the greater of the existing timestamp or the current server
          # time. The method returns the new contents of all modified cells.
          #
          # @param key [String]
          #   The key of the row to which the read/modify/write rules should be applied.
          # @param rules [Google::Cloud::Bigtable::ReadModifyWriteRule, Array<Google::Cloud::Bigtable::ReadModifyWriteRule>]
          #   Rules specifying how the specified row's contents are to be transformed
          #   into writes. Entries are applied in order, meaning that earlier rules will
          #   affect the results of later ones.
          # @return [Google::Cloud::Bigtable::Row]
          # @example Apply multiple modification rules.
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #
          #   rule_1 = table.new_read_modify_write_rule("cf", "field01")
          #   rule_1.append("append-xyz")
          #
          #   rule_2 = table.new_read_modify_write_rule("cf", "field01")
          #   rule_2.increment(1)
          #
          #   row = table.read_modify_write_row("user01", [rule_1, rule_2])
          #
          #   puts row.cells
          #
          # @example Apply single modification rules.
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #
          #   rule = table.new_read_modify_write_rule("cf", "field01").append("append-xyz")
          #
          #   row = table.read_modify_write_row("user01", rule)
          #
          #   puts row.cells
          #
          def read_modify_write_row key, rules
            rules = [rules] unless rules.instance_of?(Array)
            response = @client.read_modify_write_row(
              @path,
              key,
              rules.map(&:to_grpc),
              app_profile_id: @app_profile_id
            )
            row = Row.new(response.row.key)

            response.row.families.each do |family|
              family.columns.each do |column|
                column.cells.each do |cell|
                  row_cell = Row::Cell.new(
                    family.name,
                    column.qualifier,
                    cell.timestamp_micros,
                    cell.value,
                    cell.labels
                  )
                  row.cells[family.name] << row_cell
                end
              end
            end

            row
          end

          # Create instance of mutation_entry
          #
          # @param row_key [String] Row key. Optional
          #   The key of the row to which the mutation should be applied.
          # @return [Google::Cloud::Bigtable::MutationEntry]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #
          #   entry = table.new_mutation_entry("row-key-1")
          #
          #   # Without row key
          #   entry = table.new_mutation_entry
          #
          def new_mutation_entry row_key = nil
            Google::Cloud::Bigtable::MutationEntry.new(row_key)
          end

          # Create instance of ReadModifyWriteRule to append or increment value
          # of the cell qualifier.
          #
          # @param family [String]
          #   The name of the family to which the read/modify/write should be applied.
          # @param qualifier [String]
          #   The qualifier of the column to which the read/modify/write should be
          # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
          #
          # @example Create rule to append to qualifier value.
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #   rule = table.new_read_modify_write_rule("cf", "qualifier-1")
          #   rule.append("append-xyz")
          #
          # @example Create rule to increment qualifier value.
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   client = bigtable.client("my-instance")
          #   table = client.table("my-table")
          #   rule = table.new_read_modify_write_rule("cf", "qualifier-1")
          #   rule.increment(100)
          #
          def new_read_modify_write_rule family, qualifier
            Google::Cloud::Bigtable::ReadModifyWriteRule.new(family, qualifier)
          end

          # @private
          # @return [String]
          #
          def inspect
            "#{self.class}(#{@path})"
          end
        end
      end
    end
  end
end
