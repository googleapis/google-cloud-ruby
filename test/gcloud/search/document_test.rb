# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Search::Document, :mock_search do
  let(:index_id) { "my-index" }
  let(:index_hash) { { "indexId" => index_id, "projectId" => project } }
  let(:index) { Gcloud::Search::Index.from_raw index_hash, search.connection }
  let(:doc_id) { "my-doc" }
  let(:doc_rank) { 123456 }
  let(:doc_hash) { random_doc_hash doc_id, doc_rank }
  let(:document) { Gcloud::Search::Document.from_hash doc_hash }

  it "knows its attributes" do
    document.must_be_kind_of Gcloud::Search::Document
    document.doc_id.must_equal doc_id
    document.rank.must_equal doc_rank
    document.fields.must_equal doc_hash["fields"]
  end

  it "can set new attribute values" do
    new_doc_id = nil
    new_doc_rank = 789321
    new_doc_fields = { "title" => { "values" => [ { "stringFormat" => "TEXT",
                                                    "lang" => "en",
                                                    "stringValue" => "Hello Gcloud!" } ] } }

    document.doc_id = new_doc_id
    document.rank = new_doc_rank
    document.fields = new_doc_fields

    document.doc_id.must_equal new_doc_id
    document.rank.must_equal new_doc_rank
    document.fields.must_equal new_doc_fields
  end
end
