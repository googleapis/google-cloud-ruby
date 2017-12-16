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
  module Cloud
    module Spanner
      ##
      # # Range
      #
      # Represents a range of rows in a table or index. A range has a start key
      # and an end key. These keys can be open or closed, indicating if the
      # range includes rows with that key.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   key_range = db.range 1, 100
      #   results = db.read "users", [:id, :name], keys: key_range
      #
      #   results.rows.each do |row|
      #     puts "User #{row[:id]} is #{row[:name]}"
      #   end
      #
      class Range
        ##
        # Returns the object that defines the beginning of the range.
        attr_reader :begin

        ##
        # Returns the object that defines the end of the range.
        attr_reader :end

        ##
        # Creates a Spanner Range. This can be used in place of a Ruby Range
        # when needing to exclude the beginning value.
        #
        # @param [Object] beginning The object that defines the beginning of the
        #   range.
        # @param [Object] ending The object that defines the end of the range.
        # @param [Boolean] exclude_begin Determines if the range excludes its
        #   beginning value. Default is `false`.
        # @param [Boolean] exclude_end Determines if the range excludes its
        #   ending value. Default is `false`.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   key_range = Google::Cloud::Spanner::Range.new 1, 100
        #   results = db.read "users", [:id, :name], keys: key_range
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def initialize beginning, ending, exclude_begin: false,
                       exclude_end: false
          @begin = beginning
          @end = ending
          @exclude_begin = exclude_begin
          @exclude_end = exclude_end
        end

        ##
        # Returns `true` if the range excludes its beginning value.
        # @return [Boolean]
        def exclude_begin?
          @exclude_begin
        end

        ##
        # Returns `true` if the range excludes its end value.
        # @return [Boolean]
        def exclude_end?
          @exclude_end
        end
      end
    end
  end
end
