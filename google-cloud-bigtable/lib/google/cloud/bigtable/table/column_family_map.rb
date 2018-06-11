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
        # Table::ColumnFamilyMap is a Hash with column_family name and grpc object.
        # It is used to create instance.
        # @example Create
        #
        #  column_families = Google::Cloud::Bigtable::Instance::ColumnFamilyMap.new
        #
        #  column_families.add("cluster-1", 3, location: "us-east1-b", storage_type: :SSD)
        #
        #  # Or
        #  column_families.add("cluster-2", 1)
        #
        class ColumnFamilyMap < DelegateClass(::Hash)
          # @private
          # Create a new ColumnFamilyMap.
          def initialize value = {}
            super(value)
          end

          # Add column family.
          #
          # @param name [String] Column family name
          # @param gc_rule [Google::Bigtable::GcRule | Hash]

          def add name, gc_rule
            self[name] = \
              Google::Bigtable::Admin::V2::ColumnFamily.new(
                gc_rule: gc_rule.grpc
              )
          end

          # Remove column family from map.
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
