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
      ##
      # # ColumnRange
      #
      # Specifies a contiguous range of column qualifiers.
      #
      # * Start qualifier bound : The qualifier at which to start the range.
      #   If neither field is set, interpreted as the empty string, inclusive.
      # * End qualifier bound: The qualifier at which to end the range.
      #   If neither field is set, interpreted as the infinite string qualifier, exclusive.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   # Range that includes all qualifiers including "user-001" up until "user-010"
      #   table.new_column_range("cf").from("user-001").to("user-010")
      #
      #   # Range that includes all qualifiers including "user-001" up to and including "user-005"
      #   table.new_column_range("cf").from("user-001").to("user-005", inclusive: true)
      #
      #   # Range that includes all qualifiers until end of the row key "user-001".
      #   table.new_column_range("cf").to("user-010") # exclusive
      #
      #   # Range with unbounded start and the inclusive end "user-100"
      #   table.new_column_range("cf").to("user-100", inclusive: true)
      #
      #   # Range that includes all qualifiers including "user-001" up to and including "user-100"
      #   table.new_column_range("cf").between("user-001", "user-100")
      #
      class ColumnRange
        ##
        # Create qualifier range instance.
        #
        # @param family [String] Column family name.
        #
        def initialize family
          @grpc = Google::Cloud::Bigtable::V2::ColumnRange.new family_name: family
        end

        ##
        # Gets the column family name.
        #
        # @return [String]
        #
        def family
          @grpc.family_name
        end

        ##
        # Sets the column family name.
        #
        # @param name [String] Column family name
        #
        def family= name
          @grpc.family_name = name
        end

        ##
        # Sets the column range with the lower bound.
        #
        # @param qualifier [String] Column qualifier name. Required
        # @param inclusive [String] Lower bound flag. Inclusive/Exclusive.
        #   Default is an inclusive lower bound.
        # @return [Google::Cloud::Bigtable::ColumnRange]
        #
        # @example Inclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").from("qualifier-1")
        #
        # @example Exclusive lower bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").from("qualifier-1", inclusive: false)
        #
        def from qualifier, inclusive: true
          if inclusive
            @grpc.start_qualifier_closed = qualifier
          else
            @grpc.start_qualifier_open = qualifier
          end
          self
        end

        ##
        # Sets the column range with the upper bound.
        #
        # @param qualifier [String] Column qualifier name. Required.
        # @param inclusive [String] Upper bound flag. Inclusive/Exclusive.
        #   Default is an inclusive upper bound.
        # @return [Google::Cloud::Bigtable::ColumnRange]
        #
        # @example Inclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").to("qualifier-10", inclusive: true)
        #
        # @example Exclusive upper bound.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").to("qualifier-10")
        #
        def to qualifier, inclusive: false
          if inclusive
            @grpc.end_qualifier_closed = qualifier
          else
            @grpc.end_qualifier_open = qualifier
          end
          self
        end

        ##
        # Sets the column range with the inclusive upper and lower bound.
        #
        # @param from_qualifier [String] Inclusive from qualifier. Required.
        # @param to_qualifier [String] Inclusive to qualifier. Required.
        # @return [Google::Cloud::Bigtable::ColumnRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").between("qualifier-1", "qualifier-10")
        #
        def between from_qualifier, to_qualifier
          from(from_qualifier).to(to_qualifier, inclusive: true)
        end

        ##
        # Sets the column range with the inclusive upper and the exclusive lower bound.
        #
        # @param from_qualifier [String] Inclusive from qualifier
        # @param to_qualifier [String] Exclusive to qualifier
        # @return [Google::Cloud::Bigtable::ColumnRange]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.new_column_range("cf").of("qualifier-1", "qualifier-10")
        #
        def of from_qualifier, to_qualifier
          from(from_qualifier).to(to_qualifier)
        end

        # @private
        #
        # @return [Google::Cloud::Bigtable::V2::ColumnRange]
        #
        def to_grpc
          @grpc
        end
      end
    end
  end
end
