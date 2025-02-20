# Copyright 2020 Google LLC
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

require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/firestore"
require "google/cloud/firestore/admin/v1"
require "securerandom"

# Create shared FirestoreAdmin client object for tests.
$firestore_admin = Google::Cloud::Firestore::Admin::V1::FirestoreAdmin::Client.new

def delete_collection_test collection_name:, project_id:
  firestore = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end

def random_name prefix
  "#{prefix}_#{SecureRandom.hex 4}"
end

##
# Creates a composite index, given a project_id and collection_path.
#
# NOTE: Currently, only `density` and `population` fields are supported.
#
# @param project_id [String] The Cloud Platform project ID that the collection belongs to.
# @param collection_path [String] A string representing the path of the collection,
#   relative to the document.
#
# @return [String, nil] The name assigned to the newly created index.
def create_composite_index project_id:, collection_path:
  order = Google::Cloud::Firestore::Admin::V1::Index::IndexField::Order::ASCENDING

  index_fields = [
    Google::Cloud::Firestore::Admin::V1::Index::IndexField.new(field_path: "density", order: order),
    Google::Cloud::Firestore::Admin::V1::Index::IndexField.new(field_path: "population", order: order)
  ]

  scope = Google::Cloud::Firestore::Admin::V1::Index::QueryScope::COLLECTION
  index = Google::Cloud::Firestore::Admin::V1::Index.new query_scope: scope, fields: index_fields
  parent = "projects/#{project_id}/databases/(default)/collectionGroups/#{collection_path}"
  request = Google::Cloud::Firestore::Admin::V1::CreateIndexRequest.new parent: parent, index: index
  result = $firestore_admin.create_index request
  result.wait_until_done!
  result.response? ? result.response.name : nil
end

##
# Deletes a composite index.
#
# @param name [String] The index's name to be deleted, of the form
#  `projects/{project_id}/databases/{database_id}/collectionGroups/{collection_id}/indexes/{index_id}`.
#
# @return [Google::Protobuf::Empty]
def delete_composite_index name:
  request = Google::Cloud::Firestore::Admin::V1::DeleteIndexRequest.new name: name
  $firestore_admin.delete_index request
end
