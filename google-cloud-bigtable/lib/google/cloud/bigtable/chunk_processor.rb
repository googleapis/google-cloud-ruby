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
      # @private
      # # RowsMutator
      #
      # Read chunk and merge based on states and build rows and cells
      #
      class ChunkProcessor
        # Row states
        NEW_ROW = 1
        ROW_IN_PROGRESS = 2
        CELL_IN_PROGRESS = 3

        # Current state
        attr_accessor :state, :last_key

        # Current cached row data
        attr_accessor :chunk, :row

        # Current cell values
        attr_accessor :cur_family, :cur_qaul, :cur_ts, :cur_val, :cur_labels

        # @private
        #
        # Create chunk reader object and set row state to new
        #
        def initialize
          reset_to_new_row
        end

        # Process chunk and build full row with cells
        #
        # @param chunk [Google::Bigtable::V2::ReadRowsResponse::CellChunk]
        #
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
        #
        # @raise [Google::Cloud::Bigtable::InvalidRowStateError]
        #   if chunk has data on reset row state
        #
        def validate_reset_row
          return unless chunk.reset_row

          value = (!chunk.row_key.empty? ||
              chunk.family_name ||
              chunk.qualifier ||
              !chunk.value.empty? ||
              chunk.timestamp_micros > 0)

          raise_if value, "A reset should have no data"
        end

        # Validate chunk has new row state
        #
        # @raise [Google::Cloud::Bigtable::InvalidRowStateError]
        #   If row has already set key, chunk has emoty row key, chunk state is
        #   reset, new row key same as last read key, family name or column
        #   qualifier is empty
        #
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

        # Validate chunk merge is in progress to build new row
        #
        # @raise [Google::Cloud::Bigtable::InvalidRowStateError]
        #   If row and chunk row key are not same or chunk row key is empty.
        #
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

        # Process new row by setting valus from current chunk.
        #
        # @return [Google::Cloud::Bigtable::Row]
        #
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

        # Process chunk if row state is in progress
        #
        # @return [Google::Cloud::Bigtable::Row]
        #
        def process_row_in_progress
          validate_row_in_progress

          return reset_to_new_row if chunk.reset_row

          self.cur_family = chunk.family_name.value if chunk.family_name
          self.cur_qaul = chunk.qualifier.value if chunk.qualifier
          self.cur_ts = chunk.timestamp_micros
          self.cur_labels = chunk.labels if chunk.labels
          next_state!
        end

        # Process chunk if row cell state is in progress
        #
        # @return [Google::Cloud::Bigtable::Row]
        #
        def process_cell_in_progress
          validate_reset_row

          return reset_to_new_row if chunk.reset_row

          next_state!
        end

        # Set next state of row.
        #
        # @return [Google::Cloud::Bigtable::Row]
        #
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

        # Build cell and append to row.
        def persist_cell
          cell = Row::Cell.new(
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
          self.row = Row.new
          self.state = NEW_ROW
          self.cur_family = nil
          self.cur_qaul = nil
          self.cur_ts = nil
          self.cur_val = nil
          self.cur_labels = nil
        end

        # Validate last row is completed
        #
        # @raise [Google::Cloud::Bigtable::InvalidRowStateError]
        #   If read rows response end without last row completed
        #
        def validate_last_row_complete
          return if row.key.nil?

          raise_if(
            !chunk.commit_row,
            "Response ended with pending row without commit"
          )
        end

        private

        # Raise error on condition failure
        #
        # @raise [Google::Cloud::Bigtable::InvalidRowStateError]
        #
        def raise_if condition, message
          raise InvalidRowStateError.new(message, chunk.to_hash) if condition
        end
      end
    end
  end
end
