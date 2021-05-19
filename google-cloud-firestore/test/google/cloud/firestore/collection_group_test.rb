# Copyright 2021 Google LLC
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

require "helper"

describe Google::Cloud::Firestore::CollectionGroup, :mock_firestore do
  let(:collection_id) { "my-collection-id" }
  let(:collection_group) do
    Google::Cloud::Firestore::CollectionGroup.from_collection_id documents_path, collection_id, firestore
  end

  it "creates a query" do
    _(collection_group).must_be_kind_of Google::Cloud::Firestore::Query
    query_gapi = collection_group.query

    _(query_gapi).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
    _(query_gapi.from.size).must_equal 1
    _(query_gapi.from.first).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector
    _(query_gapi.from.first.all_descendants).must_equal true
    _(query_gapi.from.first.collection_id).must_equal collection_id
  end

  it "creates partitions" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [
        Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "my-collection-id", all_descendants: true)
      ]
    )
    num_partitions = 3

    list_res = paged_enum_struct partition_query_resp(count: num_partitions)
    firestore_mock.expect :partition_query, list_res, [partition_query_args(expected_query, partition_count: num_partitions)]

    _(collection_group).must_be_kind_of Google::Cloud::Firestore::Query
    partitions = collection_group.partitions 3

    _(partitions).must_be_kind_of Google::Cloud::Firestore::QueryPartition::List
    _(partitions.count).must_equal 3
  end
end
