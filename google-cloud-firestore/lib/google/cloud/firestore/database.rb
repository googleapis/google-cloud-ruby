# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/collection"
require "google/cloud/firestore/document"
require "google/cloud/firestore/query"

module Google
  module Cloud
    module Firestore
      ##
      # # Database
      #
      class Database
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Firestore Database instance.
        def initialize service
          @service = service
        end

        def project
          @project ||= Project.new service
        end

        def project_id
          service.project
        end

        def database_id
          "(default)"
        end

        def path
          service.database_path
        end

        ##
        # Retrieves a list of collections
        def cols
          ensure_service!

          return enum_for(:cols) unless block_given?

          collection_ids = service.list_collections "#{path}/documents"
          collection_ids.each { |collection_id| yield col(collection_id) }
        end
        alias_method :collections, :cols

        def col collection_path
          if collection_path.to_s.split("/").count.even?
            fail ArgumentError, "collection_path must refer to a collection."
          end

          Collection.from_path "#{path}/documents/#{collection_path}", self
        end
        alias_method :collection, :col

        ##
        # Retrieves an Enumerator of documents
        def docs collection_path, &block
          col(collection_path).docs(&block)
        end
        alias_method :documents, :docs

        def doc document_path
          if document_path.to_s.split("/").count.odd?
            fail ArgumentError, "document_path must refer to a document."
          end

          doc_path = "#{path}/documents/#{document_path}"

          Document.from_path doc_path, self
        end
        alias_method :document, :doc

        def get_all *document_paths, mask: nil
          ensure_service!

          unless block_given?
            return enum_for(:get_all, document_paths, mask: mask)
          end

          full_doc_paths = Array(document_paths).flatten.map do |doc_path|
            if doc_path.respond_to? :path
              doc_path.path
            else
              doc(doc_path).path
            end
          end

          results = service.get_documents full_doc_paths, mask: mask
          results.each do |result|
            yield Document.from_batch_result(result, self)
          end
        end
        alias_method :get_docs, :get_all
        alias_method :get_documents, :get_all
        alias_method :find, :get_all

        def query
          Query.start "#{path}/documents", self
        end
        alias_method :q, :query

        def select *fields
          query.select fields
        end

        def from collection_id
          query.from collection_id
        end

        def where name, operator, value
          query.where name, operator, value
        end

        def order name, direction = :asc
          query.order name, direction
        end

        def offset num
          query.offset num
        end

        def limit num
          query.limit num
        end

        def start_at *values
          query.start_at values
        end

        def start_after *values
          query.start_after values
        end

        def end_before *values
          query.end_before values
        end

        def end_at *values
          query.end_at values
        end

        def run query
          ensure_service!

          return enum_for(:run, query) unless block_given?

          results = service.run_query query.parent_path, query.grpc
          results.each do |result|
            @transaction_id ||= result.transaction
            next if result.document.nil?
            yield Document.from_query_result(result, self)
          end
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
