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
require "google/cloud/firestore/v1beta1"

module Google
  module Cloud
    module Firestore
      ##
      # @private Represents the gRPC Firestore service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :timeout, :client_config

        ##
        # @private Default project.
        def self.default_project_id
          ENV["FIRESTORE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, client_config: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @client_config = client_config || {}
        end

        def firestore
          @firestore ||= \
            V1beta1::FirestoreClient.new(
              credentials: credentials,
              timeout: timeout,
              client_config: client_config,
              lib_name: "gccl",
              lib_version: Google::Cloud::Firestore::VERSION
            )
        end

        def get_documents document_paths, mask: nil, transaction: nil
          batch_get_args = { mask: document_mask(mask) }
          if transaction.is_a? String
            batch_get_args[:transaction] = transaction
          elsif transaction
            batch_get_args[:new_transaction] = transaction
          end
          batch_get_args[:options] = call_options parent: database_path

          execute do
            firestore.batch_get_documents database_path, document_paths,
                                          batch_get_args
          end
        end

        def list_collections parent, transaction: nil
          list_args = {}
          if transaction.is_a? String
            list_args[:transaction] = transaction
          elsif transaction
            list_args[:new_transaction] = transaction
          end
          list_args[:options] = call_options parent: database_path

          execute do
            firestore.list_collection_ids parent, list_args
          end
        end

        def run_query path, query_grpc, transaction: nil
          run_query_args = { structured_query: query_grpc }
          if transaction.is_a? String
            run_query_args[:transaction] = transaction
          elsif transaction
            run_query_args[:new_transaction] = transaction
          end
          run_query_args[:options] = call_options parent: database_path

          execute do
            firestore.run_query path, run_query_args
          end
        end

        def begin_transaction transaction_opt
          options = call_options parent: database_path

          execute do
            firestore.begin_transaction database_path,
                                        options_: transaction_opt,
                                        options: options
          end
        end

        def commit writes, transaction: nil
          commit_args = {}
          commit_args[:transaction] = transaction if transaction
          commit_args[:options] = call_options parent: database_path

          execute do
            firestore.commit database_path, writes, commit_args
          end
        end

        def rollback transaction
          options = call_options parent: database_path

          execute do
            firestore.rollback database_path, transaction, options: options
          end
        end

        def database_path project_id: project, database_id: "(default)"
          V1beta1::FirestoreClient.database_root_path project_id, database_id
        end

        def documents_path project_id: project, database_id: "(default)"
          V1beta1::FirestoreClient.document_root_path project_id, database_id
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
          Google::Gax::CallOptions.new({
            kwargs: default_headers(parent),
            page_token: token
          }.delete_if { |_, v| v.nil? })
        end

        def document_mask mask
          return nil if mask.nil?

          mask = Array(mask).map(&:to_s).reject(&:nil?).reject(&:empty?)
          return nil if mask.empty?

          Google::Firestore::V1beta1::DocumentMask.new field_paths: mask
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
