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
    Google::Cloud::Firestore::V1::StructuredQuery.new(
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
  end

  it "lists partitions" do
    list_res = paged_enum_struct partition_query_resp(count: 3)
    firestore_mock.expect :partition_query, list_res, partition_query_args(expected_query)

    partitions = collection_group.partitions 3

    firestore_mock.verify

    _(partitions).must_be_kind_of Google::Cloud::Firestore::QueryPartition::List
    _(partitions.count).must_equal 3
    partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
  end

  it "paginates partitions" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_token: "next_page_token")

    first_partitions = collection_group.partitions 6
    second_partitions = collection_group.partitions 6, token: first_partitions.token

    firestore_mock.verify

    first_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(first_partitions.count).must_equal 3
    _(first_partitions.token).must_equal "next_page_token"

    second_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(second_partitions.count).must_equal 2
    _(second_partitions.token).must_be :nil?
  end

  it "paginates partitions using and next" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_token: "next_page_token")

    first_partitions = collection_group.partitions 6
    second_partitions = first_partitions.next

    firestore_mock.verify

    first_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(first_partitions.count).must_equal 3
    _(first_partitions.token).must_equal "next_page_token"

    second_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(second_partitions.count).must_equal 2
    _(second_partitions.token).must_be :nil?
  end

  it "paginates partitions using all" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 2)

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_token: "next_page_token")

    all_partitions = collection_group.partitions(6).all.to_a

    firestore_mock.verify

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 5
  end

  it "paginates partitions using all and Enumerator" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 3, token: "second_page_token")

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_token: "next_page_token")

    all_partitions = collection_group.partitions(6).all.take 5

    firestore_mock.verify

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 5
  end

  it "paginates partitions using all with request_limit set" do
    first_list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    second_list_res = paged_enum_struct partition_query_resp(count: 3, token: "second_page_token")

    firestore_mock.expect :partition_query, first_list_res, partition_query_args(expected_query, partition_count: 5)
    firestore_mock.expect :partition_query, second_list_res, partition_query_args(expected_query, partition_count: 5, page_token: "next_page_token")

    all_partitions = collection_group.partitions(6).all(request_limit: 1).to_a

    firestore_mock.verify

    all_partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
    _(all_partitions.count).must_equal 6
  end

  it "paginates partitions with max set" do
    list_res = paged_enum_struct partition_query_resp(count: 3, token: "next_page_token")
    firestore_mock.expect :partition_query, list_res, partition_query_args(expected_query, partition_count: 5, page_size: 3)

    partitions = collection_group.partitions 6, max: 3

    firestore_mock.verify

    _(partitions).must_be_kind_of Google::Cloud::Firestore::QueryPartition::List
    _(partitions.count).must_equal 3
    partitions.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::QueryPartition }
  end
end
