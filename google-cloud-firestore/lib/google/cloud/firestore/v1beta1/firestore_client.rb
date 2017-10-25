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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/firestore/v1beta1/firestore.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/firestore/v1beta1/firestore_pb"
require "google/cloud/firestore/credentials"

module Google
  module Cloud
    module Firestore
      module V1beta1
        # The Cloud Firestore service.
        #
        # This service exposes several types of comparable timestamps:
        #
        # * +create_time+ - The time at which a document was created. Changes only
        #   when a document is deleted, then re-created. Increases in a strict
        #   monotonic fashion.
        # * +update_time+ - The time at which a document was last updated. Changes
        #   every time a document is modified. Does not change when a write results
        #   in no modifications. Increases in a strict monotonic fashion.
        # * +read_time+ - The time at which a particular state was observed. Used
        #   to denote a consistent snapshot of the database or the time at which a
        #   Document was observed to not exist.
        # * +commit_time+ - The time at which the writes in a transaction were
        #   committed. Any read with an equal or greater +read_time+ is guaranteed
        #   to see the effects of the transaction.
        #
        # @!attribute [r] firestore_stub
        #   @return [Google::Firestore::V1beta1::Firestore::Stub]
        class FirestoreClient
          attr_reader :firestore_stub

          # The default address of the service.
          SERVICE_ADDRESS = "firestore.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_documents" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "documents"),
            "list_collection_ids" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "collection_ids")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/datastore"
          ].freeze

          DATABASE_ROOT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/databases/{database}"
          )

          private_constant :DATABASE_ROOT_PATH_TEMPLATE

          DOCUMENT_ROOT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/databases/{database}/documents"
          )

          private_constant :DOCUMENT_ROOT_PATH_TEMPLATE

          DOCUMENT_PATH_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/databases/{database}/documents/{document_path=**}"
          )

          private_constant :DOCUMENT_PATH_PATH_TEMPLATE

          ANY_PATH_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/databases/{database}/documents/{document}/{any_path=**}"
          )

          private_constant :ANY_PATH_PATH_TEMPLATE

          # Returns a fully-qualified database_root resource name string.
          # @param project [String]
          # @param database [String]
          # @return [String]
          def self.database_root_path project, database
            DATABASE_ROOT_PATH_TEMPLATE.render(
              :"project" => project,
              :"database" => database
            )
          end

          # Returns a fully-qualified document_root resource name string.
          # @param project [String]
          # @param database [String]
          # @return [String]
          def self.document_root_path project, database
            DOCUMENT_ROOT_PATH_TEMPLATE.render(
              :"project" => project,
              :"database" => database
            )
          end

          # Returns a fully-qualified document_path resource name string.
          # @param project [String]
          # @param database [String]
          # @param document_path [String]
          # @return [String]
          def self.document_path_path project, database, document_path
            DOCUMENT_PATH_PATH_TEMPLATE.render(
              :"project" => project,
              :"database" => database,
              :"document_path" => document_path
            )
          end

          # Returns a fully-qualified any_path resource name string.
          # @param project [String]
          # @param database [String]
          # @param document [String]
          # @param any_path [String]
          # @return [String]
          def self.any_path_path project, database, document, any_path
            ANY_PATH_PATH_TEMPLATE.render(
              :"project" => project,
              :"database" => database,
              :"document" => document,
              :"any_path" => any_path
            )
          end

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
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/firestore/v1beta1/firestore_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
              warn "`service_path` and `port` parameters are deprecated and will be removed"
            end

            credentials ||= Google::Cloud::Firestore::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Firestore::Credentials.new(credentials).updater_proc
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

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.6.8 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "firestore_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.firestore.v1beta1.Firestore",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @firestore_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Firestore::V1beta1::Firestore::Stub.method(:new)
            )

            @get_document = Google::Gax.create_api_call(
              @firestore_stub.method(:get_document),
              defaults["get_document"]
            )
            @list_documents = Google::Gax.create_api_call(
              @firestore_stub.method(:list_documents),
              defaults["list_documents"]
            )
            @create_document = Google::Gax.create_api_call(
              @firestore_stub.method(:create_document),
              defaults["create_document"]
            )
            @update_document = Google::Gax.create_api_call(
              @firestore_stub.method(:update_document),
              defaults["update_document"]
            )
            @delete_document = Google::Gax.create_api_call(
              @firestore_stub.method(:delete_document),
              defaults["delete_document"]
            )
            @batch_get_documents = Google::Gax.create_api_call(
              @firestore_stub.method(:batch_get_documents),
              defaults["batch_get_documents"]
            )
            @begin_transaction = Google::Gax.create_api_call(
              @firestore_stub.method(:begin_transaction),
              defaults["begin_transaction"]
            )
            @commit = Google::Gax.create_api_call(
              @firestore_stub.method(:commit),
              defaults["commit"]
            )
            @rollback = Google::Gax.create_api_call(
              @firestore_stub.method(:rollback),
              defaults["rollback"]
            )
            @run_query = Google::Gax.create_api_call(
              @firestore_stub.method(:run_query),
              defaults["run_query"]
            )
            @write = Google::Gax.create_api_call(
              @firestore_stub.method(:write),
              defaults["write"]
            )
            @listen = Google::Gax.create_api_call(
              @firestore_stub.method(:listen),
              defaults["listen"]
            )
            @list_collection_ids = Google::Gax.create_api_call(
              @firestore_stub.method(:list_collection_ids),
              defaults["list_collection_ids"]
            )
          end

          # Service calls

          # Gets a single document.
          #
          # @param name [String]
          #   The resource name of the Document to get. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          # @param mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads the document in a transaction.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads the version of the document at the given time.
          #   This may not be older than 60 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Firestore::V1beta1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #   response = firestore_client.get_document(formatted_name)

          def get_document \
              name,
              mask: nil,
              transaction: nil,
              read_time: nil,
              options: nil
            req = {
              name: name,
              mask: mask,
              transaction: transaction,
              read_time: read_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::GetDocumentRequest)
            @get_document.call(req, options)
          end

          # Lists documents.
          #
          # @param parent [String]
          #   The parent resource name. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents+ or
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          #   For example:
          #   +projects/my-project/databases/my-database/documents+ or
          #   +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
          # @param collection_id [String]
          #   The collection ID, relative to +parent+, to list. For example: +chatrooms+
          #   or +messages+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param order_by [String]
          #   The order to sort results by. For example: +priority desc, name+.
          # @param mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If a document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 60 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param show_missing [true, false]
          #   If the list should show missing documents. A missing document is a
          #   document that does not exist but has sub-documents. These documents will
          #   be returned with a key but will not have fields, {Google::Firestore::V1beta1::Document#create_time Document#create_time},
          #   or {Google::Firestore::V1beta1::Document#update_time Document#update_time} set.
          #
          #   Requests with +show_missing+ may not specify +where+ or
          #   +order_by+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Firestore::V1beta1::Document>]
          #   An enumerable of Google::Firestore::V1beta1::Document instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #   collection_id = ''
          #
          #   # Iterate over all results.
          #   firestore_client.list_documents(formatted_parent, collection_id).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   firestore_client.list_documents(formatted_parent, collection_id).each_page do |page|
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
              options: nil
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
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::ListDocumentsRequest)
            @list_documents.call(req, options)
          end

          # Creates a new document.
          #
          # @param parent [String]
          #   The parent resource. For example:
          #   +projects/{project_id}/databases/{database_id}/documents+ or
          #   +projects/{project_id}/databases/{database_id}/documents/chatrooms/{chatroom_id}+
          # @param collection_id [String]
          #   The collection ID, relative to +parent+, to list. For example: +chatrooms+.
          # @param document_id [String]
          #   The client-assigned document ID to use for this document.
          #
          #   Optional. If not specified, an ID will be assigned by the service.
          # @param document [Google::Firestore::V1beta1::Document | Hash]
          #   The document to create. +name+ must not be set.
          #   A hash of the same form as `Google::Firestore::V1beta1::Document`
          #   can also be provided.
          # @param mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Firestore::V1beta1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #   collection_id = ''
          #   document_id = ''
          #   document = {}
          #   response = firestore_client.create_document(formatted_parent, collection_id, document_id, document)

          def create_document \
              parent,
              collection_id,
              document_id,
              document,
              mask: nil,
              options: nil
            req = {
              parent: parent,
              collection_id: collection_id,
              document_id: document_id,
              document: document,
              mask: mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::CreateDocumentRequest)
            @create_document.call(req, options)
          end

          # Updates or inserts a document.
          #
          # @param document [Google::Firestore::V1beta1::Document | Hash]
          #   The updated document.
          #   Creates the document if it does not already exist.
          #   A hash of the same form as `Google::Firestore::V1beta1::Document`
          #   can also be provided.
          # @param update_mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to update.
          #   None of the field paths in the mask may contain a reserved name.
          #
          #   If the document exists on the server and has fields not referenced in the
          #   mask, they are left unchanged.
          #   Fields referenced in the mask, but not present in the input document, are
          #   deleted from the document on the server.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If the document has a field that is not present in this mask, that field
          #   will not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param current_document [Google::Firestore::V1beta1::Precondition | Hash]
          #   An optional precondition on the document.
          #   The request will fail if this is set and not met by the target document.
          #   A hash of the same form as `Google::Firestore::V1beta1::Precondition`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Firestore::V1beta1::Document]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   document = {}
          #   update_mask = {}
          #   response = firestore_client.update_document(document, update_mask)

          def update_document \
              document,
              update_mask,
              mask: nil,
              current_document: nil,
              options: nil
            req = {
              document: document,
              update_mask: update_mask,
              mask: mask,
              current_document: current_document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::UpdateDocumentRequest)
            @update_document.call(req, options)
          end

          # Deletes a document.
          #
          # @param name [String]
          #   The resource name of the Document to delete. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          # @param current_document [Google::Firestore::V1beta1::Precondition | Hash]
          #   An optional precondition on the document.
          #   The request will fail if this is set and not met by the target document.
          #   A hash of the same form as `Google::Firestore::V1beta1::Precondition`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #   firestore_client.delete_document(formatted_name)

          def delete_document \
              name,
              current_document: nil,
              options: nil
            req = {
              name: name,
              current_document: current_document
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::DeleteDocumentRequest)
            @delete_document.call(req, options)
            nil
          end

          # Gets multiple documents.
          #
          # Documents returned by this method are not guaranteed to be returned in the
          # same order that they were requested.
          #
          # @param database [String]
          #   The database name. In the format:
          #   +projects/{project_id}/databases/{database_id}+.
          # @param documents [Array<String>]
          #   The names of the documents to retrieve. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          #   The request will fail if any of the document is not a child resource of the
          #   given +database+. Duplicate names will be elided.
          # @param mask [Google::Firestore::V1beta1::DocumentMask | Hash]
          #   The fields to return. If not set, returns all fields.
          #
          #   If a document has a field that is not present in this mask, that field will
          #   not be returned in the response.
          #   A hash of the same form as `Google::Firestore::V1beta1::DocumentMask`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param new_transaction [Google::Firestore::V1beta1::TransactionOptions | Hash]
          #   Starts a new transaction and reads the documents.
          #   Defaults to a read-only transaction.
          #   The new transaction ID will be returned as the first response in the
          #   stream.
          #   A hash of the same form as `Google::Firestore::V1beta1::TransactionOptions`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 60 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1beta1::BatchGetDocumentsResponse>]
          #   An enumerable of Google::Firestore::V1beta1::BatchGetDocumentsResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   documents = []
          #   firestore_client.batch_get_documents(formatted_database, documents).each do |element|
          #     # Process element.
          #   end

          def batch_get_documents \
              database,
              documents,
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
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::BatchGetDocumentsRequest)
            @batch_get_documents.call(req, options)
          end

          # Starts a new transaction.
          #
          # @param database [String]
          #   The database name. In the format:
          #   +projects/{project_id}/databases/{database_id}+.
          # @param options_ [Google::Firestore::V1beta1::TransactionOptions | Hash]
          #   The options for the transaction.
          #   Defaults to a read-write transaction.
          #   A hash of the same form as `Google::Firestore::V1beta1::TransactionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Firestore::V1beta1::BeginTransactionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   response = firestore_client.begin_transaction(formatted_database)

          def begin_transaction \
              database,
              options_: nil,
              options: nil
            req = {
              database: database,
              options: options_
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::BeginTransactionRequest)
            @begin_transaction.call(req, options)
          end

          # Commits a transaction, while optionally updating documents.
          #
          # @param database [String]
          #   The database name. In the format:
          #   +projects/{project_id}/databases/{database_id}+.
          # @param writes [Array<Google::Firestore::V1beta1::Write | Hash>]
          #   The writes to apply.
          #
          #   Always executed atomically and in order.
          #   A hash of the same form as `Google::Firestore::V1beta1::Write`
          #   can also be provided.
          # @param transaction [String]
          #   If set, applies all writes in this transaction, and commits it.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Firestore::V1beta1::CommitResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   writes = []
          #   response = firestore_client.commit(formatted_database, writes)

          def commit \
              database,
              writes,
              transaction: nil,
              options: nil
            req = {
              database: database,
              writes: writes,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::CommitRequest)
            @commit.call(req, options)
          end

          # Rolls back a transaction.
          #
          # @param database [String]
          #   The database name. In the format:
          #   +projects/{project_id}/databases/{database_id}+.
          # @param transaction [String]
          #   The transaction to roll back.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   transaction = ''
          #   firestore_client.rollback(formatted_database, transaction)

          def rollback \
              database,
              transaction,
              options: nil
            req = {
              database: database,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::RollbackRequest)
            @rollback.call(req, options)
            nil
          end

          # Runs a query.
          #
          # @param parent [String]
          #   The parent resource name. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents+ or
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          #   For example:
          #   +projects/my-project/databases/my-database/documents+ or
          #   +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
          # @param structured_query [Google::Firestore::V1beta1::StructuredQuery | Hash]
          #   A structured query.
          #   A hash of the same form as `Google::Firestore::V1beta1::StructuredQuery`
          #   can also be provided.
          # @param transaction [String]
          #   Reads documents in a transaction.
          # @param new_transaction [Google::Firestore::V1beta1::TransactionOptions | Hash]
          #   Starts a new transaction and reads the documents.
          #   Defaults to a read-only transaction.
          #   The new transaction ID will be returned as the first response in the
          #   stream.
          #   A hash of the same form as `Google::Firestore::V1beta1::TransactionOptions`
          #   can also be provided.
          # @param read_time [Google::Protobuf::Timestamp | Hash]
          #   Reads documents as they were at the given time.
          #   This may not be older than 60 seconds.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1beta1::RunQueryResponse>]
          #   An enumerable of Google::Firestore::V1beta1::RunQueryResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #   firestore_client.run_query(formatted_parent).each do |element|
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
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::RunQueryRequest)
            @run_query.call(req, options)
          end

          # Streams batches of document updates and deletes, in order.
          #
          # @param reqs [Enumerable<Google::Firestore::V1beta1::WriteRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1beta1::WriteResponse>]
          #   An enumerable of Google::Firestore::V1beta1::WriteResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   request = { database: formatted_database }
          #   requests = [request]
          #   firestore_client.write(requests).each do |element|
          #     # Process element.
          #   end

          def write reqs, options: nil
            request_protos = reqs.lazy.map do |req|
              Google::Gax::to_proto(req, Google::Firestore::V1beta1::WriteRequest)
            end
            @write.call(request_protos, options)
          end

          # Listens to changes.
          #
          # @param reqs [Enumerable<Google::Firestore::V1beta1::ListenRequest>]
          #   The input requests.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Firestore::V1beta1::ListenResponse>]
          #   An enumerable of Google::Firestore::V1beta1::ListenResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          #
          # @note
          #   EXPERIMENTAL:
          #     Streaming requests are still undergoing review.
          #     This method interface might change in the future.
          #
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
          #   request = { database: formatted_database }
          #   requests = [request]
          #   firestore_client.listen(requests).each do |element|
          #     # Process element.
          #   end

          def listen reqs, options: nil
            request_protos = reqs.lazy.map do |req|
              Google::Gax::to_proto(req, Google::Firestore::V1beta1::ListenRequest)
            end
            @listen.call(request_protos, options)
          end

          # Lists all the collection IDs underneath a document.
          #
          # @param parent [String]
          #   The parent document. In the format:
          #   +projects/{project_id}/databases/{database_id}/documents/{document_path}+.
          #   For example:
          #   +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<String>]
          #   An enumerable of String instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/firestore/v1beta1"
          #
          #   firestore_client = Google::Cloud::Firestore::V1beta1.new
          #   formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
          #
          #   # Iterate over all results.
          #   firestore_client.list_collection_ids(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   firestore_client.list_collection_ids(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_collection_ids \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Firestore::V1beta1::ListCollectionIdsRequest)
            @list_collection_ids.call(req, options)
          end
        end
      end
    end
  end
end
