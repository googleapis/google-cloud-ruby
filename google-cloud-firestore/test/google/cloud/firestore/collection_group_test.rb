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
  let(:expected_query) do
    collection_group_query
  end

  it "lists partitions" do
    # grpc.partitions: 
    # [<Google::Cloud::Firestore::V1::Cursor: values: [<Google::Cloud::Firestore::V1::Value: reference_value: "projects/buoyant-ability-182823/databases/(default)/documents/gcloud-2021-05-21t23-38-03z-a581db45/query/dabf1479/32">], before: false>,
    #  <Google::Cloud::Firestore::V1::Cursor: values: [<Google::Cloud::Firestore::V1::Value: reference_value: "projects/buoyant-ability-182823/databases/(default)/documents/gcloud-2021-05-21t23-38-03z-a581db45/query/dabf1479/89">], before: false>]
    list_res = paged_enum_struct partition_query_resp
    firestore_mock.expect :partition_query, list_res, partition_query_args(expected_query)

    partitions = collection_group.partitions 3

    firestore_mock.verify

    _(partitions).must_be_kind_of Google::Cloud::Firestore::QueryPartition::List
    _(partitions.count).must_equal 3

    _(partitions[0]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[0].start_at).must_be :nil?
    _(partitions[0].end_before).must_be_kind_of Array
    _(partitions[0].end_before.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[0].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[0].end_before[0].path).must_equal document_path("10")

    _(partitions[1]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[1].start_at).must_be_kind_of Array
    _(partitions[1].start_at.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[1].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[1].start_at[0].path).must_equal document_path("10")
    _(partitions[1].end_before).must_be_kind_of Array
    _(partitions[1].end_before.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[1].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[1].end_before[0].path).must_equal document_path("20")

    _(partitions[2]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
    _(partitions[2].start_at).must_be_kind_of Array
    _(partitions[2].start_at.count).must_equal 1 # The array should have an element for each field in Order By.
    _(partitions[2].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(partitions[2].start_at[0].path).must_equal document_path("20")
    _(partitions[2].end_before).must_be :nil?

    query_1 = partitions[0].create_query
    _(query_1).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_1.query).must_equal collection_group_query(end_before: ["10"])

    query_2 = partitions[1].create_query
    _(query_2).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_2.query).must_equal collection_group_query(start_at: ["10"], end_before: ["20"])

    query_3 = partitions[2].create_query
    _(query_3).must_be_kind_of Google::Cloud::Firestore::Query
    _(query_3.query).must_equal collection_group_query(start_at: ["20"])
  end

  it "paginates partitions with max" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3, page_token: "next_page_token")

    first_partitions = collection_group.partitions 6, max: 3
    second_partitions = collection_group.partitions 6, max: 3, token: first_partitions.token

    firestore_mock.verify

    first_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(first_partitions.count).must_equal 3
    _(first_partitions.token).must_equal "next_page_token"

    second_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(second_partitions.count).must_equal 3
    _(second_partitions.token).must_be :nil?
  end

  it "paginates partitions using next" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3, page_token: "next_page_token")

    first_partitions = collection_group.partitions 6, max: 3
    second_partitions = first_partitions.next

    first_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(first_partitions.count).must_equal 3
    _(first_partitions.token).must_equal "next_page_token"

    second_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(second_partitions.count).must_equal 3
    _(second_partitions.token).must_be :nil?
  end

  it "paginates partitions using all" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3, page_token: "next_page_token")

    all_partitions = collection_group.partitions(6, max: 3).all.to_a

    firestore_mock.verify

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 6
  end

  it "paginates partitions using all and Enumerator" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 3, token: "second_page_token")

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3, page_token: "next_page_token")

    all_partitions = collection_group.partitions(6, max: 3).all.take 4

    firestore_mock.verify

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 4
  end

  it "paginates partitions using all with request_limit set" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 3, token: "second_page_token")

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 8, page_size: 3)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 8, page_size: 3, page_token: "next_page_token")

    all_partitions = collection_group.partitions(9, max: 3).all(request_limit: 1).to_a

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 6
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
