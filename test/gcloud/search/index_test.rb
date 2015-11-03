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

  it "gets nil if a document is not found" do
    doc_id = "not_found_doc"

    mock_connection.get "/v1/projects/#{project}/indexes/#{index_id}/documents/#{doc_id}" do |env|
      [404, {"Content-Type"=>"text/plain"},
       ""]
    end

    doc = index.document doc_id
    doc.must_be :nil?
  end

  def get_doc_json doc_id
    random_doc_hash(doc_id).to_json
  end

  def list_doc_json doc_count, token = nil
    {
      "documents" => doc_count.times.map { random_doc_hash },
      "nextPageToken" => token,
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
