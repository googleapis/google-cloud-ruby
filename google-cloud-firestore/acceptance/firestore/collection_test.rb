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

describe "Collection", :firestore do
  it "has properties" do
    root_col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    root_col.collection_id.must_equal root_path
    root_col.collection_path.must_equal root_path

    root_col.parent.must_equal firestore
  end

  it "has doc method" do
    doc_ref = root_col.doc # no id, will create random id instead

    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    doc_ref.document_id.length.must_equal 20 # random doc id

    doc_ref.parent.collection_path.must_equal root_col.collection_path
  end

  it "has add method" do
    doc_ref = root_col.add({ foo: "hello world" })
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc_snp = doc_ref.get
    doc_snp.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot

    doc_snp[:foo].must_equal "hello world"
  end
end
