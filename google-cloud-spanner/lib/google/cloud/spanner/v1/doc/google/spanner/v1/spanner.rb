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

module Google
  module Spanner
    ##
    # # Cloud Spanner API Contents
    #
    # | Class | Description |
    # | ----- | ----------- |
    # | [SpannerClient][] | Cloud Spanner is a managed, mission-critical, globally consistent and scalable relational database service. |
    # | [Data Types][] | Data types for Google::Cloud::Spanner::V1 |
    #
    # [SpannerClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-spanner/latest/google/spanner/v1/spannerclient
    # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-spanner/latest/google/spanner/v1/datatypes
    #
    module V1
      # The request for {Google::Spanner::V1::Spanner::CreateSession CreateSession}.
      # @!attribute [rw] database
      #   @return [String]
      #     Required. The database in which the new session is created.
      class CreateSessionRequest; end

      # A session in the Cloud Spanner API.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The name of the session.
      class Session; end

      # The request for {Google::Spanner::V1::Spanner::GetSession GetSession}.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The name of the session to retrieve.
      class GetSessionRequest; end

      # The request for {Google::Spanner::V1::Spanner::DeleteSession DeleteSession}.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The name of the session to delete.
      class DeleteSessionRequest; end

      # The request for {Google::Spanner::V1::Spanner::ExecuteSql ExecuteSql} and
      # {Google::Spanner::V1::Spanner::ExecuteStreamingSql ExecuteStreamingSql}.
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session in which the SQL query should be performed.
      # @!attribute [rw] transaction
      #   @return [Google::Spanner::V1::TransactionSelector]
      #     The transaction to use. If none is provided, the default is a
      #     temporary read-only transaction with strong concurrency.
      # @!attribute [rw] sql
      #   @return [String]
      #     Required. The SQL query string.
      # @!attribute [rw] params
      #   @return [Google::Protobuf::Struct]
      #     The SQL query string can contain parameter placeholders. A parameter
      #     placeholder consists of +'@'+ followed by the parameter
      #     name. Parameter names consist of any combination of letters,
      #     numbers, and underscores.
      #
      #     Parameters can appear anywhere that a literal value is expected.  The same
      #     parameter name can be used more than once, for example:
      #       +"WHERE id > @msg_id AND id < @msg_id + 100"+
      #
      #     It is an error to execute an SQL query with unbound parameters.
      #
      #     Parameter values are specified using +params+, which is a JSON
      #     object whose keys are parameter names, and whose values are the
      #     corresponding parameter values.
      # @!attribute [rw] param_types
      #   @return [Hash{String => Google::Spanner::V1::Type}]
      #     It is not always possible for Cloud Spanner to infer the right SQL type
      #     from a JSON value.  For example, values of type +BYTES+ and values
      #     of type +STRING+ both appear in {Google::Spanner::V1::ExecuteSqlRequest#params Params} as JSON strings.
      #
      #     In these cases, +param_types+ can be used to specify the exact
      #     SQL type for some or all of the SQL query parameters. See the
      #     definition of {Google::Spanner::V1::Type Type} for more information
      #     about SQL types.
      # @!attribute [rw] resume_token
      #   @return [String]
      #     If this request is resuming a previously interrupted SQL query
      #     execution, +resume_token+ should be copied from the last
      #     {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
      #     enables the new SQL query execution to resume where the last one left
      #     off. The rest of the request parameters must exactly match the
      #     request that yielded this token.
      # @!attribute [rw] query_mode
      #   @return [Google::Spanner::V1::ExecuteSqlRequest::QueryMode]
      #     Used to control the amount of debugging information returned in
      #     {Google::Spanner::V1::ResultSetStats ResultSetStats}.
      class ExecuteSqlRequest
        # Mode in which the query must be processed.
        module QueryMode
          # The default mode where only the query result, without any information
          # about the query plan is returned.
          NORMAL = 0

          # This mode returns only the query plan, without any result rows or
          # execution statistics information.
          PLAN = 1

          # This mode returns both the query plan and the execution statistics along
          # with the result rows.
          PROFILE = 2
        end
      end

      # The request for {Google::Spanner::V1::Spanner::Read Read} and
      # {Google::Spanner::V1::Spanner::StreamingRead StreamingRead}.
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session in which the read should be performed.
      # @!attribute [rw] transaction
      #   @return [Google::Spanner::V1::TransactionSelector]
      #     The transaction to use. If none is provided, the default is a
      #     temporary read-only transaction with strong concurrency.
      # @!attribute [rw] table
      #   @return [String]
      #     Required. The name of the table in the database to be read.
      # @!attribute [rw] index
      #   @return [String]
      #     If non-empty, the name of an index on {Google::Spanner::V1::ReadRequest#table Table}. This index is
      #     used instead of the table primary key when interpreting {Google::Spanner::V1::ReadRequest#key_set Key_set}
      #     and sorting result rows. See {Google::Spanner::V1::ReadRequest#key_set Key_set} for further information.
      # @!attribute [rw] columns
      #   @return [Array<String>]
      #     The columns of {Google::Spanner::V1::ReadRequest#table Table} to be returned for each row matching
      #     this request.
      # @!attribute [rw] key_set
      #   @return [Google::Spanner::V1::KeySet]
      #     Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
      #     primary keys of the rows in {Google::Spanner::V1::ReadRequest#table Table} to be yielded, unless {Google::Spanner::V1::ReadRequest#index Index}
      #     is present. If {Google::Spanner::V1::ReadRequest#index Index} is present, then {Google::Spanner::V1::ReadRequest#key_set Key_set} instead names
      #     index keys in {Google::Spanner::V1::ReadRequest#index Index}.
      #
      #     Rows are yielded in table primary key order (if {Google::Spanner::V1::ReadRequest#index Index} is empty)
      #     or index key order (if {Google::Spanner::V1::ReadRequest#index Index} is non-empty).
      #
      #     It is not an error for the +key_set+ to name rows that do not
      #     exist in the database. Read yields nothing for nonexistent rows.
      # @!attribute [rw] limit
      #   @return [Integer]
      #     If greater than zero, only the first +limit+ rows are yielded. If +limit+
      #     is zero, the default is no limit.
      # @!attribute [rw] resume_token
      #   @return [String]
      #     If this request is resuming a previously interrupted read,
      #     +resume_token+ should be copied from the last
      #     {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
      #     enables the new read to resume where the last read left off. The
      #     rest of the request parameters must exactly match the request
      #     that yielded this token.
      class ReadRequest; end

      # The request for {Google::Spanner::V1::Spanner::BeginTransaction BeginTransaction}.
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session in which the transaction runs.
      # @!attribute [rw] options
      #   @return [Google::Spanner::V1::TransactionOptions]
      #     Required. Options for the new transaction.
      class BeginTransactionRequest; end

      # The request for {Google::Spanner::V1::Spanner::Commit Commit}.
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session in which the transaction to be committed is running.
      # @!attribute [rw] transaction_id
      #   @return [String]
      #     Commit a previously-started transaction.
      # @!attribute [rw] single_use_transaction
      #   @return [Google::Spanner::V1::TransactionOptions]
      #     Execute mutations in a temporary transaction. Note that unlike
      #     commit of a previously-started transaction, commit with a
      #     temporary transaction is non-idempotent. That is, if the
      #     +CommitRequest+ is sent to Cloud Spanner more than once (for
      #     instance, due to retries in the application, or in the
      #     transport library), it is possible that the mutations are
      #     executed more than once. If this is undesirable, use
      #     {Google::Spanner::V1::Spanner::BeginTransaction BeginTransaction} and
      #     {Google::Spanner::V1::Spanner::Commit Commit} instead.
      # @!attribute [rw] mutations
      #   @return [Array<Google::Spanner::V1::Mutation>]
      #     The mutations to be executed when this transaction commits. All
      #     mutations are applied atomically, in the order they appear in
      #     this list.
      class CommitRequest; end

      # The response for {Google::Spanner::V1::Spanner::Commit Commit}.
      # @!attribute [rw] commit_timestamp
      #   @return [Google::Protobuf::Timestamp]
      #     The Cloud Spanner timestamp at which the transaction committed.
      class CommitResponse; end

      # The request for {Google::Spanner::V1::Spanner::Rollback Rollback}.
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session in which the transaction to roll back is running.
      # @!attribute [rw] transaction_id
      #   @return [String]
      #     Required. The transaction to roll back.
      class RollbackRequest; end
    end
  end
end