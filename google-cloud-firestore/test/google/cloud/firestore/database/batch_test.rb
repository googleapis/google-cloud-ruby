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

describe Google::Cloud::Firestore::Database, :batch, :mock_firestore do
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
  let :set_writes do
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Mike" }))
    )]
  end
  let :merge_writes do
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Mike" })),
      update_mask: Google::Firestore::V1beta1::DocumentMask.new(
        field_paths: ["name"]
      )
    )]
  end
  let :update_writes do
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Mike" })),
      update_mask: Google::Firestore::V1beta1::DocumentMask.new(
        field_paths: ["name"]
      )
    )]
  end
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

  it "creates a new document using string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    resp = firestore.batch do |b|
      b.create(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "creates a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.create(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if create is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.create document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data must be a Hash"
  end

  it "sets a new document using string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    resp = firestore.batch do |b|
      b.set(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "sets a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.set(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if set is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.set document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data must be a Hash"
  end

  it "merges a new document using string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, merge_writes, options: default_options]

    resp = firestore.batch do |b|
      b.merge(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "merges a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, merge_writes, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.merge(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if merge is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.merge document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data must be a Hash"
  end

  it "updates a new document using string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, update_writes, options: default_options]

    resp = firestore.batch do |b|
      b.update(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "updates a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, update_writes, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.update(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if update is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.update document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data must be a Hash"
  end

  it "deletes a document using string path" do
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    resp = firestore.batch do |b|
      b.delete document_path
    end

    resp.must_equal commit_time
  end

  it "deletes a document using doc ref" do
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.delete doc
    end

    resp.must_equal commit_time
  end

  it "returns nil when no work is done in the batch" do
    resp = firestore.batch do |b|
      b.database.must_equal firestore

      inside_batch_doc = b.doc document_path
      inside_batch_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_batch_doc.context.must_equal b
    end

    resp.must_be :nil?
  end

  it "performs multiple writes in the same commit" do
    all_writes = create_writes + set_writes + merge_writes + update_writes + delete_writes
    firestore_mock.expect :commit, commit_resp, [database_path, all_writes, options: default_options]

    resp = firestore.batch do |b|
      b.create(document_path, { name: "Mike" })
      b.set(document_path, { name: "Mike" })
      b.merge(document_path, { name: "Mike" })
      b.update(document_path, { name: "Mike" })
      b.delete document_path
    end

    resp.must_equal commit_time
  end

  it "performs multiple writes in the same commit using an object" do
    all_writes = create_writes + set_writes + merge_writes + update_writes + delete_writes
    firestore_mock.expect :commit, commit_resp, [database_path, all_writes, options: default_options]

    resp = firestore.batch do |b|
      b.database.must_equal firestore

      inside_batch_doc = b.doc document_path
      inside_batch_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_batch_doc.context.must_equal b

      inside_batch_doc.create({ name: "Mike" })
      inside_batch_doc.set({ name: "Mike" })
      inside_batch_doc.merge({ name: "Mike" })
      inside_batch_doc.update({ name: "Mike" })
      inside_batch_doc.delete
    end

    resp.must_equal commit_time
  end

  it "objects created inside batch can update outside of the batch" do
    outside_batch_doc = nil
    outside_batch_obj = nil

    resp = firestore.batch do |b|
      b.wont_be :closed?
      b.database.must_equal firestore

      inside_batch_doc = b.doc document_path
      inside_batch_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_batch_doc.context.must_equal b

      outside_batch_obj = b
      outside_batch_doc = inside_batch_doc
    end

    resp.must_be :nil?

    outside_batch_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    outside_batch_doc.context.must_equal outside_batch_obj
    outside_batch_obj.must_be :closed?

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    outside_batch_doc.create({ name: "Mike" })

    outside_batch_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    outside_batch_doc.context.must_equal firestore
  end
end
