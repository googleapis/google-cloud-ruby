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


require "google/cloud/firestore/document"
require "google/cloud/firestore/query"
require "google/cloud/firestore/generate"

module Google
  module Cloud
    module Firestore
      ##
      # # Collection
      #
      module Collection
        ##
        # @private New Collection reference object from a path.
        def self.from_path path, context
          Reference.new.tap do |c|
            c.context = context
            c.instance_variable_set :@path, path
          end
        end

        class Reference
          ##
          # @private The connection context object.
          attr_accessor :context

          def project_id
            path.split("/")[1]
          end

          def database_id
            path.split("/")[3]
          end

          def collection_id
            path.split("/").last
          end

          def collection_path
            path.split("/", 6).last
          end

          def path
            @path
          end

          # Document OR Database
          def parent
            if collection_path.include? "/"
              return Document.from_path parent_path, context
            end
            return context.database if context.respond_to? :database
            context
          end

          ##
          # Retrieves an Enumerator of documents
          def docs &block
            query.run(&block)
          end
          alias_method :documents, :docs
          alias_method :get, :docs
          alias_method :run, :docs

          def doc document_path = nil
            document_path ||= random_document_id

            ensure_context!
            context.doc "#{collection_path}/#{document_path}"
          end
          alias_method :document, :doc

          def add
            doc.tap { |d| d.create({}) }
          end

          def get_all *document_paths, mask: nil, &block
            full_doc_paths = Array(document_paths).flatten.map do |doc_path|
              if doc_path.respond_to? :document_path
                doc_path.document_path
              else
                doc(doc_path).document_path
              end
            end

            ensure_context!
            context.get_all(full_doc_paths, mask: mask, &block)
          end
          alias_method :get_docs, :get_all
          alias_method :get_documents, :get_all
          alias_method :find, :get_all

          def query
            ensure_context!

            Query.start(parent_path, context).from(collection_id)
          end
          alias_method :q, :query

          def select *fields
            query.select fields
          end

          def from collection_id
            query.from collection_id
          end

          def all_descendants
            query.all_descendants
          end

          def direct_descendants
            query.direct_descendants
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

          protected

          def parent_path
            path.split("/")[0...-1].join("/")
          end

          def random_document_id
            Generate.unique_id
          end

          ##
          # @private Raise an error unless context is available.
          def ensure_context!
            fail "Must have active connection to service" unless context
            return unless context.respond_to? :closed?
            self.context = context.database if context.closed?
          end
        end
      end
    end
  end
end
