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

describe Google::Cloud::Firestore::Transaction, :create, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_database(firestore).tap do |b|
      b.instance_variable_set :@transaction_id, transaction_id
    end
  end

  let(:document_path) { "users/mike" }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:commit_time) { Time.now }
  let :create_writes do
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Mike" })),
      current_document: Google::Firestore::V1beta1::Precondition.new(
        exists: false)
    )]
  end
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "creates a new document given a string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, transaction: transaction_id, options: default_options]

    transaction.create(document_path, { name: "Mike" })
    resp = transaction.commit

    resp.must_equal commit_time
  end

  it "creates a new document given a Document::Reference" do
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, transaction: transaction_id, options: default_options]

    doc = transaction.doc document_path
    doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    transaction.create(doc, { name: "Mike" })
    resp = transaction.commit

    resp.must_equal commit_time
  end

  it "raises if not given a Hash" do
    error = expect do
      transaction.create document_path, "not a hash"
    end.must_raise ArgumentError
    error.message.must_equal "data is required"
  end
end
