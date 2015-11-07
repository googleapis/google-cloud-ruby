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

      def document doc_id
        ensure_connection!
        resp = connection.get_doc index_id, doc_id
        return Document.from_hash(JSON.parse(resp.body)) if resp.success?
        return nil if resp.status == 404
        fail ApiError.from_response(resp)
      rescue JSON::ParserError
        raise ApiError.from_response(resp)
      end

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
          document.raw = JSON.parse resp.body
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

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
