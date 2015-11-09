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

describe Gcloud::Search::Index, :mock_search do
  let(:index_id) { "my-index" }
  let(:index_hash) { { "indexId" => index_id, "projectId" => project } }
  let(:index) { Gcloud::Search::Index.from_raw(index_hash, search.connection) }

  it "deletes itself with the force option" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      [200, {"Content-Type"=>"application/json"},
       page_one_docs_json]
    end
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      [200, {"Content-Type"=>"application/json"},
       page_two_docs_json]
    end
    ("doc_1".."doc_5").each do |doc_id|
      mock_connection.delete "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
        [200, {"Content-Type" => "text/plain"},
         ""]
      end
    end

    index.delete force: true
  end

  it "delete will succeed if no documents exist" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      [200, {"Content-Type"=>"application/json"},
        { "documents" => [] }.to_json]
    end

    index.delete
  end

  it "delete will fail if documents exist and force is not set" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      [200, {"Content-Type"=>"application/json"},
       page_one_docs_json]
    end

    expect { index.delete }.must_raise
  end

  it "gets a document" do
    doc_id = "found_doc"

    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       get_doc_json(doc_id)]
    end

    doc = index.document doc_id
    doc.must_be_kind_of Gcloud::Search::Document
    doc.doc_id.must_equal doc_id
  end

  it "gets a document when passed a document" do
    doc_id = "found_doc"
    document = Gcloud::Search::Document.from_hash random_doc_hash(doc_id)

    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       get_doc_json(doc_id)]
    end

    gotten_doc = index.document document
    gotten_doc.must_be_kind_of Gcloud::Search::Document
    gotten_doc.doc_id.must_equal doc_id
  end

  it "gets nil if a document is not found" do
    doc_id = "not_found_doc"

    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [404, {"Content-Type"=>"text/plain"},
       ""]
    end

    doc = index.document doc_id
    doc.must_be :nil?
  end

  it "lists documents" do
    num_documents = 3
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.wont_include "pageToken"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(num_documents)]
    end

    documents = index.documents
    documents.size.must_equal num_documents
    documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
  end

  it "paginates documents" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.wont_include "pageToken"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(3, "next_page_token")]
    end
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(2)]
    end

    first_documents = index.documents
    first_documents.count.must_equal 3
    first_documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    first_documents.token.wont_be :nil?
    first_documents.token.must_equal "next_page_token"

    second_documents = index.documents token: first_documents.token
    second_documents.count.must_equal 2
    second_documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    second_documents.token.must_be :nil?
  end

  it "paginates documents with next" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.wont_include "pageToken"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(3, "next_page_token")]
    end
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(2)]
    end

    first_documents = index.documents
    first_documents.count.must_equal 3
    first_documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    first_documents.next?.must_equal true

    second_documents = first_documents.next
    second_documents.count.must_equal 2
    second_documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    second_documents.next?.must_equal false
  end

  it "paginates documents with all" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.wont_include "pageToken"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(3, "next_page_token")]
    end
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      env.params.wont_include "pageSize"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(2)]
    end

    all_documents = index.documents.all
    all_documents.count.must_equal 5
    all_documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    all_documents.token.must_be :nil?
  end

  it "paginates documents with max set" do
    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      env.params.wont_include "pageToken"
      env.params.must_include "pageSize"
      env.params["pageSize"].must_equal "3"
      env.params.must_include "view"
      env.params["view"].must_equal "FULL"
      [200, {"Content-Type"=>"application/json"},
       list_docs_json(3, "next_page_token")]
    end

    documents = index.documents max: 3
    documents.count.must_equal 3
    documents.each { |ds| ds.must_be_kind_of Gcloud::Search::Document }
    documents.token.wont_be :nil?
    documents.token.must_equal "next_page_token"
  end

  it "saves a document" do
    document = Gcloud::Search::Document.from_hash random_doc_hash
    document.doc_id = nil
    document.rank = nil

    mock_connection.post "/v1/projects/#{project}/indexes/#{index_id}/documents" do |env|
      json = JSON.parse(env.body)
      json["doc_id"].must_be :nil?
      json["rank"].must_be :nil?
      [200, {"Content-Type" => "application/json"},
       random_doc_hash.to_json]
    end

    new_doc = index.save document
    new_doc.doc_id.wont_be :nil?
    new_doc.rank.wont_be :nil?
    # The object passed in is also updated
    document.doc_id.wont_be :nil?
    document.rank.wont_be :nil?
    # The object passed in is the same as the object returned
    new_doc.must_equal document
  end

  it "removes a document from the index" do
    doc_id = "document-to-be-deleted"
    document = Gcloud::Search::Document.from_hash random_doc_hash(doc_id)

    mock_connection.delete "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [200, {"Content-Type" => "text/plain"},
       ""]
    end

    index.remove document
  end

  it "removes a document by doc_id" do
    doc_id = "document-to-be-deleted"

    mock_connection.delete "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [200, {"Content-Type" => "text/plain"},
       ""]
    end

    index.remove doc_id
  end

  def page_one_docs_json
    {
      "documents" => [random_doc_hash("doc_1"), random_doc_hash("doc_2"), random_doc_hash("doc_3")],
      "nextPageToken" => "next_page_token",
    }.to_json
  end

  def page_two_docs_json
    {
      "documents" => [random_doc_hash("doc_4"), random_doc_hash("doc_5")]
    }.to_json
  end

  def get_doc_json doc_id
    random_doc_hash(doc_id).to_json
  end

  def list_docs_json doc_count, token = nil
    {
      "documents" => doc_count.times.map { random_doc_hash },
      "nextPageToken" => token,
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
