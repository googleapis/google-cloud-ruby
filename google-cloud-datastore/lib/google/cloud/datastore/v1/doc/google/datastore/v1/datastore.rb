# Copyright 2017 Google LLC
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
  module Datastore
    ##
    # # Google Cloud Datastore API Contents
    #
    # | Class | Description |
    # | ----- | ----------- |
    # | [DatastoreClient][] | Accesses the schemaless NoSQL database to provide fully managed, robust, scalable storage for your application. |
    # | [Data Types][] | Data types for Google::Cloud::Datastore::V1 |
    #
    # [DatastoreClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-datastore/latest/google/datastore/v1/datastoreclient
    # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-datastore/latest/google/datastore/v1/datatypes
    #
    module V1
      # The request for {Google::Datastore::V1::Datastore::Lookup Datastore::Lookup}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] read_options
      #   @return [Google::Datastore::V1::ReadOptions]
      #     The options for this lookup request.
      # @!attribute [rw] keys
      #   @return [Array<Google::Datastore::V1::Key>]
      #     Keys of entities to look up.
      class LookupRequest; end

      # The response for {Google::Datastore::V1::Datastore::Lookup Datastore::Lookup}.
      # @!attribute [rw] found
      #   @return [Array<Google::Datastore::V1::EntityResult>]
      #     Entities found as +ResultType.FULL+ entities. The order of results in this
      #     field is undefined and has no relation to the order of the keys in the
      #     input.
      # @!attribute [rw] missing
      #   @return [Array<Google::Datastore::V1::EntityResult>]
      #     Entities not found as +ResultType.KEY_ONLY+ entities. The order of results
      #     in this field is undefined and has no relation to the order of the keys
      #     in the input.
      # @!attribute [rw] deferred
      #   @return [Array<Google::Datastore::V1::Key>]
      #     A list of keys that were not looked up due to resource constraints. The
      #     order of results in this field is undefined and has no relation to the
      #     order of the keys in the input.
      class LookupResponse; end

      # The request for {Google::Datastore::V1::Datastore::RunQuery Datastore::RunQuery}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] partition_id
      #   @return [Google::Datastore::V1::PartitionId]
      #     Entities are partitioned into subsets, identified by a partition ID.
      #     Queries are scoped to a single partition.
      #     This partition ID is normalized with the standard default context
      #     partition ID.
      # @!attribute [rw] read_options
      #   @return [Google::Datastore::V1::ReadOptions]
      #     The options for this query.
      # @!attribute [rw] query
      #   @return [Google::Datastore::V1::Query]
      #     The query to run.
      # @!attribute [rw] gql_query
      #   @return [Google::Datastore::V1::GqlQuery]
      #     The GQL query to run.
      class RunQueryRequest; end

      # The response for {Google::Datastore::V1::Datastore::RunQuery Datastore::RunQuery}.
      # @!attribute [rw] batch
      #   @return [Google::Datastore::V1::QueryResultBatch]
      #     A batch of query results (always present).
      # @!attribute [rw] query
      #   @return [Google::Datastore::V1::Query]
      #     The parsed form of the +GqlQuery+ from the request, if it was set.
      class RunQueryResponse; end

      # The request for {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] transaction_options
      #   @return [Google::Datastore::V1::TransactionOptions]
      #     Options for a new transaction.
      class BeginTransactionRequest; end

      # The response for {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction identifier (always present).
      class BeginTransactionResponse; end

      # The request for {Google::Datastore::V1::Datastore::Rollback Datastore::Rollback}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction identifier, returned by a call to
      #     {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
      class RollbackRequest; end

      # The response for {Google::Datastore::V1::Datastore::Rollback Datastore::Rollback}.
      # (an empty message).
      class RollbackResponse; end

      # The request for {Google::Datastore::V1::Datastore::Commit Datastore::Commit}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] mode
      #   @return [Google::Datastore::V1::CommitRequest::Mode]
      #     The type of commit to perform. Defaults to +TRANSACTIONAL+.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The identifier of the transaction associated with the commit. A
      #     transaction identifier is returned by a call to
      #     {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
      # @!attribute [rw] mutations
      #   @return [Array<Google::Datastore::V1::Mutation>]
      #     The mutations to perform.
      #
      #     When mode is +TRANSACTIONAL+, mutations affecting a single entity are
      #     applied in order. The following sequences of mutations affecting a single
      #     entity are not permitted in a single +Commit+ request:
      #
      #     * +insert+ followed by +insert+
      #     * +update+ followed by +insert+
      #     * +upsert+ followed by +insert+
      #     * +delete+ followed by +update+
      #
      #     When mode is +NON_TRANSACTIONAL+, no two mutations may affect a single
      #     entity.
      class CommitRequest
        # The modes available for commits.
        module Mode
          # Unspecified. This value must not be used.
          MODE_UNSPECIFIED = 0

          # Transactional: The mutations are either all applied, or none are applied.
          # Learn about transactions [here](https://cloud.google.com/datastore/docs/concepts/transactions).
          TRANSACTIONAL = 1

          # Non-transactional: The mutations may not apply as all or none.
          NON_TRANSACTIONAL = 2
        end
      end

      # The response for {Google::Datastore::V1::Datastore::Commit Datastore::Commit}.
      # @!attribute [rw] mutation_results
      #   @return [Array<Google::Datastore::V1::MutationResult>]
      #     The result of performing the mutations.
      #     The i-th mutation result corresponds to the i-th mutation in the request.
      # @!attribute [rw] index_updates
      #   @return [Integer]
      #     The number of index entries updated during the commit, or zero if none were
      #     updated.
      class CommitResponse; end

      # The request for {Google::Datastore::V1::Datastore::AllocateIds Datastore::AllocateIds}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] keys
      #   @return [Array<Google::Datastore::V1::Key>]
      #     A list of keys with incomplete key paths for which to allocate IDs.
      #     No key may be reserved/read-only.
      class AllocateIdsRequest; end

      # The response for {Google::Datastore::V1::Datastore::AllocateIds Datastore::AllocateIds}.
      # @!attribute [rw] keys
      #   @return [Array<Google::Datastore::V1::Key>]
      #     The keys specified in the request (in the same order), each with
      #     its key path completed with a newly allocated ID.
      class AllocateIdsResponse; end

      # The request for {Google::Datastore::V1::Datastore::ReserveIds Datastore::ReserveIds}.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project against which to make the request.
      # @!attribute [rw] database_id
      #   @return [String]
      #     If not empty, the ID of the database against which to make the request.
      # @!attribute [rw] keys
      #   @return [Array<Google::Datastore::V1::Key>]
      #     A list of keys with complete key paths whose numeric IDs should not be
      #     auto-allocated.
      class ReserveIdsRequest; end

      # The response for {Google::Datastore::V1::Datastore::ReserveIds Datastore::ReserveIds}.
      class ReserveIdsResponse; end

      # A mutation to apply to an entity.
      # @!attribute [rw] insert
      #   @return [Google::Datastore::V1::Entity]
      #     The entity to insert. The entity must not already exist.
      #     The entity key's final path element may be incomplete.
      # @!attribute [rw] update
      #   @return [Google::Datastore::V1::Entity]
      #     The entity to update. The entity must already exist.
      #     Must have a complete key path.
      # @!attribute [rw] upsert
      #   @return [Google::Datastore::V1::Entity]
      #     The entity to upsert. The entity may or may not already exist.
      #     The entity key's final path element may be incomplete.
      # @!attribute [rw] delete
      #   @return [Google::Datastore::V1::Key]
      #     The key of the entity to delete. The entity may or may not already exist.
      #     Must have a complete key path and must not be reserved/read-only.
      # @!attribute [rw] base_version
      #   @return [Integer]
      #     The version of the entity that this mutation is being applied to. If this
      #     does not match the current version on the server, the mutation conflicts.
      class Mutation; end

      # The result of applying a mutation.
      # @!attribute [rw] key
      #   @return [Google::Datastore::V1::Key]
      #     The automatically allocated key.
      #     Set only when the mutation allocated a key.
      # @!attribute [rw] version
      #   @return [Integer]
      #     The version of the entity on the server after processing the mutation. If
      #     the mutation doesn't change anything on the server, then the version will
      #     be the version of the current entity or, if no entity is present, a version
      #     that is strictly greater than the version of any previous entity and less
      #     than the version of any possible future entity.
      # @!attribute [rw] conflict_detected
      #   @return [true, false]
      #     Whether a conflict was detected for this mutation. Always false when a
      #     conflict detection strategy field is not set in the mutation.
      class MutationResult; end

      # The options shared by read requests.
      # @!attribute [rw] read_consistency
      #   @return [Google::Datastore::V1::ReadOptions::ReadConsistency]
      #     The non-transactional read consistency to use.
      #     Cannot be set to +STRONG+ for global queries.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The identifier of the transaction in which to read. A
      #     transaction identifier is returned by a call to
      #     {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction}.
      class ReadOptions
        # The possible values for read consistencies.
        module ReadConsistency
          # Unspecified. This value must not be used.
          READ_CONSISTENCY_UNSPECIFIED = 0

          # Strong consistency.
          STRONG = 1

          # Eventual consistency.
          EVENTUAL = 2
        end
      end

      # Options for beginning a new transaction.
      #
      # Transactions can be created explicitly with calls to
      # {Google::Datastore::V1::Datastore::BeginTransaction Datastore::BeginTransaction} or implicitly by setting
      # {Google::Datastore::V1::ReadOptions#new_transaction ReadOptions#new_transaction} in read requests.
      # @!attribute [rw] read_write
      #   @return [Google::Datastore::V1::TransactionOptions::ReadWrite]
      #     The transaction should allow both reads and writes.
      # @!attribute [rw] read_only
      #   @return [Google::Datastore::V1::TransactionOptions::ReadOnly]
      #     The transaction should only allow reads.
      class TransactionOptions
        # Options specific to read / write transactions.
        # @!attribute [rw] previous_transaction
        #   @return [String]
        #     The transaction identifier of the transaction being retried.
        class ReadWrite; end

        # Options specific to read-only transactions.
        class ReadOnly; end
      end
    end
  end
end