# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/spanner/v1/spanner_pb"

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
          attr_reader :spanner_stub

          # The default address of the service.
          SERVICE_ADDRESS = "spanner.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

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

          # Parses the project from a database resource.
          # @param database_name [String]
          # @return [String]
          def self.match_project_from_database_name database_name
            DATABASE_PATH_TEMPLATE.match(database_name)["project"]
          end

          # Parses the instance from a database resource.
          # @param database_name [String]
          # @return [String]
          def self.match_instance_from_database_name database_name
            DATABASE_PATH_TEMPLATE.match(database_name)["instance"]
          end

          # Parses the database from a database resource.
          # @param database_name [String]
          # @return [String]
          def self.match_database_from_database_name database_name
            DATABASE_PATH_TEMPLATE.match(database_name)["database"]
          end

          # Parses the project from a session resource.
          # @param session_name [String]
          # @return [String]
          def self.match_project_from_session_name session_name
            SESSION_PATH_TEMPLATE.match(session_name)["project"]
          end

          # Parses the instance from a session resource.
          # @param session_name [String]
          # @return [String]
          def self.match_instance_from_session_name session_name
            SESSION_PATH_TEMPLATE.match(session_name)["instance"]
          end

          # Parses the database from a session resource.
          # @param session_name [String]
          # @return [String]
          def self.match_database_from_session_name session_name
            SESSION_PATH_TEMPLATE.match(session_name)["database"]
          end

          # Parses the session from a session resource.
          # @param session_name [String]
          # @return [String]
          def self.match_session_from_session_name session_name
            SESSION_PATH_TEMPLATE.match(session_name)["session"]
          end

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param channel [Channel]
          #   A Channel object through which to make calls.
          # @param chan_creds [Grpc::ChannelCredentials]
          #   A ChannelCredentials for the setting up the RPC client.
          # @param client_config[Hash]
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
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              app_name: nil,
              app_version: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/spanner/v1/spanner_services_pb"


            if app_name || app_version
              warn "`app_name` and `app_version` are no longer being used in the request headers."
            end

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
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
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @spanner_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              scopes: scopes,
              &Google::Spanner::V1::Spanner::Stub.method(:new)
            )

            @create_session = Google::Gax.create_api_call(
              @spanner_stub.method(:create_session),
              defaults["create_session"]
            )
            @get_session = Google::Gax.create_api_call(
              @spanner_stub.method(:get_session),
              defaults["get_session"]
            )
            @delete_session = Google::Gax.create_api_call(
              @spanner_stub.method(:delete_session),
              defaults["delete_session"]
            )
            @execute_sql = Google::Gax.create_api_call(
              @spanner_stub.method(:execute_sql),
              defaults["execute_sql"]
            )
            @execute_streaming_sql = Google::Gax.create_api_call(
              @spanner_stub.method(:execute_streaming_sql),
              defaults["execute_streaming_sql"]
            )
            @read = Google::Gax.create_api_call(
              @spanner_stub.method(:read),
              defaults["read"]
            )
            @streaming_read = Google::Gax.create_api_call(
              @spanner_stub.method(:streaming_read),
              defaults["streaming_read"]
            )
            @begin_transaction = Google::Gax.create_api_call(
              @spanner_stub.method(:begin_transaction),
              defaults["begin_transaction"]
            )
            @commit = Google::Gax.create_api_call(
              @spanner_stub.method(:commit),
              defaults["commit"]
            )
            @rollback = Google::Gax.create_api_call(
              @spanner_stub.method(:rollback),
              defaults["rollback"]
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
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Spanner::V1::Session]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_database = SpannerClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
          #   response = spanner_client.create_session(formatted_database)

          def create_session \
              database,
              options: nil
            req = Google::Spanner::V1::CreateSessionRequest.new({
              database: database
            }.delete_if { |_, v| v.nil? })
            @create_session.call(req, options)
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
          # @return [Google::Spanner::V1::Session]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_name = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   response = spanner_client.get_session(formatted_name)

          def get_session \
              name,
              options: nil
            req = Google::Spanner::V1::GetSessionRequest.new({
              name: name
            }.delete_if { |_, v| v.nil? })
            @get_session.call(req, options)
          end

          # Ends a session, releasing server resources associated with it.
          #
          # @param name [String]
          #   Required. The name of the session to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_name = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   spanner_client.delete_session(formatted_name)

          def delete_session \
              name,
              options: nil
            req = Google::Spanner::V1::DeleteSessionRequest.new({
              name: name
            }.delete_if { |_, v| v.nil? })
            @delete_session.call(req, options)
            nil
          end

          # Executes an SQL query, returning all rows in a single reply. This
          # method cannot be used to return a result set larger than 10 MiB;
          # if the query yields more data than that, the query fails with
          # a +FAILED_PRECONDITION+ error.
          #
          # Queries inside read-write transactions might return +ABORTED+. If
          # this occurs, the application should restart the transaction from
          # the beginning. See Transaction for more details.
          #
          # Larger result sets can be fetched in streaming fashion by calling
          # ExecuteStreamingSql instead.
          #
          # @param session [String]
          #   Required. The session in which the SQL query should be performed.
          # @param transaction [Google::Spanner::V1::TransactionSelector]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          # @param sql [String]
          #   Required. The SQL query string.
          # @param params [Google::Protobuf::Struct]
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
          # @param param_types [Hash{String => Google::Spanner::V1::Type}]
          #   It is not always possible for Cloud Spanner to infer the right SQL type
          #   from a JSON value.  For example, values of type +BYTES+ and values
          #   of type +STRING+ both appear in Params as JSON strings.
          #
          #   In these cases, +param_types+ can be used to specify the exact
          #   SQL type for some or all of the SQL query parameters. See the
          #   definition of Type for more information
          #   about SQL types.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted SQL query
          #   execution, +resume_token+ should be copied from the last
          #   PartialResultSet yielded before the interruption. Doing this
          #   enables the new SQL query execution to resume where the last one left
          #   off. The rest of the request parameters must exactly match the
          #   request that yielded this token.
          # @param query_mode [Google::Spanner::V1::ExecuteSqlRequest::QueryMode]
          #   Used to control the amount of debugging information returned in
          #   ResultSetStats.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Spanner::V1::ResultSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
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
              options: nil
            req = Google::Spanner::V1::ExecuteSqlRequest.new({
              session: session,
              sql: sql,
              transaction: transaction,
              params: params,
              param_types: param_types,
              resume_token: resume_token,
              query_mode: query_mode
            }.delete_if { |_, v| v.nil? })
            @execute_sql.call(req, options)
          end

          # Like ExecuteSql, except returns the result
          # set as a stream. Unlike ExecuteSql, there
          # is no limit on the size of the returned result set. However, no
          # individual row in the result set can exceed 100 MiB, and no
          # column value can exceed 10 MiB.
          #
          # @param session [String]
          #   Required. The session in which the SQL query should be performed.
          # @param transaction [Google::Spanner::V1::TransactionSelector]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          # @param sql [String]
          #   Required. The SQL query string.
          # @param params [Google::Protobuf::Struct]
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
          # @param param_types [Hash{String => Google::Spanner::V1::Type}]
          #   It is not always possible for Cloud Spanner to infer the right SQL type
          #   from a JSON value.  For example, values of type +BYTES+ and values
          #   of type +STRING+ both appear in Params as JSON strings.
          #
          #   In these cases, +param_types+ can be used to specify the exact
          #   SQL type for some or all of the SQL query parameters. See the
          #   definition of Type for more information
          #   about SQL types.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted SQL query
          #   execution, +resume_token+ should be copied from the last
          #   PartialResultSet yielded before the interruption. Doing this
          #   enables the new SQL query execution to resume where the last one left
          #   off. The rest of the request parameters must exactly match the
          #   request that yielded this token.
          # @param query_mode [Google::Spanner::V1::ExecuteSqlRequest::QueryMode]
          #   Used to control the amount of debugging information returned in
          #   ResultSetStats.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Spanner::V1::PartialResultSet>]
          #   An enumerable of Google::Spanner::V1::PartialResultSet instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
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
              options: nil
            req = Google::Spanner::V1::ExecuteSqlRequest.new({
              session: session,
              sql: sql,
              transaction: transaction,
              params: params,
              param_types: param_types,
              resume_token: resume_token,
              query_mode: query_mode
            }.delete_if { |_, v| v.nil? })
            @execute_streaming_sql.call(req, options)
          end

          # Reads rows from the database using key lookups and scans, as a
          # simple key/value style alternative to
          # ExecuteSql.  This method cannot be used to
          # return a result set larger than 10 MiB; if the read matches more
          # data than that, the read fails with a +FAILED_PRECONDITION+
          # error.
          #
          # Reads inside read-write transactions might return +ABORTED+. If
          # this occurs, the application should restart the transaction from
          # the beginning. See Transaction for more details.
          #
          # Larger result sets can be yielded in streaming fashion by calling
          # StreamingRead instead.
          #
          # @param session [String]
          #   Required. The session in which the read should be performed.
          # @param transaction [Google::Spanner::V1::TransactionSelector]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          # @param table [String]
          #   Required. The name of the table in the database to be read.
          # @param index [String]
          #   If non-empty, the name of an index on Table. This index is
          #   used instead of the table primary key when interpreting Key_set
          #   and sorting result rows. See Key_set for further information.
          # @param columns [Array<String>]
          #   The columns of Table to be returned for each row matching
          #   this request.
          # @param key_set [Google::Spanner::V1::KeySet]
          #   Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
          #   primary keys of the rows in Table to be yielded, unless Index
          #   is present. If Index is present, then Key_set instead names
          #   index keys in Index.
          #
          #   Rows are yielded in table primary key order (if Index is empty)
          #   or index key order (if Index is non-empty).
          #
          #   It is not an error for the +key_set+ to name rows that do not
          #   exist in the database. Read yields nothing for nonexistent rows.
          # @param limit [Integer]
          #   If greater than zero, only the first +limit+ rows are yielded. If +limit+
          #   is zero, the default is no limit.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted read,
          #   +resume_token+ should be copied from the last
          #   PartialResultSet yielded before the interruption. Doing this
          #   enables the new read to resume where the last read left off. The
          #   rest of the request parameters must exactly match the request
          #   that yielded this token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Spanner::V1::ResultSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   KeySet = Google::Spanner::V1::KeySet
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   table = ''
          #   columns = []
          #   key_set = KeySet.new
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
              options: nil
            req = Google::Spanner::V1::ReadRequest.new({
              session: session,
              table: table,
              columns: columns,
              key_set: key_set,
              transaction: transaction,
              index: index,
              limit: limit,
              resume_token: resume_token
            }.delete_if { |_, v| v.nil? })
            @read.call(req, options)
          end

          # Like Read, except returns the result set as a
          # stream. Unlike Read, there is no limit on the
          # size of the returned result set. However, no individual row in
          # the result set can exceed 100 MiB, and no column value can exceed
          # 10 MiB.
          #
          # @param session [String]
          #   Required. The session in which the read should be performed.
          # @param transaction [Google::Spanner::V1::TransactionSelector]
          #   The transaction to use. If none is provided, the default is a
          #   temporary read-only transaction with strong concurrency.
          # @param table [String]
          #   Required. The name of the table in the database to be read.
          # @param index [String]
          #   If non-empty, the name of an index on Table. This index is
          #   used instead of the table primary key when interpreting Key_set
          #   and sorting result rows. See Key_set for further information.
          # @param columns [Array<String>]
          #   The columns of Table to be returned for each row matching
          #   this request.
          # @param key_set [Google::Spanner::V1::KeySet]
          #   Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
          #   primary keys of the rows in Table to be yielded, unless Index
          #   is present. If Index is present, then Key_set instead names
          #   index keys in Index.
          #
          #   Rows are yielded in table primary key order (if Index is empty)
          #   or index key order (if Index is non-empty).
          #
          #   It is not an error for the +key_set+ to name rows that do not
          #   exist in the database. Read yields nothing for nonexistent rows.
          # @param limit [Integer]
          #   If greater than zero, only the first +limit+ rows are yielded. If +limit+
          #   is zero, the default is no limit.
          # @param resume_token [String]
          #   If this request is resuming a previously interrupted read,
          #   +resume_token+ should be copied from the last
          #   PartialResultSet yielded before the interruption. Doing this
          #   enables the new read to resume where the last read left off. The
          #   rest of the request parameters must exactly match the request
          #   that yielded this token.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Spanner::V1::PartialResultSet>]
          #   An enumerable of Google::Spanner::V1::PartialResultSet instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   KeySet = Google::Spanner::V1::KeySet
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   table = ''
          #   columns = []
          #   key_set = KeySet.new
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
              options: nil
            req = Google::Spanner::V1::ReadRequest.new({
              session: session,
              table: table,
              columns: columns,
              key_set: key_set,
              transaction: transaction,
              index: index,
              limit: limit,
              resume_token: resume_token
            }.delete_if { |_, v| v.nil? })
            @streaming_read.call(req, options)
          end

          # Begins a new transaction. This step can often be skipped:
          # Read, ExecuteSql and
          # Commit can begin a new transaction as a
          # side-effect.
          #
          # @param session [String]
          #   Required. The session in which the transaction runs.
          # @param options_ [Google::Spanner::V1::TransactionOptions]
          #   Required. Options for the new transaction.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Spanner::V1::Transaction]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #   TransactionOptions = Google::Spanner::V1::TransactionOptions
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   options_ = TransactionOptions.new
          #   response = spanner_client.begin_transaction(formatted_session, options_)

          def begin_transaction \
              session,
              options_,
              options: nil
            req = Google::Spanner::V1::BeginTransactionRequest.new({
              session: session,
              options: options_
            }.delete_if { |_, v| v.nil? })
            @begin_transaction.call(req, options)
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
          # @param transaction_id [String]
          #   Commit a previously-started transaction.
          # @param single_use_transaction [Google::Spanner::V1::TransactionOptions]
          #   Execute mutations in a temporary transaction. Note that unlike
          #   commit of a previously-started transaction, commit with a
          #   temporary transaction is non-idempotent. That is, if the
          #   +CommitRequest+ is sent to Cloud Spanner more than once (for
          #   instance, due to retries in the application, or in the
          #   transport library), it is possible that the mutations are
          #   executed more than once. If this is undesirable, use
          #   BeginTransaction and
          #   Commit instead.
          # @param mutations [Array<Google::Spanner::V1::Mutation>]
          #   The mutations to be executed when this transaction commits. All
          #   mutations are applied atomically, in the order they appear in
          #   this list.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Spanner::V1::CommitResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   mutations = []
          #   response = spanner_client.commit(formatted_session, mutations)

          def commit \
              session,
              mutations,
              transaction_id: nil,
              single_use_transaction: nil,
              options: nil
            req = Google::Spanner::V1::CommitRequest.new({
              session: session,
              mutations: mutations,
              transaction_id: transaction_id,
              single_use_transaction: single_use_transaction
            }.delete_if { |_, v| v.nil? })
            @commit.call(req, options)
          end

          # Rolls back a transaction, releasing any locks it holds. It is a good
          # idea to call this for any transaction that includes one or more
          # Read or ExecuteSql requests and
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
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/spanner/v1/spanner_client"
          #
          #   SpannerClient = Google::Cloud::Spanner::V1::SpannerClient
          #
          #   spanner_client = SpannerClient.new
          #   formatted_session = SpannerClient.session_path("[PROJECT]", "[INSTANCE]", "[DATABASE]", "[SESSION]")
          #   transaction_id = ''
          #   spanner_client.rollback(formatted_session, transaction_id)

          def rollback \
              session,
              transaction_id,
              options: nil
            req = Google::Spanner::V1::RollbackRequest.new({
              session: session,
              transaction_id: transaction_id
            }.delete_if { |_, v| v.nil? })
            @rollback.call(req, options)
            nil
          end
        end
      end
    end
  end
end
