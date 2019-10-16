# frozen_string_literal: true

# Copyright 2019 Google LLC
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
        # An accumulator for modifications to a table's column families. See
        # {Table#column_families}. Modifications will be atomically applied to
        # the table's column families. Entries are applied in order, meaning
        # that earlier modifications can be masked by later ones (in the case
        # of repeated updates to the same family, for example).
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
        #
        #   table.column_families do |cf_updater|
        #
        #     cf_updater.add "cf1", Google::Cloud::Bigtable::GcRule.max_age(600)
        #     cf_updater.add "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
        #
        #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
        #     rule_union = Google::Cloud::Bigtable::GcRule.union(rule_1, rule_2)
        #     cf_updater.update "cf3", rule_union
        #
        #     cf_updater.delete "cf5"
        #   end
        #
        class ColumnFamiliesUpdater
          # @private
          attr_reader :modifications

          # @private
          def initialize
            @modifications = []
          end

          ##
          # Adds a new column family to the table.
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
          #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
          #
          #   table.column_families do |cf_updater|
          #     cf_updater.add "cf1", Google::Cloud::Bigtable::GcRule.max_age(600)
          #     cf_updater.add "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
          #   end
          #
          def add name, gc_rule = nil
            modifications.push(
              self.class.column_modification_grpc(:create, name, gc_rule)
            )
            nil
          end
          alias create add

          ##
          # Updates an existing column family in the table.
          #
          # @param name [String] Column family name
          # @param gc_rule [Google::Cloud::Bigtable::GcRule] The new garbage
          #   collection rule to be used for the column family. Optional. The
          #   service default value will be used when not specified.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
          #
          #   table.column_families do |cf_updater|
          #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
          #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
          #     rule_union = Google::Cloud::Bigtable::GcRule.union(rule_1, rule_2)
          #
          #     cf_updater.update "cf3", rule_union
          #   end
          #
          def update name, gc_rule = nil
            modifications.push(
              self.class.column_modification_grpc(:update, name, gc_rule)
            )
            nil
          end

          ##
          # Deletes the named column family from the table.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
          #
          #   table.column_families do |cf_updater|
          #     cf_updater.delete "cf5"
          #   end
          #
          def delete name
            modifications.push(
              self.class.column_modification_grpc(:drop, name)
            )
            nil
          end
          alias drop delete

          # @private
          #
          # Create column family modification gRPC instance
          #
          # @param type [Symbol] Type of modification.
          #   Valid values are `:create`, `:update`, `drop`
          # @param family_name [String] Column family name
          # @param gc_rule [Google::Cloud::Bigtable::GcRule] The garbage
          #   collection rule to be used for the column family. Optional. The
          #   service default value will be used when not specified.
          # @return [Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification]
          #
          def self.column_modification_grpc type, family_name, gc_rule = nil
            attrs = { id: family_name }

            attrs[type] = if type == :drop
                            true
                          else
                            cf = Google::Bigtable::Admin::V2::ColumnFamily.new
                            cf.gc_rule = gc_rule.to_grpc if gc_rule
                            cf
                          end

            Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
            Modification.new(attrs)
          end
        end
      end
    end
  end
end
