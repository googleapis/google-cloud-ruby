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

describe Google::Cloud::Firestore::Client, :batch, :mock_firestore do
  let(:document_path) { "users/alice" }



  let(:commit_time) { Time.now }
  let :create_writes do
    [Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Alice" })),
      current_document: Google::Cloud::Firestore::V1::Precondition.new(
        exists: false)
    )]
  end
  let :set_writes do
    [Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Alice" }))
    )]
  end
  let :update_writes do
    [Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: Google::Cloud::Firestore::Convert.hash_to_fields({ name: "Alice" })),
      update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
        field_paths: ["name"]
      ),
      current_document: Google::Cloud::Firestore::V1::Precondition.new(
        exists: true)
    )]
  end
  let :delete_writes do
    [Google::Cloud::Firestore::V1::Write.new(
      delete: "#{documents_path}/#{document_path}")]
  end
  let :commit_resp do
    Google::Cloud::Firestore::V1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Cloud::Firestore::V1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "creates a new document using string path" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: create_writes)

    resp = firestore.batch do |b|
      b.create(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "creates a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: create_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.create(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if create is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.create document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "sets a new document using string path" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: set_writes)

    resp = firestore.batch do |b|
      b.set(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "sets a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: set_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.set(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if set is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.set document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "updates a new document using string path" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: update_writes)

    resp = firestore.batch do |b|
      b.update(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "updates a new document using doc ref" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: update_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.update(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if update is not given a Hash" do
    error = expect do
      firestore.batch do |b|
        b.update document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "deletes a document using string path" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: delete_writes)

    resp = firestore.batch do |b|
      b.delete document_path
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "deletes a document using doc ref" do
    firestore_mock.expect :commit, commit_resp, commit_args(writes: delete_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.delete doc
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "deletes a document with exists precondition" do
    delete_writes.first.current_document = Google::Cloud::Firestore::V1::Precondition.new(exists: true)

    firestore_mock.expect :commit, commit_resp, commit_args(writes: delete_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.delete doc, exists: true
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "deletes a document with update_time precondition" do
    delete_writes.first.current_document = Google::Cloud::Firestore::V1::Precondition.new(
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))

    firestore_mock.expect :commit, commit_resp, commit_args(writes: delete_writes)

    doc = firestore.doc document_path
    resp = firestore.batch do |b|
      b.delete doc, update_time: commit_time
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "can't specify both exists and update_time precondition" do
    error = expect do
      doc = firestore.doc document_path
      resp = firestore.batch do |b|
        b.delete doc, exists: true, update_time: commit_time
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "cannot specify both exists and update_time"
  end

  it "returns nil when no work is done in the batch" do
    resp = firestore.batch do |b|
      _(b.firestore).must_equal firestore
    end

    _(resp).must_be :nil?
  end

  it "performs multiple writes in the same commit (string)" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :commit, commit_resp, commit_args(writes: all_writes)

    resp = firestore.batch do |b|
      b.create(document_path, { name: "Alice" })
      b.set(document_path, { name: "Alice" })
      b.update(document_path, { name: "Alice" })
      b.delete document_path
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "performs multiple writes in the same commit (doc ref)" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :commit, commit_resp, commit_args(writes: all_writes)

    doc_ref = firestore.doc document_path
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    resp = firestore.batch do |b|
      b.create(doc_ref, { name: "Alice" })
      b.set(doc_ref, { name: "Alice" })
      b.update(doc_ref, { name: "Alice" })
      b.delete doc_ref
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "closed batches cannot make changes" do
    doc_ref = firestore.doc document_path
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    outside_batch_obj = nil

    resp = firestore.batch do |b|
      _(b).wont_be :closed?
      _(b.firestore).must_equal firestore

      outside_batch_obj = b
    end

    _(resp).must_be :nil?

    _(outside_batch_obj).must_be :closed?

    error = expect do
      firestore.batch do |b|
        outside_batch_obj.create(doc_ref, { name: "Alice" })
      end
    end.must_raise RuntimeError
    _(error.message).must_equal "batch is closed"
  end
end
