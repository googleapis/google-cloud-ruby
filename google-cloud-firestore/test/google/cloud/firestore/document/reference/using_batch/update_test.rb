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

describe Google::Cloud::Firestore::Document::Reference, :update, :using_batch, :mock_firestore do
  let(:batch) { Google::Cloud::Firestore::Batch.from_database firestore }
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::Document.from_path "#{documents_path}/#{document_path}", batch }

  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:commit_time) { Time.now }
  let :update_writes do
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Mike" })),
      update_mask: Google::Firestore::V1beta1::DocumentMask.new(
        field_paths: ["name"]
      ),
      current_document: Google::Firestore::V1beta1::Precondition.new(
        exists: true)
    )]
  end
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "updates a new document" do
    firestore_mock.expect :commit, commit_resp, [database_path, update_writes, options: default_options]

    document.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    document.update({ name: "Mike" })
    document.context.must_equal batch
    resp = batch.commit

    resp.must_equal commit_time
  end

  it "raises if not given a Hash" do
    error = expect do
      document.update "not a hash"
    end.must_raise ArgumentError
    error.message.must_equal "data is required"
  end
end
