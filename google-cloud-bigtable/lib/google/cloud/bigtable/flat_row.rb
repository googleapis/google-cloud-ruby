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
      # FlatRow
      #
      # Row structure based on merged cells using read row state.
      class FlatRow
        # Cell
        #
        # Row cell build from data chunks.
        class Cell
          attr_accessor :family, :qualifier, :value, :labels, :timestamp_micros

          # Create cell object
          #
          # @param family [String] Column family name
          # @param qualifier [String] Column cell qualifier name
          # @param timestamp_micros [Integer] Timestamp in micro seconds
          # @param value [String] Cell value
          # @param labels [Array<String>] List of label array

          def initialize family, qualifier, timestamp_micros, value, labels = []
            @family = family
            @qualifier = qualifier
            @timestamp_micros = timestamp_micros
            @value = value
            @labels = labels
          end

          # Timestamp in "Time" object format
          # @return [Time | nil]

          def timestamp
            Time.at(@timestamp_micros / 100_0000) if @timestamp_micros
          end

          # Cell object comparator
          #
          # @return [Boolean]

          def == other
            return false unless self.class == other.class

            instance_variables.all? do |var|
              instance_variable_get(var) == other.instance_variable_get(var)
            end
          end
        end

        attr_accessor :key, :cells

        # Create flat row object
        #
        # @param key [String] Row key name

        def initialize key = nil
          @key = key
          @cells = Hash.new { |h, k| h[k] = [] }
        end

        # List of column families
        # @return [Array<String>]

        def column_families
          @cells.keys
        end

        # FlatRow object comparator
        # @return [Boolean]

        def == other
          return false unless self.class == other.class
          if key != other.key || column_families != other.column_families
            return false
          end

          cells.all? do |family, list|
            list == other.cells[family]
          end
        end
      end
    end
  end
end
