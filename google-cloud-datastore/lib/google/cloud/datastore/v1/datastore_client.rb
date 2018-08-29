# Copyright 2018 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/datastore/v1/datastore.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/datastore/v1/datastore_pb"
require "google/cloud/datastore/v1/credentials"

module Google
  module Cloud
    module Datastore
      module V1
        # Each RPC normalizes the partition IDs of the keys in its input entities,
        # and always returns entities with keys with normalized partition IDs.
        # This applies to all keys and entities, including those in values, except keys
        # with both an empty path and an empty or unset partition ID. Normalization of
        # input keys sets the project ID (if not already set) to the project ID from
        # the request.
        #
        # @!attribute [r] datastore_stub
        #   @return [Google::Datastore::V1::Datastore::Stub]
        class DatastoreClient
          # @private
          attr_reader :datastore_stub

          # The default address of the service.
          SERVICE_ADDRESS = "datastore.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

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
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/datastore/v1/datastore_services_pb"

            credentials ||= Google::Cloud::Datastore::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Datastore::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-datastore'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "datastore_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.datastore.v1.Datastore",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @datastore_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Datastore::V1::Datastore::Stub.method(:new)
            )

            @lookup = Google::Gax.create_api_call(
              @datastore_stub.method(:lookup),
              defaults["lookup"],
              exception_transformer: exception_transformer
            )
            @run_query = Google::Gax.create_api_call(
              @datastore_stub.method(:run_query),
              defaults["run_query"],
              exception_transformer: exception_transformer
            )
            @begin_transaction = Google::Gax.create_api_call(
              @datastore_stub.method(:begin_transaction),
              defaults["begin_transaction"],
              exception_transformer: exception_transformer
            )
            @commit = Google::Gax.create_api_call(
              @datastore_stub.method(:commit),
              defaults["commit"],
              exception_transformer: exception_transformer
            )
            @rollback = Google::Gax.create_api_call(
              @datastore_stub.method(:rollback),
              defaults["rollback"],
              exception_transformer: exception_transformer
            )
            @allocate_ids = Google::Gax.create_api_call(
              @datastore_stub.method(:allocate_ids),
              defaults["allocate_ids"],
              exception_transformer: exception_transformer
            )
            @reserve_ids = Google::Gax.create_api_call(
              @datastore_stub.method(:reserve_ids),
              defaults["reserve_ids"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Looks up entities by key.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param keys [Array<Google::Datastore::V1::Key | Hash>]
          #   Keys of entities to look up.
          #   A hash of the same form as `Google::Datastore::V1::Key`
          #   can also be provided.
          # @param read_options [Google::Datastore::V1::ReadOptions | Hash]
          #   The options for this lookup request.
          #   A hash of the same form as `Google::Datastore::V1::ReadOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::LookupResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::LookupResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +keys+:
          #   keys = []
          #   response = datastore_client.lookup(project_id, keys)

          def lookup \
              project_id,
              keys,
              read_options: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              keys: keys,
              read_options: read_options
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::LookupRequest)
            @lookup.call(req, options, &block)
          end

          # Queries for entities.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param partition_id [Google::Datastore::V1::PartitionId | Hash]
          #   Entities are partitioned into subsets, identified by a partition ID.
          #   Queries are scoped to a single partition.
          #   This partition ID is normalized with the standard default context
          #   partition ID.
          #   A hash of the same form as `Google::Datastore::V1::PartitionId`
          #   can also be provided.
          # @param read_options [Google::Datastore::V1::ReadOptions | Hash]
          #   The options for this query.
          #   A hash of the same form as `Google::Datastore::V1::ReadOptions`
          #   can also be provided.
          # @param query [Google::Datastore::V1::Query | Hash]
          #   The query to run.
          #   A hash of the same form as `Google::Datastore::V1::Query`
          #   can also be provided.
          # @param gql_query [Google::Datastore::V1::GqlQuery | Hash]
          #   The GQL query to run.
          #   A hash of the same form as `Google::Datastore::V1::GqlQuery`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::RunQueryResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::RunQueryResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +partition_id+:
          #   partition_id = {}
          #   response = datastore_client.run_query(project_id, partition_id)

          def run_query \
              project_id,
              partition_id,
              read_options: nil,
              query: nil,
              gql_query: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              partition_id: partition_id,
              read_options: read_options,
              query: query,
              gql_query: gql_query
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::RunQueryRequest)
            @run_query.call(req, options, &block)
          end

          # Begins a new transaction.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param transaction_options [Google::Datastore::V1::TransactionOptions | Hash]
          #   Options for a new transaction.
          #   A hash of the same form as `Google::Datastore::V1::TransactionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::BeginTransactionResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::BeginTransactionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #   response = datastore_client.begin_transaction(project_id)

          def begin_transaction \
              project_id,
              transaction_options: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              transaction_options: transaction_options
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::BeginTransactionRequest)
            @begin_transaction.call(req, options, &block)
          end

          # Commits a transaction, optionally creating, deleting or modifying some
          # entities.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param mode [Google::Datastore::V1::CommitRequest::Mode]
          #   The type of commit to perform. Defaults to +TRANSACTIONAL+.
          # @param mutations [Array<Google::Datastore::V1::Mutation | Hash>]
          #   The mutations to perform.
          #
          #   When mode is +TRANSACTIONAL+, mutations affecting a single entity are
          #   applied in order. The following sequences of mutations affecting a single
          #   entity are not permitted in a single +Commit+ request:
          #
          #   * +insert+ followed by +insert+
          #   * +update+ followed by +insert+
          #   * +upsert+ followed by +insert+
          #   * +delete+ followed by +update+
          #
          #   When mode is +NON_TRANSACTIONAL+, no two mutations may affect a single
          #   entity.
          #   A hash of the same form as `Google::Datastore::V1::Mutation`
          #   can also be provided.
          # @param transaction [String]
          #   The identifier of the transaction associated with the commit. A
          #   transaction identifier is returned by a call to
          #   {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::CommitResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::CommitResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +mode+:
          #   mode = :MODE_UNSPECIFIED
          #
          #   # TODO: Initialize +mutations+:
          #   mutations = []
          #   response = datastore_client.commit(project_id, mode, mutations)

          def commit \
              project_id,
              mode,
              mutations,
              transaction: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              mode: mode,
              mutations: mutations,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::CommitRequest)
            @commit.call(req, options, &block)
          end

          # Rolls back a transaction.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param transaction [String]
          #   The transaction identifier, returned by a call to
          #   {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::RollbackResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::RollbackResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +transaction+:
          #   transaction = ''
          #   response = datastore_client.rollback(project_id, transaction)

          def rollback \
              project_id,
              transaction,
              options: nil,
              &block
            req = {
              project_id: project_id,
              transaction: transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::RollbackRequest)
            @rollback.call(req, options, &block)
          end

          # Allocates IDs for the given keys, which is useful for referencing an entity
          # before it is inserted.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param keys [Array<Google::Datastore::V1::Key | Hash>]
          #   A list of keys with incomplete key paths for which to allocate IDs.
          #   No key may be reserved/read-only.
          #   A hash of the same form as `Google::Datastore::V1::Key`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::AllocateIdsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::AllocateIdsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +keys+:
          #   keys = []
          #   response = datastore_client.allocate_ids(project_id, keys)

          def allocate_ids \
              project_id,
              keys,
              options: nil,
              &block
            req = {
              project_id: project_id,
              keys: keys
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::AllocateIdsRequest)
            @allocate_ids.call(req, options, &block)
          end

          # Prevents the supplied keys' IDs from being auto-allocated by Cloud
          # Datastore.
          #
          # @param project_id [String]
          #   The ID of the project against which to make the request.
          # @param keys [Array<Google::Datastore::V1::Key | Hash>]
          #   A list of keys with complete key paths whose numeric IDs should not be
          #   auto-allocated.
          #   A hash of the same form as `Google::Datastore::V1::Key`
          #   can also be provided.
          # @param database_id [String]
          #   If not empty, the ID of the database against which to make the request.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Datastore::V1::ReserveIdsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Datastore::V1::ReserveIdsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore_client = Google::Cloud::Datastore.new(version: :v1)
          #
          #   # TODO: Initialize +project_id+:
          #   project_id = ''
          #
          #   # TODO: Initialize +keys+:
          #   keys = []
          #   response = datastore_client.reserve_ids(project_id, keys)

          def reserve_ids \
              project_id,
              keys,
              database_id: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              keys: keys,
              database_id: database_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Datastore::V1::ReserveIdsRequest)
            @reserve_ids.call(req, options, &block)
          end
        end
      end
    end
  end
end
