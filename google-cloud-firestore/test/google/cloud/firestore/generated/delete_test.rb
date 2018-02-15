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

describe "Cross-Language Delete Tests", :mock_firestore do
  let(:document_path) { "C/d" }
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

  it "delete with exists precondition" do
    delete_writes = [
      Google::Firestore::V1beta1::Write.new(
        delete: "projects/projectID/databases/(default)/documents/C/d",
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: true)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    firestore.batch { |b| b.delete document_path, exists: true }
  end

  it "delete without precondition" do
    delete_writes = [
      Google::Firestore::V1beta1::Write.new(
        delete: "projects/projectID/databases/(default)/documents/C/d"
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    firestore.batch { |b| b.delete document_path }
  end

  it "delete with last-update-time precondition" do
    delete_time = Time.now - 42 #42 seconds ago

    delete_writes = [
      Google::Firestore::V1beta1::Write.new(
        delete: "projects/projectID/databases/(default)/documents/C/d",
        current_document: Google::Firestore::V1beta1::Precondition.new(
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(delete_time))
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    firestore.batch { |b| b.delete document_path, update_time: delete_time }
  end
end
