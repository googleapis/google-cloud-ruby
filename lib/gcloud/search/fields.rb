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


require "gcloud/search/field_values"
require "gcloud/search/field_value"

module Gcloud
  module Search
    ##
    # # Fields
    #
    # Fields is the object that provides access to a document's fields.
    #
    # Each field has a name (String) and a list of values. Each field name
    # consists of only ASCII characters, must be unique within the document and
    # is case sensitive. A field name must start with a letter and can contain
    # letters, digits, or underscore, with a maximum of 500 characters.
    #
    # A field can have multiple values with same or different types; however, it
    # cannot have multiple datetime (DateTime) or number (Float) values. (See
    # {FieldValues} and {FieldValue})
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "products"
    #
    #   document = index.document "product-sku-000001"
    #   puts "The document #{document.doc_id} has the following fields:"
    #   document.names.each do |name|
    #     puts "* #{name}:"
    #     document[name].each do |value|
    #       puts "  * #{value} (#{value.type})"
    #     end
    #   end
    #
    # @see https://cloud.google.com/search/documents_indexes Documents and
    #   fields
    #
    class Fields
      include Enumerable

      ##
      # @private Create a new empty fields object.
      def initialize
        @hash = {}
      end

      ##
      # Retrieve the field values associated to a field name.
      #
      # @param [String] name The name of the field. New values will be
      #   configured with this name.
      #
      # @return [FieldValues]
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
      #   document.fields["description"].each do |value|
      #     puts "* #{value} (#{value.type}) [#{value.lang}]"
      #   end
      #
      def [] name
        @hash[name] ||= FieldValues.new name
      end

      ##
      # Add a new value. If the field name does not exist it will be added. If
      # the field value is a DateTime or Numeric, or the type is set to
      # `:datetime` or `:number`, then the added value will replace any existing
      # values of the same type (since there can be only one).
      #
      # @param [String] name The name of the field.
      # @param [String, Datetime, Float] value The value to add to the field.
      # @param [Symbol] type The type of the field value. An attempt is made to
      #   set the correct type when this option is missing, although it must be
      #   provided for `:geo` values. A field can have multiple values with same
      #   or different types; however, it cannot have multiple `:datetime` or
      #   `:number` values.
      #
      #   The following values are supported:
      #
      #   * `:default` - The value is a string. The format will be automatically
      #     detected. This is the default value for strings.
      #   * `:text` - The value is a string with maximum length 1024**2
      #     characters.
      #   * `:html` - The value is an HTML-formatted string with maximum length
      #     1024**2 characters.
      #   * `:atom` - The value is a string with maximum length 500 characters.
      #   * `:geo` - The value is a point on earth described by latitude and
      #     longitude coordinates, represented in string with any of the listed
      #     [ways of writing coordinates](http://en.wikipedia.org/wiki/Geographic_coordinate_conversion).
      #   * `:datetime` - The value is a `DateTime`.
      #   * `:number` - The value is a `Numeric` between -2,147,483,647 and
      #     2,147,483,647. The value will be stored as a double precision
      #     floating point value in Cloud Search.
      # @param [String] lang The language of a string value. Must be a valid
      #   [ISO 639-1 code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes).
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.fields.add "sku", "product-sku-000001", type: :atom
      #   document.fields.add "description", "The best T-shirt ever.",
      #                       type: :text, lang: "en"
      #   document.fields.add "description", "<p>The best T-shirt ever.</p>",
      #                       type: :html, lang: "en"
      #   document.fields.add "price", 24.95
      #
      def add name, value, type: nil, lang: nil
        @hash[name] ||= FieldValues.new name
        @hash[name].add value, type: type, lang: lang
      end

      ##
      # Deletes a field and all values.
      #
      # @param [String] name The name of the field.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.fields.delete "description"
      #
      def delete name, &block
        @hash.delete name, &block
      end

      ##
      # Calls block once for each field, passing the field name and values pair
      # as parameters. If no block is given an enumerator is returned instead.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document #{document.doc_id} has the following fields:"
      #   document.fields.each do |name, values|
      #     puts "* #{name}:"
      #     values.each do |value|
      #       puts "  * #{value} (#{value.type})"
      #     end
      #   end
      #
      def each &block
        # Only yield fields that have values.
        fields_with_values.each(&block)
      end

      ##
      # Returns a new array populated with all the field names.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document #{document.doc_id} has the following fields:"
      #   document.fields.names.each do |name|
      #     puts "* #{name}:"
      #   end
      #
      def names
        # Only return fields that have values.
        fields_with_values.keys
      end

      ##
      # @private Create a new Fields instance from a raw Hash.
      def self.from_raw raw
        hsh = {}
        raw.each do |k, v|
          hsh[k] = FieldValues.from_raw k, v["values"]
        end unless raw.nil?
        fields = new
        fields.instance_variable_set "@hash", hsh
        fields
      end

      ##
      # @private Create a raw Hash object containing all the field names and
      # values.
      def to_raw
        hsh = {}
        @hash.each do |k, v|
          hsh[k] = v.to_raw unless v.empty?
        end
        hsh
      end

      protected

      ##
      # @private Find all the fields that have values. This is needed because a
      # field is required to have at least one value.
      #
      # Users can remove all values, and the empty FieldValues object will
      # remain in the internal hash. This is the same as not having that field.
      #
      # Users can also reference the field by name before adding a value. So we
      # have multiple valid use cases which add an empty FieldValues object to
      # the hash.
      def fields_with_values
        @hash.select { |_name, values| values.any? }
      end
    end
  end
end
