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
          if Convert.is_nested data, :DELETE
            raise ArgumentError, "DELETE not allowed on create"
          end

          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          data, server_time_pairs = Convert.remove_from data, :SERVER_TIME

          if data.any? || server_time_pairs.empty?
            write = Google::Firestore::V1beta1::Write.new(
              update: Google::Firestore::V1beta1::Document.new(
                name: full_doc_path,
                fields: Convert.hash_to_fields(data)),
              current_document: Google::Firestore::V1beta1::Precondition.new(
                exists: false)
            )
            @writes << write
          end

          if server_time_pairs.any?
            field_transforms = server_time_pairs.map do |server_time_pair|
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: server_time_pair,
                set_to_server_value: :REQUEST_TIME
              )
            end
            write = Google::Firestore::V1beta1::Write.new(
              transform: Google::Firestore::V1beta1::DocumentTransform.new(
                document: full_doc_path,
                field_transforms: field_transforms
              )
            )
            if data.empty?
              write.current_document = \
                Google::Firestore::V1beta1::Precondition.new(exists: false)
            end
            @writes << write
          end

          nil
        end

        def set doc_path, data, merge: nil
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          data, delete_paths = Convert.remove_from data, :DELETE
          raise ArgumentError, "DELETE not allowed on set" if delete_paths.any?

          data, server_time_paths = Convert.remove_from data, :SERVER_TIME

          write = Google::Firestore::V1beta1::Write.new(
            update: Google::Firestore::V1beta1::Document.new(
              name: full_doc_path,
              fields: Convert.hash_to_fields(data))
          )

          if merge
            if merge == true
              # extract the leaf node field paths from data
              field_paths = Convert.extract_leaf_nodes data
            else
              field_paths = Array(merge).map do |inner_field_path|
                if inner_field_path.is_a? Array
                  paths = inner_field_path.map do |field_path|
                    Convert.escape_field_path field_path.to_s
                  end
                  paths.join(".")
                else
                  inner_field_path
                end
              end
            end

            # Ensure provided field paths are valid.
            all_valid = Convert.extract_leaf_nodes data
            verify_paths = field_paths - server_time_paths
            all_valid_check = verify_paths.map do |verify_path|
              all_valid.include?(verify_path) ||
                all_valid.select { |fp| fp.start_with? "#{verify_path}." }.any?
            end
            all_valid_check = all_valid_check.include? false
            raise ArgumentError, "all fields must be in data" if all_valid_check

            # Choose only the data there are field paths for
            data = Convert.select_by_field_paths data, verify_paths

            if data.empty?
              if merge == true
                raise ArgumentError, "data required for merge: true"
              end
              write = nil
            else
              write = Google::Firestore::V1beta1::Write.new(
                update: Google::Firestore::V1beta1::Document.new(
                  name: full_doc_path,
                  fields: Convert.hash_to_fields(data)),
                update_mask: Google::Firestore::V1beta1::DocumentMask.new(
                  field_paths: field_paths)
              )
            end
          end

          @writes << write if write

          if server_time_paths.any?
            field_transforms = server_time_paths.map do |server_time_pair|
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: server_time_pair,
                set_to_server_value: :REQUEST_TIME
              )
            end
            transform_write = Google::Firestore::V1beta1::Write.new(
              transform: Google::Firestore::V1beta1::DocumentTransform.new(
                document: full_doc_path,
                field_transforms: field_transforms
              )
            )
            @writes << transform_write
          end

          nil
        end

        def update doc_path, data, update_time: nil
          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end
          fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

          data, server_time_paths = Convert.remove_from data, :SERVER_TIME

          field_paths = data.keys.map(&:to_s).map do |path|
            path.split(".").map { |p| Convert.escape_field_path p }.join(".")
          end

          data, delete_paths = Convert.remove_from data, :DELETE
          nested_delete = (delete_paths - field_paths).any?
          fail ArgumentError, "DELETE cannot be nested" if nested_delete

          # extract data after building field paths
          data = Convert.extract_field_paths data

          if data.empty? && delete_paths.empty? && server_time_paths.empty?
            fail ArgumentError, "data is required"
          end

          if data.any? || delete_paths.any?
            write = Google::Firestore::V1beta1::Write.new(
              update: Google::Firestore::V1beta1::Document.new(
                name: full_doc_path,
                fields: Convert.hash_to_fields(data)),
              update_mask: Google::Firestore::V1beta1::DocumentMask.new(
                field_paths: field_paths),
              current_document: Google::Firestore::V1beta1::Precondition.new(
                exists: true)
            )
            if update_time
              write.current_document = \
                Google::Firestore::V1beta1::Precondition.new(
                  update_time: Convert.time_to_timestamp(update_time))
            end
            @writes << write
          end

          if server_time_paths.any?
            field_transforms = server_time_paths.map do |server_time_pair|
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: server_time_pair,
                set_to_server_value: :REQUEST_TIME
              )
            end
            write = Google::Firestore::V1beta1::Write.new(
              transform: Google::Firestore::V1beta1::DocumentTransform.new(
                document: full_doc_path,
                field_transforms: field_transforms
              )
            )
            if data.empty?
              write.current_document = \
                Google::Firestore::V1beta1::Precondition.new(exists: true)
            end
            @writes << write
          end

          nil
        end

        def delete doc_path, exists: nil, update_time: nil
          if !exists.nil? && !update_time.nil?
            raise ArgumentError, "cannot specify both exists and update_time"
          end

          ensure_not_closed!

          full_doc_path = if doc_path.respond_to? :path
                            doc_path.path
                          else
                            doc(doc_path).path
                          end

          write = Google::Firestore::V1beta1::Write.new(
            delete: full_doc_path
          )
          delete_precondition = build_precondition exists: exists,
                                                   update_time: update_time
          write.current_document = delete_precondition if delete_precondition
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

        def build_precondition exists: nil, update_time: nil
          return nil if exists.nil? && update_time.nil?

          Google::Firestore::V1beta1::Precondition.new({
            exists: exists, update_time: Convert.time_to_timestamp(update_time)
          }.delete_if { |_, v| v.nil? })
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
