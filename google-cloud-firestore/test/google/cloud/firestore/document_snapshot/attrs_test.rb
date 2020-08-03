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

describe Google::Cloud::Firestore::DocumentSnapshot, :attrs, :mock_firestore do
  let(:document_path) { "users/alice" }
  let(:document_ref) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let :document_grpc do
    Google::Cloud::Firestore::V1::Document.new(
      name: document_ref.path,
      fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
    )
  end
  let(:document) do
    Google::Cloud::Firestore::DocumentSnapshot.new.tap do |s|
      s.grpc = document_grpc
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "represents a document reference" do
    _(document).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    # document's metadata
    _(document.document_id).must_equal "alice"
    _(document.document_path).must_equal document_path

    _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(document.parent.collection_id).must_equal "users"
    _(document.parent.collection_path).must_equal "users"

    # a reference document does not have any data
    _(document.data).wont_be :nil?
    _(document.data).must_be_kind_of Hash
    _(document.data).must_equal({ name: "Alice" })
    _(document.created_at).wont_be :nil?
    _(document.created_at).must_equal document_time
    _(document.updated_at).wont_be :nil?
    _(document.updated_at).must_equal document_time
    _(document.read_at).wont_be :nil?
    _(document.read_at).must_equal document_time
    _(document).must_be :exists?
    _(document).wont_be :missing?

    # aliases for resource methods
    _(document.fields).wont_be :nil?
    _(document.fields).must_be_kind_of Hash
    _(document.fields).must_equal({ name: "Alice" })
    _(document.create_time).wont_be :nil?
    _(document.create_time).must_equal document_time
    _(document.update_time).wont_be :nil?
    _(document.update_time).must_equal document_time
    _(document.read_time).wont_be :nil?
    _(document.read_time).must_equal document_time
  end

  it "represents a missing document reference" do
    document.grpc = nil

    _(document).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    # document's metadata
    _(document.document_id).must_equal "alice"
    _(document.document_path).must_equal document_path

    _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(document.parent.collection_id).must_equal "users"
    _(document.parent.collection_path).must_equal "users"

    # a reference document does not have any data
    _(document.data).must_be :nil?
    _(document.created_at).must_be :nil?
    _(document.updated_at).must_be :nil?
    _(document.read_at).wont_be :nil?
    _(document.read_at).must_equal document_time
    _(document).wont_be :exists?
    _(document).must_be :missing?

    # aliases for resource methods
    _(document.fields).must_be :nil?
    _(document.create_time).must_be :nil?
    _(document.update_time).must_be :nil?
    _(document.read_time).wont_be :nil?
    _(document.read_time).must_equal document_time
  end
end
