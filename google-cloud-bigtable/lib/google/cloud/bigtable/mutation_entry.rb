# frozen_string_literal: true

module Google
  module Cloud
    module Bigtable
      class MutationEntry
        # Chainable mutation entry data holder
        attr_accessor :row_key, :mutations

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
