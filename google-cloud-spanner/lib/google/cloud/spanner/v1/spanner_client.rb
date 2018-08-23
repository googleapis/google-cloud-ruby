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
# https://github.com/googleapis/googleapis/blob/master/google/spanner/v1/spanner.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/spanner/v1/spanner_pb"
require "google/cloud/spanner/v1/credentials"

module Google
  module Cloud
    module Spanner
      module V1
        # Cloud Spanner API
        #
        # The Cloud Spanner API can be used to manage sessions and execute
        # transactions on data stored in Cloud Spanner databases.
        #
        # @!attribute [r] spanner_stub
        #   @return [Google::Spanner::V1::Spanner::Stub]
        class SpannerClient
          # @private
          attr_reader :spanner_stub

          # The default address of the service.
          SERVICE_ADDRESS = "spanner.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_sessions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "sessions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/spanner.data"
          ].freeze


          DATABASE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/instances/{instance}/databases/{database}"
          )

          private_constant :DATABASE_PATH_TEMPLATE

          SESSION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/instances/{instance}/databases/{database}/sessions/{session}"
          )

          private_constant :SESSION_PATH_TEMPLATE

          # Returns a fully-qualified database resource name string.
          # @param project [String]
          # @param instance [String]
          # @param database [String]
          # @return [String]
          def self.database_path project, instance, database
            DATABASE_PATH_TEMPLATE.render(
              :"project" => project,
              :"instance" => instance,
              :"database" => database
            )
          end

          # Returns a fully-qualified session resource name string.
          # @param project [String]
          # @param instance [String]
          # @param database [String]
          # @param session [String]
          # @return [String]
          def self.session_path project, instance, database, session
            SESSION_PATH_TEMPLATE.render(
              :"project" => project,
              :"instance" => instance,
              :"database" => database,
              :"session" => session
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
            require "google/spanner/v1/spanner_services_pb"

            credentials ||= Google::Cloud::Spanner::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Spanner::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-spanner'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "spanner_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.spanner.v1.Spanner",
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
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @spanner_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Spanner::V1::Spanner::Stub.method(:new)
            )

            @create_session = Google::Gax.create_api_call(
              @spanner_stub.method(:create_session),
              defaults["create_session"],
              exception_transformer: exception_transformer
            )
            @get_session = Google::Gax.create_api_call(
              @spanner_stub.method(:get_session),
              defaults["get_session"],
              exception_transformer: exception_transformer
            )
            @list_sessions = Google::Gax.create_api_call(
              @spanner_stub.method(:list_sessions),
              defaults["list_sessions"],
              exception_transformer: exception_transformer
            )
            @delete_session = Google::Gax.create_api_call(
              @spanner_stub.method(:delete_session),
              defaults["delete_session"],
              exception_transformer: exception_transformer
            )
            @execute_sql = Google::Gax.create_api_call(
              @spanner_stub.method(:execute_sql),
              defaults["execute_sql"],
              exception_transformer: exception_transformer
            )
            @execute_streaming_sql = Google::Gax.create_api_call(
              @spanner_stub.method(:execute_streaming_sql),
              defaults["execute_streaming_sql"],
              exception_transformer: exception_transformer
            )
            @read = Google::Gax.create_api_call(
              @spanner_stub.method(:read),
              defaults["read"],
              exception_transformer: exception_transformer
            )
            @streaming_read = Google::Gax.create_api_call(
              @spanner_stub.method(:streaming_read),
              defaults["streaming_read"],
              exception_transformer: exception_transformer
            )
            @begin_transaction = Google::Gax.create_api_call(
              @spanner_stub.method(:begin_transaction),
              defaults["begin_transaction"],
              exception_transformer: exception_transformer
            )
            @commit = Google::Gax.create_api_call(
              @spanner_stub.method(:commit),
              defaults["commit"],
              exception_transformer: exception_transformer
            )
            @rollback = Google::Gax.create_api_call(
              @spanner_stub.method(:rollback),
              defaults["rollback"],
              exception_transformer: exception_transformer
            )
            @partition_query = Google::Gax.create_api_call(
              @spanner_stub.method(:partition_query),
              defaults["partition_query"],
              exception_transformer: exception_transformer
            )
            @partition_read = Google::Gax.create_api_call(
              @spanner_stub.method(:partition_read),
              defaults["partition_read"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Creates a new session. A session can be used to perform
          # transactions that read and/or modify data in a Cloud Spanner database.
          # Sessions are meant to be reused for many consecutive
          # transactions.
          #
          # Sessions can only execute one transaction at a time. To execute
          # multiple concurrent read-write/write-only transactions, create
          # multiple sessions. Note that standalone reads and queries use a
          # transaction internally, and count toward the one transaction
          # limit.
          #
          # Cloud Spanner limits the number of sessions that can exist at any given
          # time; thus, it is a good idea to delete idle and/or unneeded sessions.
          # Aside from explicit deletes, Cloud Spanner can delete sessions for which no
          # operations are sent for more than an hour. If a session is deleted,
          # requests to it return +NOT_FOUND+.
          #
          # Idle sessions can be kept alive by sending a trivial SQL query
          # periodically, e.g., +"SELECT 1"+.
          #
          # @param database [String]
          #   Required. The database in which the new session is created.
          # @param session [Google::Spanner::V1::Session | Hash]
          #   The session to create.
          #   A hash of the same form as `Google::Spanner::V1::Session`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::Session]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::Session]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
          #   response = spanner_client.create_session(formatted_database)

          def create_session \
              database,
              session: nil,
              options: nil,
              &block
            req = {
              database: database,
              session: session
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::CreateSessionRequest)
            @create_session.call(req, options, &block)
          end

          # Gets a session. Returns +NOT_FOUND+ if the session does not exist.
          # This is mainly useful for determining whether a session is still
          # alive.
          #
          # @param name [String]
          #   Required. The name of the session to retrieve.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::Session]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::Session]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   response = spanner_client.get_session(formatted_name)

          def get_session \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::GetSessionRequest)
            @get_session.call(req, options, &block)
          end

          # Lists all sessions in a given database.
          #
          # @param database [String]
          #   Required. The database in which to list sessions.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param filter [String]
          #   An expression for filtering the results of the request. Filter rules are
          #   case insensitive. The fields eligible for filtering are:
          #
          #   * +labels.key+ where key is the name of a label
          #
          #   Some examples of using filters are:
          #
          #   * +labels.env:*+ --> The session has the label "env".
          #     * +labels.env:dev+ --> The session has the label "env" and the value of
          #       the label contains the string "dev".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Spanner::V1::Session>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Spanner::V1::Session>]
          #   An enumerable of Google::Spanner::V1::Session instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_database = Google::Cloud::Spanner::V1::SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
          #
          #   # Iterate over all results.
          #   spanner_client.list_sessions(formatted_database).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   spanner_client.list_sessions(formatted_database).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_sessions \
              database,
              page_size: nil,
              filter: nil,
              options: nil,
              &block
            req = {
              database: database,
              page_size: page_size,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::ListSessionsRequest)
            @list_sessions.call(req, options, &block)
          end

          # Ends a session, releasing server resources associated with it.
          #
          # @param name [String]
          #   Required. The name of the session to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_name = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   spanner_client.delete_session(formatted_name)

          def delete_session \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::DeleteSessionRequest)
            @delete_session.call(req, options, &block)
            nil
          end

          # Executes an SQL query, returning all rows in a single reply. This
          # method cannot be used to return a result set larger than 10 MiB;
          # if the query yields more data than that, the query fails with
          # a +FAILED_PRECONDITION+ error.
          #
          # Queries inside read-write transactions might return +ABORTED+. If
          # this occurs, the application should restart the transaction from
          # the beginning. See {Google::Spanner::V1::Transaction Transaction} for more details.
          #
          # Larger result sets can be fetched in streaming fashion by calling
          # {Google::Spanner::V1::Spanner::ExecuteStreamingSql ExecuteStreamingSql} instead.
          #
          # @param session [String]
          #   Required. The session in which the SQL query should be performed.
          # @param sql [String]
          #   Required. The SQL query string.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param params [Google::Protobuf::Struct | Hash]
          #   The SQL query string can contain parameter placeholders. A parameter
          #   placeholder consists of +'@'+ followed by the parameter
          #   name. Parameter names consist of any combination of letters,
          #   numbers, and underscores.
          #
          #   Parameters can appear anywhere that a literal value is expected.  The same
          #   parameter name can be used more than once, for example:
          #     +"WHERE id > @msg_id AND id < @msg_id + 100"+
          #
          #   It is an error to execute an SQL query with unbound parameters.
          #
          #   Parameter values are specified using +params+, which is a JSON
          #   object whose keys are parameter names, and whose values are the
          #   corresponding parameter values.
          #   A hash of the same form as `Google::Protobuf::Struct`
          #   can also be provided.
          # @param param_types [Hash{String => Google::Spanner::V1::Type | Hash}]
          #   It is not always possible for Cloud Spanner to infer the right SQL type
          #   from a JSON value.  For example, values of type +BYTES+ and values
          #   of type +STRING+ both appear in {Google::Spanner::V1::ExecuteSqlRequest#params params} as JSON strings.
          #
          #   In these cases, +param_types+ can be used to specify the exact
          #   SQL type for some or all of the SQL query parameters. See the
          #   definition of {Google::Spanner::V1::Type Type} for more information
          #   about SQL types.
          #   A hash of the same form as `Google::Spanner::V1::Type`
          #   can also be provided.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted SQL query
          #   execution, +resume_token+ should be copied from the last
          #   {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
          #   enables the new SQL query execution to resume where the last one left
          #   off. The rest of the request parameters must exactly match the
          #   request that yielded this token.
          # @param query_mode [Google::Spanner::V1::ExecuteSqlRequest::QueryMode]
          #   Used to control the amount of debugging information returned in
          #   {Google::Spanner::V1::ResultSetStats ResultSetStats}. If {Google::Spanner::V1::ExecuteSqlRequest#partition_token partition_token} is set, {Google::Spanner::V1::ExecuteSqlRequest#query_mode query_mode} can only
          #   be set to {Google::Spanner::V1::ExecuteSqlRequest::QueryMode::NORMAL QueryMode::NORMAL}.
          # @param partition_token [String]
          #   If present, results will be restricted to the specified partition
          #   previously created using PartitionQuery().  There must be an exact
          #   match for the values of fields common to this message and the
          #   PartitionQueryRequest message used to create this partition_token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::ResultSet]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::ResultSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +sql+:
          #   sql = ''
          #   response = spanner_client.execute_sql(formatted_session, sql)

          def execute_sql \
              session,
              sql,
              transaction: nil,
              params: nil,
              param_types: nil,
              resume_token: nil,
              query_mode: nil,
              partition_token: nil,
              options: nil,
              &block
            req = {
              session: session,
              sql: sql,
              transaction: transaction,
              params: params,
              param_types: param_types,
              resume_token: resume_token,
              query_mode: query_mode,
              partition_token: partition_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::ExecuteSqlRequest)
            @execute_sql.call(req, options, &block)
          end

          # Like {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql}, except returns the result
          # set as a stream. Unlike {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql}, there
          # is no limit on the size of the returned result set. However, no
          # individual row in the result set can exceed 100 MiB, and no
          # column value can exceed 10 MiB.
          #
          # @param session [String]
          #   Required. The session in which the SQL query should be performed.
          # @param sql [String]
          #   Required. The SQL query string.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param params [Google::Protobuf::Struct | Hash]
          #   The SQL query string can contain parameter placeholders. A parameter
          #   placeholder consists of +'@'+ followed by the parameter
          #   name. Parameter names consist of any combination of letters,
          #   numbers, and underscores.
          #
          #   Parameters can appear anywhere that a literal value is expected.  The same
          #   parameter name can be used more than once, for example:
          #     +"WHERE id > @msg_id AND id < @msg_id + 100"+
          #
          #   It is an error to execute an SQL query with unbound parameters.
          #
          #   Parameter values are specified using +params+, which is a JSON
          #   object whose keys are parameter names, and whose values are the
          #   corresponding parameter values.
          #   A hash of the same form as `Google::Protobuf::Struct`
          #   can also be provided.
          # @param param_types [Hash{String => Google::Spanner::V1::Type | Hash}]
          #   It is not always possible for Cloud Spanner to infer the right SQL type
          #   from a JSON value.  For example, values of type +BYTES+ and values
          #   of type +STRING+ both appear in {Google::Spanner::V1::ExecuteSqlRequest#params params} as JSON strings.
          #
          #   In these cases, +param_types+ can be used to specify the exact
          #   SQL type for some or all of the SQL query parameters. See the
          #   definition of {Google::Spanner::V1::Type Type} for more information
          #   about SQL types.
          #   A hash of the same form as `Google::Spanner::V1::Type`
          #   can also be provided.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted SQL query
          #   execution, +resume_token+ should be copied from the last
          #   {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
          #   enables the new SQL query execution to resume where the last one left
          #   off. The rest of the request parameters must exactly match the
          #   request that yielded this token.
          # @param query_mode [Google::Spanner::V1::ExecuteSqlRequest::QueryMode]
          #   Used to control the amount of debugging information returned in
          #   {Google::Spanner::V1::ResultSetStats ResultSetStats}. If {Google::Spanner::V1::ExecuteSqlRequest#partition_token partition_token} is set, {Google::Spanner::V1::ExecuteSqlRequest#query_mode query_mode} can only
          #   be set to {Google::Spanner::V1::ExecuteSqlRequest::QueryMode::NORMAL QueryMode::NORMAL}.
          # @param partition_token [String]
          #   If present, results will be restricted to the specified partition
          #   previously created using PartitionQuery().  There must be an exact
          #   match for the values of fields common to this message and the
          #   PartitionQueryRequest message used to create this partition_token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Spanner::V1::PartialResultSet>]
          #   An enumerable of Google::Spanner::V1::PartialResultSet instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +sql+:
          #   sql = ''
          #   spanner_client.execute_streaming_sql(formatted_session, sql).each do |element|
          #     # Process element.
          #   end

          def execute_streaming_sql \
              session,
              sql,
              transaction: nil,
              params: nil,
              param_types: nil,
              resume_token: nil,
              query_mode: nil,
              partition_token: nil,
              options: nil
            req = {
              session: session,
              sql: sql,
              transaction: transaction,
              params: params,
              param_types: param_types,
              resume_token: resume_token,
              query_mode: query_mode,
              partition_token: partition_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::ExecuteSqlRequest)
            @execute_streaming_sql.call(req, options)
          end

          # Reads rows from the database using key lookups and scans, as a
          # simple key/value style alternative to
          # {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql}.  This method cannot be used to
          # return a result set larger than 10 MiB; if the read matches more
          # data than that, the read fails with a +FAILED_PRECONDITION+
          # error.
          #
          # Reads inside read-write transactions might return +ABORTED+. If
          # this occurs, the application should restart the transaction from
          # the beginning. See {Google::Spanner::V1::Transaction Transaction} for more details.
          #
          # Larger result sets can be yielded in streaming fashion by calling
          # {Google::Spanner::V1::Spanner::StreamingRead StreamingRead} instead.
          #
          # @param session [String]
          #   Required. The session in which the read should be performed.
          # @param table [String]
          #   Required. The name of the table in the database to be read.
          # @param columns [Array<String>]
          #   The columns of {Google::Spanner::V1::ReadRequest#table table} to be returned for each row matching
          #   this request.
          # @param key_set [Google::Spanner::V1::KeySet | Hash]
          #   Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
          #   primary keys of the rows in {Google::Spanner::V1::ReadRequest#table table} to be yielded, unless {Google::Spanner::V1::ReadRequest#index index}
          #   is present. If {Google::Spanner::V1::ReadRequest#index index} is present, then {Google::Spanner::V1::ReadRequest#key_set key_set} instead names
          #   index keys in {Google::Spanner::V1::ReadRequest#index index}.
          #
          #   If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is empty, rows are yielded
          #   in table primary key order (if {Google::Spanner::V1::ReadRequest#index index} is empty) or index key order
          #   (if {Google::Spanner::V1::ReadRequest#index index} is non-empty).  If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is not
          #   empty, rows will be yielded in an unspecified order.
          #
          #   It is not an error for the +key_set+ to name rows that do not
          #   exist in the database. Read yields nothing for nonexistent rows.
          #   A hash of the same form as `Google::Spanner::V1::KeySet`
          #   can also be provided.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param index [String]
          #   If non-empty, the name of an index on {Google::Spanner::V1::ReadRequest#table table}. This index is
          #   used instead of the table primary key when interpreting {Google::Spanner::V1::ReadRequest#key_set key_set}
          #   and sorting result rows. See {Google::Spanner::V1::ReadRequest#key_set key_set} for further information.
          # @param limit [Integer]
          #   If greater than zero, only the first +limit+ rows are yielded. If +limit+
          #   is zero, the default is no limit. A limit cannot be specified if
          #   +partition_token+ is set.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted read,
          #   +resume_token+ should be copied from the last
          #   {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
          #   enables the new read to resume where the last read left off. The
          #   rest of the request parameters must exactly match the request
          #   that yielded this token.
          # @param partition_token [String]
          #   If present, results will be restricted to the specified partition
          #   previously created using PartitionRead().    There must be an exact
          #   match for the values of fields common to this message and the
          #   PartitionReadRequest message used to create this partition_token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::ResultSet]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::ResultSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +table+:
          #   table = ''
          #
          #   # TODO: Initialize +columns+:
          #   columns = []
          #
          #   # TODO: Initialize +key_set+:
          #   key_set = {}
          #   response = spanner_client.read(formatted_session, table, columns, key_set)

          def read \
              session,
              table,
              columns,
              key_set,
              transaction: nil,
              index: nil,
              limit: nil,
              resume_token: nil,
              partition_token: nil,
              options: nil,
              &block
            req = {
              session: session,
              table: table,
              columns: columns,
              key_set: key_set,
              transaction: transaction,
              index: index,
              limit: limit,
              resume_token: resume_token,
              partition_token: partition_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::ReadRequest)
            @read.call(req, options, &block)
          end

          # Like {Google::Spanner::V1::Spanner::Read Read}, except returns the result set as a
          # stream. Unlike {Google::Spanner::V1::Spanner::Read Read}, there is no limit on the
          # size of the returned result set. However, no individual row in
          # the result set can exceed 100 MiB, and no column value can exceed
          # 10 MiB.
          #
          # @param session [String]
          #   Required. The session in which the read should be performed.
          # @param table [String]
          #   Required. The name of the table in the database to be read.
          # @param columns [Array<String>]
          #   The columns of {Google::Spanner::V1::ReadRequest#table table} to be returned for each row matching
          #   this request.
          # @param key_set [Google::Spanner::V1::KeySet | Hash]
          #   Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
          #   primary keys of the rows in {Google::Spanner::V1::ReadRequest#table table} to be yielded, unless {Google::Spanner::V1::ReadRequest#index index}
          #   is present. If {Google::Spanner::V1::ReadRequest#index index} is present, then {Google::Spanner::V1::ReadRequest#key_set key_set} instead names
          #   index keys in {Google::Spanner::V1::ReadRequest#index index}.
          #
          #   If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is empty, rows are yielded
          #   in table primary key order (if {Google::Spanner::V1::ReadRequest#index index} is empty) or index key order
          #   (if {Google::Spanner::V1::ReadRequest#index index} is non-empty).  If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is not
          #   empty, rows will be yielded in an unspecified order.
          #
          #   It is not an error for the +key_set+ to name rows that do not
          #   exist in the database. Read yields nothing for nonexistent rows.
          #   A hash of the same form as `Google::Spanner::V1::KeySet`
          #   can also be provided.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param index [String]
          #   If non-empty, the name of an index on {Google::Spanner::V1::ReadRequest#table table}. This index is
          #   used instead of the table primary key when interpreting {Google::Spanner::V1::ReadRequest#key_set key_set}
          #   and sorting result rows. See {Google::Spanner::V1::ReadRequest#key_set key_set} for further information.
          # @param limit [Integer]
          #   If greater than zero, only the first +limit+ rows are yielded. If +limit+
          #   is zero, the default is no limit. A limit cannot be specified if
          #   +partition_token+ is set.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted read,
          #   +resume_token+ should be copied from the last
          #   {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
          #   enables the new read to resume where the last read left off. The
          #   rest of the request parameters must exactly match the request
          #   that yielded this token.
          # @param partition_token [String]
          #   If present, results will be restricted to the specified partition
          #   previously created using PartitionRead().    There must be an exact
          #   match for the values of fields common to this message and the
          #   PartitionReadRequest message used to create this partition_token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Spanner::V1::PartialResultSet>]
          #   An enumerable of Google::Spanner::V1::PartialResultSet instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +table+:
          #   table = ''
          #
          #   # TODO: Initialize +columns+:
          #   columns = []
          #
          #   # TODO: Initialize +key_set+:
          #   key_set = {}
          #   spanner_client.streaming_read(formatted_session, table, columns, key_set).each do |element|
          #     # Process element.
          #   end

          def streaming_read \
              session,
              table,
              columns,
              key_set,
              transaction: nil,
              index: nil,
              limit: nil,
              resume_token: nil,
              partition_token: nil,
              options: nil
            req = {
              session: session,
              table: table,
              columns: columns,
              key_set: key_set,
              transaction: transaction,
              index: index,
              limit: limit,
              resume_token: resume_token,
              partition_token: partition_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::ReadRequest)
            @streaming_read.call(req, options)
          end

          # Begins a new transaction. This step can often be skipped:
          # {Google::Spanner::V1::Spanner::Read Read}, {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql} and
          # {Google::Spanner::V1::Spanner::Commit Commit} can begin a new transaction as a
          # side-effect.
          #
          # @param session [String]
          #   Required. The session in which the transaction runs.
          # @param options_ [Google::Spanner::V1::TransactionOptions | Hash]
          #   Required. Options for the new transaction.
          #   A hash of the same form as `Google::Spanner::V1::TransactionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::Transaction]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::Transaction]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +options_+:
          #   options_ = {}
          #   response = spanner_client.begin_transaction(formatted_session, options_)

          def begin_transaction \
              session,
              options_,
              options: nil,
              &block
            req = {
              session: session,
              options: options_
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::BeginTransactionRequest)
            @begin_transaction.call(req, options, &block)
          end

          # Commits a transaction. The request includes the mutations to be
          # applied to rows in the database.
          #
          # +Commit+ might return an +ABORTED+ error. This can occur at any time;
          # commonly, the cause is conflicts with concurrent
          # transactions. However, it can also happen for a variety of other
          # reasons. If +Commit+ returns +ABORTED+, the caller should re-attempt
          # the transaction from the beginning, re-using the same session.
          #
          # @param session [String]
          #   Required. The session in which the transaction to be committed is running.
          # @param mutations [Array<Google::Spanner::V1::Mutation | Hash>]
          #   The mutations to be executed when this transaction commits. All
          #   mutations are applied atomically, in the order they appear in
          #   this list.
          #   A hash of the same form as `Google::Spanner::V1::Mutation`
          #   can also be provided.
          # @param transaction_id [String]
          #   Commit a previously-started transaction.
          # @param single_use_transaction [Google::Spanner::V1::TransactionOptions | Hash]
          #   Execute mutations in a temporary transaction. Note that unlike
          #   commit of a previously-started transaction, commit with a
          #   temporary transaction is non-idempotent. That is, if the
          #   +CommitRequest+ is sent to Cloud Spanner more than once (for
          #   instance, due to retries in the application, or in the
          #   transport library), it is possible that the mutations are
          #   executed more than once. If this is undesirable, use
          #   {Google::Spanner::V1::Spanner::BeginTransaction BeginTransaction} and
          #   {Google::Spanner::V1::Spanner::Commit Commit} instead.
          #   A hash of the same form as `Google::Spanner::V1::TransactionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::CommitResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::CommitResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +mutations+:
          #   mutations = []
          #   response = spanner_client.commit(formatted_session, mutations)

          def commit \
              session,
              mutations,
              transaction_id: nil,
              single_use_transaction: nil,
              options: nil,
              &block
            req = {
              session: session,
              mutations: mutations,
              transaction_id: transaction_id,
              single_use_transaction: single_use_transaction
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::CommitRequest)
            @commit.call(req, options, &block)
          end

          # Rolls back a transaction, releasing any locks it holds. It is a good
          # idea to call this for any transaction that includes one or more
          # {Google::Spanner::V1::Spanner::Read Read} or {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql} requests and
          # ultimately decides not to commit.
          #
          # +Rollback+ returns +OK+ if it successfully aborts the transaction, the
          # transaction was already aborted, or the transaction is not
          # found. +Rollback+ never returns +ABORTED+.
          #
          # @param session [String]
          #   Required. The session in which the transaction to roll back is running.
          # @param transaction_id [String]
          #   Required. The transaction to roll back.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +transaction_id+:
          #   transaction_id = ''
          #   spanner_client.rollback(formatted_session, transaction_id)

          def rollback \
              session,
              transaction_id,
              options: nil,
              &block
            req = {
              session: session,
              transaction_id: transaction_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::RollbackRequest)
            @rollback.call(req, options, &block)
            nil
          end

          # Creates a set of partition tokens that can be used to execute a query
          # operation in parallel.  Each of the returned partition tokens can be used
          # by {Google::Spanner::V1::Spanner::ExecuteStreamingSql ExecuteStreamingSql} to specify a subset
          # of the query result to read.  The same session and read-only transaction
          # must be used by the PartitionQueryRequest used to create the
          # partition tokens and the ExecuteSqlRequests that use the partition tokens.
          # Partition tokens become invalid when the session used to create them
          # is deleted or begins a new transaction.
          #
          # @param session [String]
          #   Required. The session used to create the partitions.
          # @param sql [String]
          #   The query request to generate partitions for. The request will fail if
          #   the query is not root partitionable. The query plan of a root
          #   partitionable query has a single distributed union operator. A distributed
          #   union operator conceptually divides one or more tables into multiple
          #   splits, remotely evaluates a subquery independently on each split, and
          #   then unions all results.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   Read only snapshot transactions are supported, read/write and single use
          #   transactions are not.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param params [Google::Protobuf::Struct | Hash]
          #   The SQL query string can contain parameter placeholders. A parameter
          #   placeholder consists of +'@'+ followed by the parameter
          #   name. Parameter names consist of any combination of letters,
          #   numbers, and underscores.
          #
          #   Parameters can appear anywhere that a literal value is expected.  The same
          #   parameter name can be used more than once, for example:
          #     +"WHERE id > @msg_id AND id < @msg_id + 100"+
          #
          #   It is an error to execute an SQL query with unbound parameters.
          #
          #   Parameter values are specified using +params+, which is a JSON
          #   object whose keys are parameter names, and whose values are the
          #   corresponding parameter values.
          #   A hash of the same form as `Google::Protobuf::Struct`
          #   can also be provided.
          # @param param_types [Hash{String => Google::Spanner::V1::Type | Hash}]
          #   It is not always possible for Cloud Spanner to infer the right SQL type
          #   from a JSON value.  For example, values of type +BYTES+ and values
          #   of type +STRING+ both appear in {Google::Spanner::V1::PartitionQueryRequest#params params} as JSON strings.
          #
          #   In these cases, +param_types+ can be used to specify the exact
          #   SQL type for some or all of the SQL query parameters. See the
          #   definition of {Google::Spanner::V1::Type Type} for more information
          #   about SQL types.
          #   A hash of the same form as `Google::Spanner::V1::Type`
          #   can also be provided.
          # @param partition_options [Google::Spanner::V1::PartitionOptions | Hash]
          #   Additional options that affect how many partitions are created.
          #   A hash of the same form as `Google::Spanner::V1::PartitionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::PartitionResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::PartitionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +sql+:
          #   sql = ''
          #   response = spanner_client.partition_query(formatted_session, sql)

          def partition_query \
              session,
              sql,
              transaction: nil,
              params: nil,
              param_types: nil,
              partition_options: nil,
              options: nil,
              &block
            req = {
              session: session,
              sql: sql,
              transaction: transaction,
              params: params,
              param_types: param_types,
              partition_options: partition_options
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::PartitionQueryRequest)
            @partition_query.call(req, options, &block)
          end

          # Creates a set of partition tokens that can be used to execute a read
          # operation in parallel.  Each of the returned partition tokens can be used
          # by {Google::Spanner::V1::Spanner::StreamingRead StreamingRead} to specify a subset of the read
          # result to read.  The same session and read-only transaction must be used by
          # the PartitionReadRequest used to create the partition tokens and the
          # ReadRequests that use the partition tokens.
          # Partition tokens become invalid when the session used to create them
          # is deleted or begins a new transaction.
          #
          # @param session [String]
          #   Required. The session used to create the partitions.
          # @param table [String]
          #   Required. The name of the table in the database to be read.
          # @param key_set [Google::Spanner::V1::KeySet | Hash]
          #   Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
          #   primary keys of the rows in {Google::Spanner::V1::PartitionReadRequest#table table} to be yielded, unless {Google::Spanner::V1::PartitionReadRequest#index index}
          #   is present. If {Google::Spanner::V1::PartitionReadRequest#index index} is present, then {Google::Spanner::V1::PartitionReadRequest#key_set key_set} instead names
          #   index keys in {Google::Spanner::V1::PartitionReadRequest#index index}.
          #
          #   It is not an error for the +key_set+ to name rows that do not
          #   exist in the database. Read yields nothing for nonexistent rows.
          #   A hash of the same form as `Google::Spanner::V1::KeySet`
          #   can also be provided.
          # @param transaction [Google::Spanner::V1::TransactionSelector | Hash]
          #   Read only snapshot transactions are supported, read/write and single use
          #   transactions are not.
          #   A hash of the same form as `Google::Spanner::V1::TransactionSelector`
          #   can also be provided.
          # @param index [String]
          #   If non-empty, the name of an index on {Google::Spanner::V1::PartitionReadRequest#table table}. This index is
          #   used instead of the table primary key when interpreting {Google::Spanner::V1::PartitionReadRequest#key_set key_set}
          #   and sorting result rows. See {Google::Spanner::V1::PartitionReadRequest#key_set key_set} for further information.
          # @param columns [Array<String>]
          #   The columns of {Google::Spanner::V1::PartitionReadRequest#table table} to be returned for each row matching
          #   this request.
          # @param partition_options [Google::Spanner::V1::PartitionOptions | Hash]
          #   Additional options that affect how many partitions are created.
          #   A hash of the same form as `Google::Spanner::V1::PartitionOptions`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Spanner::V1::PartitionResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Spanner::V1::PartitionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1"
          #
          #   spanner_client = Google::Cloud::Spanner::V1::SpannerClient.new
          #   formatted_session = Google::Cloud::Spanner::V1::SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #
          #   # TODO: Initialize +table+:
          #   table = ''
          #
          #   # TODO: Initialize +key_set+:
          #   key_set = {}
          #   response = spanner_client.partition_read(formatted_session, table, key_set)

          def partition_read \
              session,
              table,
              key_set,
              transaction: nil,
              index: nil,
              columns: nil,
              partition_options: nil,
              options: nil,
              &block
            req = {
              session: session,
              table: table,
              key_set: key_set,
              transaction: transaction,
              index: index,
              columns: columns,
              partition_options: partition_options
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Spanner::V1::PartitionReadRequest)
            @partition_read.call(req, options, &block)
          end
        end
      end
    end
  end
end
