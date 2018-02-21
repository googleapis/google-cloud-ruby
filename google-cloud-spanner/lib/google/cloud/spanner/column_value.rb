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
    module Spanner
      ##
      # # ColumnValue
      #
      # Represents a change to be made to row's column value by the Spanner API.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   # create column value object
      #   commit_timestamp = db.commit_timestamp
      #   commit_timestamp.type #=> :commit_timestamp
      #
      #   db.commit do |c|
      #     c.insert "users", [
      #       { id: 5, name: "Murphy", updated_at: commit_timestamp }
      #     ]
      #   end
      #
      class ColumnValue
        ##
        # @private Creates a column value object representing changes made to
        # fields in document data.
        def initialize type
          @type = type
        end

        ##
        # The type of change to make to a row's column value.
        #
        # @return [Symbol] The type of the column value.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   # create column value object
        #   commit_timestamp = db.commit_timestamp
        #   commit_timestamp.type #=> :commit_timestamp
        #
        #   db.commit do |c|
        #     c.insert "users", [
        #       { id: 5, name: "Murphy", updated_at: commit_timestamp }
        #     ]
        #   end
        #
        def type
          @type
        end

        ##
        # Creates a column value object representing setting a field's value to
        # the timestamp of the commit. (See {Client#commit_timestamp})
        #
        # @return [ColumnValue] The commit timestamp column value object.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   # create column value object
        #   commit_timestamp = \
        #     Google::Cloud::Spanner::ColumnValue.commit_timestamp
        #
        #   db.commit do |c|
        #     c.insert "users", [
        #       { id: 5, name: "Murphy", updated_at: commit_timestamp }
        #     ]
        #   end
        #
        def self.commit_timestamp
          new :commit_timestamp
        end

        ##
        # @private The actual value that is sent to Spanner for the field.
        def to_column_value
          # We only have one ColumnValue, so hard-code this for now.
          "spanner.commit_timestamp()"
        end
      end
    end
  end
end
