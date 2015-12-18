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
    # The list of values for a field.
    #
    # Each field has a name (String) and a list of values. Each field name
    # consists of only ASCII characters, must be unique within the document and
    # is case sensitive. A field name must start with a letter and can contain
    # letters, digits, or underscore, with a maximum of 500 characters.
    #
    # Each field on a document can have multiple values. FieldValues is the
    # object that manages the multiple values. Values can be the same or
    # different types; however, it cannot have multiple datetime (DateTime) or
    # number (Float) values. (See {FieldValue})
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "products"
    #
    #   document = index.document "product-sku-000001"
    #   puts "The document description is:"
    #   document["description"].each do |value|
    #     puts "* #{value} (#{value.type}) [#{value.lang}]"
    #   end
    #
    # @see https://cloud.google.com/search/documents_indexes Documents and
    #   Indexes
    #
    class FieldValues
      include Enumerable

      ##
      # @private Create a new FieldValues object.
      #
      # @param [String] name The name of the field. New values will be
      #   configured with this name.
      # @param [Array<FieldValue>] values A list of values to add to the field.
      #
      def initialize name, values = []
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
      # @return [FieldValue, nil] Returns nil if the index (or starting index)
      #   are out of range.
      def [] index
        @values[index]
      end

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Add a new value. If the field name does not exist it will be added. If
      # the field value is a DateTime or Numeric, or the type is set to
      # +:datetime+ or +:number+, then the added value will replace any existing
      # values of the same type (since there can be only one).
      #
      # @param [String, Datetime, Float] value The value to add to the field.
      # @param [Symbol] type The type of the field value. An attempt is made to
      #   set the correct type when this option is missing, although it must be
      #   provided for +:geo+ values. A field can have multiple values with same
      #   or different types; however, it cannot have multiple +:datetime+ or
      #   +:number+ values.
      #
      #   The following values are supported:
      #   * +:default+ - The value is a string. The format will be automatically
      #     detected. This is the default value for strings.
      #   * +:text+ - The value is a string with maximum length 1024**2
      #     characters.
      #   * +:html+ - The value is an HTML-formatted string with maximum length
      #     1024**2 characters.
      #   * +:atom+ - The value is a string with maximum length 500 characters.
      #   * +:geo+ - The value is a point on earth described by latitude and
      #     longitude coordinates, represented in string with any of the listed
      #     {ways of writing coordinates}[http://en.wikipedia.org/wiki/Geographic_coordinate_conversion].
      #   * +:datetime+ - The value is a +DateTime+.
      #   * +:number+ - The value is a +Numeric+ between -2,147,483,647 and
      #     2,147,483,647. The value will be stored as a double precision
      #     floating point value in Cloud Search.
      # @param [String] lang The language of a string value. Must be a valid
      #   {ISO 639-1 code}[https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes].
      #
      # @return [FieldValue]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document["sku"].add "product-sku-000001", type: :atom
      #   document["description"].add "The best T-shirt ever.",
      #                               type: :text, lang: "en"
      #   document["description"].add "<p>The best T-shirt ever.</p>",
      #                               type: :html, lang: "en"
      #   document["price"].add 24.95
      #
      def add value, type: nil, lang: nil
        new_field = FieldValue.new value, type: type, lang: lang, name: @name
        if [:datetime, :number].include? new_field.type
          @values.delete_if { |v| v.type == new_field.type }
        end
        @values << new_field
      end

      # rubocop:enable Metrics/LineLength

      ##
      # Deletes all values that are equal to value.
      #
      # @param [String] value The value to remove from the list of values.
      #
      # @return [FieldValue, nil] The last deleted +FieldValue+, or +nil+ if no
      #   matching value is found.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document["description"].count #=> 2
      #   document["description"].delete "The best T-shirt ever."
      #   document["description"].count #=> 1
      #
      def delete value, &block
        fv = @values.detect { |v| v == value }
        @values.delete fv, &block
      end

      ##
      # Deletes the value at the specified index, returning that FieldValue, or
      # +nil+ if the index is out of range.
      #
      # @param [String] index The index of the value to be removed from the list
      #   of values.
      #
      # @return [FieldValue] The deleted +FieldValue+ found at the specified
      #   index, or # +nil+ if the index is out of range.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document["description"].count #=> 2
      #   document["description"].delete_at 0
      #   document["description"].count #=> 1
      #
      def delete_at index
        @values.delete_at index
      end

      ##
      # Calls the given block once for each field value, passing the field value
      # as a parameter.
      #
      # An Enumerator is returned if no block is given.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document description is:"
      #   document["description"].each do |value|
      #     puts "* #{value} (#{value.type}) [#{value.lang}]"
      #   end
      #
      def each &block
        @values.each(&block)
      end

      ##
      # Returns +true+ if there are no values.
      def empty?
        @values.empty?
      end

      ##
      # @private Create a new FieldValues instance from a name and values Hash.
      def self.from_raw name, values
        field_values = values.map { |value| FieldValue.from_raw value, name }
        FieldValues.new name, field_values
      end

      ##
      # @private Create a raw Hash object containing all the field values.
      def to_raw
        { "values" => @values.map(&:to_raw) }
      end
    end
  end
end
