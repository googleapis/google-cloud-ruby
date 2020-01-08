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
    root_col.must_be_kind_of Google::Cloud::Firestore::CollectionReference
    root_col.collection_id.must_equal root_path
    root_col.collection_path.must_equal root_path

    root_col.parent.must_equal firestore
  end

  it "has doc method" do
    doc_ref = root_col.doc # no id, will create random id instead

    doc_ref.must_be_kind_of Google::Cloud::Firestore::DocumentReference
    doc_ref.client.must_be_kind_of Google::Cloud::Firestore::Client
    doc_ref.document_id.length.must_equal 20 # random doc id

    doc_ref.parent.collection_path.must_equal root_col.collection_path
  end

  it "has add method" do
    doc_ref = root_col.add({ foo: "hello world" })
    doc_ref.must_be_kind_of Google::Cloud::Firestore::DocumentReference
    doc_ref.client.must_be_kind_of Google::Cloud::Firestore::Client

    doc_snp = doc_ref.get
    doc_snp.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    doc_snp[:foo].must_equal "hello world"
  end

  it "lists its documents" do
    rand_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_col.add({foo: "bar"})
    rand_col.add({bar: "foo"})
    docs = rand_col.list_documents

    docs.must_be_kind_of Array
    docs.size.must_be :>, 1
    docs.first.must_be_kind_of Google::Cloud::Firestore::DocumentReference
    docs.first.client.must_be_kind_of Google::Cloud::Firestore::Client

    docs_max_1 = rand_col.list_documents max: 1
    docs_max_1.size.must_equal 1

    rand_col.list_documents.map(&:delete)
    rand_col.list_documents.must_be :empty?
  end
end
