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

module Google
  module Spanner
    ##
    # # Cloud Spanner API Contents
    #
    # | Class | Description |
    # | ----- | ----------- |
    # | [SpannerClient][] | Cloud Spanner API |
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
      # @!attribute [rw] session
      #   @return [Google::Spanner::V1::Session]
      #     The session to create.
      class CreateSessionRequest; end

      # A session in the Cloud Spanner API.
      # @!attribute [rw] name
      #   @return [String]
      #     The name of the session. This is always system-assigned; values provided
      #     when creating a session are ignored.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     The labels for the session.
      #
      #     * Label keys must be between 1 and 63 characters long and must conform to
      #       the following regular expression: +[a-z](https://cloud.google.com[-a-z0-9]*[a-z0-9])?+.
      #     * Label values must be between 0 and 63 characters long and must conform
      #       to the regular expression +([a-z](https://cloud.google.com[-a-z0-9]*[a-z0-9])?)?+.
      #     * No more than 64 labels can be associated with a given session.
      #
      #     See https://goo.gl/xmQnxf for more information on and examples of labels.
      # @!attribute [rw] create_time
      #   @return [Google::Protobuf::Timestamp]
      #     Output only. The timestamp when the session is created.
      # @!attribute [rw] approximate_last_use_time
      #   @return [Google::Protobuf::Timestamp]
      #     Output only. The approximate timestamp when the session is last used. It is
      #     typically earlier than the actual last use time.
      class Session; end

      # The request for {Google::Spanner::V1::Spanner::GetSession GetSession}.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The name of the session to retrieve.
      class GetSessionRequest; end

      # The request for {Google::Spanner::V1::Spanner::ListSessions ListSessions}.
      # @!attribute [rw] database
      #   @return [String]
      #     Required. The database in which to list sessions.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Number of sessions to be returned in the response. If 0 or less, defaults
      #     to the server's maximum allowed page size.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If non-empty, +page_token+ should contain a
      #     {Google::Spanner::V1::ListSessionsResponse#next_page_token next_page_token} from a previous
      #     {Google::Spanner::V1::ListSessionsResponse ListSessionsResponse}.
      # @!attribute [rw] filter
      #   @return [String]
      #     An expression for filtering the results of the request. Filter rules are
      #     case insensitive. The fields eligible for filtering are:
      #
      #     * +labels.key+ where key is the name of a label
      #
      #     Some examples of using filters are:
      #
      #     * +labels.env:*+ --> The session has the label "env".
      #       * +labels.env:dev+ --> The session has the label "env" and the value of
      #         the label contains the string "dev".
      class ListSessionsRequest; end

      # The response for {Google::Spanner::V1::Spanner::ListSessions ListSessions}.
      # @!attribute [rw] sessions
      #   @return [Array<Google::Spanner::V1::Session>]
      #     The list of requested sessions.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     +next_page_token+ can be sent in a subsequent
      #     {Google::Spanner::V1::Spanner::ListSessions ListSessions} call to fetch more of the matching
      #     sessions.
      class ListSessionsResponse; end

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
      #     of type +STRING+ both appear in {Google::Spanner::V1::ExecuteSqlRequest#params params} as JSON strings.
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
      #     {Google::Spanner::V1::ResultSetStats ResultSetStats}. If {Google::Spanner::V1::ExecuteSqlRequest#partition_token partition_token} is set, {Google::Spanner::V1::ExecuteSqlRequest#query_mode query_mode} can only
      #     be set to {Google::Spanner::V1::ExecuteSqlRequest::QueryMode::NORMAL QueryMode::NORMAL}.
      # @!attribute [rw] partition_token
      #   @return [String]
      #     If present, results will be restricted to the specified partition
      #     previously created using PartitionQuery().  There must be an exact
      #     match for the values of fields common to this message and the
      #     PartitionQueryRequest message used to create this partition_token.
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

      # Options for a PartitionQueryRequest and
      # PartitionReadRequest.
      # @!attribute [rw] partition_size_bytes
      #   @return [Integer]
      #     **Note:** This hint is currently ignored by PartitionQuery and
      #     PartitionRead requests.
      #
      #     The desired data size for each partition generated.  The default for this
      #     option is currently 1 GiB.  This is only a hint. The actual size of each
      #     partition may be smaller or larger than this size request.
      # @!attribute [rw] max_partitions
      #   @return [Integer]
      #     **Note:** This hint is currently ignored by PartitionQuery and
      #     PartitionRead requests.
      #
      #     The desired maximum number of partitions to return.  For example, this may
      #     be set to the number of workers available.  The default for this option
      #     is currently 10,000. The maximum value is currently 200,000.  This is only
      #     a hint.  The actual number of partitions returned may be smaller or larger
      #     than this maximum count request.
      class PartitionOptions; end

      # The request for {Google::Spanner::V1::Spanner::PartitionQuery PartitionQuery}
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session used to create the partitions.
      # @!attribute [rw] transaction
      #   @return [Google::Spanner::V1::TransactionSelector]
      #     Read only snapshot transactions are supported, read/write and single use
      #     transactions are not.
      # @!attribute [rw] sql
      #   @return [String]
      #     The query request to generate partitions for. The request will fail if
      #     the query is not root partitionable. The query plan of a root
      #     partitionable query has a single distributed union operator. A distributed
      #     union operator conceptually divides one or more tables into multiple
      #     splits, remotely evaluates a subquery independently on each split, and
      #     then unions all results.
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
      #     of type +STRING+ both appear in {Google::Spanner::V1::PartitionQueryRequest#params params} as JSON strings.
      #
      #     In these cases, +param_types+ can be used to specify the exact
      #     SQL type for some or all of the SQL query parameters. See the
      #     definition of {Google::Spanner::V1::Type Type} for more information
      #     about SQL types.
      # @!attribute [rw] partition_options
      #   @return [Google::Spanner::V1::PartitionOptions]
      #     Additional options that affect how many partitions are created.
      class PartitionQueryRequest; end

      # The request for {Google::Spanner::V1::Spanner::PartitionRead PartitionRead}
      # @!attribute [rw] session
      #   @return [String]
      #     Required. The session used to create the partitions.
      # @!attribute [rw] transaction
      #   @return [Google::Spanner::V1::TransactionSelector]
      #     Read only snapshot transactions are supported, read/write and single use
      #     transactions are not.
      # @!attribute [rw] table
      #   @return [String]
      #     Required. The name of the table in the database to be read.
      # @!attribute [rw] index
      #   @return [String]
      #     If non-empty, the name of an index on {Google::Spanner::V1::PartitionReadRequest#table table}. This index is
      #     used instead of the table primary key when interpreting {Google::Spanner::V1::PartitionReadRequest#key_set key_set}
      #     and sorting result rows. See {Google::Spanner::V1::PartitionReadRequest#key_set key_set} for further information.
      # @!attribute [rw] columns
      #   @return [Array<String>]
      #     The columns of {Google::Spanner::V1::PartitionReadRequest#table table} to be returned for each row matching
      #     this request.
      # @!attribute [rw] key_set
      #   @return [Google::Spanner::V1::KeySet]
      #     Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
      #     primary keys of the rows in {Google::Spanner::V1::PartitionReadRequest#table table} to be yielded, unless {Google::Spanner::V1::PartitionReadRequest#index index}
      #     is present. If {Google::Spanner::V1::PartitionReadRequest#index index} is present, then {Google::Spanner::V1::PartitionReadRequest#key_set key_set} instead names
      #     index keys in {Google::Spanner::V1::PartitionReadRequest#index index}.
      #
      #     It is not an error for the +key_set+ to name rows that do not
      #     exist in the database. Read yields nothing for nonexistent rows.
      # @!attribute [rw] partition_options
      #   @return [Google::Spanner::V1::PartitionOptions]
      #     Additional options that affect how many partitions are created.
      class PartitionReadRequest; end

      # Information returned for each partition returned in a
      # PartitionResponse.
      # @!attribute [rw] partition_token
      #   @return [String]
      #     This token can be passed to Read, StreamingRead, ExecuteSql, or
      #     ExecuteStreamingSql requests to restrict the results to those identified by
      #     this partition token.
      class Partition; end

      # The response for {Google::Spanner::V1::Spanner::PartitionQuery PartitionQuery}
      # or {Google::Spanner::V1::Spanner::PartitionRead PartitionRead}
      # @!attribute [rw] partitions
      #   @return [Array<Google::Spanner::V1::Partition>]
      #     Partitions created by this request.
      # @!attribute [rw] transaction
      #   @return [Google::Spanner::V1::Transaction]
      #     Transaction created by this request.
      class PartitionResponse; end

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
      #     If non-empty, the name of an index on {Google::Spanner::V1::ReadRequest#table table}. This index is
      #     used instead of the table primary key when interpreting {Google::Spanner::V1::ReadRequest#key_set key_set}
      #     and sorting result rows. See {Google::Spanner::V1::ReadRequest#key_set key_set} for further information.
      # @!attribute [rw] columns
      #   @return [Array<String>]
      #     The columns of {Google::Spanner::V1::ReadRequest#table table} to be returned for each row matching
      #     this request.
      # @!attribute [rw] key_set
      #   @return [Google::Spanner::V1::KeySet]
      #     Required. +key_set+ identifies the rows to be yielded. +key_set+ names the
      #     primary keys of the rows in {Google::Spanner::V1::ReadRequest#table table} to be yielded, unless {Google::Spanner::V1::ReadRequest#index index}
      #     is present. If {Google::Spanner::V1::ReadRequest#index index} is present, then {Google::Spanner::V1::ReadRequest#key_set key_set} instead names
      #     index keys in {Google::Spanner::V1::ReadRequest#index index}.
      #
      #     If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is empty, rows are yielded
      #     in table primary key order (if {Google::Spanner::V1::ReadRequest#index index} is empty) or index key order
      #     (if {Google::Spanner::V1::ReadRequest#index index} is non-empty).  If the {Google::Spanner::V1::ReadRequest#partition_token partition_token} field is not
      #     empty, rows will be yielded in an unspecified order.
      #
      #     It is not an error for the +key_set+ to name rows that do not
      #     exist in the database. Read yields nothing for nonexistent rows.
      # @!attribute [rw] limit
      #   @return [Integer]
      #     If greater than zero, only the first +limit+ rows are yielded. If +limit+
      #     is zero, the default is no limit. A limit cannot be specified if
      #     +partition_token+ is set.
      # @!attribute [rw] resume_token
      #   @return [String]
      #     If this request is resuming a previously interrupted read,
      #     +resume_token+ should be copied from the last
      #     {Google::Spanner::V1::PartialResultSet PartialResultSet} yielded before the interruption. Doing this
      #     enables the new read to resume where the last read left off. The
      #     rest of the request parameters must exactly match the request
      #     that yielded this token.
      # @!attribute [rw] partition_token
      #   @return [String]
      #     If present, results will be restricted to the specified partition
      #     previously created using PartitionRead().    There must be an exact
      #     match for the values of fields common to this message and the
      #     PartitionReadRequest message used to create this partition_token.
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