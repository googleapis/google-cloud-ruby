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


module Google
  module Firestore
    module Admin
      module V1
        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::CreateIndex FirestoreAdmin::CreateIndex}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. A parent name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
        # @!attribute [rw] index
        #   @return [Google::Firestore::Admin::V1::Index]
        #     Required. The composite index to create.
        class CreateIndexRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::ListIndexes FirestoreAdmin::ListIndexes}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. A parent name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
        # @!attribute [rw] filter
        #   @return [String]
        #     The filter to apply to list results.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     The number of results to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     A page token, returned from a previous call to
        #     {Google::Firestore::Admin::V1::FirestoreAdmin::ListIndexes FirestoreAdmin::ListIndexes}, that may be used to get the next
        #     page of results.
        class ListIndexesRequest; end

        # The response for {Google::Firestore::Admin::V1::FirestoreAdmin::ListIndexes FirestoreAdmin::ListIndexes}.
        # @!attribute [rw] indexes
        #   @return [Array<Google::Firestore::Admin::V1::Index>]
        #     The requested indexes.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A page token that may be used to request another page of results. If blank,
        #     this is the last page.
        class ListIndexesResponse; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::GetIndex FirestoreAdmin::GetIndex}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. A name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/indexes/{index_id}`
        class GetIndexRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::DeleteIndex FirestoreAdmin::DeleteIndex}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. A name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/indexes/{index_id}`
        class DeleteIndexRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::UpdateField FirestoreAdmin::UpdateField}.
        # @!attribute [rw] field
        #   @return [Google::Firestore::Admin::V1::Field]
        #     Required. The field to be updated.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     A mask, relative to the field. If specified, only configuration specified
        #     by this field_mask will be updated in the field.
        class UpdateFieldRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::GetField FirestoreAdmin::GetField}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. A name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/fields/{field_id}`
        class GetFieldRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. A parent name of the form
        #     `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}`
        # @!attribute [rw] filter
        #   @return [String]
        #     The filter to apply to list results. Currently,
        #     {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} only supports listing fields
        #     that have been explicitly overridden. To issue this query, call
        #     {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields} with the filter set to
        #     `indexConfig.usesAncestorConfig:false`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     The number of results to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     A page token, returned from a previous call to
        #     {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields}, that may be used to get the next
        #     page of results.
        class ListFieldsRequest; end

        # The response for {Google::Firestore::Admin::V1::FirestoreAdmin::ListFields FirestoreAdmin::ListFields}.
        # @!attribute [rw] fields
        #   @return [Array<Google::Firestore::Admin::V1::Field>]
        #     The requested fields.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A page token that may be used to request another page of results. If blank,
        #     this is the last page.
        class ListFieldsResponse; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::ExportDocuments FirestoreAdmin::ExportDocuments}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. Database to export. Should be of the form:
        #     `projects/{project_id}/databases/{database_id}`.
        # @!attribute [rw] collection_ids
        #   @return [Array<String>]
        #     Which collection ids to export. Unspecified means all collections.
        # @!attribute [rw] output_uri_prefix
        #   @return [String]
        #     The output URI. Currently only supports Google Cloud Storage URIs of the
        #     form: `gs://BUCKET_NAME[/NAMESPACE_PATH]`, where `BUCKET_NAME` is the name
        #     of the Google Cloud Storage bucket and `NAMESPACE_PATH` is an optional
        #     Google Cloud Storage namespace path. When
        #     choosing a name, be sure to consider Google Cloud Storage naming
        #     guidelines: https://cloud.google.com/storage/docs/naming.
        #     If the URI is a bucket (without a namespace path), a prefix will be
        #     generated based on the start time.
        class ExportDocumentsRequest; end

        # The request for {Google::Firestore::Admin::V1::FirestoreAdmin::ImportDocuments FirestoreAdmin::ImportDocuments}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. Database to import into. Should be of the form:
        #     `projects/{project_id}/databases/{database_id}`.
        # @!attribute [rw] collection_ids
        #   @return [Array<String>]
        #     Which collection ids to import. Unspecified means all collections included
        #     in the import.
        # @!attribute [rw] input_uri_prefix
        #   @return [String]
        #     Location of the exported files.
        #     This must match the output_uri_prefix of an ExportDocumentsResponse from
        #     an export that has completed successfully.
        #     See:
        #     {Google::Firestore::Admin::V1::ExportDocumentsResponse#output_uri_prefix}.
        class ImportDocumentsRequest; end
      end
    end
  end
end