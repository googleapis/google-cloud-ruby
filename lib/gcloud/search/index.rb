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


require "gcloud/search/document"
require "gcloud/search/index/list"
require "gcloud/search/result"

module Gcloud
  module Search
    ##
    # # Index
    #
    # An index manages {Document} instances for retrieval. Indexes cannot be
    # created, updated, or deleted directly on the server: They are derived from
    # the documents that reference them. You can manage groups of documents by
    # putting them into separate indexes.
    #
    # With an index, you can retrieve documents with {#find} and {#documents};
    # manage them with {#document}, {#save}, and {#remove}; and perform searches
    # over their fields with {#search}.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "books"
    #
    #   results = index.search "dark stormy"
    #   results.each do |result|
    #     puts result.doc_id
    #   end
    #
    # @see https://cloud.google.com/search/documents_indexes Documents and
    #   Indexes
    #
    class Index
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The raw data object.
      attr_accessor :raw

      ##
      # @private Creates a new Index instance.
      #
      def initialize
        @connection = nil
        @raw = nil
      end

      ##
      # The index identifier. May be defined by the server or by the client.
      # Must be unique within the project. It cannot be an empty string. It must
      # contain only visible, printable ASCII characters (ASCII codes 33 through
      # 126 inclusive) and be no longer than 100 characters. It cannot begin
      # with an exclamation point (<code>!</code>), and it cannot begin and end
      # with double underscores (<code>__</code>).
      def index_id
        @raw["indexId"]
      end

      ##
      # The names of fields in which TEXT values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def text_fields
        return @raw["indexedField"]["textFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of fields in which HTML values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def html_fields
        return @raw["indexedField"]["htmlFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of fields in which ATOM values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def atom_fields
        return @raw["indexedField"]["atomFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of fields in which DATE values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def datetime_fields
        return @raw["indexedField"]["dateFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of fields in which NUMBER values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def number_fields
        return @raw["indexedField"]["numberFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of fields in which GEO values are stored.
      # @see https://cloud.google.com/search/documents_indexes#index_schemas
      #   Index schemas
      def geo_fields
        return @raw["indexedField"]["geoFields"] if @raw["indexedField"]
        []
      end

      ##
      # The names of all the fields that are stored on the index.
      def field_names
        (text_fields + html_fields + atom_fields + datetime_fields +
          number_fields + geo_fields).uniq
      end

      ##
      # The field value types that are stored on the field name.
      def field_types_for name
        {
          text: text_fields.include?(name),
          html: html_fields.include?(name),
          atom: atom_fields.include?(name),
          datetime: datetime_fields.include?(name),
          number: number_fields.include?(name),
          geo: geo_fields.include?(name)
        }.delete_if { |_k, v| !v }.keys
      end

      ##
      # Retrieves an existing document by id.
      #
      # @param [String, Gcloud::Search::Document] doc_id The id of a document or
      #   a Document instance.
      # @return [Gcloud::Search::Document, nil] Returns `nil` if the document
      #   does not exist
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.find "product-sku-000001"
      #   puts document.doc_id
      #
      def find doc_id
        # Get the id if passes a Document object
        doc_id = doc_id.doc_id if doc_id.respond_to? :doc_id
        ensure_connection!
        resp = connection.get_doc index_id, doc_id
        return Document.from_hash(JSON.parse(resp.body)) if resp.success?
        return nil if resp.status == 404
        fail ApiError.from_response(resp)
      rescue JSON::ParserError
        raise ApiError.from_response(resp)
      end
      alias_method :get, :find

      ##
      # Helper for creating a new Document instance. The returned instance is
      # local: It is either not yet saved to the service (see {#save}), or if it
      # has been given the id of an existing document, it is not yet populated
      # with the document's data (see {#find}).
      #
      # @param [String, nil] doc_id An optional unique ID for the new document.
      #   When the document is saved, this value must contain only visible,
      #   printable ASCII characters (ASCII codes 33 through 126 inclusive) and
      #   be no longer than 500 characters. It cannot begin with an exclamation
      #   point (<code>!</code>), and it cannot begin and end with double
      #   underscores (<code>__</code>).
      # @param [Integer, nil] rank An optional rank for the new document. An
      #   integer which determines the default ordering of documents returned
      #   from a search. It is a bad idea to assign the same rank to many
      #   documents, and the same rank should never be assigned to more than
      #   10,000 documents. By default (when it is not specified or set to 0),
      #   it is set at the time the document is saved to the number of seconds
      #   since January 1, 2011. The rank can be used in the `expressions`,
      #   `order`, and `fields` options in {#search}, where it should referenced
      #   as `rank`.
      #
      # @return [Gcloud::Search::Document]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.doc_id #=> nil
      #   document.rank #=> nil
      #
      # @example To check if an index already contains a document:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document = index.find document # returns nil if not present
      #
      def document doc_id = nil, rank = nil
        Document.new.tap do |d|
          d.doc_id = doc_id
          d.rank = rank
        end
      end

      ##
      # Retrieves the list of documents belonging to the index.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of documents to return. The default
      #   is `100`.
      # @return [Array<Gcloud::Search::Document>] See
      #   {Gcloud::Search::Document::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.documents
      #   documents.each do |index|
      #     puts index.index_id
      #   end
      #
      # @example With pagination: (See {Gcloud::Search::Document::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.documents
      #   loop do
      #     documents.each do |index|
      #       puts index.index_id
      #     end
      #     break unless documents.next?
      #     documents = documents.next
      #   end
      #
      def documents token: nil, max: nil, view: nil
        ensure_connection!
        options = { token: token, max: max, view: view }
        resp = connection.list_docs index_id, options
        return Document::List.from_response(resp, self) if resp.success?
        fail ApiError.from_response(resp)
      end

      ##
      # Saves a new or existing document to the index. If the document instance
      # is new and has been given an id (see {#document}), it will replace an
      # existing document in the index that has the same unique id.
      #
      # @param [Gcloud::Search::Document] document A Document instance, either
      #   new (see {#document}) or existing (see {#find}).
      #
      # @return [Gcloud::Search::Document]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   document = index.document "product-sku-000001"
      #   document.doc_id #=> nil
      #   document.rank #=> nil
      #
      #   document = index.save document
      #   document.doc_id #=> "-2486020449015432113"
      #   document.rank #=> 154223228
      #
      def save document
        ensure_connection!
        resp = connection.create_doc index_id, document.to_hash
        if resp.success?
          raw = document.instance_variable_get "@raw"
          raw.merge! JSON.parse(resp.body)
          return document
        end
        fail ApiError.from_response(resp)
      rescue JSON::ParserError
        raise ApiError.from_response(resp)
      end

      ##
      # Permanently deletes the document from the index.
      #
      # @param [String] doc_id The id of the document.
      # @return [Boolean] `true` if successful
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   index.remove "product-sku-000001"
      #
      def remove doc_id
        # Get the id if passes a Document object
        doc_id = doc_id.doc_id if doc_id.respond_to? :doc_id
        ensure_connection!
        resp = connection.delete_doc index_id, doc_id
        return true if resp.success?
        fail ApiError.from_response(resp)
      end

      ##
      # Permanently deletes the index by deleting its documents. (Indexes cannot
      # be created, updated, or deleted directly on the server: They are derived
      # from the documents that reference them.)
      #
      # @param [Boolean] force If `true`, ensures the deletion of the index by
      #   first deleting all documents. If `false` and the index contains
      #   documents, the request will fail. Default is `false`.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "books"
      #   index.delete
      #
      # @example Deleting an index containing documents with the `force` option:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "books"
      #   index.delete force: true
      #
      def delete force: false
        ensure_connection!
        docs_to_be_removed = documents view: "ID_ONLY"
        return if docs_to_be_removed.empty?
        unless force
          fail "Unable to delete because documents exist. Use force option."
        end
        while docs_to_be_removed
          docs_to_be_removed.each { |d| remove d }
          if docs_to_be_removed.next?
            docs_to_be_removed = documents token: docs_to_be_removed.token,
                                           view: "ID_ONLY"
          else
            docs_to_be_removed = nil
          end
        end
      end

      ##
      # @private New Index from a raw data object.
      def self.from_raw raw, conn
        new.tap do |f|
          f.raw = raw
          f.connection = conn
        end
      end

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Runs a search against the documents in the index using the provided
      # query.
      #
      # By default, Result objects are sorted by document rank. For more information
      # see the [REST API documentation for Document.rank](https://cloud.google.com/search/reference/rest/v1/projects/indexes/documents#resource_representation.google.cloudsearch.v1.Document.rank).
      #
      # You can specify how to sort results with the `order` option. In the
      # example below, the <code>-</code> character before `avg_review` means
      # that results will be sorted in ascending order by `published` and then
      # in descending order by `avg_review`. You can add computed fields with
      # the `expressions` option, and limit the fields that are returned with
      # the `fields` option.
      #
      # @see https://cloud.google.com/search/reference/rest/v1/projects/indexes/search
      #   The REST API documentation for indexes.search
      #
      # @param [String] query The query string in search query syntax. If the
      #   query is `nil` or empty, all documents are returned. For more
      #   information see [Query
      #   Strings](https://cloud.google.com/search/query).
      # @param [Hash] expressions Customized expressions used in `order` or
      #   `fields`. The expression can contain fields in Document, the built-in
      #   fields ( `rank`, the document `rank`, and `score` if scoring is
      #   enabled) and fields defined in `expressions`. All field expressions
      #   expressed as a `Hash` with the keys as the `name` and the values as
      #   the `expression`. The expression value can be a combination of
      #   supported functions encoded in the string. Expressions involving
      #   number fields can use the arithmetical operators (+, -, *, /) and the
      #   built-in numeric functions (`max`, `min`, `pow`, `count`, `log`,
      #   `abs`). Expressions involving geopoint fields can use the `geopoint`
      #   and `distance` functions. Expressions for text and html fields can use
      #   the `snippet` function.
      # @param [Integer] matched_count_accuracy Minimum accuracy requirement for
      #   {Result::List#matched_count}. If specified, `matched_count` will be
      #   accurate to at least that number. For example, when set to 100, any
      #   <code>matched_count <= 100</code> is accurate. This option may add
      #   considerable latency/expense. By default (when it is not specified or
      #   set to 0), the accuracy is the same as `max`.
      # @param [Integer] offset Used to advance pagination to an arbitrary
      #   result, independent of the previous results. Offsets are an
      #   inefficient alternative to using `token`. (Both cannot be both set.)
      #   The default is 0.
      # @param [String] order A comma-separated list of fields for sorting on
      #   the search result, including fields from Document, the built-in fields
      #   (`rank` and `score`), and fields defined in expressions. The default
      #   sorting order is ascending. To specify descending order for a field, a
      #   suffix <code>" desc"</code> should be appended to the field name. For
      #   example: <code>orderBy="foo desc,bar"</code>. The default value for
      #   text sort is the empty string, and the default value for numeric sort
      #   is 0. If not specified, the search results are automatically sorted by
      #   descending `rank`. Sorting by ascending `rank` is not allowed.
      # @param [String, Array<String>] fields The fields to return in the
      #   {Search::Result} objects. These can be fields from {Document}, the
      #   built-in fields `rank` and `score`, and fields defined in expressions.
      #   The default is to return all fields.
      # @param [String, Symbol] scorer The scoring function to invoke on a
      #   search result for this query. If scorer is not set, scoring is
      #   disabled and `score` is 0 for all documents in the search result. To
      #   enable document relevancy score based on term frequency, set `scorer`
      #   to `:generic`.
      # @param [Integer] scorer_size Maximum number of top retrieved results to
      #   score. It is valid only when `scorer` is set. The default is 100.
      # @param [String] token A previously-returned page token representing part
      #   of the larger set
      #   of results to view.
      # @param [Integer] max Maximum number of results to return per page.
      #
      # @return [Array<Gcloud::Search::Result>] (See
      #   {Gcloud::Search::Result::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "books"
      #
      #   results = index.search "dark stormy"
      #   results.each do |result|
      #     puts result.doc_id
      #   end
      #
      # @example With pagination: (See {Gcloud::Search::Result::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "books"
      #
      #   results = index.results
      #   loop do
      #     results.each do |result|
      #       puts result.doc_id
      #     end
      #     break unless results.next?
      #     results = results.next
      #   end
      #
      # @example With the `order` option:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "books"
      #
      #   results = index.search "dark stormy", order: "published, avg_review desc"
      #   documents = index.search query # API call
      #
      # @example With the `fields` option:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   results = index.search "cotton T-shirt",
      #                          expressions: { total_price: "(price + tax)" },
      #                          fields: ["name", "total_price", "highlight"]
      #
      # @example Just as in documents, data is accessible via {Fields} methods:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #   document = index.find "product-sku-000001"
      #   results = index.search "cotton T-shirt"
      #   values = results[0]["description"]
      #
      #   values[0] #=> "100% organic cotton ruby gem T-shirt"
      #   values[0].type #=> :text
      #   values[0].lang #=> "en"
      #   values[1] #=> "<p>100% organic cotton ruby gem T-shirt</p>"
      #   values[1].type #=> :html
      #   values[1].lang #=> "en"
      #
      def search query, expressions: nil, matched_count_accuracy: nil,
                 offset: nil, order: nil, fields: nil, scorer: nil,
                 scorer_size: nil, token: nil, max: nil
        ensure_connection!
        options = { expressions: format_expressions(expressions),
                    matched_count_accuracy: matched_count_accuracy,
                    offset: offset, order: order, fields: fields,
                    scorer: scorer, scorer_size: scorer_size, token: token,
                    max: max }
        resp = connection.search index_id, query, options
        if resp.success?
          Result::List.from_response resp, self, query, options
        else
          fail ApiError.from_response(resp)
        end
      end

      # rubocop:enable Metrics/LineLength

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def format_expressions expressions
        return nil if expressions.nil?
        expressions.to_h.map { |k, v| { name: k, expression: v } }
      end
    end
  end
end
