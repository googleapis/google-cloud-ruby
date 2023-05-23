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
      #   # Get a document reference
      #   nyc_ref = firestore.doc "cities/NYC"
      #
      #   # Set the population to increment by 1.
      #   increment_value = Google::Cloud::Firestore::FieldValue.increment 1
      #
      #   nyc_ref.update({ name: "New York City",
      #                    population: increment_value })
      #
      class FieldValue
        ##
        # @private Creates a field value object representing changes made to
        # fields in document data.
        def initialize type, value = nil
          @type = type
          @value = value
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
        # The value to change to an individual field in document data, depending
        # on the type of change.
        #
        # @return [Object] The value.
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
        #   array_union.value #=> [1, 2, 3]
        #
        #   nyc_ref.update({ name: "New York City",
        #                    lucky_numbers: array_union })
        #
        def value
          @value
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
        # Creates a sentinel value to indicate the union of the given value
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
          raise ArgumentError, "values must be provided" if values.empty?
          # verify the values are the correct types
          Convert.raw_to_value values

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
          raise ArgumentError, "values must be provided" if values.empty?
          # verify the values are the correct types
          Convert.raw_to_value values

          new :array_delete, values
        end

        ##
        # Creates a sentinel value to indicate the addition the given value to
        # the field's current value.
        #
        # If the field's current value is not an integer or a double value
        # (Numeric), or if the field does not yet exist, the transformation will
        # set the field to the given value. If either of the given value or the
        # current field value are doubles, both values will be interpreted as
        # doubles. Double arithmetic and representation of double values follow
        # IEEE 754 semantics. If there is positive/negative integer overflow,
        # the field is resolved to the largest magnitude positive/negative
        # integer.
        #
        # @param [Numeric] value The value to add to the given value. Required.
        #
        # @return [FieldValue] The increment field value object.
        #
        # @raise [ArgumentError] if the value is not an Integer or Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to increment by 1.
        #   increment_value = Google::Cloud::Firestore::FieldValue.increment 1
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: increment_value })
        #
        def self.increment value
          # verify the values are the correct types
          unless value.is_a? Numeric
            raise ArgumentError, "value must be a Numeric"
          end

          new :increment, value
        end

        ##
        # Creates a sentinel value to indicate the setting the field to the
        # maximum of its current value and the given value.
        #
        # If the field is not an integer or double (Numeric), or if the field
        # does not yet exist, the transformation will set the field to the given
        # value. If a maximum operation is applied where the field and the input
        # value are of mixed types (that is - one is an integer and one is a
        # double) the field takes on the type of the larger operand. If the
        # operands are equivalent (e.g. 3 and 3.0), the field does not change.
        # 0, 0.0, and -0.0 are all zero. The maximum of a zero stored value and
        # zero input value is always the stored value. The maximum of any
        # numeric value x and NaN is NaN.
        #
        # @param [Numeric] value The value to compare against the given value to
        #   calculate the maximum value to set. Required.
        #
        # @return [FieldValue] The maximum field value object.
        #
        # @raise [ArgumentError] if the value is not an Integer or Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to be at maximum 4,000,000.
        #   maximum_value = Google::Cloud::Firestore::FieldValue.maximum 4000000
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: maximum_value })
        #
        def self.maximum value
          # verify the values are the correct types
          unless value.is_a? Numeric
            raise ArgumentError, "value must be a Numeric"
          end

          new :maximum, value
        end

        ##
        # Creates a sentinel value to indicate the setting the field to the
        # minimum of its current value and the given value.
        #
        # If the field is not an integer or double (Numeric), or if the field
        # does not yet exist, the transformation will set the field to the input
        # value. If a minimum operation is applied where the field and the input
        # value are of mixed types (that is - one is an integer and one is a
        # double) the field takes on the type of the smaller operand. If the
        # operands are equivalent (e.g. 3 and 3.0), the field does not change.
        # 0, 0.0, and -0.0 are all zero. The minimum of a zero stored value and
        # zero input value is always the stored value. The minimum of any
        # numeric value x and NaN is NaN.
        #
        # @param [Numeric] value The value to compare against the given value to
        #   calculate the minimum value to set. Required.
        #
        # @return [FieldValue] The minimum field value object.
        #
        # @raise [ArgumentError] if the value is not an Integer or Numeric.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Set the population to be at minimum 1,000,000.
        #   minimum_value = Google::Cloud::Firestore::FieldValue.minimum 1000000
        #
        #   nyc_ref.update({ name: "New York City",
        #                    population: minimum_value })
        #
        def self.minimum value
          # verify the values are the correct types
          unless value.is_a? Numeric
            raise ArgumentError, "value must be a Numeric"
          end

          new :minimum, value
        end
      end
    end
  end
end
