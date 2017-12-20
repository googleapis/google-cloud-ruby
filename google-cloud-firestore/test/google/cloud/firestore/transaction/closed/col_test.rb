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

describe Google::Cloud::Firestore::Transaction, :collection, :closed, :mock_firestore do
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_database(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end

  it "gets a collection by a collection_id" do
    col = firestore.col "users"

    col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    col.collection_id.must_equal "users"
    col.collection_path.must_equal "users"
    col.path.must_equal "projects/#{project}/databases/(default)/documents/users"
  end

  it "gets a collection by a nested collection path" do
    col = firestore.col "users/mike/messages"

    col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    col.collection_id.must_equal "messages"
    col.collection_path.must_equal "users/mike/messages"
    col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages"
  end

  it "does not allow a document path" do
    error = expect do
      firestore.col "users/mike"
    end.must_raise ArgumentError
    error.message.must_equal "collection_path must refer to a collection."
  end

  describe "using collection alias" do
    it "gets a collection by a collection_id" do
      col = firestore.collection "users"

      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      col.collection_id.must_equal "users"
      col.collection_path.must_equal "users"
      col.path.must_equal "projects/#{project}/databases/(default)/documents/users"
    end

    it "gets a collection by a nested collection path" do
      col = firestore.collection "users/mike/messages"

      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      col.collection_id.must_equal "messages"
      col.collection_path.must_equal "users/mike/messages"
      col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages"
    end

    it "does not allow a document path" do
      error = expect do
        firestore.collection "users/mike"
      end.must_raise ArgumentError
      error.message.must_equal "collection_path must refer to a collection."
    end
  end
end
