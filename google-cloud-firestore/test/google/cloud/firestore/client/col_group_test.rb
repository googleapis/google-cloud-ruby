# Copyright 2019 Google LLC
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

describe Google::Cloud::Firestore::Client, :col_group, :mock_firestore do
  let(:collection_id) { "my-collection-id" }
  let(:collection_id_bad) { "a/b/my-collection-id" }

  it "creates a collection group query" do
    collection_group = firestore.col_group(collection_id)

    _(collection_group).must_be_kind_of Google::Cloud::Firestore::Query
    query_gapi = collection_group.query
    _(query_gapi).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
    _(query_gapi.from.size).must_equal 1
    _(query_gapi.from.first).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector
    _(query_gapi.from.first.all_descendants).must_equal true
    _(query_gapi.from.first.collection_id).must_equal collection_id
  end

  it "creates a collection group query using collection_group alias" do
    collection_group = firestore.collection_group(collection_id)

    _(collection_group).must_be_kind_of Google::Cloud::Firestore::Query
    query_gapi = collection_group.query
    _(query_gapi).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
    _(query_gapi.from.size).must_equal 1
    _(query_gapi.from.first).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector
    _(query_gapi.from.first.all_descendants).must_equal true
    _(query_gapi.from.first.collection_id).must_equal collection_id
  end

  it "raises when collection_id contains a forward slash" do
    error = expect do
      firestore.col_group collection_id_bad
    end.must_raise ArgumentError
    _(error.message).must_equal "Invalid collection_id: 'a/b/my-collection-id', must not contain '/'."
  end
end
