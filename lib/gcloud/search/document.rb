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

require "gcloud/search/document/list"
require "gcloud/search/connection"
require "gcloud/search/fields"

module Gcloud
  module Search
    ##
    # = Document
    #
    # A document is an object that stores data that can be searched. Each
    # document has a {#doc_id} that is unique within its index, a {#rank}, and a
    # list of {#fields} that contain typed data. Its field values can be
    # accessed through hash-like methods such as {#[]} and {#each}.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "products"
    #
    #   document = index.document "product-sku-000001"
    #   document.add "price", 24.95
    #   index.save document
    #   document.rank #=> 1443648166
    #   document["price"] #=> 24.95
    #
    # @see https://cloud.google.com/search/documents_indexes Documents and
    #   Indexes
    #
    class Document
      ##
      # @private Creates a new Document instance.
      #
      def initialize
        @fields = Fields.new
        @raw = {}
      end

      ##
      # The unique identifier for the document. Can be set explicitly when the
      # document is saved. (See {Index#document} and {#doc_id=}.) If missing, it
      # is automatically assigned to the document when saved.
      def doc_id
        @raw["docId"]
      end

      ##
      # Sets the unique identifier for the document.
      #
      # Must contain only visible, printable ASCII characters (ASCII codes 33
      # through 126 inclusive) and be no longer than 500 characters. It cannot
      # begin with an exclamation point (<code>!</code>), and it cannot begin
      # and end with double underscores (<code>__</code>).
      def doc_id= new_doc_id
        @raw["docId"] = new_doc_id
      end

      ##
      # A positive integer which determines the default ordering of documents
      # returned from a search. The rank can be set explicitly when the document
      # is saved. (See {Index#document} and {#rank=}.)  If missing, it is
      # automatically assigned to the document when saved.
      def rank
        @raw["rank"]
      end

      ##
      # Sets the rank of the document.
      #
      # The same rank should not be assigned to many documents, and should
      # never be assigned to more than 10,000 documents. By default (when it is
      # not specified or set to 0), it is set at the time the document is
      # created to the number of seconds since January 1, 2011. The rank can be
      # used in {Index#search} options +expressions+, +order+, and
      # +fields+, where it is referenced as +rank+.
      def rank= new_rank
        @raw["rank"] = new_rank
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
      #   document["description"].each do |value|
      #     puts "* #{value} (#{value.type}) [#{value.lang}]"
      #   end
      #
      def [] name
        @fields[name]
      end

      # rubocop:disable Style/TrivialAccessors
      # Disable rubocop because we want .fields to be listed with the other
      # methods on the class.

      ##
      # The fields in the document. Each field has a name (String) and a list of
      # values ({FieldValues}). (See {Fields})
      def fields
        @fields
      end

      # rubocop:enable Style/TrivialAccessors

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Add a new value. If the field name does not exist it will be added. If
      # the field value is a DateTime or Numeric, or the type is set to
      # +:datetime+ or +:number+, then the added value will replace any existing
      # values of the same type (since there can be only one).
      #
      # @param [String] name The name of the field.
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
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.add "sku", "product-sku-000001", type: :atom
      #   document.add "description", "The best T-shirt ever.",
      #                type: :text, lang: "en"
      #   document.add "description", "<p>The best T-shirt ever.</p>",
      #                type: :html, lang: "en"
      #   document.add "price", 24.95
      #
      def add name, value, type: nil, lang: nil
        @fields[name].add value, type: type, lang: lang
      end

      # rubocop:enable Metrics/LineLength

      ##
      # Deletes a field and all values. (See {Fields#delete})
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
      #   document.delete "description"
      #
      def delete name, &block
        @fields.delete name, &block
      end

      ##
      # Calls block once for each field, passing the field name and values pair
      # as parameters. If no block is given an enumerator is returned instead.
      # (See {Fields#each})
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
      #   document.each do |name, values|
      #     puts "* #{name}:"
      #     values.each do |value|
      #       puts "  * #{value} (#{value.type})"
      #     end
      #   end
      #
      def each &block
        @fields.each(&block)
      end

      ##
      # Returns a new array populated with all the field names.
      # (See {Fields#names})
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
      #   end
      #
      def names
        @fields.names
      end

      ##
      # @private Override to keep working in interactive shells manageable.
      def inspect
        insp_rank = ""
        insp_rank = ", rank: #{rank}" if rank
        insp_fields = ", fields: (#{fields.names.map(&:inspect).join ', '})"
        "#{self.class}(doc_id: #{doc_id.inspect}#{insp_rank}#{insp_fields})"
      end

      ##
      # @private New Document from a raw data object.
      def self.from_hash hash
        doc = new
        doc.instance_variable_set "@raw", hash
        doc.instance_variable_set "@fields", Fields.from_raw(hash["fields"])
        doc
      end

      ##
      # @private Returns the Document data as a hash
      def to_hash
        hash = @raw.dup
        hash["fields"] = @fields.to_raw
        hash
      end
    end
  end
end
