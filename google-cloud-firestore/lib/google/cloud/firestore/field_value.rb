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
    module Firestore
      ##
      # # FieldValue
      #
      # Represents a change to be made to fields in document data in the
      # Firestore API.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   user_snap = firestore.doc("users/frank").get
      #
      #   # TODO
      #
      class FieldValue
        ##
        # @private Creates a field value object representing changes made to
        # fields in document data.
        def initialize type, values = nil
          @type = type
          @values = values
        end

        ##
        # The type of change to make to an individual field in document data.
        #
        # @return [Symbol] The type.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   field_delete = Google::Cloud::Firestore::FieldValue.delete
        #   field_delete.type #=> :delete
        #
        #   nyc_ref.update({ name: "New York City",
        #                    trash: field_delete })
        #
        def type
          @type
        end

        ##
        # @private
        # The values to change to an individual field in document data,
        # depending on the type of change.
        #
        # @return [Array<Object>] The values.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   array_union = Google::Cloud::Firestore::FieldValue.array_union(
        #     1, 2, 3
        #   )
        #   array_union.type #=> :array_union
        #   array_union.values #=> [1, 2, 3]
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_union })
        #
        def values
          @values
        end

        ##
        # Creates a field value object representing the deletion of a field in
        # document data.
        #
        # @return [FieldValue] The delete field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   field_delete = Google::Cloud::Firestore::FieldValue.delete
        #
        #   nyc_ref.update({ name: "New York City",
        #                    trash: field_delete })
        #
        def self.delete
          new :delete
        end

        ##
        # Creates a field value object representing set a field's value to
        # the server timestamp when accessing the document data.
        #
        # @return [FieldValue] The server time field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   field_server_time = Google::Cloud::Firestore::FieldValue.server_time
        #
        #   nyc_ref.update({ name: "New York City",
        #                    updated_at: field_server_time })
        #
        def self.server_time
          new :server_time
        end

        ##
        # Creates a sentinel value to indicate the union of the given values
        # with an array.
        #
        # @param [Object] values The values to add to the array. Required.
        #
        # @return [FieldValue] The array union field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   array_union = Google::Cloud::Firestore::FieldValue.array_union(
        #     1, 2, 3
        #   )
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_union })
        #
        def self.array_union *values
          # We can flatten the values because arrays don't support sub-arrays
          values.flatten!
          raise ArgumentError, "values must be provided" if values.nil?

          new :array_union, values
        end

        ##
        # Creates a sentinel value to indicate the removal of the given values
        # with an array.
        #
        # @param [Object] values The values to remove from the array. Required.
        #
        # @return [FieldValue] The array delete field value object.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   array_delete = Google::Cloud::Firestore::FieldValue.array_delete(
        #     7, 8, 9
        #   )
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_delete })
        #
        def self.array_delete *values
          # We can flatten the values because arrays don't support sub-arrays
          values.flatten!
          raise ArgumentError, "values must be provided" if values.nil?

          new :array_delete, values
        end
      end
    end
  end
end
