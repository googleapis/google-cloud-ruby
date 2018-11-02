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
        # Table::ColumnFamilyMap is a hash accepting string `ColumnFamily` names as keys and `GcRule` objects as values.
        # It is used to create an instance.
        # @example Add column family with name and garbage collection rule
        #
        #  column_families = Google::Cloud::Bigtable::Instance::ColumnFamilyMap.new
        #
        #  column_families.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(3))
        #
        class ColumnFamilyMap < DelegateClass(::Hash)
          # @private
          # Create a new ColumnFamilyMap.
          def initialize value = {}
            super(value)
          end

          # Adds a column family.
          #
          # @param name [String] Column family name
          # @param gc_rule [Google::Bigtable::GcRule] GC Rule
          # @example
          #  column_families = Google::Cloud::Bigtable::Instance::ColumnFamilyMap.new
          #
          #  gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
          #  column_families.add('cf1', gc_rule_1)
          #
          #  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(1800)
          #  column_families.add('cf2', gc_rule)

          def add name, gc_rule
            self[name] = Google::Bigtable::Admin::V2::ColumnFamily.new(
              gc_rule: gc_rule.to_grpc
            )
          end

          # Removes a column family from the map.
          #
          # @param name [String] Column family name
          # @return [Google::Bigtable::Admin::V2::ColumnFamily]

          def remove name
            delete(name)
          end
        end
      end
    end
  end
end
