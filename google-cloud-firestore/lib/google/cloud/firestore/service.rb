# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/env"
require "google/cloud/errors"
require "google/cloud/firestore/credentials"
require "google/cloud/firestore/version"
require "google/cloud/firestore/v1"

module Google
  module Cloud
    module Firestore
      ##
      # @private Represents the gRPC Firestore service, including all the API
      # methods.
      class Service
        attr_accessor :project
        attr_accessor :credentials
        attr_accessor :timeout
        attr_accessor :host

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil
          @project = project
          @credentials = credentials
          @host = host
          @timeout = timeout
        end

        def firestore
          @firestore ||= \
            V1::Firestore::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Firestore::VERSION
              config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}/databases/(default)" }
            end
        end

        def get_documents document_paths, mask: nil, transaction: nil
          batch_get_req = {
            database:  database_path,
            documents: document_paths,
            mask:      document_mask(mask)
          }
          if transaction.is_a? String
            batch_get_req[:transaction] = transaction
          elsif transaction
            batch_get_req[:new_transaction] = transaction
          end

          firestore.batch_get_documents batch_get_req, call_options(parent: database_path)
        end

        ##
        # Returns a list of DocumentReferences that are directly nested under
        # the given collection. Fetches all documents from the server, but
        # provides an empty field mask to avoid unnecessary data transfer. Sets
        # the showMissing flag to true to support full document traversal. If
        # there are too many documents, recommendation will be not to call this
        # method.
        def list_documents parent, collection_id, token: nil, max: nil
          mask = { field_paths: [] }
          paged_enum = firestore.list_documents parent:        parent,
                                                collection_id: collection_id,
                                                page_size:     max,
                                                page_token:    token,
                                                mask:          mask,
                                                show_missing:  true
          paged_enum.response
        end

        def list_collections parent, token: nil, max: nil
          firestore.list_collection_ids(
            {
              parent:     parent,
              page_size:  max,
              page_token: token
            },
            call_options(parent: database_path)
          )
        end

        ##
        # Returns Google::Cloud::Firestore::V1::PartitionQueryResponse
        def partition_query parent, query_grpc, partition_count, token: nil, max: nil
          request = Google::Cloud::Firestore::V1::PartitionQueryRequest.new(
            parent: parent,
            structured_query: query_grpc,
            partition_count: partition_count,
            page_token: token,
            page_size: max
          )
          paged_enum = firestore.partition_query request
          paged_enum.response
        end

        def run_query path, query_grpc, transaction: nil
          run_query_req = {
            parent:           path,
            structured_query: query_grpc
          }
          if transaction.is_a? String
            run_query_req[:transaction] = transaction
          elsif transaction
            run_query_req[:new_transaction] = transaction
          end

          firestore.run_query run_query_req, call_options(parent: database_path)
        end

        def listen enum
          firestore.listen enum, call_options(parent: database_path)
        end

        def begin_transaction transaction_opt
          firestore.begin_transaction(
            {
              database: database_path,
              options:  transaction_opt
            },
            call_options(parent: database_path)
          )
        end

        def commit writes, transaction: nil
          commit_req = {
            database: database_path,
            writes:   writes
          }
          commit_req[:transaction] = transaction if transaction

          firestore.commit commit_req, call_options(parent: database_path)
        end

        def rollback transaction
          firestore.rollback(
            {
              database:    database_path,
              transaction: transaction
            },
            call_options(parent: database_path)
          )
        end

        def database_path project_id: project, database_id: "(default)"
          # Originally used V1::FirestoreClient.database_root_path until it was removed in #5405.
          "projects/#{project_id}/databases/#{database_id}"
        end

        def documents_path project_id: project, database_id: "(default)"
          # Originally used V1::FirestoreClient.document_root_path until it was removed in #5405.
          "projects/#{project_id}/databases/#{database_id}/documents"
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def default_headers parent = nil
          parent ||= database_path
          { "google-cloud-resource-prefix" => parent }
        end

        def call_options parent: nil, token: nil
          Gapic::CallOptions.new(**{
            metadata:   default_headers(parent),
            page_token: token
          }.delete_if { |_, v| v.nil? })
        end

        def document_mask mask
          return nil if mask.nil?

          mask = Array(mask).map(&:to_s).reject(&:empty?)
          return nil if mask.empty?

          Google::Cloud::Firestore::V1::DocumentMask.new field_paths: mask
        end
      end
    end
  end
end
