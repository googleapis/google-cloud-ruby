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

describe Google::Cloud::Firestore::Client, :collection, :mock_firestore do
  it "gets a collection by a collection_id" do
    col = firestore.col "users"

    _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(col.collection_id).must_equal "users"
    _(col.collection_path).must_equal "users"
    _(col.path).must_equal "projects/#{project}/databases/(default)/documents/users"
  end

  it "gets a collection by a nested collection path" do
    col = firestore.col "users/alice/messages"

    _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(col.collection_id).must_equal "messages"
    _(col.collection_path).must_equal "users/alice/messages"
    _(col.path).must_equal "projects/#{project}/databases/(default)/documents/users/alice/messages"
  end

  it "does not allow a document path" do
    error = expect do
      firestore.col "users/alice"
    end.must_raise ArgumentError
    _(error.message).must_equal "collection_path must refer to a collection."
  end

  describe "using collection alias" do
    it "gets a collection by a collection_id" do
      col = firestore.collection "users"

      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(col.collection_id).must_equal "users"
      _(col.collection_path).must_equal "users"
      _(col.path).must_equal "projects/#{project}/databases/(default)/documents/users"
    end

    it "gets a collection by a nested collection path" do
      col = firestore.collection "users/alice/messages"

      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(col.collection_id).must_equal "messages"
      _(col.collection_path).must_equal "users/alice/messages"
      _(col.path).must_equal "projects/#{project}/databases/(default)/documents/users/alice/messages"
    end

    it "does not allow a document path" do
      error = expect do
        firestore.collection "users/alice"
      end.must_raise ArgumentError
      _(error.message).must_equal "collection_path must refer to a collection."
    end
  end
end
