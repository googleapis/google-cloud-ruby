# Copyright 2023 Google LLC
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

describe "BulkWriter", :firestore_acceptance do
  let(:query_count) { 5 }

  focus; it "has create method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    bw = firestore.bulk_writer

    doc_refs = []
    results = []
    (1..query_count).each do |i|
      doc_ref = rand_tx_col.doc
      doc_refs << doc_ref
      results << bw.create(doc_ref, { foo: "bar" })
    end

    bw.flush
    bw.close

    results.each do |result|
      _(result.fulfilled?).must_equal true
      _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    end
    doc_refs.each do |doc_ref|
      _(doc_ref.get.exists?).must_equal true
    end
  end

  it "has update method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_refs = []
    (1..query_count).each do |i|
      doc_ref = rand_tx_col.doc
      doc_ref.create foo: "bar"
      doc_refs << doc_ref
    end

    bw = firestore.bulk_writer
    results = []
    doc_refs.each do |doc_ref|
      results << bw.update(doc_ref, { foo: "baz" })
    end

    bw.flush
    bw.close

    results.each do |result|
      _(result.fulfilled?).must_equal true
      _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    end
    doc_refs.each do |doc_ref|
      _(doc_ref.get[:foo]).must_equal "baz"
    end
  end

  it "has set method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_refs = []
    (1..query_count).each do |i|
      doc_ref = rand_tx_col.doc
      doc_ref.create foo: "bar"
      doc_refs << doc_ref
    end

    bw = firestore.bulk_writer
    results = []
    doc_refs.each do |doc_ref|
      results << bw.set(doc_ref, { name: "New York City" })
    end

    bw.flush
    bw.close

    results.each do |result|
      _(result.fulfilled?).must_equal true
      _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    end
    doc_refs.each do |doc_ref|
      _(doc_ref.get[:name]).must_equal "New York City"
    end
  end

  it "has delete method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_refs = []
    (1..query_count).each do |i|
      doc_ref = rand_tx_col.doc
      doc_ref.create foo: "bar"
      doc_refs << doc_ref
    end

    bw = firestore.bulk_writer
    results = []
    doc_refs.each do |doc_ref|
      results << bw.delete(doc_ref)
    end

    bw.flush
    bw.close

    results.each do |result|
      _(result.fulfilled?).must_equal true
      _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    end
    doc_refs.each do |doc_ref|
      _(doc_ref.get).wont_be :exists?
    end
  end

  it "CRUD operations" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    doc_refs = []
    (1..50).each do |i|
      doc_refs << rand_tx_col.doc
    end
    bw = firestore.bulk_writer

    doc_refs.each do |doc_ref|
      bw.create doc_ref, { foo: "bar" }
    end
    bw.flush
    doc_refs.each do |doc_ref|
      _(doc_ref.get.exists?).must_equal true
    end

    doc_refs.each do |doc_ref|
      bw.update doc_ref, { foo: "baz" }
    end
    bw.flush
    doc_refs.each do |doc_ref|
      _(doc_ref.get[:foo]).must_equal "baz"
    end

    doc_refs.each do |doc_ref|
      bw.set doc_ref, { name: "New York City" }
    end
    bw.flush
    doc_refs.each do |doc_ref|
      _(doc_ref.get[:name]).must_equal "New York City"
    end

    doc_refs.each do |doc_ref|
      bw.delete doc_ref
    end
    bw.flush
    doc_refs.each do |doc_ref|
      _(doc_ref.get).wont_be :exists?
    end

    bw.close
  end
end
