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
  let(:expected_query) { collection_group_query }

  it "raises if partition_count is < 1" do
    expect do
      partitions = collection_group.partitions 0
    end.must_raise ArgumentError
  end

  it "returns 1 empty partition if partition_count is 1, without RPC" do
    partitions = collection_group.partitions 1

    _(partitions).must_be_kind_of Array
    _(partitions.count).must_equal 1

    _(partitions[0]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[0].start_at).must_be :nil?
    _(partitions[0].end_before).must_be :nil?
  end

  it "returns 1 empty partition if RPC returns no partitions" do
    list_res = paged_enum_struct partition_query_resp(doc_ids: [])
    firestore_mock.expect :partition_query, list_res, partition_query_args(expected_query)

    partitions = collection_group.partitions 3

    firestore_mock.verify

    _(partitions).must_be_kind_of Array
    _(partitions.count).must_equal 1

    _(partitions[0]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[0].start_at).must_be :nil?
    _(partitions[0].end_before).must_be :nil?
  end

  it "sorts and lists partitions" do
    # Results should be sorted so that "alice" comes before "alice-"
    # Use an ID ending in "-" to ensure correct sorting, since full path strings are sorted dash before slash
    # See Google::Cloud::Firestore::ResourcePath
    list_res = paged_enum_struct partition_query_resp(doc_ids: ["alice-", "alice"])
    firestore_mock.expect :partition_query, list_res, partition_query_args(expected_query)

    partitions = collection_group.partitions 3

    firestore_mock.verify

    _(partitions).must_be_kind_of Array
    _(partitions.count).must_equal 3

    _(partitions[0]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[0].start_at).must_be :nil?
    _(partitions[0].end_before).must_be_kind_of Array
    _(partitions[0].end_before.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[0].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[0].end_before[0].path).must_equal document_path("alice")

    _(partitions[1]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[1].start_at).must_be_kind_of Array
    _(partitions[1].start_at.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[1].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[1].start_at[0].path).must_equal document_path("alice")
    _(partitions[1].end_before).must_be_kind_of Array
    _(partitions[1].end_before.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[1].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[1].end_before[0].path).must_equal document_path("alice-")

    _(partitions[2]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[2].start_at).must_be_kind_of Array
    _(partitions[2].start_at.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[2].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[2].start_at[0].path).must_equal document_path("alice-")
    _(partitions[2].end_before).must_be :nil?

    query_1 = partitions[0].to_query
    _(query_1).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_1.query).must_equal collection_group_query(end_before: ["alice"])

    query_2 = partitions[1].to_query
    _(query_2).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_2.query).must_equal collection_group_query(start_at: ["alice"], end_before: ["alice-"])

    query_3 = partitions[2].to_query
    _(query_3).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_3.query).must_equal collection_group_query(start_at: ["alice-"])
  end

  def collection_group_query start_at: nil, end_before: nil
    query_grpc = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [
        Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(
          collection_id: "my-collection-id",
          all_descendants: true
        )
      ],
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ]
    )
    query_grpc.start_at = cursor_grpc(doc_ids: start_at) if start_at
    query_grpc.end_at = cursor_grpc(doc_ids: end_before) if end_before
    query_grpc
  end
end
