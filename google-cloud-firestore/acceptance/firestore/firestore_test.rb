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

require "firestore_helper"

describe "Firestore", :firestore_acceptance do
  it "lists root collections" do
    root_col.add # call to ensure that the collection exists
    cols = firestore.collections
    _(cols).must_be_kind_of Enumerator
    col_paths = cols.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      col.collection_path
    end

    _(col_paths).wont_be :empty?
    _(col_paths).must_include root_path
  end

  it "has collection method" do
    col_ref = firestore.col "col"

    _(col_ref).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(col_ref.collection_id).must_equal "col"
    _(col_ref.collection_path).must_equal "col"
  end

  it "has doc method" do
    doc_ref = firestore.doc "col/doc"

    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(doc_ref.document_id).must_equal "doc"
    _(doc_ref.document_path).must_equal "col/doc"
  end

  it "has get_all method" do
    get_all_col = firestore.col "#{root_path}/get_all/#{SecureRandom.hex(4)}"

    doc1 = get_all_col.doc "doc1"
    doc2 = get_all_col.doc "doc2"

    doc1.create foo: :a
    doc2.create foo: :b

    docs = firestore.get_all doc1, doc2
    _(docs.to_a.count).must_equal 2
  end

  it "has get_all method with field_mask argument" do
    get_all_col = firestore.col "#{root_path}/get_all/#{SecureRandom.hex(4)}"

    doc1 = get_all_col.doc "doc1"
    doc2 = get_all_col.doc "doc2"

    doc1.create foo: :a
    doc2.create foo: :b

    docs = firestore.get_all doc1, doc2, field_mask: :foo
    _(docs.to_a.count).must_equal 2
  end
end
