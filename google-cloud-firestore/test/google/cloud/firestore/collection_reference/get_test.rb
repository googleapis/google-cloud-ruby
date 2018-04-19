# Copyright 2017 Google LLC
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

describe Google::Cloud::Firestore::CollectionReference, :get, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/mike/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  let(:read_time) { Time.now }
  let :query_docs_enum do
    [
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123",
          fields: { "body" => Google::Firestore::V1beta1::Value.new(string_value: "LGTM") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike/messages/xyz789",
          fields: { "body" => Google::Firestore::V1beta1::Value.new(string_value: "PTAL") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "gets docs" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents/users/mike", structured_query: expected_query, options: default_options]

    docs_enum = collection.get

    assert_docs_enum docs_enum
  end

  it "gets docs using run alias" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_docs_enum, ["projects/#{project}/databases/(default)/documents/users/mike", structured_query: expected_query, options: default_options]

    docs_enum = collection.run

    assert_docs_enum docs_enum
  end

  def assert_docs_enum enum
    enum.must_be_kind_of Enumerator

    docs = enum.to_a
    docs.count.must_equal 2

    docs.each do |doc|
      doc.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      doc.ref.must_be_kind_of Google::Cloud::Firestore::DocumentReference
      doc.ref.client.must_equal firestore

      doc.parent.must_be_kind_of Google::Cloud::Firestore::CollectionReference
      doc.parent.collection_id.must_equal "messages"
      doc.parent.collection_path.must_equal "users/mike/messages"
      doc.parent.path.must_equal "projects/projectID/databases/(default)/documents/users/mike/messages"
      doc.parent.client.must_equal firestore
    end

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ body: "LGTM" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.last.data.must_be_kind_of Hash
    docs.last.data.must_equal({ body: "PTAL" })
    docs.last.created_at.must_equal read_time
    docs.last.updated_at.must_equal read_time
    docs.last.read_at.must_equal read_time
  end
end
