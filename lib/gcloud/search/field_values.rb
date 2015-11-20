#--
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "gcloud/search/field_value"

module Gcloud
  module Search
    ##
    # = FieldValues
    #
    # The values for a Field.
    #
    class FieldValues
      include Enumerable

      def initialize name, values = [] # :nodoc:
        @name = name
        @values = values
      end

      ##
      # Returns the element at index, or returns a subarray starting at the
      # start index and continuing for length elements, or returns a subarray
      # specified by range of indices.
      #
      # Negative indices count backward from the end of the array (-1 is the
      # last element). For start and range cases the starting index is just
      # before an element. Additionally, an empty array is returned when the
      # starting index for an element range is at the end of the array.
      #
      # Returns nil if the index (or starting index) are out of range.
      def [] index
        @values[index]
      end

      ##
      # Calls the given block once for each element in self, passing that
      # element as a parameter.
      #
      # An Enumerator is returned if no block is given.
      def each &block
        @values.each(&block)
      end

      def add value, options = {}
        @values << FieldValue.new(value, options.merge(name: @name))
      end

      ##
      # Deletes all values that are equal to value.
      #
      # Returns the last deleted FieldValue, or +nil+ if no matching item is
      # found.
      def delete value, &block
        fv = @values.detect { |v| v.value == value }
        @values.delete fv, &block
      end

      ##
      # Deletes the value at the specified index, returning that FieldValue, or
      # +nil+ if the index is out of range.
      def delete_at index
        @values.delete_at index
      end

      ##
      # Returns +true+ if there are no values.
      def empty?
        @values.empty?
      end

      def self.from_raw name, values #:nodoc:
        field_values = values.map { |value| FieldValue.from_raw value, name }
        FieldValues.new name, field_values
      end

      def to_raw #:nodoc:
        { "values" => @values.map(&:to_raw) }
      end
    end
  end
end
