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

describe Google::Cloud::Firestore::Document::Reference, :delete, :closed_transaction, :mock_firestore do
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_database(firestore).tap do |s|
      s.instance_variable_set :@closed, true
    end
  end
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::Document.from_path "#{documents_path}/#{document_path}", transaction }

  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:commit_time) { Time.now }
  let :delete_writes do
    [Google::Firestore::V1beta1::Write.new(
      delete: "#{documents_path}/#{document_path}")]
  end
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "deletes a document" do
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    document.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    resp = document.delete

    resp.must_equal commit_time
  end
end
