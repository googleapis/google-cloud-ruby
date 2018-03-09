# frozen_string_literal: true

module Google
  module Cloud
    module Bigtable
      # Invalid row state error
      class InvalidRowStateError < Google::Cloud::Error
        attr_reader :data

        def initialize message, data = nil
          super(message)
          @data = data if data
        end
      end

      class ChunkReader # :nodoc:
        # Row and cells chunk merger based on states

        # Row states
        NEW_ROW = 1
        ROW_IN_PROGRESS = 2
        CELL_IN_PROGRESS = 3

        # Current state
        attr_accessor :state, :last_key

        # Current cached row data
        attr_accessor :chunk, :row

        # current cell values
        attr_accessor :cur_family, :cur_qaul, :cur_ts, :cur_val, :cur_labels

        def initialize
          reset_to_new_row
        end

        def process chunk
          self.chunk = chunk

          if chunk.commit_row
            raise_if(
              chunk.value_size > 0,
              "A row cant not have value_size and commit_row"
            )
          end

          if state == NEW_ROW
            process_new_row
          elsif state == CELL_IN_PROGRESS
            process_cell_in_progress
          elsif state == ROW_IN_PROGRESS
            process_row_in_progress
          end
        end

        # Validate row status commit or reset
        def validate_reset_row
          return unless chunk.reset_row

          value = (!chunk.row_key.empty? ||
              chunk.family_name ||
              chunk.qualifier ||
              !chunk.value.empty? ||
              chunk.timestamp_micros.positive?)

          raise_if value, "A reset should have no data"
        end

        def validate_new_row
          raise_if(row.key, "A new row cannot have existing state")
          raise_if(chunk.row_key.empty?, "A row key must be set")
          raise_if(chunk.reset_row, "A new row cannot be reset")
          raise_if(
            last_key == chunk.row_key,
            "A commit happened but the same key followed"
          )
          raise_if(chunk.family_name.nil?, "A family must be set")
          raise_if(chunk.qualifier.nil?, "A column qualifier must be set")
        end

        def validate_row_in_progress
          raise_if(
            !chunk.row_key.empty? && chunk.row_key != row.key,
            "A commit is required between row keys"
          )

          raise_if(
            chunk.family_name && chunk.qualifier.nil?,
            "A qualifier must be specified"
          )

          validate_reset_row
        end

        def process_new_row
          validate_new_row

          return if chunk.family_name.nil? || chunk.qualifier.nil?

          row.key = chunk.row_key
          self.cur_family = chunk.family_name.value
          self.cur_qaul = chunk.qualifier.value
          self.cur_ts = chunk.timestamp_micros
          self.cur_labels = chunk.labels

          next_state!
        end

        def process_row_in_progress
          validate_row_in_progress

          return reset_to_new_row if chunk.reset_row

          self.cur_family = chunk.family_name.value if chunk.family_name
          self.cur_qaul = chunk.qualifier.value if chunk.qualifier
          self.cur_ts = chunk.timestamp_micros
          self.cur_labels = chunk.labels if chunk.labels
          next_state!
        end

        def process_cell_in_progress
          validate_reset_row

          return reset_to_new_row if chunk.reset_row

          next_state!
        end

        def next_state!
          if cur_val
            self.cur_val += chunk.value
          else
            self.cur_val = chunk.value
          end

          if chunk.value_size.zero?
            persist_cell
            self.state = ROW_IN_PROGRESS
          else
            self.state = CELL_IN_PROGRESS
          end

          return unless chunk.commit_row

          self.last_key = row.key
          completed_row = row
          reset_to_new_row
          completed_row
        end

        def persist_cell
          cell = FlatRow::Cell.new(
            cur_family,
            cur_qaul,
            cur_ts,
            cur_val,
            cur_labels
          )
          row.cells[cur_family] << cell

          # Clear cached cell values
          self.cur_val = nil
          self.cur_ts = nil
          self.cur_labels = nil
        end

        # Reset read state and cached data
        def reset_to_new_row
          self.row = FlatRow.new
          self.state = NEW_ROW
          self.cur_family = nil
          self.cur_qaul = nil
          self.cur_ts = nil
          self.cur_val = nil
          self.cur_labels = nil
        end

        def validate_last_row_complete
          return if row.key.nil?

          raise_if(
            !chunk.commit_row,
            "Response ended with pending row without commit"
          )
        end

        private

        def raise_if condition, message
          raise InvalidRowStateError.new(message, chunk.to_hash) if condition
        end
      end
    end
  end
end
