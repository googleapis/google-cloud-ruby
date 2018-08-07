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


require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # FieldPath
      #
      # Represents a field path to the Firestore API. See {Client#field_path}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   user_snap = firestore.doc("users/frank").get
      #
      #   nested_field_path = Google::Cloud::Firestore::FieldPath.new(
      #     :favorites, :food
      #   )
      #   user_snap.get(nested_field_path) #=> "Pizza"
      #
      class FieldPath
        include Comparable

        ##
        # Creates a field path object representing a nested field for
        # document data.
        #
        # @param [String, Symbol, Array<String|Symbol>] fields One or more
        #   strings representing the path of the data to select. Each field must
        #   be provided separately.
        #
        # @return [FieldPath] The field path object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   nested_field_path = Google::Cloud::Firestore::FieldPath.new(
        #     :favorites, :food
        #   )
        #   user_snap.get(nested_field_path) #=> "Pizza"
        #
        def initialize *fields
          @fields = fields.flatten.map(&:to_s).freeze

          invalid_fields = @fields.detect(&:empty?)
          raise ArgumentError, "empty paths not allowed" if invalid_fields
        end

        ##
        # @private The individual fields representing the nested field path for
        # document data. The fields are frozen.
        #
        # @return [Array<String>] The fields.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   nested_field_path = Google::Cloud::Firestore::FieldPath.new(
        #     :favorites, :food
        #   )
        #   nested_field_path.fields #=> ["favorites", "food"]
        #
        def fields
          @fields
        end

        ##
        # @private A string representing the nested fields for document data as
        # a string of individual fields joined by ".". Fields containing `~`,
        # `*`, `/`, `[`, `]`, and `.` are escaped.
        #
        # @return [String] The formatted string.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   nested_field_path = Google::Cloud::Firestore::FieldPath.new(
        #     :favorites, :food
        #   )
        #   nested_field_path.formatted_string #=> "favorites.food"
        #
        def formatted_string
          escaped_fields = @fields.map { |field| escape_field_for_path field }
          escaped_fields.join(".")
        end

        ##
        # Creates a field path object representing the sentinel ID of a
        # document. It can be used in queries to sort or filter by the document
        # ID. See {Client#document_id}.
        #
        # @return [FieldPath] The field path object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(
        #     Google::Cloud::Firestore::FieldPath.document_id
        #   ).start_at("NYC")
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def self.document_id
          new :__name__
        end

        ##
        # @private Creates a field path object representing the nested fields
        # for document data.
        #
        # The values are memoized to increase performance.
        #
        # @param [String] dotted_string A string representing the path of the
        #   document data. The string can represent as a string of individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should be created by passing
        #   individual field strings to  {FieldPath.new} instead.
        #
        # @return [FieldPath] The field path object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   field_path = Google::Cloud::Firestore::FieldPath.parse(
        #     "favorites.food"
        #   )
        #   field_path.fields #=> ["favorites", "food"]
        #
        def self.parse dotted_string
          # Memoize parsed field paths
          @memoized_field_paths ||= {}
          if @memoized_field_paths.key? dotted_string
            return @memoized_field_paths[dotted_string]
          end

          if dotted_string.is_a? Array
            return @memoized_field_paths[dotted_string] = new(dotted_string)
          end

          fields = String(dotted_string).split(".")

          if fields.grep(INVALID_FIELD_PATH_CHARS).any?
            raise ArgumentError, "invalid character, use FieldPath instead"
          end

          @memoized_field_paths[dotted_string] = new(fields)
        end

        ##
        # @private
        def <=> other
          return nil unless other.is_a? FieldPath
          formatted_string <=> other.formatted_string
        end

        ##
        # @private
        def eql? other
          formatted_string.eql? other.formatted_string
        end

        ##
        # @private
        def hash
          formatted_string.hash
        end

        protected

        START_FIELD_PATH_CHARS = /\A[a-zA-Z_]/
        INVALID_FIELD_PATH_CHARS = %r{[\~\*\/\[\]]}

        def escape_field_for_path field
          field = String field

          if INVALID_FIELD_PATH_CHARS.match(field) ||
             field["."] || field["`"] || field["\\"]
            escaped_field = field.gsub(/[\`\\]/, "`" => "\\\`", "\\" => "\\\\")
            return "`#{escaped_field}`"
          end

          return field if START_FIELD_PATH_CHARS.match field

          "`#{field}`"
        end
      end
    end
  end
end
