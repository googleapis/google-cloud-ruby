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

require "firestore_helper"

describe "Firestore", :firestore do
  it "lists root collections" do
    root_col.add # call to ensure that the collection exists

    col_paths = firestore.collections.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.collection_path
    end

    col_paths.wont_be :empty?
    col_paths.must_include root_path
  end

  it "has collection method" do
    col_ref = firestore.col "col"

    col_ref.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    col_ref.collection_id.must_equal "col"
    col_ref.collection_path.must_equal "col"
  end

  it "has doc method" do
    doc_ref = firestore.doc "col/doc"

    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    doc_ref.document_id.must_equal "doc"
    doc_ref.document_path.must_equal "col/doc"
  end

  it "has get_all method" do
    get_all_col = firestore.col "#{root_path}/get_all/#{SecureRandom.hex(4)}"

    doc1 = get_all_col.doc "doc1"
    doc2 = get_all_col.doc "doc2"

    doc1.create foo: :a
    doc2.create foo: :b

    docs = firestore.get_all doc1, doc2
    docs.to_a.count.must_equal 2
  end
end
