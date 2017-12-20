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

describe Google::Cloud::Firestore::Document::Snapshot, :attrs, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document_ref) { Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let :document_grpc do
    Google::Firestore::V1beta1::Document.new(
      name: document_ref.path,
      fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
    )
  end
  let(:document) do
    Google::Cloud::Firestore::Document::Snapshot.new.tap do |s|
      s.grpc = document_grpc
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "represents a document reference" do
    document.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot

    # document's metadata
    document.project_id.must_equal project
    document.database_id.must_equal "(default)"
    document.document_id.must_equal "mike"
    document.document_path.must_equal document_path

    document.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    document.parent.project_id.must_equal project
    document.parent.database_id.must_equal "(default)"
    document.parent.collection_id.must_equal "users"
    document.parent.collection_path.must_equal "users"

    # a reference document does not have any data
    document.data.wont_be :nil?
    document.data.must_be_kind_of Hash
    document.data.must_equal({ name: "Mike" })
    document.created_at.wont_be :nil?
    document.created_at.must_equal document_time
    document.updated_at.wont_be :nil?
    document.updated_at.must_equal document_time
    document.read_at.wont_be :nil?
    document.read_at.must_equal document_time
    document.must_be :exists?
    document.wont_be :missing?

    # aliases for resource methods
    document.fields.wont_be :nil?
    document.fields.must_be_kind_of Hash
    document.fields.must_equal({ name: "Mike" })
    document.create_time.wont_be :nil?
    document.create_time.must_equal document_time
    document.update_time.wont_be :nil?
    document.update_time.must_equal document_time
    document.read_time.wont_be :nil?
    document.read_time.must_equal document_time
  end

  it "represents a missing document reference" do
    document.grpc = nil

    document.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot

    # document's metadata
    document.project_id.must_equal project
    document.database_id.must_equal "(default)"
    document.document_id.must_equal "mike"
    document.document_path.must_equal document_path

    document.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    document.parent.project_id.must_equal project
    document.parent.database_id.must_equal "(default)"
    document.parent.collection_id.must_equal "users"
    document.parent.collection_path.must_equal "users"

    # a reference document does not have any data
    document.data.must_be :nil?
    document.created_at.must_be :nil?
    document.updated_at.must_be :nil?
    document.read_at.wont_be :nil?
    document.read_at.must_equal document_time
    document.wont_be :exists?
    document.must_be :missing?

    # aliases for resource methods
    document.fields.must_be :nil?
    document.create_time.must_be :nil?
    document.update_time.must_be :nil?
    document.read_time.wont_be :nil?
    document.read_time.must_equal document_time
  end
end
