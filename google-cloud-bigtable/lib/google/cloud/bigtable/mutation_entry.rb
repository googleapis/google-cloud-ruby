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
      # MutationEntry
      #
      # MutationEntry is a chainable structure, which hold data for diffrent
      # type of mutations. It is used in murate rows, and check and mutate row
      # using predicate.
      #
      # @example
      #   entry = Google::Cloud::Bigtable::MutationEntry.new(row_key: "user-1")
      #   entry.set_cell({
      #     family_name: "cf1",
      #     column_qualifier: "field01",
      #     timestamp_micros: Time.now.to_i * 1000,
      #     value: "XYZ"
      #   }).delete_from_column({
      #     family_name: "cf2",
      #     column_qualifier: "fiel01",
      #     time_range: {
      #       start_timestamp_micros: (Time.now - 1.day).to_i * 1000,
      #       end_timestamp_micros: Time.now.to_i * 1000
      #     }
      #   }).delete_from_family("cf3").delete_from_row
      class MutationEntry
        attr_accessor :row_key, :mutations

        # Create instance of mutation entry
        #
        # @param row_key [String]
        def initialize row_key: nil
          @row_key = row_key
          @mutations = []
        end

        # Add SetCell mutation to list of mutations
        #
        # @param family_name [String]
        # @param column_qualifier [String]
        # @param timestamp_micros [Integer]
        # @param value [String]
        # @return [MutationEntry]
        #   `self` object of mutation entry for chaining.

        def set_cell \
            family_name: nil,
            column_qualifier: nil,
            timestamp_micros: nil,
            value: nil
          options = {
            family_name: family_name,
            column_qualifier: column_qualifier,
            timestamp_micros: timestamp_micros,
            value: value
          }.delete_if { |_, v| v.nil? }

          @mutations << Google::Bigtable::V2::Mutation.new(set_cell: options)
          self
        end

        # Add DeleteFromColumn mutation to list of mutations
        #
        # @param family_name [String]
        # @param column_qualifier [String]
        # @param time_range [Google::Bigtable::V2::TimestampRange | Hash]
        # @return [MutationEntry]
        #   `self` object of mutation entry for chaining.

        def delete_from_column \
            family_name: nil,
            column_qualifier: nil,
            time_range: nil
          options = {
            family_name: family_name,
            column_qualifier: column_qualifier,
            time_range: time_range
          }.delete_if { |_, v| v.nil? }

          @mutations <<
            Google::Bigtable::V2::Mutation.new(delete_from_column: options)
        end

        # Add DeleteFromFamily to list of mutations
        #
        # @param family_name [String]
        # @return [MutationEntry]
        #   `self` object of mutation entry for chaining.

        def delete_from_family family_name
          options = { family_name: family_name }
          @mutations <<
            Google::Bigtable::V2::Mutation.new(delete_from_family: options)
        end

        # Add DeleteFromRow mutation to list of mutations
        #
        # @return [MutationEntry]
        #   `self` object of mutation entry for chaining.

        def delete_from_row
          @mutations <<
            Google::Bigtable::V2::Mutation.new(delete_from_row: {})
        end
      end
    end
  end
end
