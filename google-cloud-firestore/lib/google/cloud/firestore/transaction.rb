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
require "google/cloud/firestore/collection"
require "google/cloud/firestore/query"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # Transaction
      #
      class Transaction
        ##
        # @private New Transaction object.
        def initialize
          @writes = []
          @transaction_id
        end

        def transaction_id
          @transaction_id
        end

        def project
          @database.project
        end

        def database
          @database
        end

        def project_id
          @database.project_id
        end

        def database_id
          @database.database_id
        end

        def path
          @database.path
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
          ensure_not_closed!

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
          ensure_not_closed!

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

          results = service.get_documents \
            full_doc_paths, mask: mask, transaction: transaction_or_create
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

        def get obj
          ensure_not_closed!
          ensure_service!

          obj = coalesce_get_argument obj

          if obj.is_a?(Document::Reference)
            doc = get_all([obj]).first
            yield doc if block_given?
            return doc
          end

          return enum_for(:get, obj) unless block_given?

          results = service.run_query obj.parent_path, obj.grpc,
                                      transaction: transaction_or_create
          results.each do |result|
            # if we don't have a transaction_id yet, use what was given
            @transaction_id ||= result.transaction
            next if result.document.nil?
            yield Document.from_query_result(result, self)
          end
        end
        alias_method :run, :get

        def create doc_path, data
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          write = Google::Firestore::V1beta1::Write.new(
            update: Google::Firestore::V1beta1::Document.new(
              name: full_doc_path,
              fields: Convert.hash_to_fields(data)),
            current_document: Google::Firestore::V1beta1::Precondition.new(
              exists: false)
          )
          @writes << write
          nil
        end

        def set doc_path, data
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          write = Google::Firestore::V1beta1::Write.new(
            update: Google::Firestore::V1beta1::Document.new(
              name: full_doc_path,
              fields: Convert.hash_to_fields(data))
          )
          @writes << write
          nil
        end

        def merge doc_path, data
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          data_mask = data.keys.map(&:to_s)

          write = Google::Firestore::V1beta1::Write.new(
            update: Google::Firestore::V1beta1::Document.new(
              name: full_doc_path,
              fields: Convert.hash_to_fields(data)),
            update_mask: Google::Firestore::V1beta1::DocumentMask.new(
              field_paths: data_mask)
          )
          @writes << write
          nil
        end

        def update doc_path, data
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          data_mask = data.keys.map(&:to_s)

          write = Google::Firestore::V1beta1::Write.new(
            update: Google::Firestore::V1beta1::Document.new(
              name: full_doc_path,
              fields: Convert.hash_to_fields(data)),
            update_mask: Google::Firestore::V1beta1::DocumentMask.new(
              field_paths: data_mask)
          )
          @writes << write
          nil
        end

        def delete doc_path
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end

          write = Google::Firestore::V1beta1::Write.new(
            delete: full_doc_path
          )
          @writes << write
          nil
        end

        ##
        # @private commit the transaction
        def commit
          ensure_not_closed!
          return rollback if @writes.empty?
          @closed = true
          return if @writes.empty?
          ensure_transaction_id!
          resp = service.commit @writes, transaction: transaction_id
          return nil if resp.nil?
          Convert.timestamp_to_time resp.commit_time
        end

        ##
        # @private rollback and close the transaction
        def rollback
          ensure_not_closed!
          @closed = true
          return if @transaction_id.nil?
          service.rollback @transaction_id
        end

        ##
        # @private the transaction is complete and closed
        def closed?
          @closed
        end

        ##
        # @private New Transaction reference object from a path.
        def self.from_database database
          new.tap do |s|
            s.instance_variable_set :@database, database
          end
        end

        ##
        # @private The database's Service object.
        def service
          ensure_database!

          database.service
        end

        protected

        def coalesce_get_argument obj
          if obj.is_a?(String) || obj.is_a?(Symbol)
            if obj.to_s.split("/").count.even?
              return doc obj # Convert a Document::Reference
            else
              return col(obj).query # Convert to Query
            end
          end

          return obj.ref if obj.is_a?(Document::Snapshot)

          return obj.query if obj.is_a? Collection::Reference

          obj
        end

        def transaction_or_create
          return @transaction_id if @transaction_id

          transaction_opt
        end

        def transaction_opt
          Google::Firestore::V1beta1::TransactionOptions.new(
            read_write: \
              Google::Firestore::V1beta1::TransactionOptions::ReadWrite.new
          )
        end

        def ensure_not_closed!
          fail "transaction is closed" if closed?
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_transaction_id!
          ensure_service!

          return unless @transaction_id.nil?
          resp = service.begin_transaction transaction_opt
          @transaction_id = resp.transaction
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_database!
          fail "Must have active connection to service" unless database
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
