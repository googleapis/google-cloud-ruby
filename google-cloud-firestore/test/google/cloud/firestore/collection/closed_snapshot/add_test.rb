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

require "helper"

describe Google::Cloud::Firestore::Collection, :add, :closed_snapshot, :mock_firestore do
  let(:snapshot) do
    Google::Cloud::Firestore::Snapshot.from_database(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/mike/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::Collection.from_path "#{documents_path}/#{collection_path}", snapshot }

  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "produces a Document reference when no id or path is provided" do
    random_document_id = "helloiamarandomdocid"

    commit_writes = [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{collection_path}/#{random_document_id}",
        fields: {}),
      current_document: Google::Firestore::V1beta1::Precondition.new(
        exists: false)
    )]

    firestore_mock.expect :commit, commit_resp, [database_path, commit_writes, options: default_options]

    Google::Cloud::Firestore::Generate.stub :unique_id, random_document_id do
      document = collection.add

      document.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      document.project_id.must_equal project
      document.database_id.must_equal "(default)"
      document.document_id.must_equal random_document_id
      document.document_path.must_equal "#{collection_path}/#{random_document_id}"
      document.path.must_equal "#{documents_path}/#{collection_path}/#{random_document_id}"

      document.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      document.parent.project_id.must_equal project
      document.parent.database_id.must_equal "(default)"
      document.parent.collection_id.must_equal collection_id
      document.parent.collection_path.must_equal collection_path
      document.parent.path.must_equal "#{documents_path}/#{collection_path}"

      document.context.must_equal firestore
      document.parent.context.must_equal firestore
    end
  end
end
