# Copyright 2017 Google LLC
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
  module Bigtable
    module Admin
      module V2
        # A collection of user data indexed by row, column, and timestamp.
        # Each table is served using the resources of its parent cluster.
        # @!attribute [rw] name
        #   @return [String]
        #     (+OutputOnly+)
        #     The unique name of the table. Values are of the form
        #     +projects/<project>/instances/<instance>/tables/[_a-zA-Z0-9][-_.a-zA-Z0-9]*+.
        #     Views: +NAME_ONLY+, +SCHEMA_VIEW+, +FULL+
        # @!attribute [rw] column_families
        #   @return [Hash{String => Google::Bigtable::Admin::V2::ColumnFamily}]
        #     (+CreationOnly+)
        #     The column families configured for this table, mapped by column family ID.
        #     Views: +SCHEMA_VIEW+, +FULL+
        # @!attribute [rw] granularity
        #   @return [Google::Bigtable::Admin::V2::Table::TimestampGranularity]
        #     (+CreationOnly+)
        #     The granularity (e.g. +MILLIS+, +MICROS+) at which timestamps are stored in
        #     this table. Timestamps not matching the granularity will be rejected.
        #     If unspecified at creation time, the value will be set to +MILLIS+.
        #     Views: +SCHEMA_VIEW+, +FULL+
        class Table
          # Possible timestamp granularities to use when keeping multiple versions
          # of data in a table.
          module TimestampGranularity
            # The user did not specify a granularity. Should not be returned.
            # When specified during table creation, MILLIS will be used.
            TIMESTAMP_GRANULARITY_UNSPECIFIED = 0

            # The table keeps data versioned at a granularity of 1ms.
            MILLIS = 1
          end

          # Defines a view over a table's fields.
          module View
            # Uses the default view for each method as documented in its request.
            VIEW_UNSPECIFIED = 0

            # Only populates +name+.
            NAME_ONLY = 1

            # Only populates +name+ and fields related to the table's schema.
            SCHEMA_VIEW = 2

            # Populates all fields.
            FULL = 4
          end
        end

        # A set of columns within a table which share a common configuration.
        # @!attribute [rw] gc_rule
        #   @return [Google::Bigtable::Admin::V2::GcRule]
        #     Garbage collection rule specified as a protobuf.
        #     Must serialize to at most 500 bytes.
        #
        #     NOTE: Garbage collection executes opportunistically in the background, and
        #     so it's possible for reads to return a cell even if it matches the active
        #     GC expression for its family.
        class ColumnFamily; end

        # Rule for determining which cells to delete during garbage collection.
        # @!attribute [rw] max_num_versions
        #   @return [Integer]
        #     Delete all cells in a column except the most recent N.
        # @!attribute [rw] max_age
        #   @return [Google::Protobuf::Duration]
        #     Delete cells in a column older than the given age.
        #     Values must be at least one millisecond, and will be truncated to
        #     microsecond granularity.
        # @!attribute [rw] intersection
        #   @return [Google::Bigtable::Admin::V2::GcRule::Intersection]
        #     Delete cells that would be deleted by every nested rule.
        # @!attribute [rw] union
        #   @return [Google::Bigtable::Admin::V2::GcRule::Union]
        #     Delete cells that would be deleted by any nested rule.
        class GcRule
          # A GcRule which deletes cells matching all of the given rules.
          # @!attribute [rw] rules
          #   @return [Array<Google::Bigtable::Admin::V2::GcRule>]
          #     Only delete cells which would be deleted by every element of +rules+.
          class Intersection; end

          # A GcRule which deletes cells matching any of the given rules.
          # @!attribute [rw] rules
          #   @return [Array<Google::Bigtable::Admin::V2::GcRule>]
          #     Delete cells which would be deleted by any element of +rules+.
          class Union; end
        end
      end
    end
  end
end