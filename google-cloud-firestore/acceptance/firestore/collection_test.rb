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

describe "Collection", :firestore_acceptance do
  it "has properties" do
    _(root_col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(root_col.collection_id).must_equal root_path
    _(root_col.collection_path).must_equal root_path

    _(root_col.parent).must_equal firestore
  end

  it "has doc method" do
    doc_ref = root_col.doc # no id, will create random id instead

    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(doc_ref.client).must_be_kind_of Google::Cloud::Firestore::Client
    _(doc_ref.document_id.length).must_equal 20 # random doc id

    _(doc_ref.parent.collection_path).must_equal root_col.collection_path
  end

  it "has add method" do
    doc_ref = root_col.add({ foo: "hello world" })
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(doc_ref.client).must_be_kind_of Google::Cloud::Firestore::Client

    doc_snp = doc_ref.get
    _(doc_snp).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    _(doc_snp[:foo]).must_equal "hello world"
  end

  it "lists its documents" do
    rand_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_col.add({foo: "bar"})
    rand_col.add({bar: "foo"})
    docs = rand_col.list_documents

    _(docs).must_be_kind_of Google::Cloud::Firestore::DocumentReference::List
    _(docs.size).must_be :>, 1
    _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(docs.first.client).must_be_kind_of Google::Cloud::Firestore::Client

    docs_max_1 = rand_col.list_documents max: 1
    _(docs_max_1.size).must_equal 1

    rand_col.list_documents.map(&:delete)
    _(rand_col.list_documents).must_be :empty?
  end
 
  it "lists its documents with read_time" do
    rand_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_col.add({foo: "bar"})
    rand_col.add({bar: "foo"})

    sleep(1)
    read_time = Time.now
    sleep(1)

    rand_col.add({after_time_bar: "after_time_foo"})

    docs = rand_col.list_documents
    _(docs).must_be_kind_of Google::Cloud::Firestore::DocumentReference::List
    _(docs.size).must_equal 3
    _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(docs.first.client).must_be_kind_of Google::Cloud::Firestore::Client

    docs = rand_col.list_documents read_time: read_time
    _(docs).must_be_kind_of Google::Cloud::Firestore::DocumentReference::List
    _(docs.size).must_equal 2
    _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(docs.first.client).must_be_kind_of Google::Cloud::Firestore::Client

    rand_col.list_documents.map(&:delete)
    _(rand_col.list_documents).must_be :empty?
  end

  describe "Multiple database tests" do
    it "lists the documents of multiple databases" do
      skip "Don't have secondary database to run the test" unless firestore_2
      col_id = "#{root_path}/query/#{SecureRandom.hex(4)}"

      rand_col = firestore.col col_id
      rand_col.add({foo: "bar"})
      rand_col.add({bar: "foo"})
      rand_col_2 = firestore_2.col col_id
      rand_col_2.add({foo: "bar"})
      rand_col_2.add({bar: "foo"})

      docs = rand_col.list_documents
      _(docs).must_be_kind_of Google::Cloud::Firestore::DocumentReference::List
      _(docs.size).must_equal 2
      _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(docs.first.client).must_be_kind_of Google::Cloud::Firestore::Client
      docs = rand_col_2.list_documents
      _(docs).must_be_kind_of Google::Cloud::Firestore::DocumentReference::List
      _(docs.size).must_equal 2
      _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(docs.first.client).must_be_kind_of Google::Cloud::Firestore::Client

      rand_col.list_documents.map(&:delete)
      _(rand_col.list_documents).must_be :empty?
      rand_col_2.list_documents.map(&:delete)
      _(rand_col_2.list_documents).must_be :empty?
    end
  end 
end
