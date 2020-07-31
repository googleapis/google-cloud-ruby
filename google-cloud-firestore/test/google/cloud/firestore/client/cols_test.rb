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

describe Google::Cloud::Firestore::Client, :cols, :mock_firestore do
  let(:first_page) { list_collection_ids_resp "users", "lists", "todos", next_page_token: "next_page_token" }
  let(:second_page) { list_collection_ids_resp "users2", "lists2", "todos2", next_page_token: "next_page_token" }
  let(:last_page) { list_collection_ids_resp "users3", "lists3" }

  it "retrieves collections" do
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args

    col_enum = firestore.cols
    _(col_enum).must_be_kind_of Google::Cloud::Firestore::CollectionReferenceList

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::Client

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["users", "lists", "todos"]
  end

  it "retrieves collections using collections alias" do
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args

    col_enum = firestore.collections
    _(col_enum).must_be_kind_of Google::Cloud::Firestore::CollectionReferenceList

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::Client

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["users", "lists", "todos"]
  end

  it "paginates collections with max set" do
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args(page_size: 3)

    collections = firestore.collections max: 3

    _(collections.size).must_equal 3
    token = collections.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates collections with next? and next and max set" do
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args(page_size: 3)
    firestore_mock.expect :list_collection_ids, last_page, list_collection_ids_args(page_size: 3, page_token: "next_page_token")

    first_collections = firestore.collections max: 3
    second_collections = first_collections.next

    _(first_collections.size).must_equal 3
    _(first_collections.next?).must_equal true

    _(second_collections.size).must_equal 2
    _(second_collections.next?).must_equal false
  end

  it "iterates collections with all and request_limit set" do
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args
    firestore_mock.expect :list_collection_ids, second_page, list_collection_ids_args(page_token: "next_page_token")

    collections = firestore.collections.all(request_limit: 1).to_a

    _(collections.size).must_equal 6
  end
end
