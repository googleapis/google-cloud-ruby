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

describe Google::Cloud::Firestore::Snapshot, :get_all, :closed, :mock_firestore do
  let(:snapshot) do
    Google::Cloud::Firestore::Snapshot.from_database(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end

  let(:read_time) { Time.now }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let :batch_doc_enum do
    [
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "raises when calling get_all directly" do
    error = expect do
      snapshot.get_all "users/mike", "users/tad", "users/chris"
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "gets a single doc from a doc ref object" do
    firestore_mock.expect :batch_get_documents, batch_doc_enum, [database_path, ["#{documents_path}/users/mike"], mask: nil, options: default_options]

    doc_ref = snapshot.doc("users/mike")
    doc_snp = doc_ref.get

    doc_snp.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc_snp.project_id.must_equal project
    doc_snp.database_id.must_equal "(default)"

    doc_snp.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc_snp.parent.project_id.must_equal project
    doc_snp.parent.database_id.must_equal "(default)"
    doc_snp.parent.collection_id.must_equal "users"
    doc_snp.parent.collection_path.must_equal "users"
    doc_snp.parent.path.must_equal "projects/test/databases/(default)/documents/users"

    doc_snp.data.must_be_kind_of Hash
    doc_snp.data.must_equal({ name: "Mike" })
    doc_snp.created_at.must_equal read_time
    doc_snp.updated_at.must_equal read_time
    doc_snp.read_at.must_equal read_time
  end
end
