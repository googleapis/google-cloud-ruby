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

describe Google::Cloud::Firestore::Batch, :set, :mock_firestore do
  let(:batch) { Google::Cloud::Firestore::Batch.from_client firestore }

  let(:document_path) { "users/alice" }


  let(:commit_time) { Time.now }
  let :set_writes do
    [Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Alice" }))
    )]
  end
  let :commit_resp do
    Google::Cloud::Firestore::V1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Cloud::Firestore::V1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "sets a new document given a string path" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: set_writes)

    batch.set(document_path, { name: "Alice" })
    resp = batch.commit

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "sets a new document given a DocumentReference" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: set_writes)

    doc = firestore.doc document_path
    _(doc).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    batch.set(doc, { name: "Alice" })
    resp = batch.commit

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if not given a Hash" do
    error = expect do
      batch.set document_path, "not a hash"
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end
end
