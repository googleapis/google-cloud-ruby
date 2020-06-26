# Copyright 2020 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/firestore/v1/firestore.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/firestore/v1/firestore_pb"
require "google/cloud/firestore/v1/credentials"
require "google/cloud/firestore/version"

module Google
  module Cloud
    module Firestore
      module V1
        # The Cloud Firestore service.
        #
        # Cloud Firestore is a fast, fully managed, serverless, cloud-native NoSQL
        # document database that simplifies storing, syncing, and querying data for
        # your mobile, web, and IoT apps at global scale. Its client libraries provide
        # live synchronization and offline support, while its security features and
        # integrations with Firebase and Google Cloud Platform (GCP) accelerate
        # building truly serverless apps.
        #
        # @!attribute [r] firestore_stub
        #   @return [Google::Firestore::V1::Firestore::Stub]
        class FirestoreClient
          # @private
          attr_reader :firestore_stub

          # The default address of the service.
          SERVICE_ADDRESS = "firestore.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_documents" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "documents"),
            "list_collection_ids" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "collection_ids"),
            "partition_query" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "partitions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/datastore"
          ].freeze


          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/firestore/v1/firestore_services_pb"

            credentials ||= Google::Cloud::Firestore::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Firestore::V1::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Google::Cloud::Firestore::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "firestore_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.firestore.v1.Firestore",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @firestore_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Firestore::V1::Firestore::Stub.method(:new)
            )

            @get_document = Google::Gax.create_api_call(
              @firestore_stub.method(:get_document),
              defaults["get_document"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_documents = Google::Gax.create_api_call(
              @firestore_stub.method(:list_documents),
              defaults["list_documents"],
              exception_transformer: exception_transformer
            )
            @create_document = Google::Gax.create_api_call(
              @firestore_stub.method(:create_document),
              defaults["create_document"],
              exception_transformer: exception_transformer
            )
            @update_document = Google::Gax.create_api_call(
              @firestore_stub.method(:update_document),
              defaults["update_document"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'document.name' => request.document.name}
              end
            )
            @delete_document = Google::Gax.create_api_call(
              @firestore_stub.method(:delete_document),
              defaults["delete_document"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @batch_get_documents = Google::Gax.create_api_call(
              @firestore_stub.method(:batch_get_documents),
              defaults["batch_get_documents"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'database' => request.database}
              end
            )
            @begin_transaction = Google::Gax.create_api_call(
              @firestore_stub.method(:begin_transaction),
              defaults["begin_transaction"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'database' => request.database}
              end
            )
            @commit = Google::Gax.create_api_call(
              @firestore_stub.method(:commit),
              defaults["commit"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'database' => request.database}
              end
            )
            @rollback = Google::Gax.create_api_call(
              @firestore_stub.method(:rollback),
              defaults["rollback"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'database' => request.database}
              end
            )
            @run_query = Google::Gax.create_api_call(
              @firestore_stub.method(:run_query),
              defaults["run_query"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @write = Google::Gax.create_api_call(
              @firestore_stub.method(:write),
              defaults["write"],
              exception_transformer: exception_transformer
            )
            @listen = Google::Gax.create_api_call(
              @firestore_stub.method(:listen),
              defaults["listen"],
              exception_transformer: exception_transformer
            )
            @list_collection_ids = Google::Gax.create_api_call(
              @firestore_stub.method(:list_collection_ids),
              defaults["list_collection_ids"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @partition_query = Google::Gax.create_api_call(
              @firestore_stub.method(:partition_query),
              defaults["partition_query"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @batch_write = Google::Gax.create_api_call(
              @firestore_stub.method(:batch_write),
              defaults["batch_write"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'database' => request.database}
              end
            )
          end

          # Service calls

          # Gets a single document.
          #
          # @param name [String]
          #   Required. The resource name of the Document to get. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          # @param mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads the document in a transaction.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads the version of the document at the given time.
          #   This may not be older than 270 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::Document]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `name`:
          #   name = ''
          #   response = firestore_client.get_document(name)

          def get_document \
              name,
              mask: nil,
              transaction: nil,
              read_time: nil,
              options: nil,
              &block
            req = {
              name: name,
              mask: mask,
              transaction: transaction,
              read_time: read_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::GetDocumentRequest)
            @get_document.call(req, options, &block)
          end

          # Lists documents.
          #
          # @param parent [String]
          #   Required. The parent resource name. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents` or
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          #   For example:
          #   `projects/my-project/databases/my-database/documents` or
          #   `projects/my-project/databases/my-database/documents/chatrooms/my-chatroom`
          # @param collection_id [String]
          #   Required. The collection ID, relative to `parent`, to list. For example: `chatrooms`
          #   or `messages`.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param order_by [String]
          #   The order to sort results by. For example: `priority desc, name`.
          # @param mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If a document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 270 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param show_missing [true, false]
          #   If the list should show missing documents. A missing document is a
          #   document that does not exist but has sub-documents. These documents will
          #   be returned with a key but will not have fields, {Google::Firestore::V1::Document#create_time Document#create_time},
          #   or {Google::Firestore::V1::Document#update_time Document#update_time} set.
          #
          #   Requests with `show_missing` may not specify `where` or
          #   `order_by`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Firestore::V1::Document>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Firestore::V1::Document>]
          #   An enumerable of Google::Firestore::V1::Document instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # TODO: Initialize `collection_id`:
          #   collection_id = ''
          #
          #   # Iterate over all results.
          #   firestore_client.list_documents(parent, collection_id).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   firestore_client.list_documents(parent, collection_id).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_documents \
              parent,
              collection_id,
              page_size: nil,
              order_by: nil,
              mask: nil,
              transaction: nil,
              read_time: nil,
              show_missing: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              collection_id: collection_id,
              page_size: page_size,
              order_by: order_by,
              mask: mask,
              transaction: transaction,
              read_time: read_time,
              show_missing: show_missing
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::ListDocumentsRequest)
            @list_documents.call(req, options, &block)
          end

          # Creates a new document.
          #
          # @param parent [String]
          #   Required. The parent resource. For example:
          #   `projects/{project_id}/databases/{database_id}/documents` or
          #   `projects/{project_id}/databases/{database_id}/documents/chatrooms/{chatroom_id}`
          # @param collection_id [String]
          #   Required. The collection ID, relative to `parent`, to list. For example: `chatrooms`.
          # @param document [Google::Firestore::V1::Document | Hash]
          #   Required. The document to create. `name` must not be set.
          #   A hash of the same form as `Google::Firestore::V1::Document`
          #   can also be provided.
          # @param document_id [String]
          #   The client-assigned document ID to use for this document.
          #
          #   Optional. If not specified, an ID will be assigned by the service.
          # @param mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::Document]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # TODO: Initialize `collection_id`:
          #   collection_id = ''
          #
          #   # TODO: Initialize `document`:
          #   document = {}
          #   response = firestore_client.create_document(parent, collection_id, document)

          def create_document \
              parent,
              collection_id,
              document,
              document_id: nil,
              mask: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              collection_id: collection_id,
              document: document,
              document_id: document_id,
              mask: mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::CreateDocumentRequest)
            @create_document.call(req, options, &block)
          end

          # Updates or inserts a document.
          #
          # @param document [Google::Firestore::V1::Document | Hash]
          #   Required. The updated document.
          #   Creates the document if it does not already exist.
          #   A hash of the same form as `Google::Firestore::V1::Document`
          #   can also be provided.
          # @param update_mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to update.
          #   None of the field paths in the mask may contain a reserved name.
          #
          #   If the document exists on the server and has fields not referenced in the
          #   mask, they are left unchanged.
          #   Fields referenced in the mask, but not present in the input document, are
          #   deleted from the document on the server.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param current_document [Google::Firestore::V1::Precondition | Hash]
          #   An optional precondition on the document.
          #   The request will fail if this is set and not met by the target document.
          #   A hash of the same form as `Google::Firestore::V1::Precondition`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::Document]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `document`:
          #   document = {}
          #   response = firestore_client.update_document(document)

          def update_document \
              document,
              update_mask: nil,
              mask: nil,
              current_document: nil,
              options: nil,
              &block
            req = {
              document: document,
              update_mask: update_mask,
              mask: mask,
              current_document: current_document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::UpdateDocumentRequest)
            @update_document.call(req, options, &block)
          end

          # Deletes a document.
          #
          # @param name [String]
          #   Required. The resource name of the Document to delete. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          # @param current_document [Google::Firestore::V1::Precondition | Hash]
          #   An optional precondition on the document.
          #   The request will fail if this is set and not met by the target document.
          #   A hash of the same form as `Google::Firestore::V1::Precondition`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `name`:
          #   name = ''
          #   firestore_client.delete_document(name)

          def delete_document \
              name,
              current_document: nil,
              options: nil,
              &block
            req = {
              name: name,
              current_document: current_document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::DeleteDocumentRequest)
            @delete_document.call(req, options, &block)
            nil
          end

          # Gets multiple documents.
          #
          # Documents returned by this method are not guaranteed to be returned in the
          # same order that they were requested.
          #
          # @param database [String]
          #   Required. The database name. In the format:
          #   `projects/{project_id}/databases/{database_id}`.
          # @param documents [Array<String>]
          #   The names of the documents to retrieve. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          #   The request will fail if any of the document is not a child resource of the
          #   given `database`. Duplicate names will be elided.
          # @param mask [Google::Firestore::V1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If a document has a field that is not present in this mask, that field will
          #   not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param new_transaction [Google::Firestore::V1::TransactionOptions | Hash]
          #   Starts a new transaction and reads the documents.
          #   Defaults to a read-only transaction.
          #   The new transaction ID will be returned as the first response in the
          #   stream.
          #   A hash of the same form as `Google::Firestore::V1::TransactionOptions`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 270 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1::BatchGetDocumentsResponse>]
          #   An enumerable of Google::Firestore::V1::BatchGetDocumentsResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   firestore_client.batch_get_documents(database).each do |element|
          #     # Process element.
          #   end

          def batch_get_documents \
              database,
              documents: nil,
              mask: nil,
              transaction: nil,
              new_transaction: nil,
              read_time: nil,
              options: nil
            req = {
              database: database,
              documents: documents,
              mask: mask,
              transaction: transaction,
              new_transaction: new_transaction,
              read_time: read_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::BatchGetDocumentsRequest)
            @batch_get_documents.call(req, options)
          end

          # Starts a new transaction.
          #
          # @param database [String]
          #   Required. The database name. In the format:
          #   `projects/{project_id}/databases/{database_id}`.
          # @param options_ [Google::Firestore::V1::TransactionOptions | Hash]
          #   The options for the transaction.
          #   Defaults to a read-write transaction.
          #   A hash of the same form as `Google::Firestore::V1::TransactionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::BeginTransactionResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::BeginTransactionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   response = firestore_client.begin_transaction(database)

          def begin_transaction \
              database,
              options_: nil,
              options: nil,
              &block
            req = {
              database: database,
              options: options_
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::BeginTransactionRequest)
            @begin_transaction.call(req, options, &block)
          end

          # Commits a transaction, while optionally updating documents.
          #
          # @param database [String]
          #   Required. The database name. In the format:
          #   `projects/{project_id}/databases/{database_id}`.
          # @param writes [Array<Google::Firestore::V1::Write | Hash>]
          #   The writes to apply.
          #
          #   Always executed atomically and in order.
          #   A hash of the same form as `Google::Firestore::V1::Write`
          #   can also be provided.
          # @param transaction [String]
          #   If set, applies all writes in this transaction, and commits it.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::CommitResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::CommitResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   response = firestore_client.commit(database)

          def commit \
              database,
              writes: nil,
              transaction: nil,
              options: nil,
              &block
            req = {
              database: database,
              writes: writes,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::CommitRequest)
            @commit.call(req, options, &block)
          end

          # Rolls back a transaction.
          #
          # @param database [String]
          #   Required. The database name. In the format:
          #   `projects/{project_id}/databases/{database_id}`.
          # @param transaction [String]
          #   Required. The transaction to roll back.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #
          #   # TODO: Initialize `transaction`:
          #   transaction = ''
          #   firestore_client.rollback(database, transaction)

          def rollback \
              database,
              transaction,
              options: nil,
              &block
            req = {
              database: database,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::RollbackRequest)
            @rollback.call(req, options, &block)
            nil
          end

          # Runs a query.
          #
          # @param parent [String]
          #   Required. The parent resource name. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents` or
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          #   For example:
          #   `projects/my-project/databases/my-database/documents` or
          #   `projects/my-project/databases/my-database/documents/chatrooms/my-chatroom`
          # @param structured_query [Google::Firestore::V1::StructuredQuery | Hash]
          #   A structured query.
          #   A hash of the same form as `Google::Firestore::V1::StructuredQuery`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param new_transaction [Google::Firestore::V1::TransactionOptions | Hash]
          #   Starts a new transaction and reads the documents.
          #   Defaults to a read-only transaction.
          #   The new transaction ID will be returned as the first response in the
          #   stream.
          #   A hash of the same form as `Google::Firestore::V1::TransactionOptions`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 270 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1::RunQueryResponse>]
          #   An enumerable of Google::Firestore::V1::RunQueryResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #   firestore_client.run_query(parent).each do |element|
          #     # Process element.
          #   end

          def run_query \
              parent,
              structured_query: nil,
              transaction: nil,
              new_transaction: nil,
              read_time: nil,
              options: nil
            req = {
              parent: parent,
              structured_query: structured_query,
              transaction: transaction,
              new_transaction: new_transaction,
              read_time: read_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::RunQueryRequest)
            @run_query.call(req, options)
          end

          # Streams batches of document updates and deletes, in order.
          #
          # @param reqs [Enumerable<Google::Firestore::V1::WriteRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1::WriteResponse>]
          #   An enumerable of Google::Firestore::V1::WriteResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   request = { database: database }
          #   requests = [request]
          #   firestore_client.write(requests).each do |element|
          #     # Process element.
          #   end

          def write reqs, options: nil
            request_protos = reqs.lazy.map do |req|
              Google::Gax::to_proto(req, Google::Firestore::V1::WriteRequest)
            end
            @write.call(request_protos, options)
          end

          # Listens to changes.
          #
          # @param reqs [Enumerable<Google::Firestore::V1::ListenRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1::ListenResponse>]
          #   An enumerable of Google::Firestore::V1::ListenResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   request = { database: database }
          #   requests = [request]
          #   firestore_client.listen(requests).each do |element|
          #     # Process element.
          #   end

          def listen reqs, options: nil
            request_protos = reqs.lazy.map do |req|
              Google::Gax::to_proto(req, Google::Firestore::V1::ListenRequest)
            end
            @listen.call(request_protos, options)
          end

          # Lists all the collection IDs underneath a document.
          #
          # @param parent [String]
          #   Required. The parent document. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents/{document_path}`.
          #   For example:
          #   `projects/my-project/databases/my-database/documents/chatrooms/my-chatroom`
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<String>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<String>]
          #   An enumerable of String instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # Iterate over all results.
          #   firestore_client.list_collection_ids(parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   firestore_client.list_collection_ids(parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_collection_ids \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::ListCollectionIdsRequest)
            @list_collection_ids.call(req, options, &block)
          end

          # Partitions a query by returning partition cursors that can be used to run
          # the query in parallel. The returned partition cursors are split points that
          # can be used by RunQuery as starting/end points for the query results.
          #
          # @param parent [String]
          #   Required. The parent resource name. In the format:
          #   `projects/{project_id}/databases/{database_id}/documents`.
          #   Document resource names are not supported; only database resource names
          #   can be specified.
          # @param structured_query [Google::Firestore::V1::StructuredQuery | Hash]
          #   A structured query.
          #   Filters, order bys, limits, offsets, and start/end cursors are not
          #   supported.
          #   A hash of the same form as `Google::Firestore::V1::StructuredQuery`
          #   can also be provided.
          # @param partition_count [Integer]
          #   The desired maximum number of partition points.
          #   The partitions may be returned across multiple pages of results.
          #   The number must be strictly positive. The actual number of partitions
          #   returned may be fewer.
          #
          #   For example, this may be set to one fewer than the number of parallel
          #   queries to be run, or in running a data pipeline job, one fewer than the
          #   number of workers or compute instances available.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Firestore::V1::Cursor>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Firestore::V1::Cursor>]
          #   An enumerable of Google::Firestore::V1::Cursor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `parent`:
          #   parent = ''
          #
          #   # Iterate over all results.
          #   firestore_client.partition_query(parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   firestore_client.partition_query(parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def partition_query \
              parent,
              structured_query: nil,
              partition_count: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              structured_query: structured_query,
              partition_count: partition_count,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::PartitionQueryRequest)
            @partition_query.call(req, options, &block)
          end

          # Applies a batch of write operations.
          #
          # The BatchWrite method does not apply the write operations atomically
          # and can apply them out of order. Method does not allow more than one write
          # per document. Each write succeeds or fails independently. See the
          # {Google::Firestore::V1::BatchWriteResponse BatchWriteResponse} for the success status of each write.
          #
          # If you require an atomically applied set of writes, use
          # {Google::Firestore::V1::Firestore::Commit Commit} instead.
          #
          # @param database [String]
          #   Required. The database name. In the format:
          #   `projects/{project_id}/databases/{database_id}`.
          # @param writes [Array<Google::Firestore::V1::Write | Hash>]
          #   The writes to apply.
          #
          #   Method does not apply writes atomically and does not guarantee ordering.
          #   Each write succeeds or fails independently. You cannot write to the same
          #   document more than once per request.
          #   A hash of the same form as `Google::Firestore::V1::Write`
          #   can also be provided.
          # @param labels [Hash{String => String}]
          #   Labels associated with this batch write.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Firestore::V1::BatchWriteResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Firestore::V1::BatchWriteResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1.new
          #
          #   # TODO: Initialize `database`:
          #   database = ''
          #   response = firestore_client.batch_write(database)

          def batch_write \
              database,
              writes: nil,
              labels: nil,
              options: nil,
              &block
            req = {
              database: database,
              writes: writes,
              labels: labels
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1::BatchWriteRequest)
            @batch_write.call(req, options, &block)
          end
        end
      end
    end
  end
end
