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
      # # MutationOperations
      #
      # Collection of mutations APIs.
      #
      #   * Mutate single row
      #   * Mutate multiple rows
      #   * Read modify and write row atomically on the server
      #   * Check and mutate row
      #
      module MutationOperations
        # Mutate row.
        #
        # Mutates a row atomically. Cells in the row are left
        # unchanged unless explicitly changed by +mutation+.
        # Changes to be atomically applied to the specified row. Entries are applied
        # in order, meaning that earlier mutations can be masked by later mutations.
        # Must contain at least one mutation entry and at most 100,000.
        #
        # @param entry [Google::Cloud::Bigtable::MutationEntry]
        #   Mutation entry with row key and list of mutations.
        # @return [Boolean]
        # @example Single mutation on row.
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
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
        #   table = bigtable.table("my-instance", "my-table")
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
          client.mutate_row(
            path,
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
        #   contain a maximum of 100,000 mutations.
        # @return [Array<Google::Bigtable::V2::MutateRowsResponse::Entry>]
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   entries = []
        #   entries << table.new_mutation_entry("row-1").set_cell("cf1", "field1", "XYZ")
        #   entries << table.new_mutation_entry("row-2").set_cell("cf1", "field1", "ABC")
        #   table.mutate_row(entries)
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
        #   The row key of the row to which the read/modify/write rules should be applied.
        # @param rules [Google::Cloud::Bigtable::ReadModifyWriteRule, Array<Google::Cloud::Bigtable::ReadModifyWriteRule>]
        #   Rules specifying how the specified row's contents are to be transformed
        #   into writes. Entries are applied in order, meaning that earlier rules will
        #   affect the results of later ones.
        # @return [Google::Cloud::Bigtable::Row]
        # @example Apply multiple modification rules.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
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
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   rule = table.new_read_modify_write_rule("cf", "field01").append("append-xyz")
        #
        #   row = table.read_modify_write_row("user01", rule)
        #
        #   puts row.cells
        #
        def read_modify_write_row key, rules
          res_row = client.read_modify_write_row(
            path,
            key,
            Array(rules).map(&:to_grpc),
            app_profile_id: @app_profile_id
          ).row
          row = Row.new(res_row.key)

          res_row.families.each do |family|
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

        # Mutates a row atomically based on the output of a predicate reader filter.
        #
        # NOTE: Condition predicate filter is not supported.
        #
        # @param key [String] Row key.
        #   The row key of the row to which the conditional mutation should be applied.
        # @param predicate [SimpleFilter, ChainFilter, InterleaveFilter] Predicate filter.
        #   The filter to be applied to the contents of the specified row. Depending
        #   on whether or not any results are yielded, either +true_mutations+ or
        #   +false_mutations+ will be executed. If unset, checks that the row contains
        #   any values.
        # @param on_match [Google::Cloud::Bigtable::MutationEntry] Mutation entry 
        #   applied to predicate filter match.
        #   Changes to be atomically applied to the specified row if +predicate_filter+
        #   yields at least one cell when applied to +row_key+. Entries are applied in
        #   order, meaning that earlier mutations can be masked by later ones.
        #   Must contain at least one entry if +false_mutations+ is empty and at most
        #   100,000 entries.
        # @param otherwise [Google::Cloud::Bigtable::MutationEntry] Mutation entry applied 
        #   when predicate filter does not match.
        #   Changes to be atomically applied to the specified row if +predicate_filter+
        #   does not yield any cells when applied to +row_key+. Entries are applied in
        #   order, meaning that earlier mutations can be masked by later ones.
        #   Must contain at least one entry if +true_mutations+ is empty and at most
        #   100,000 entries.
        # @return [Boolean]
        #   Predicate match or not status
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   predicate_filter = Google::Cloud::Bigtable::RowFilter.key("user-10")
        #   on_match_mutations = Google::Cloud::Bigtable::MutationEntry.new
        #   on_match_mutations.set_cell(
        #     "cf-1",
        #     "field-1",
        #     "XYZ",
        #     timestamp: Time.now.to_i * 1000 # Time stamp in micro seconds.
        #   ).delete_from_column("cf2", "field02")
        #
        #   otherwise_mutations = Google::Cloud::Bigtable::MutationEntry.new
        #   otherwise_mutations.delete_from_family("cf3")
        #
        #   response = table.check_and_mutate_row(
        #     "user01",
        #     predicate_filter,
        #     on_match: on_match_mutations,
        #     otherwise: otherwise_mutations
        #   )
        #
        #   if response
        #     puts "All predicates matched"
        #   end
        #
        def check_and_mutate_row \
            key,
            predicate,
            on_match: nil,
            otherwise: nil
          true_mutations = on_match.mutations if on_match
          false_mutations = otherwise.mutations if otherwise
          response = client.check_and_mutate_row(
            path,
            key,
            predicate_filter: predicate.to_grpc,
            true_mutations: true_mutations,
            false_mutations: false_mutations,
            app_profile_id: @app_profile_id
          )
          response.predicate_matched
        end

        # Read sample row keys.
        #
        # Returns a sample of row keys in the table. The returned row keys will
        # delimit contiguous sections of the table of approximately equal size. The
        # sections can be used to break up the data for distributed tasks like
        # mapreduces.
        #
        # @yieldreturn [Google::Cloud::Bigtable::SampleRowKey]
        # @return [:yields: sample_row_key]
        #   Yield block for each processed SampleRowKey.
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   table.sample_row_keys.each do |sample_row_key|
        #     p sample_row_key.key # user00116
        #     p sample_row_key.offset # 805306368
        #   end
        #
        def sample_row_keys
          return enum_for(:sample_row_keys) unless block_given?

          response = client.sample_row_keys(
            path,
            app_profile_id: @app_profile_id
          )
          response.each do |grpc|
            yield SampleRowKey.from_grpc(grpc)
          end
        end

        # Create an instance of mutation_entry
        #
        # @param row_key [String] Row key. Optional
        #   The row key of the row to which the mutation should be applied.
        # @return [Google::Cloud::Bigtable::MutationEntry]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   entry = table.new_mutation_entry("row-key-1")
        #
        #   # Without row key
        #   entry = table.new_mutation_entry
        #
        def new_mutation_entry row_key = nil
          Google::Cloud::Bigtable::MutationEntry.new(row_key)
        end

        # Create an instance of ReadModifyWriteRule to append or increment the value
        # of the cell qualifier.
        #
        # @param family [String]
        #   The name of the column family to which the read/modify/write should be applied.
        # @param qualifier [String]
        #   The qualifier of the column to which the read/modify/write should be applied.
        # @return [Google::Cloud::Bigtable::ReadModifyWriteRule]
        #
        # @example Create rule to append to qualifier value.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
        #   rule = table.new_read_modify_write_rule("cf", "qualifier-1")
        #   rule.append("append-xyz")
        #
        # @example Create rule to increment qualifier value.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table("my-instance", "my-table")
        #   rule = table.new_read_modify_write_rule("cf", "qualifier-1")
        #   rule.increment(100)
        #
        def new_read_modify_write_rule family, qualifier
          Google::Cloud::Bigtable::ReadModifyWriteRule.new(family, qualifier)
        end
      end
    end
  end
end
