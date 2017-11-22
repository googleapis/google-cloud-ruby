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

describe Google::Cloud::Firestore::Document::Reference, :create, :empty_read_transaction, :mock_firestore do
  let(:read_transaction) { Google::Cloud::Firestore::ReadOnlyTransaction.from_database firestore }
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::Document.from_path "#{documents_path}/#{document_path}", read_transaction }

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

  it "creates a new document" do
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    document.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    resp = document.create({ name: "Mike" })

    resp.must_equal commit_time
  end

  it "raises if not given a Hash" do
    error = expect do
      document.create "not a hash"
    end.must_raise ArgumentError
    error.message.must_equal "data must be a Hash"
  end
end
