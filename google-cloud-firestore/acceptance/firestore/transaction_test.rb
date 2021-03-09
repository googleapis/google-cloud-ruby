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

describe "Transaction", :firestore_acceptance do
  it "has get method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc

    doc_snp = firestore.transaction do |tx|
      tx.get doc_ref
    end
    _(doc_snp).wont_be :exists?
  end

  it "returns CommitResponse when commit_response option is true" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc

    resp = firestore.transaction commit_response: true do |tx|
      doc_snp = tx.get doc_ref
      _(doc_snp).wont_be :exists?
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_be_kind_of Time
  end

  it "has get with query" do
    rand_query_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    query = rand_query_col.select "foo"

    results = firestore.transaction do |tx|
      tx.get(query).to_a # all results must be retrieved inside tx
    end
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]
  end

  it "has set method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc

    resp = firestore.transaction do |tx|
      tx.set doc_ref, { foo: "bar" }
    end

    _(resp).must_be :nil?
    _(doc_ref.get[:foo]).must_equal "bar"
  end

  it "has update method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc
    doc_ref.create foo: "bar"

    resp = firestore.transaction do |tx|
      tx.update doc_ref, { foo: "baz" }
    end

    _(resp).must_be :nil?
    _(doc_ref.get[:foo]).must_equal "baz"
  end

  it "update enforces document exists" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc
    _(doc_ref.get).wont_be :exists?

    expect do
      firestore.transaction do |tx|
        tx.update doc_ref, { foo: "baz" }
      end
    end.must_raise Google::Cloud::NotFoundError
  end

  it "has delete method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_ref = rand_tx_col.doc
    doc_ref.create foo: "bar"

    resp = firestore.transaction do |tx|
      tx.delete doc_ref
    end

    _(resp).must_be :nil?
    _(doc_ref.get).wont_be :exists?
  end
end
