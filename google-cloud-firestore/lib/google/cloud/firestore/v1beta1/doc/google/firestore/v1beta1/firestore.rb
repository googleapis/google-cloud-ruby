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
  module Firestore
    module V1beta1
      # The request for {Google::Firestore::V1beta1::Firestore::GetDocument Firestore::GetDocument}.
      # @!attribute [rw] name
      #   @return [String]
      #     The resource name of the Document to get. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      # @!attribute [rw] mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to return. If not set, returns all fields.
      #
      #     If the document has a field that is not present in this mask, that field
      #     will not be returned in the response.
      # @!attribute [rw] transaction
      #   @return [String]
      #     Reads the document in a transaction.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     Reads the version of the document at the given time.
      #     This may not be older than 60 seconds.
      class GetDocumentRequest; end

      # The request for {Google::Firestore::V1beta1::Firestore::ListDocuments Firestore::ListDocuments}.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent resource name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents+ or
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      #     For example:
      #     +projects/my-project/databases/my-database/documents+ or
      #     +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
      # @!attribute [rw] collection_id
      #   @return [String]
      #     The collection ID, relative to +parent+, to list. For example: +chatrooms+
      #     or +messages+.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of documents to return.
      # @!attribute [rw] page_token
      #   @return [String]
      #     The +next_page_token+ value returned from a previous List request, if any.
      # @!attribute [rw] order_by
      #   @return [String]
      #     The order to sort results by. For example: +priority desc, name+.
      # @!attribute [rw] mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to return. If not set, returns all fields.
      #
      #     If a document has a field that is not present in this mask, that field
      #     will not be returned in the response.
      # @!attribute [rw] transaction
      #   @return [String]
      #     Reads documents in a transaction.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     Reads documents as they were at the given time.
      #     This may not be older than 60 seconds.
      # @!attribute [rw] show_missing
      #   @return [true, false]
      #     If the list should show missing documents. A missing document is a
      #     document that does not exist but has sub-documents. These documents will
      #     be returned with a key but will not have fields, {Google::Firestore::V1beta1::Document#create_time Document#create_time},
      #     or {Google::Firestore::V1beta1::Document#update_time Document#update_time} set.
      #
      #     Requests with +show_missing+ may not specify +where+ or
      #     +order_by+.
      class ListDocumentsRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::ListDocuments Firestore::ListDocuments}.
      # @!attribute [rw] documents
      #   @return [Array<Google::Firestore::V1beta1::Document>]
      #     The Documents found.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     The next page token.
      class ListDocumentsResponse; end

      # The request for {Google::Firestore::V1beta1::Firestore::CreateDocument Firestore::CreateDocument}.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent resource. For example:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents+ or
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/chatrooms/\\{chatroom_id}+
      # @!attribute [rw] collection_id
      #   @return [String]
      #     The collection ID, relative to +parent+, to list. For example: +chatrooms+.
      # @!attribute [rw] document_id
      #   @return [String]
      #     The client-assigned document ID to use for this document.
      #
      #     Optional. If not specified, an ID will be assigned by the service.
      # @!attribute [rw] document
      #   @return [Google::Firestore::V1beta1::Document]
      #     The document to create. +name+ must not be set.
      # @!attribute [rw] mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to return. If not set, returns all fields.
      #
      #     If the document has a field that is not present in this mask, that field
      #     will not be returned in the response.
      class CreateDocumentRequest; end

      # The request for {Google::Firestore::V1beta1::Firestore::UpdateDocument Firestore::UpdateDocument}.
      # @!attribute [rw] document
      #   @return [Google::Firestore::V1beta1::Document]
      #     The updated document.
      #     Creates the document if it does not already exist.
      # @!attribute [rw] update_mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to update.
      #     None of the field paths in the mask may contain a reserved name.
      #
      #     If the document exists on the server and has fields not referenced in the
      #     mask, they are left unchanged.
      #     Fields referenced in the mask, but not present in the input document, are
      #     deleted from the document on the server.
      # @!attribute [rw] mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to return. If not set, returns all fields.
      #
      #     If the document has a field that is not present in this mask, that field
      #     will not be returned in the response.
      # @!attribute [rw] current_document
      #   @return [Google::Firestore::V1beta1::Precondition]
      #     An optional precondition on the document.
      #     The request will fail if this is set and not met by the target document.
      class UpdateDocumentRequest; end

      # The request for {Google::Firestore::V1beta1::Firestore::DeleteDocument Firestore::DeleteDocument}.
      # @!attribute [rw] name
      #   @return [String]
      #     The resource name of the Document to delete. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      # @!attribute [rw] current_document
      #   @return [Google::Firestore::V1beta1::Precondition]
      #     An optional precondition on the document.
      #     The request will fail if this is set and not met by the target document.
      class DeleteDocumentRequest; end

      # The request for {Google::Firestore::V1beta1::Firestore::BatchGetDocuments Firestore::BatchGetDocuments}.
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      # @!attribute [rw] documents
      #   @return [Array<String>]
      #     The names of the documents to retrieve. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      #     The request will fail if any of the document is not a child resource of the
      #     given +database+. Duplicate names will be elided.
      # @!attribute [rw] mask
      #   @return [Google::Firestore::V1beta1::DocumentMask]
      #     The fields to return. If not set, returns all fields.
      #
      #     If a document has a field that is not present in this mask, that field will
      #     not be returned in the response.
      # @!attribute [rw] transaction
      #   @return [String]
      #     Reads documents in a transaction.
      # @!attribute [rw] new_transaction
      #   @return [Google::Firestore::V1beta1::TransactionOptions]
      #     Starts a new transaction and reads the documents.
      #     Defaults to a read-only transaction.
      #     The new transaction ID will be returned as the first response in the
      #     stream.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     Reads documents as they were at the given time.
      #     This may not be older than 60 seconds.
      class BatchGetDocumentsRequest; end

      # The streamed response for {Google::Firestore::V1beta1::Firestore::BatchGetDocuments Firestore::BatchGetDocuments}.
      # @!attribute [rw] found
      #   @return [Google::Firestore::V1beta1::Document]
      #     A document that was requested.
      # @!attribute [rw] missing
      #   @return [String]
      #     A document name that was requested but does not exist. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction that was started as part of this request.
      #     Will only be set in the first response, and only if
      #     {Google::Firestore::V1beta1::BatchGetDocumentsRequest#new_transaction BatchGetDocumentsRequest#new_transaction} was set in the request.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     The time at which the document was read.
      #     This may be monotically increasing, in this case the previous documents in
      #     the result stream are guaranteed not to have changed between their
      #     read_time and this one.
      class BatchGetDocumentsResponse; end

      # The request for {Google::Firestore::V1beta1::Firestore::BeginTransaction Firestore::BeginTransaction}.
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      # @!attribute [rw] options
      #   @return [Google::Firestore::V1beta1::TransactionOptions]
      #     The options for the transaction.
      #     Defaults to a read-write transaction.
      class BeginTransactionRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::BeginTransaction Firestore::BeginTransaction}.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction that was started.
      class BeginTransactionResponse; end

      # The request for {Google::Firestore::V1beta1::Firestore::Commit Firestore::Commit}.
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      # @!attribute [rw] writes
      #   @return [Array<Google::Firestore::V1beta1::Write>]
      #     The writes to apply.
      #
      #     Always executed atomically and in order.
      # @!attribute [rw] transaction
      #   @return [String]
      #     If set, applies all writes in this transaction, and commits it.
      class CommitRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::Commit Firestore::Commit}.
      # @!attribute [rw] write_results
      #   @return [Array<Google::Firestore::V1beta1::WriteResult>]
      #     The result of applying the writes.
      #
      #     This i-th write result corresponds to the i-th write in the
      #     request.
      # @!attribute [rw] commit_time
      #   @return [Google::Protobuf::Timestamp]
      #     The time at which the commit occurred.
      class CommitResponse; end

      # The request for {Google::Firestore::V1beta1::Firestore::Rollback Firestore::Rollback}.
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction to roll back.
      class RollbackRequest; end

      # The request for {Google::Firestore::V1beta1::Firestore::RunQuery Firestore::RunQuery}.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent resource name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents+ or
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      #     For example:
      #     +projects/my-project/databases/my-database/documents+ or
      #     +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
      # @!attribute [rw] structured_query
      #   @return [Google::Firestore::V1beta1::StructuredQuery]
      #     A structured query.
      # @!attribute [rw] transaction
      #   @return [String]
      #     Reads documents in a transaction.
      # @!attribute [rw] new_transaction
      #   @return [Google::Firestore::V1beta1::TransactionOptions]
      #     Starts a new transaction and reads the documents.
      #     Defaults to a read-only transaction.
      #     The new transaction ID will be returned as the first response in the
      #     stream.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     Reads documents as they were at the given time.
      #     This may not be older than 60 seconds.
      class RunQueryRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::RunQuery Firestore::RunQuery}.
      # @!attribute [rw] transaction
      #   @return [String]
      #     The transaction that was started as part of this request.
      #     Can only be set in the first response, and only if
      #     {Google::Firestore::V1beta1::RunQueryRequest#new_transaction RunQueryRequest#new_transaction} was set in the request.
      #     If set, no other fields will be set in this response.
      # @!attribute [rw] document
      #   @return [Google::Firestore::V1beta1::Document]
      #     A query result.
      #     Not set when reporting partial progress.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     The time at which the document was read. This may be monotonically
      #     increasing; in this case, the previous documents in the result stream are
      #     guaranteed not to have changed between their +read_time+ and this one.
      #
      #     If the query returns no results, a response with +read_time+ and no
      #     +document+ will be sent, and this represents the time at which the query
      #     was run.
      # @!attribute [rw] skipped_results
      #   @return [Integer]
      #     The number of results that have been skipped due to an offset between
      #     the last response and the current response.
      class RunQueryResponse; end

      # The request for {Google::Firestore::V1beta1::Firestore::Write Firestore::Write}.
      #
      # The first request creates a stream, or resumes an existing one from a token.
      #
      # When creating a new stream, the server replies with a response containing
      # only an ID and a token, to use in the next request.
      #
      # When resuming a stream, the server first streams any responses later than the
      # given token, then a response containing only an up-to-date token, to use in
      # the next request.
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      #     This is only required in the first message.
      # @!attribute [rw] stream_id
      #   @return [String]
      #     The ID of the write stream to resume.
      #     This may only be set in the first message. When left empty, a new write
      #     stream will be created.
      # @!attribute [rw] writes
      #   @return [Array<Google::Firestore::V1beta1::Write>]
      #     The writes to apply.
      #
      #     Always executed atomically and in order.
      #     This must be empty on the first request.
      #     This may be empty on the last request.
      #     This must not be empty on all other requests.
      # @!attribute [rw] stream_token
      #   @return [String]
      #     A stream token that was previously sent by the server.
      #
      #     The client should set this field to the token from the most recent
      #     {Google::Firestore::V1beta1::WriteResponse WriteResponse} it has received. This acknowledges that the client has
      #     received responses up to this token. After sending this token, earlier
      #     tokens may not be used anymore.
      #
      #     The server may close the stream if there are too many unacknowledged
      #     responses.
      #
      #     Leave this field unset when creating a new stream. To resume a stream at
      #     a specific point, set this field and the +stream_id+ field.
      #
      #     Leave this field unset when creating a new stream.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     Labels associated with this write request.
      class WriteRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::Write Firestore::Write}.
      # @!attribute [rw] stream_id
      #   @return [String]
      #     The ID of the stream.
      #     Only set on the first message, when a new stream was created.
      # @!attribute [rw] stream_token
      #   @return [String]
      #     A token that represents the position of this response in the stream.
      #     This can be used by a client to resume the stream at this point.
      #
      #     This field is always set.
      # @!attribute [rw] write_results
      #   @return [Array<Google::Firestore::V1beta1::WriteResult>]
      #     The result of applying the writes.
      #
      #     This i-th write result corresponds to the i-th write in the
      #     request.
      # @!attribute [rw] commit_time
      #   @return [Google::Protobuf::Timestamp]
      #     The time at which the commit occurred.
      class WriteResponse; end

      # A request for {Google::Firestore::V1beta1::Firestore::Listen Firestore::Listen}
      # @!attribute [rw] database
      #   @return [String]
      #     The database name. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}+.
      # @!attribute [rw] add_target
      #   @return [Google::Firestore::V1beta1::Target]
      #     A target to add to this stream.
      # @!attribute [rw] remove_target
      #   @return [Integer]
      #     The ID of a target to remove from this stream.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     Labels associated with this target change.
      class ListenRequest; end

      # The response for {Google::Firestore::V1beta1::Firestore::Listen Firestore::Listen}.
      # @!attribute [rw] target_change
      #   @return [Google::Firestore::V1beta1::TargetChange]
      #     Targets have changed.
      # @!attribute [rw] document_change
      #   @return [Google::Firestore::V1beta1::DocumentChange]
      #     A {Google::Firestore::V1beta1::Document Document} has changed.
      # @!attribute [rw] document_delete
      #   @return [Google::Firestore::V1beta1::DocumentDelete]
      #     A {Google::Firestore::V1beta1::Document Document} has been deleted.
      # @!attribute [rw] document_remove
      #   @return [Google::Firestore::V1beta1::DocumentRemove]
      #     A {Google::Firestore::V1beta1::Document Document} has been removed from a target (because it is no longer
      #     relevant to that target).
      # @!attribute [rw] filter
      #   @return [Google::Firestore::V1beta1::ExistenceFilter]
      #     A filter to apply to the set of documents previously returned for the
      #     given target.
      #
      #     Returned when documents may have been removed from the given target, but
      #     the exact documents are unknown.
      class ListenResponse; end

      # A specification of a set of documents to listen to.
      # @!attribute [rw] query
      #   @return [Google::Firestore::V1beta1::Target::QueryTarget]
      #     A target specified by a query.
      # @!attribute [rw] documents
      #   @return [Google::Firestore::V1beta1::Target::DocumentsTarget]
      #     A target specified by a set of document names.
      # @!attribute [rw] resume_token
      #   @return [String]
      #     A resume token from a prior {Google::Firestore::V1beta1::TargetChange TargetChange} for an identical target.
      #
      #     Using a resume token with a different target is unsupported and may fail.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     Start listening after a specific +read_time+.
      #
      #     The client must know the state of matching documents at this time.
      # @!attribute [rw] target_id
      #   @return [Integer]
      #     A client provided target ID.
      #
      #     If not set, the server will assign an ID for the target.
      #
      #     Used for resuming a target without changing IDs. The IDs can either be
      #     client-assigned or be server-assigned in a previous stream. All targets
      #     with client provided IDs must be added before adding a target that needs
      #     a server-assigned id.
      # @!attribute [rw] once
      #   @return [true, false]
      #     If the target should be removed once it is current and consistent.
      class Target
        # A target specified by a set of documents names.
        # @!attribute [rw] documents
        #   @return [Array<String>]
        #     The names of the documents to retrieve. In the format:
        #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
        #     The request will fail if any of the document is not a child resource of
        #     the given +database+. Duplicate names will be elided.
        class DocumentsTarget; end

        # A target specified by a query.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name. In the format:
        #     +projects/\\{project_id}/databases/\\{database_id}/documents+ or
        #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
        #     For example:
        #     +projects/my-project/databases/my-database/documents+ or
        #     +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
        # @!attribute [rw] structured_query
        #   @return [Google::Firestore::V1beta1::StructuredQuery]
        #     A structured query.
        class QueryTarget; end
      end

      # Targets being watched have changed.
      # @!attribute [rw] target_change_type
      #   @return [Google::Firestore::V1beta1::TargetChange::TargetChangeType]
      #     The type of change that occurred.
      # @!attribute [rw] target_ids
      #   @return [Array<Integer>]
      #     The target IDs of targets that have changed.
      #
      #     If empty, the change applies to all targets.
      #
      #     For +target_change_type=ADD+, the order of the target IDs matches the order
      #     of the requests to add the targets. This allows clients to unambiguously
      #     associate server-assigned target IDs with added targets.
      #
      #     For other states, the order of the target IDs is not defined.
      # @!attribute [rw] cause
      #   @return [Google::Rpc::Status]
      #     The error that resulted in this change, if applicable.
      # @!attribute [rw] resume_token
      #   @return [String]
      #     A token that can be used to resume the stream for the given +target_ids+,
      #     or all targets if +target_ids+ is empty.
      #
      #     Not set on every target change.
      # @!attribute [rw] read_time
      #   @return [Google::Protobuf::Timestamp]
      #     The consistent +read_time+ for the given +target_ids+ (omitted when the
      #     target_ids are not at a consistent snapshot).
      #
      #     The stream is guaranteed to send a +read_time+ with +target_ids+ empty
      #     whenever the entire stream reaches a new consistent snapshot. ADD,
      #     CURRENT, and RESET messages are guaranteed to (eventually) result in a
      #     new consistent snapshot (while NO_CHANGE and REMOVE messages are not).
      #
      #     For a given stream, +read_time+ is guaranteed to be monotonically
      #     increasing.
      class TargetChange
        # The type of change.
        module TargetChangeType
          # No change has occurred. Used only to send an updated +resume_token+.
          NO_CHANGE = 0

          # The targets have been added.
          ADD = 1

          # The targets have been removed.
          REMOVE = 2

          # The targets reflect all changes committed before the targets were added
          # to the stream.
          #
          # This will be sent after or with a +read_time+ that is greater than or
          # equal to the time at which the targets were added.
          #
          # Listeners can wait for this change if read-after-write semantics
          # are desired.
          CURRENT = 3

          # The targets have been reset, and a new initial state for the targets
          # will be returned in subsequent changes.
          #
          # After the initial state is complete, +CURRENT+ will be returned even
          # if the target was previously indicated to be +CURRENT+.
          RESET = 4
        end
      end

      # The request for {Google::Firestore::V1beta1::Firestore::ListCollectionIds Firestore::ListCollectionIds}.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent document. In the format:
      #     +projects/\\{project_id}/databases/\\{database_id}/documents/\\{document_path}+.
      #     For example:
      #     +projects/my-project/databases/my-database/documents/chatrooms/my-chatroom+
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of results to return.
      # @!attribute [rw] page_token
      #   @return [String]
      #     A page token. Must be a value from
      #     {Google::Firestore::V1beta1::ListCollectionIdsResponse ListCollectionIdsResponse}.
      class ListCollectionIdsRequest; end

      # The response from {Google::Firestore::V1beta1::Firestore::ListCollectionIds Firestore::ListCollectionIds}.
      # @!attribute [rw] collection_ids
      #   @return [Array<String>]
      #     The collection ids.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     A page token that may be used to continue the list.
      class ListCollectionIdsResponse; end
    end
  end
end