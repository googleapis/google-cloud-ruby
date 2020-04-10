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
# https://github.com/googleapis/googleapis/blob/master/google/firestore/admin/v1/firestore_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/firestore/admin/v1/firestore_admin_pb"
require "google/cloud/firestore/admin/v1/credentials"
require "google/cloud/firestore/version"

module Google
  module Cloud
    module Firestore
      module Admin
        module V1
          # Operations are created by service `FirestoreAdmin`, but are accessed via
          # service `google.longrunning.Operations`.
          #
          # @!attribute [r] firestore_admin_stub
          #   @return [Google::Firestore::Admin::V1::FirestoreAdmin::Stub]
          class FirestoreAdminClient
            # @private
            attr_reader :firestore_admin_stub

            # The default address of the service.
            SERVICE_ADDRESS = "firestore.googleapis.com".freeze

            # The default port of the service.
            DEFAULT_SERVICE_PORT = 443

            # The default set of gRPC interceptors.
            GRPC_INTERCEPTORS = []

            DEFAULT_TIMEOUT = 30

            PAGE_DESCRIPTORS = {
              "list_indexes" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "indexes"),
              "list_fields" => Google::Gax::PageDescriptor.new(
                "page_token",
                "next_page_token",
                "fields")
            }.freeze

            private_constant :PAGE_DESCRIPTORS

            # The scopes needed to make gRPC calls to all of the methods defined in
            # this service.
            ALL_SCOPES = [
              "https://www.googleapis.com/auth/cloud-platform",
              "https://www.googleapis.com/auth/datastore"
            ].freeze

            class OperationsClient < Google::Longrunning::OperationsClient
              self::SERVICE_ADDRESS = FirestoreAdminClient::SERVICE_ADDRESS
              self::GRPC_INTERCEPTORS = FirestoreAdminClient::GRPC_INTERCEPTORS
            end

            COLLECTION_GROUP_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/databases/{database}/collectionGroups/{collection}"
            )

            private_constant :COLLECTION_GROUP_PATH_TEMPLATE

            DATABASE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/databases/{database}"
            )

            private_constant :DATABASE_PATH_TEMPLATE

            FIELD_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/databases/{database}/collectionGroups/{collection}/fields/{field}"
            )

            private_constant :FIELD_PATH_TEMPLATE

            INDEX_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
              "projects/{project}/databases/{database}/collectionGroups/{collection}/indexes/{index}"
            )

            private_constant :INDEX_PATH_TEMPLATE

            # Returns a fully-qualified collection_group resource name string.
            # @param project [String]
            # @param database [String]
            # @param collection [String]
            # @return [String]
            def self.collection_group_path project, database, collection
              COLLECTION_GROUP_PATH_TEMPLATE.render(
                :"project" => project,
                :"database" => database,
                :"collection" => collection
              )
            end

            # Returns a fully-qualified database resource name string.
            # @param project [String]
            # @param database [String]
            # @return [String]
            def self.database_path project, database
              DATABASE_PATH_TEMPLATE.render(
                :"project" => project,
                :"database" => database
              )
            end

            # Returns a fully-qualified field resource name string.
            # @param project [String]
            # @param database [String]
            # @param collection [String]
            # @param field [String]
            # @return [String]
            def self.field_path project, database, collection, field
              FIELD_PATH_TEMPLATE.render(
                :"project" => project,
                :"database" => database,
                :"collection" => collection,
                :"field" => field
              )
            end

            # Returns a fully-qualified index resource name string.
            # @param project [String]
            # @param database [String]
            # @param collection [String]
            # @param index [String]
            # @return [String]
            def self.index_path project, database, collection, index
              INDEX_PATH_TEMPLATE.render(
                :"project" => project,
                :"database" => database,
                :"collection" => collection,
                :"index" => index
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
              require "google/firestore/admin/v1/firestore_admin_services_pb"

              credentials ||= Google::Cloud::Firestore::Admin::V1::Credentials.default

              @operations_client = OperationsClient.new(
                credentials: credentials,
                scopes: scopes,
                client_config: client_config,
                timeout: timeout,
                lib_name: lib_name,
                service_address: service_address,
                service_port: service_port,
                lib_version: lib_version,
                metadata: metadata,
              )

              if credentials.is_a?(String) || credentials.is_a?(Hash)
                updater_proc = Google::Cloud::Firestore::Admin::V1::Credentials.new(credentials).updater_proc
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
                "firestore_admin_client_config.json"
              )
              defaults = client_config_file.open do |f|
                Google::Gax.construct_settings(
                  "google.firestore.admin.v1.FirestoreAdmin",
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
              @firestore_admin_stub = Google::Gax::Grpc.create_stub(
                service_path,
                port,
                chan_creds: chan_creds,
                channel: channel,
                updater_proc: updater_proc,
                scopes: scopes,
                interceptors: interceptors,
                &Google::Firestore::Admin::V1::FirestoreAdmin::Stub.method(:new)
              )

              @delete_index = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:delete_index),
                defaults["delete_index"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @update_field = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:update_field),
                defaults["update_field"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'field.name' => request.field.name}
                end
              )
              @create_index = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:create_index),
                defaults["create_index"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @list_indexes = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:list_indexes),
                defaults["list_indexes"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @get_index = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:get_index),
                defaults["get_index"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @get_field = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:get_field),
                defaults["get_field"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @list_fields = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:list_fields),
                defaults["list_fields"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'parent' => request.parent}
                end
              )
              @export_documents = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:export_documents),
                defaults["export_documents"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
              @import_documents = Google::Gax.create_api_call(
                @firestore_admin_stub.method(:import_documents),
                defaults["import_documents"],
                exception_transformer: exception_transformer,
                params_extractor: proc do |request|
                  {'name' => request.name}
                end
              )
            end

            # Service calls

            # Deletes a composite index.
            #
            # @param name [String]
            #   Required. A name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/indexes/{index_id}`
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result []
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION]", "[INDEX]")
            #   firestore_admin_client.delete_index(formatted_name)

            def delete_index \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::DeleteIndexRequest)
              @delete_index.call(req, options, &block)
              nil
            end

            # Updates a field configuration. Currently, field updates apply only to
            # single field index configuration. However, calls to
            # {Google::Firestore::Admin::V1::FirestoreAdmin::UpdateField FirestoreAdmin::UpdateField} should provide a field mask to avoid
            # changing any configuration that the caller isn't aware of. The field mask
            # should be specified as: `{ paths: "index_config" }`.
            #
            # This call returns a {Google::Longrunning::Operation} which may be used to
            # track the status of the field update. The metadata for
            # the operation will be the type {Google::Firestore::Admin::V1::FieldOperationMetadata FieldOperationMetadata}.
            #
            # To configure the default field settings for the database, use
            # the special `Field` with resource name:
            # `projects/{project_id}/databases/{database_id}/collectionGroups/__default__/fields/*`.
            #
            # @param field [Google::Firestore::Admin::V1::Field | Hash]
            #   Required. The field to be updated.
            #   A hash of the same form as `Google::Firestore::Admin::V1::Field`
            #   can also be provided.
            # @param update_mask [Google::Protobuf::FieldMask | Hash]
            #   A mask, relative to the field. If specified, only configuration specified
            #   by this field_mask will be updated in the field.
            #   A hash of the same form as `Google::Protobuf::FieldMask`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #
            #   # TODO: Initialize `field`:
            #   field = {}
            #
            #   # Register a callback during the method call.
            #   operation = firestore_admin_client.update_field(field) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def update_field \
                field,
                update_mask: nil,
                options: nil
              req = {
                field: field,
                update_mask: update_mask
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::UpdateFieldRequest)
              operation = Google::Gax::Operation.new(
                @update_field.call(req, options),
                @operations_client,
                Google::Firestore::Admin::V1::Field,
                Google::Firestore::Admin::V1::FieldOperationMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Creates a composite index. This returns a {Google::Longrunning::Operation}
            # which may be used to track the status of the creation. The metadata for
            # the operation will be the type {Google::Firestore::Admin::V1::IndexOperationMetadata IndexOperationMetadata}.
            #
            # @param parent [String]
            #   Required. A parent name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
            # @param index [Google::Firestore::Admin::V1::Index | Hash]
            #   Required. The composite index to create.
            #   A hash of the same form as `Google::Firestore::Admin::V1::Index`
            #   can also be provided.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.collection_group_path("[PROJECT]", "[DATABASE]", "[COLLECTION]")
            #
            #   # TODO: Initialize `index`:
            #   index = {}
            #
            #   # Register a callback during the method call.
            #   operation = firestore_admin_client.create_index(formatted_parent, index) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def create_index \
                parent,
                index,
                options: nil
              req = {
                parent: parent,
                index: index
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::CreateIndexRequest)
              operation = Google::Gax::Operation.new(
                @create_index.call(req, options),
                @operations_client,
                Google::Firestore::Admin::V1::Index,
                Google::Firestore::Admin::V1::IndexOperationMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Lists composite indexes.
            #
            # @param parent [String]
            #   Required. A parent name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
            # @param filter [String]
            #   The filter to apply to list results.
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
            # @yieldparam result [Google::Gax::PagedEnumerable<Google::Firestore::Admin::V1::Index>]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Gax::PagedEnumerable<Google::Firestore::Admin::V1::Index>]
            #   An enumerable of Google::Firestore::Admin::V1::Index instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.collection_group_path("[PROJECT]", "[DATABASE]", "[COLLECTION]")
            #
            #   # Iterate over all results.
            #   firestore_admin_client.list_indexes(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   firestore_admin_client.list_indexes(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_indexes \
                parent,
                filter: nil,
                page_size: nil,
                options: nil,
                &block
              req = {
                parent: parent,
                filter: filter,
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::ListIndexesRequest)
              @list_indexes.call(req, options, &block)
            end

            # Gets a composite index.
            #
            # @param name [String]
            #   Required. A name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/indexes/{index_id}`
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Firestore::Admin::V1::Index]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Firestore::Admin::V1::Index]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION]", "[INDEX]")
            #   response = firestore_admin_client.get_index(formatted_name)

            def get_index \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::GetIndexRequest)
              @get_index.call(req, options, &block)
            end

            # Gets the metadata and configuration for a Field.
            #
            # @param name [String]
            #   Required. A name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/fields/{field_id}`
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Firestore::Admin::V1::Field]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Firestore::Admin::V1::Field]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.field_path("[PROJECT]", "[DATABASE]", "[COLLECTION]", "[FIELD]")
            #   response = firestore_admin_client.get_field(formatted_name)

            def get_field \
                name,
                options: nil,
                &block
              req = {
                name: name
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::GetFieldRequest)
              @get_field.call(req, options, &block)
            end

            # Lists the field configuration and metadata for this database.
            #
            # Currently, {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} only supports listing fields
            # that have been explicitly overridden. To issue this query, call
            # {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} with the filter set to
            # `indexConfig.usesAncestorConfig:false`.
            #
            # @param parent [String]
            #   Required. A parent name of the form
            #   `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
            # @param filter [String]
            #   The filter to apply to list results. Currently,
            #   {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} only supports listing fields
            #   that have been explicitly overridden. To issue this query, call
            #   {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} with the filter set to
            #   `indexConfig.usesAncestorConfig:false`.
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
            # @yieldparam result [Google::Gax::PagedEnumerable<Google::Firestore::Admin::V1::Field>]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            # @return [Google::Gax::PagedEnumerable<Google::Firestore::Admin::V1::Field>]
            #   An enumerable of Google::Firestore::Admin::V1::Field instances.
            #   See Google::Gax::PagedEnumerable documentation for other
            #   operations such as per-page iteration or access to the response
            #   object.
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.collection_group_path("[PROJECT]", "[DATABASE]", "[COLLECTION]")
            #
            #   # Iterate over all results.
            #   firestore_admin_client.list_fields(formatted_parent).each do |element|
            #     # Process element.
            #   end
            #
            #   # Or iterate over results one page at a time.
            #   firestore_admin_client.list_fields(formatted_parent).each_page do |page|
            #     # Process each page at a time.
            #     page.each do |element|
            #       # Process element.
            #     end
            #   end

            def list_fields \
                parent,
                filter: nil,
                page_size: nil,
                options: nil,
                &block
              req = {
                parent: parent,
                filter: filter,
                page_size: page_size
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::ListFieldsRequest)
              @list_fields.call(req, options, &block)
            end

            # Exports a copy of all or a subset of documents from Google Cloud Firestore
            # to another storage system, such as Google Cloud Storage. Recent updates to
            # documents may not be reflected in the export. The export occurs in the
            # background and its progress can be monitored and managed via the
            # Operation resource that is created. The output of an export may only be
            # used once the associated operation is done. If an export operation is
            # cancelled before completion it may leave partial data behind in Google
            # Cloud Storage.
            #
            # @param name [String]
            #   Required. Database to export. Should be of the form:
            #   `projects/{project_id}/databases/{database_id}`.
            # @param collection_ids [Array<String>]
            #   Which collection ids to export. Unspecified means all collections.
            # @param output_uri_prefix [String]
            #   The output URI. Currently only supports Google Cloud Storage URIs of the
            #   form: `gs://BUCKET_NAME[/NAMESPACE_PATH]`, where `BUCKET_NAME` is the name
            #   of the Google Cloud Storage bucket and `NAMESPACE_PATH` is an optional
            #   Google Cloud Storage namespace path. When
            #   choosing a name, be sure to consider Google Cloud Storage naming
            #   guidelines: https://cloud.google.com/storage/docs/naming.
            #   If the URI is a bucket (without a namespace path), a prefix will be
            #   generated based on the start time.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")
            #
            #   # Register a callback during the method call.
            #   operation = firestore_admin_client.export_documents(formatted_name) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def export_documents \
                name,
                collection_ids: nil,
                output_uri_prefix: nil,
                options: nil
              req = {
                name: name,
                collection_ids: collection_ids,
                output_uri_prefix: output_uri_prefix
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::ExportDocumentsRequest)
              operation = Google::Gax::Operation.new(
                @export_documents.call(req, options),
                @operations_client,
                Google::Firestore::Admin::V1::ExportDocumentsResponse,
                Google::Firestore::Admin::V1::ExportDocumentsMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end

            # Imports documents into Google Cloud Firestore. Existing documents with the
            # same name are overwritten. The import occurs in the background and its
            # progress can be monitored and managed via the Operation resource that is
            # created. If an ImportDocuments operation is cancelled, it is possible
            # that a subset of the data has already been imported to Cloud Firestore.
            #
            # @param name [String]
            #   Required. Database to import into. Should be of the form:
            #   `projects/{project_id}/databases/{database_id}`.
            # @param collection_ids [Array<String>]
            #   Which collection ids to import. Unspecified means all collections included
            #   in the import.
            # @param input_uri_prefix [String]
            #   Location of the exported files.
            #   This must match the output_uri_prefix of an ExportDocumentsResponse from
            #   an export that has completed successfully.
            #   See:
            #   {Google::Firestore::Admin::V1::ExportDocumentsResponse#output_uri_prefix}.
            # @param options [Google::Gax::CallOptions]
            #   Overrides the default settings for this call, e.g, timeout,
            #   retries, etc.
            # @return [Google::Gax::Operation]
            # @raise [Google::Gax::GaxError] if the RPC is aborted.
            # @example
            #   require "google/cloud/firestore/admin"
            #
            #   firestore_admin_client = Google::Cloud::Firestore::Admin.new(version: :v1)
            #   formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")
            #
            #   # Register a callback during the method call.
            #   operation = firestore_admin_client.import_documents(formatted_name) do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Or use the return value to register a callback.
            #   operation.on_done do |op|
            #     raise op.results.message if op.error?
            #     op_results = op.results
            #     # Process the results.
            #
            #     metadata = op.metadata
            #     # Process the metadata.
            #   end
            #
            #   # Manually reload the operation.
            #   operation.reload!
            #
            #   # Or block until the operation completes, triggering callbacks on
            #   # completion.
            #   operation.wait_until_done!

            def import_documents \
                name,
                collection_ids: nil,
                input_uri_prefix: nil,
                options: nil
              req = {
                name: name,
                collection_ids: collection_ids,
                input_uri_prefix: input_uri_prefix
              }.delete_if { |_, v| v.nil? }
              req = Google::Gax::to_proto(req, Google::Firestore::Admin::V1::ImportDocumentsRequest)
              operation = Google::Gax::Operation.new(
                @import_documents.call(req, options),
                @operations_client,
                Google::Protobuf::Empty,
                Google::Firestore::Admin::V1::ImportDocumentsMetadata,
                call_options: options
              )
              operation.on_done { |operation| yield(operation) } if block_given?
              operation
            end
          end
        end
      end
    end
  end
end
