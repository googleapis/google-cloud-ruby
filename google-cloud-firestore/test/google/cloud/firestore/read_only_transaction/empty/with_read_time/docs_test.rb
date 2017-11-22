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

require "helper"

describe Google::Cloud::Firestore::ReadOnlyTransaction, :docs, :empty, :with_read_time, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:read_transaction) { Google::Cloud::Firestore::ReadOnlyTransaction.from_database firestore, read_time: read_time }
  let(:transaction_opt) do
    Google::Firestore::V1beta1::TransactionOptions.new(
      read_only: \
        Google::Firestore::V1beta1::TransactionOptions::ReadOnly.new(
          read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )
    )
  end
  let(:read_time) { Time.now }
  let :query_docs_enum do
    [
      Google::Firestore::V1beta1::RunQueryResponse.new(transaction: transaction_id),
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/chris",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Chris") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "gets docs with string" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.docs "users"

    assert_docs_enum docs_enum
  end

  it "gets docs with symbol" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.docs :users

    assert_docs_enum docs_enum
  end

  it "gets docs with string using documents alias" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.documents "users"

    assert_docs_enum docs_enum
  end

  it "gets docs with symbol using documents alias" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.documents :users

    assert_docs_enum docs_enum
  end

  def assert_docs_enum enum
    enum.must_be_kind_of Enumerator

    docs = enum.to_a
    docs.count.must_equal 2

    docs.each do |doc|
      doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
      doc.project_id.must_equal project
      doc.database_id.must_equal "(default)"

      doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      doc.parent.project_id.must_equal project
      doc.parent.database_id.must_equal "(default)"
      doc.parent.collection_id.must_equal "users"
      doc.parent.collection_path.must_equal "users"
      doc.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

      doc.ref.context.must_equal read_transaction
      doc.parent.context.must_equal read_transaction
    end

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ name: "Mike" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.last.data.must_be_kind_of Hash
    docs.last.data.must_equal({ name: "Chris" })
    docs.last.created_at.must_equal read_time
    docs.last.updated_at.must_equal read_time
    docs.last.read_at.must_equal read_time
  end
end
