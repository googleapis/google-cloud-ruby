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
  focus; it "has set method" do
    rand_tx_col = firestore.col "#{root_path}/tx/#{SecureRandom.hex(4)}"
    bw = firestore.bulk_writer

    results = []
    (1..5000).each do
      results << bw.create(rand_tx_col.doc, { foo: "bar" })
    end

    results.each_with_index do |result, idx|
      if result.fulfilled?
        puts "Completed #{idx}"
      else
        result.wait!
        puts "Completed #{idx}"
      end
    end

    bw.flush
    bw.close

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

    bw = firestore.bulk_writer
    result = bw.delete doc_ref

    result.wait!


    _(resp).must_be :nil?
    _(doc_ref.get).wont_be :exists?
  end
end
