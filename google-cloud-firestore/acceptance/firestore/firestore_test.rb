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
  it "paginates root collections" do
    skip if Google::Cloud.configure.firestore.transport == :rest
    root_col.add # call to ensure that the collection exists
    cols = firestore.collections
    _(cols).must_be_kind_of Enumerator
    col = cols.peek
    _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(col.collection_path).wont_be :empty?
    paths = cols.take(3).map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(col.collection_path).wont_be :empty?
      col.collection_path
    end
    _(paths.size).must_be :<=, 3
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

  it "has get_all method with read_time argument" do
    get_all_col = firestore.col "#{root_path}/get_all/#{SecureRandom.hex(4)}"
    results = []
    results_1 = []

    doc1 = get_all_col.doc "doc1"
    doc2 = get_all_col.doc "doc2"

    doc1.create foo: :a
    doc2.create foo: :b

    sleep(1)
    read_time = Time.now
    sleep(1)

    doc3 = get_all_col.doc "doc3"
    doc3.create foo: :c

    firestore.get_all(doc1, doc2, doc3, read_time: read_time) { |doc| results << doc unless doc.grpc.nil? }
    firestore.get_all(doc1, doc2, doc3) { |doc| results_1 << doc unless doc.grpc.nil? }

    _(results.count).must_equal 2
    _(results_1.count).must_equal 3
  end
end
