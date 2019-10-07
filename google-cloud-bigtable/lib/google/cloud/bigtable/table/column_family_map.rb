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
        # Table::ColumnFamilyMap is a hash accepting string `ColumnFamily` names as keys and `GcRule` objects as values.
        # It is used to create an instance.
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
          def add name, gc_rule = nil
            cf = Google::Bigtable::Admin::V2::ColumnFamily.new
            cf.gc_rule = gc_rule.to_grpc if gc_rule
            self[name] = cf
          end

          ##
          # Removes a column family from the map.
          #
          # @param name [String] Column family name
          # @return [Google::Bigtable::Admin::V2::ColumnFamily]
          #
          def remove name
            delete(name)
          end
        end
      end
    end
  end
end
