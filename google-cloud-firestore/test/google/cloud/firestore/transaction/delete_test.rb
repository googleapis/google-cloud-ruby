# Copyright 2017 Google LLC
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

require "helper"

describe Google::Cloud::Firestore::Transaction, :delete, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_client(firestore).tap do |b|
      b.instance_variable_set :@transaction_id, transaction_id
    end
  end

  let(:document_path) { "users/mike" }
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

  it "deletes a document given a string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, transaction: transaction_id, options: default_options]

    transaction.delete document_path
    resp = transaction.commit

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse
    resp.commit_time.must_equal commit_time
  end

  it "deletes a document given a doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, transaction: transaction_id, options: default_options]

    doc = firestore.doc document_path
    doc.must_be_kind_of Google::Cloud::Firestore::DocumentReference

    transaction.delete doc
    resp = transaction.commit

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse
    resp.commit_time.must_equal commit_time
  end
end
