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

describe Google::Cloud::Firestore::Document::Reference, :get, :using_transaction, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_database(firestore).tap do |s|
      s.instance_variable_set :@transaction_id, transaction_id
    end
  end
  let(:read_time) { Time.now }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let :found_doc_enum do
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
  let :missing_doc_enum do
    [
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        missing: "projects/#{project}/databases/(default)/documents/users/tad")
    ].to_enum
  end
  let(:name_mask) { Google::Firestore::V1beta1::DocumentMask.new field_paths: ["name"] }

  it "gets a found snapshot" do
    firestore_mock.expect :batch_get_documents, found_doc_enum, [database_path, ["#{documents_path}/users/mike"], mask: nil, transaction: transaction_id, options: default_options]

    doc_ref = transaction.doc "users/mike"
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    doc_ref.context.must_equal transaction

    doc = doc_ref.get

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.project_id
    doc.parent.database_id.must_equal doc_ref.database_id
    doc.parent.collection_id.must_equal "users"
    doc.parent.collection_path.must_equal "users"

    doc.must_be :exists?
    doc.data.must_be_kind_of Hash
    doc.data.must_equal({ name: "Mike" })
    doc.created_at.must_equal read_time
    doc.updated_at.must_equal read_time
    doc.read_at.must_equal read_time

    doc.ref.context.must_equal transaction
    doc.parent.context.must_equal transaction
  end

  it "gets a found snapshot with mask" do
    firestore_mock.expect :batch_get_documents, found_doc_enum, [database_path, ["#{documents_path}/users/mike"], mask: name_mask, transaction: transaction_id, options: default_options]

    doc_ref = transaction.doc "users/mike"
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc = doc_ref.get mask: "name"

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.project_id
    doc.parent.database_id.must_equal doc_ref.database_id
    doc.parent.collection_id.must_equal "users"
    doc.parent.collection_path.must_equal "users"

    doc.must_be :exists?
    doc.data.must_be_kind_of Hash
    doc.data.must_equal({ name: "Mike" })
    doc.created_at.must_equal read_time
    doc.updated_at.must_equal read_time
    doc.read_at.must_equal read_time
  end

  it "gets a missing transaction" do
    firestore_mock.expect :batch_get_documents, missing_doc_enum, [database_path, ["#{documents_path}/users/tad"], mask: nil, transaction: transaction_id, options: default_options]

    doc_ref = transaction.doc "users/tad"
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc = doc_ref.get

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.project_id
    doc.parent.database_id.must_equal doc_ref.database_id
    doc.parent.collection_id.must_equal "users"
    doc.parent.collection_path.must_equal "users"

    doc.must_be :missing?
    doc.data.must_be :nil?
    doc.created_at.must_be :nil?
    doc.updated_at.must_be :nil?
    doc.read_at.must_equal read_time
  end

  it "gets a missing transaction with mask" do
    firestore_mock.expect :batch_get_documents, missing_doc_enum, [database_path, ["#{documents_path}/users/tad"], mask: name_mask, transaction: transaction_id, options: default_options]

    doc_ref = transaction.doc "users/tad"
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc = doc_ref.get mask: :name

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.project_id
    doc.parent.database_id.must_equal doc_ref.database_id
    doc.parent.collection_id.must_equal "users"
    doc.parent.collection_path.must_equal "users"

    doc.must_be :missing?
    doc.data.must_be :nil?
    doc.created_at.must_be :nil?
    doc.updated_at.must_be :nil?
    doc.read_at.must_equal read_time
  end
end
