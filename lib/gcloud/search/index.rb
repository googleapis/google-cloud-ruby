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

require "gcloud/search/document"
require "gcloud/search/index/list"
require "gcloud/search/result"

module Gcloud
  module Search
    ##
    # = Index
    #
    # See Gcloud#search
    class Index
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The raw data object.
      attr_accessor :raw #:nodoc:

      ##
      # Creates a new Index instance.
      #
      def initialize #:nodoc:
        @connection = nil
        @raw = nil
      end

      def index_id
        @raw["indexId"]
      end

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

      def documents options = {}
        ensure_connection!
        resp = connection.list_docs index_id, options
        return Document::List.from_response(resp, self) if resp.success?
        fail ApiError.from_response(resp)
      end

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

      def remove doc_id
        # Get the id if passes a Document object
        doc_id = doc_id.doc_id if doc_id.respond_to? :doc_id
        ensure_connection!
        resp = connection.delete_doc index_id, doc_id
        return true if resp.success?
        fail ApiError.from_response(resp)
      end

      def delete options = {}
        ensure_connection!
        docs_to_be_removed = documents
        return if docs_to_be_removed.empty?
        unless options[:force]
          fail "Unable to delete because documents exist. Use :force option."
        end
        while docs_to_be_removed
          docs_to_be_removed.each { |d| remove d }
          docs_to_be_removed = docs_to_be_removed.next
        end
      end

      ##
      # New Index from a raw data object.
      def self.from_raw raw, conn #:nodoc:
        new.tap do |f|
          f.raw = raw
          f.connection = conn
        end
      end

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Runs a search against the documents in the index using the provided
      # query. For more information see the REST API documentation for
      # {indexes.search}[https://cloud.google.com/search/reference/rest/v1/projects/indexes/search].
      #
      # === Parameters
      #
      # +query+::
      #   The query string in search query syntax. If the query is +nil+ or
      #   empty, all documents are returned. For more information see {Query
      #   Strings}[https://cloud.google.com/search/query]. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:expressions]</code>::
      #   Customized expressions used in +order+ or +return_fields+. The
      #   expression can contain fields in Document, the built-in fields (
      #   +_rank+, the document +rank+, and +_score+ if scoring is enabled) and
      #   fields defined in +expressions+. Each field expression is represented
      #   in a json object with +name+ and +expression+ fields. The expression
      #   value can be a combination of supported functions encoded in the
      #   string. Expressions involving number fields can use the arithmetical
      #   operators (+, -, *, /) and the built-in numeric functions (+max+,
      #   +min+, +pow+, +count+, +log+, +abs+). Expressions involving geopoint
      #   fields can use the geopoint and distance functions. Expressions for
      #   text and html fields can use the +snippet+ function.
      #   (+String+)
      # <code>options[:matched_count_accuracy]</code>::
      #   Minimum accuracy requirement for Result::List#matched_count. If
      #   specified, +matched_count+ will be accurate to at least that number.
      #   For example, when set to 100, any +matched_count <= 100+ is accurate.
      #   This option may add considerable latency/expense. By default (when it
      #   is not specified or set to 0), the accuracy is the same as +max+.
      #   (+Integer+)
      # <code>options[:offset]</code>::
      #   Used to advance pagination to an arbitrary result, independent of the
      #   previous results. Offsets are an inefficient alternative to using
      #   +token+. (Both cannot be both set.) The default is 0.
      #   (+Integer+)
      # <code>options[:order]</code>::
      #   A comma-separated list of fields for sorting on the search result,
      #   including fields from Document, the built-in fields (+_rank+ and
      #   +_score+), and fields defined in expressions. The default sorting
      #   order is ascending. To specify descending order for a field, a suffix
      #   <code>" desc"</code> should be appended to the field name. For
      #   example: <code>orderBy="foo desc,bar"</code>. The default value for
      #   text sort is the empty string, and the default value for numeric sort
      #   is 0. If not specified, the search results are automatically sorted by
      #   descending +_rank+. Sorting by ascending +_rank+ is not allowed.
      #   (+String+)
      # <code>options[:return_fields]</code>::
      #   The fields to return in the Search::Result objects. These can be
      #   fields from Document, the built-in fields +_rank+ and +_score+, and
      #   fields defined in expressions. The default is to return all fields.
      #   (+String+)
      # <code>options[:scorer]</code>::
      #   The scoring function to invoke on a search result for this query. If
      #   scorer is not set, scoring is disabled and +_score+ is 0 for all
      #   documents in the search result. To enable document relevancy score
      #   based on term frequency, set +scorer+ to +:generic+.
      #   (+String+ or +Symbol+)
      # <code>options[:scorer_size]</code>::
      #   Maximum number of top retrieved results to score. It is valid only
      #   when +scorer+ is set. The default is 100. (+Integer+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of results to return per page. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Search::Result (See Gcloud::Search::Result::List)
      #
      # === Examples
      #
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
      # If you have a significant number of search results, you may need to
      # paginate through them: (See Gcloud::Search::Result::List)
      #
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
      # You can add computed fields with the +expressions+ option, and limit the
      # fields that are returned with the +fields+ option. In this example, an
      # expression uses the Search service's +snippet+ function to truncate
      # document data. For more information see the App Engine Search Python
      # guide, {Writing
      # expressions}[https://cloud.google.com/appengine/docs/python/search/options#Python_Writing_expressions].
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   expressions = [
      #     { name: "total_price", expression: "(price + tax)" },
      #     { name: "highlight", expression: "snippet('cotton', description, 80)" }
      #   ]
      #   results = index.search "cotton T-shirt",
      #                          expressions: expressions,
      #                          fields: [name, total_price, highlight]
      #
      def search query, options = {}
        ensure_connection!
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
    end
  end
end
