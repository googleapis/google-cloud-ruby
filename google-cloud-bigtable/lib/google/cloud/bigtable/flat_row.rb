# frozen_string_literal: true

module Google
  module Cloud
    module Bigtable
      # Merged row object with cells
      class FlatRow
        # Row cell
        class Cell
          attr_accessor :family, :qualifier, :value, :labels, :timestamp_micros

          def initialize family, qualifier, timestamp_micros, value, labels = []
            @family = family
            @qualifier = qualifier
            @timestamp_micros = timestamp_micros
            @value = value
            @labels = labels
          end

          # timestamp in milliseconds
          # @return [Integer]

          def timestamp
            Time.at(@timestamp / 100_0000)
          end

          def == other # :nodoc:
            return false unless self.class == other.class

            instance_variables.all? do |var|
              instance_variable_get(var) == other.instance_variable_get(var)
            end
          end
        end

        attr_accessor :key, :cells

        def initialize key = nil
          @key = key
          @cells = Hash.new { |h, k| h[k] = [] }
        end

        # Column families
        # @return [String]

        def column_families
          @cells.keys
        end

        def == other # :nodoc:
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
