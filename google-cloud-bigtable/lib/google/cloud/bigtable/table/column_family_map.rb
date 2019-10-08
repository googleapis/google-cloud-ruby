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
        # Table::ColumnFamilyMap is a hash accepting string column family names
        # as keys and `ColumnFamily` objects as values.
        # It is used to manage the column families belonging to a table.
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

          def self.from_grpc grpc, instance_id, table_id, service
            new(
              grpc.map do |name, cf_grpc|
                [
                  name,
                  ColumnFamily.from_grpc(
                    cf_grpc,
                    service,
                    name: name,
                    instance_id: instance_id,
                    table_id: table_id
                  )
                ]
              end.to_h
            )
          end
        end
      end
    end
  end
end
