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
    class Document
      ##
      # Creates a new Document instance.
      #
      def initialize #:nodoc:
        @fields = Fields.new
        @raw = {}
      end

      ##
      # The unique identifier of the document.
      #
      # It must contain only visible, printable ASCII characters (ASCII codes 33
      # through 126 inclusive) and be no longer than 500 characters. It cannot
      # begin with an exclamation point (<code>!</code>), and it cannot begin
      # and end with double underscores (<code>__</code>). If missing, it is
      # automatically assigned to the document when saved.
      def doc_id
        @raw["docId"]
      end

      ##
      # Sets the unique identifier of the document.
      def doc_id= new_doc_id
        @raw["docId"] = new_doc_id
      end

      ##
      # A positive integer which determines the default ordering of documents
      # returned from a search.
      #
      # The rank can be set explicitly when the document is created. It is a bad
      # idea to assign the same rank to many documents, and the same rank should
      # never be assigned to more than 10,000 documents. By default (when it is
      # not specified or set to 0), it is set at the time the document is
      # created to the number of seconds since January 1, 2011. The rank can be
      # used in Index#search options +expressions+, +order+, and
      # +return_fields+, where it is referenced as +_rank+.
      def rank
        @raw["rank"]
      end

      ##
      # Sets the rank of the document.
      def rank= new_rank
        @raw["rank"] = new_rank
      end

      ##
      # Retrieve the field values associated to a field name.
      #
      # === Parameters
      #
      # +name+::
      #   The name of the field. New values will be configured with this name.
      #   (+String+)
      #
      # === Returns
      #
      # FieldValue
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document description is:"
      #   document["description"].each do |value|
      #     puts "* #{value.value} (#{value.type}) [#{value.lang}]"
      #   end
      #
      def [] k
        @fields[k]
      end

      # rubocop:disable Style/TrivialAccessors
      # Disable rubocop because we want .fields to be listed with the other
      # methods on the class.

      ##
      # The fields in the document. Each key is a field name and each
      # value is a FieldValues. See Fields.
      def fields
        @fields
      end

      # rubocop:enable Style/TrivialAccessors

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Add a new value. If the field name does not exist it will be added.
      # (See Fields#add)
      #
      # === Parameters
      #
      # +name+::
      #   The name of the field. (+String+)
      # +value+::
      #   The value to add to the field. (+String+ or +Datetime+ or +Float+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:type]</code>::
      #   The type of the field value. A field can have multiple values with
      #   same or different types; however, it cannot have multiple Timestamp or
      #   number values. (+Symbol+)
      #
      #   The following values are supported:
      #   * +:text+ - The value is a string with maximum length 1024**2
      #     characters.
      #   * +:html+ - The value is an HTML-formatted string with maximum length
      #     1024**2 characters.
      #   * +:atom+ - The value is a string with maximum length 500 characters.
      #   * +:geo+ - The value is a point on earth described by latitude and
      #     longitude coordinates, represented in string with any of the listed
      #     {ways of writing
      #     coordinates}[http://en.wikipedia.org/wiki/Geographic_coordinate_conversion].
      #   * +:timestamp+ - The value is a +DateTime+.
      #   * +:number+ - The value is a +Numeric+ between -2,147,483,647 and
      #     2,147,483,647. The value will be stored as a double precision
      #     floating point value in Cloud Search.
      # <code>options[:lang]</code>::
      #   The language of a string value. Must be a valid {ISO 639-1
      #   code}[https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes].
      #   (+String+)
      #
      # === Example
      #
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
      def add name, value, options = {}
        @fields[name].add value, options
      end

      # rubocop:enable Metrics/LineLength

      ##
      # Deletes a field and all values. (See Fields#delete)
      #
      # === Parameters
      #
      # +name+::
      #   The name of the field. (+String+)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.delete "description"
      #
      def delete key, &block
        @fields.delete key, &block
      end

      ##
      # Calls block once for each key, passing the field name and values pair as
      # parameters. If no block is given an enumerator is returned instead.
      # (See Fields#each)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document #{document.doc_id} has the following fields:"
      #   document.each do |key, values|
      #     puts "* #{key}:"
      #     values.each do |value|
      #       puts "  * #{value.value} (#{value.type})"
      #     end
      #   end
      #
      def each &block
        @fields.each(&block)
      end

      ##
      # Calls block once for each key, passing the field name and values pair as
      # parameters. If no block is given an enumerator is returned instead.
      # (See Fields#each_pair)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document #{document.doc_id} has the following fields:"
      #   document.each_pair do |key, values|
      #     puts "* #{key}:"
      #     values.each do |value|
      #       puts "  * #{value.value} (#{value.type})"
      #     end
      #   end
      #
      def each_pair &block
        @fields.each_pair(&block)
      end

      ##
      # Returns a new array populated with all the field names.
      # (See Fields#keys)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   puts "The document #{document.doc_id} has the following fields:"
      #   document.keys.each do |key|
      #     puts "* #{key}:"
      #   end
      #
      def keys
        @fields.keys
      end

      ##
      # Override to keep working in interactive shells manageable.
      def inspect #:nodoc:
        insp_rank = ""
        insp_rank = ", rank: #{rank}" if rank
        insp_fields = ", fields: (#{fields.keys.join ', '})"
        "#{self.class}(doc_id: #{doc_id.inspect}#{insp_rank}#{insp_fields})"
      end

      ##
      # New Document from a raw data object.
      def self.from_hash hash #:nodoc:
        doc = new
        doc.instance_variable_set "@raw", hash
        doc.instance_variable_set "@fields", Fields.from_raw(hash["fields"])
        doc
      end

      ##
      # Returns the Document data as a hash
      def to_hash #:nodoc:
        hash = @raw.dup
        hash["fields"] = @fields.to_raw
        hash
      end
    end
  end
end
