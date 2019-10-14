# frozen_string_literal: true

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


module Google
  module Cloud
    module Bigtable
      class Table
        ##
        # Table::ColumnFamilyMap is a hash delegate that contains string column
        # family names as keys and `ColumnFamily` objects as values.
        # It is used to manage the column families belonging to a table.
        #
        # @example Create a table with column families.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table("my-instance", "my-table") do |column_families|
        #     column_families.add("cf1", Google::Cloud::Bigtable::GcRule.max_versions(5))
        #     column_families.add("cf2", Google::Cloud::Bigtable::GcRule.max_age(600))
        #
        #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     column_families.add("cf3", gc_rule)
        #   end
        #
        #   puts table
        #
        # @example Inspect the column families in a table.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
        #
        #   table.column_families.each do |name, cf|
        #     puts name
        #     puts cf.gc_rule
        #   end
        #
        #   # Get a column family by name
        #   cf1 = table.column_families["cf1"]
        #
        class ColumnFamilyMap < DelegateClass(::Hash)
          # @private
          # Create a new ColumnFamilyMap.
          def initialize value = {}
            super(value)
          end

          ##
          # Adds a column family.
          #
          # @param name [String] Column family name
          # @param gc_rule [Google::Cloud::Bigtable::GcRule] The garbage
          #   collection rule to be used for the column family. Optional. The
          #   service default value will be used when not specified.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   table = bigtable.create_table("my-instance", "my-table") do |column_families|
          #     column_families.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(5))
          #     column_families.add('cf2', Google::Cloud::Bigtable::GcRule.max_age(600))
          #
          #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
          #       Google::Cloud::Bigtable::GcRule.max_age(1800),
          #       Google::Cloud::Bigtable::GcRule.max_versions(3)
          #     )
          #     column_families.add('cf3', gc_rule)
          #   end
          #
          #   puts table
          #
          def add name, gc_rule = nil
            cf = Google::Cloud::Bigtable::ColumnFamily.new name
            cf.gc_rule = gc_rule if gc_rule
            self[name] = cf
          end

          # @private
          # @param grpc [Hash{String => Google::Bigtable::Admin::V2::ColumnFamily}]
          #   A hash with column family names as keys, from
          #   `Google::Bigtable::Admin::V2::Table#column_families`.
          # @return [Google::Cloud::Bigtable::Table::ColumnFamilyMap]
          #
          def self.from_grpc grpc
            new(
              grpc.map do |name, cf_grpc|
                [
                  name,
                  ColumnFamily.from_grpc(cf_grpc, name)
                ]
              end.to_h
            )
          end

          # @private
          # @return [Hash{String => Google::Bigtable::Admin::V2::ColumnFamily}]
          #   A hash with column family names as keys, for
          #   `Google::Bigtable::Admin::V2::Table#column_families`.
          #
          def to_grpc
            map do |name, cf|
              cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new
              cf_grpc.gc_rule = cf.gc_rule.to_grpc if cf.gc_rule
              [name, cf_grpc]
            end.to_h
          end
        end
      end
    end
  end
end
