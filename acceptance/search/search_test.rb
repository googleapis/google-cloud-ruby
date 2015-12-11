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

require "search_helper"
require "gcloud/search"

# This test is a ruby version of gcloud-node's search test.

describe "Search", :search do
  let(:index) { search.index "#{prefix}-main-index", skip_lookup: true }
  let(:chris_where_doc) do
    doc = index.document "chris-where"
    doc["question"].add "Where did Chris go?"
    doc["answer"].add "to the mountains"
    doc["tags"].add "chris"
    doc["tags"].add "gcloud"
    doc["tags"].add "ruby"
    doc
  end
  let(:chris_what_doc) do
    doc = index.document "chris-what"
    doc["question"].add "What did Chris do?"
    doc["answer"].add "hunting"
    doc["tags"].add "chris"
    doc["tags"].add "gcloud"
    doc["tags"].add "ruby"
    doc
  end
  let(:mike_where_doc) do
    doc = index.document "mike-where"
    doc["question"].add "Where did Mike go?"
    doc["answer"].add "comic book store"
    doc["tags"].add "mike"
    doc["tags"].add "gcloud"
    doc["tags"].add "ruby"
    doc
  end
  let(:mike_what_doc) do
    doc = index.document "mike-what"
    doc["question"].add "What did Mike do?"
    doc["answer"].add "bought some comics"
    doc["tags"].add "mike"
    doc["tags"].add "gcloud"
    doc["tags"].add "ruby"
    doc
  end

  before do
    if index.find(chris_where_doc.doc_id).nil?
      index.save chris_where_doc
      index.save chris_what_doc
      index.save mike_where_doc
      index.save mike_what_doc
    end
  end

  it "creates and deletes a document in a new index" do
    new_index = search.index "#{prefix}-new-index", skip_lookup: true
    new_doc = new_index.document "new-document"
    new_doc["hello"].add "world"
    new_index.documents.count.must_equal 0
    new_index.save new_doc
    new_index.documents.count.must_equal 1
    new_index.remove new_doc
    new_index.documents.count.must_equal 0
  end

  it "should get the indexes" do
    search.indexes.count.must_be :>, 0
    search.indexes.all.count.must_be :>, 0
  end

  it "should get all documents" do
    index.documents.count.must_be :>, 0
    index.documents.all.count.must_be :>, 0
  end

  it "searches" do
    search_results = index.search "mountains"
    search_results.count.must_equal 1
    search_results.first.doc_id.must_equal chris_where_doc.doc_id
    search_results.first["title"].must_be :empty?
    search_results.first["questions"].must_be :empty?
    search_results.first["tags"].must_be :empty?
    search_results.first["rank"].must_be :empty?
    search_results.first["score"].must_be :empty?

    search_results = index.search "where", fields: ["question"]
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include chris_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.each do |sr|
      sr["question"].wont_be :empty?
      sr["answer"].must_be :empty?
      sr["tags"].must_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end

    search_results = index.search "chris", fields: ["question", "answer"]
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include chris_where_doc.doc_id
    search_results.map(&:doc_id).must_include chris_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].wont_be :empty?
      sr["answer"].wont_be :empty?
      sr["tags"].must_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end

    search_results = index.search "mike", fields: "*"
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].wont_be :empty?
      sr["answer"].wont_be :empty?
      sr["tags"].wont_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end

    search_results = index.search "mike", fields: "*", order: "question, answer"
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].wont_be :empty?
      sr["answer"].wont_be :empty?
      sr["tags"].wont_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end

    search_results = index.search "mike", fields: ["*", "rank", "score"], scorer: "generic", order: "score desc"
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].wont_be :empty?
      sr["answer"].wont_be :empty?
      sr["tags"].wont_be :empty?
      sr["rank"].wont_be :empty?
      sr["score"].wont_be :empty?
    end

    search_results = index.search "ruby", fields: ["tags", "rank", "score"], scorer: "generic"
    search_results.count.must_equal 4
    search_results.map(&:doc_id).must_include chris_where_doc.doc_id
    search_results.map(&:doc_id).must_include chris_what_doc.doc_id
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].must_be :empty?
      sr["answer"].must_be :empty?
      sr["tags"].wont_be :empty?
      sr["rank"].wont_be :empty?
      sr["score"].wont_be :empty?
    end

    search_results = index.search "where", fields: ["question_snippet", "answer"],
                                  expressions: { question_snippet: "snippet(\"where\", question)" }
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include chris_where_doc.doc_id
    search_results.map(&:doc_id).must_include mike_where_doc.doc_id
    search_results.each do |sr|
      sr["question"].must_be :empty?
      sr["question_snippet"].wont_be :empty?
      sr["answer"].wont_be :empty?
      sr["answer_snippet"].must_be :empty?
      sr["tags"].must_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end

    search_results = index.search "What", fields: ["question_snippet", "answer_snippet"],
                                  expressions: { question_snippet: "snippet(\"what\", question)",
                                                 answer_snippet: "snippet(\"what\", answer)" }
    search_results.count.must_equal 2
    search_results.map(&:doc_id).must_include chris_what_doc.doc_id
    search_results.map(&:doc_id).must_include mike_what_doc.doc_id
    search_results.each do |sr|
      sr["question"].must_be :empty?
      sr["question_snippet"].wont_be :empty?
      sr["answer"].must_be :empty?
      sr["answer_snippet"].wont_be :empty?
      sr["tags"].must_be :empty?
      sr["rank"].must_be :empty?
      sr["score"].must_be :empty?
    end
  end
end
