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

describe Google::Cloud::Firestore::Database, :transaction, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction_opt) do
    Google::Firestore::V1beta1::TransactionOptions.new(
      read_write: Google::Firestore::V1beta1::TransactionOptions::ReadWrite.new
    )
  end
  let(:transaction_opt) do
    Google::Firestore::V1beta1::TransactionOptions.new(
      read_write: Google::Firestore::V1beta1::TransactionOptions::ReadWrite.new
    )
  end
  let(:read_time) { Time.now }
  let :query_results_enum do
    [
      Google::Firestore::V1beta1::RunQueryResponse.new(
        transaction: transaction_id,
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/chris",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Chris") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

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
  let :delete_writes do
    [Google::Firestore::V1beta1::Write.new(
      delete: "#{documents_path}/#{document_path}")]
  end
  let :begin_tx_resp do
    Google::Firestore::V1beta1::BeginTransactionResponse.new(
      transaction: transaction_id
    )
  end
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "runs a simple query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]
    firestore_mock.expect :rollback, nil, ["projects/#{project}/databases/(default)", transaction_id, options: default_options]

    firestore.transaction do |tx|
      results_enum = tx.select(:name).from(:users).run
      assert_results_enum results_enum
    end
  end

  it "runs a complex query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]
    firestore_mock.expect :rollback, nil, ["projects/#{project}/databases/(default)", transaction_id, options: default_options]

    firestore.transaction do |tx|
      results_enum = tx.select(:name).from(:users).offset(3).limit(42).order(:name).order(:__name__, :desc).start_after(:foo).end_before(:bar).run
      assert_results_enum results_enum
    end
  end

  it "runs multiple queries" do
    first_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    second_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: first_query, new_transaction: transaction_opt, options: default_options]
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: second_query, transaction: transaction_id, options: default_options]
    firestore_mock.expect :rollback, nil, ["projects/#{project}/databases/(default)", transaction_id, options: default_options]

    firestore.transaction do |tx|
      results_enum = tx.select(:name).from(:users).run
      assert_results_enum results_enum

      results_enum = tx.select(:name).from(:users).offset(3).limit(42).order(:name).order(:__name__, :desc).start_after(:foo).end_before(:bar).run
      assert_results_enum results_enum
    end
  end

  it "that does nothing makes no calls" do
    firestore.transaction do |tx|
      col = tx.col "users"
    end
  end

  it "creates a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.create(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "creates a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, transaction: transaction_id, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.transaction do |tx|
      tx.create(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if create is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.create document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data is required"
  end

  it "sets a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.set(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "sets a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, transaction: transaction_id, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.transaction do |tx|
      tx.set(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if set is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.set document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data is required"
  end

  it "updates a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, update_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.update(document_path, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "updates a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, update_writes, transaction: transaction_id, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.transaction do |tx|
      tx.update(doc, { name: "Mike" })
    end

    resp.must_equal commit_time
  end

  it "raises if update is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.update document_path, "not a hash"
      end
    end.must_raise ArgumentError
    error.message.must_equal "data is required"
  end

  it "deletes a document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.delete document_path
    end

    resp.must_equal commit_time
  end

  it "deletes a document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, delete_writes, transaction: transaction_id, options: default_options]

    doc = firestore.doc document_path
    resp = firestore.transaction do |tx|
      tx.delete doc
    end

    resp.must_equal commit_time
  end

  it "returns nil when no work is done in the transaction" do
    resp = firestore.transaction do |tx|
      tx.database.must_equal firestore

      inside_transaction_doc = tx.doc document_path
      inside_transaction_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_transaction_doc.context.must_equal tx
    end

    resp.must_be :nil?
  end

  it "performs multiple writes in the same commit" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, all_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.create(document_path, { name: "Mike" })
      tx.set(document_path, { name: "Mike" })
      tx.update(document_path, { name: "Mike" })
      tx.delete document_path
    end

    resp.must_equal commit_time
  end

  it "performs multiple writes in the same commit using an object" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
    firestore_mock.expect :commit, commit_resp, [database_path, all_writes, transaction: transaction_id, options: default_options]

    resp = firestore.transaction do |tx|
      tx.database.must_equal firestore

      inside_transaction_doc = tx.doc document_path
      inside_transaction_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_transaction_doc.context.must_equal tx

      inside_transaction_doc.create({ name: "Mike" })
      inside_transaction_doc.set({ name: "Mike" })
      inside_transaction_doc.update({ name: "Mike" })
      inside_transaction_doc.delete
    end

    resp.must_equal commit_time
  end

  it "objects created inside transaction can update outside of the transaction" do
    outside_transaction_doc = nil
    outside_transaction_obj = nil

    resp = firestore.transaction do |tx|
      tx.wont_be :closed?
      tx.database.must_equal firestore

      inside_transaction_doc = tx.doc document_path
      inside_transaction_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      inside_transaction_doc.context.must_equal tx

      outside_transaction_obj = tx
      outside_transaction_doc = inside_transaction_doc
    end

    resp.must_be :nil?

    outside_transaction_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    outside_transaction_doc.context.must_equal outside_transaction_obj
    outside_transaction_obj.must_be :closed?

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    outside_transaction_doc.create({ name: "Mike" })

    outside_transaction_doc.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    outside_transaction_doc.context.must_equal firestore
  end

  describe :retry do
    it "retries when an unavailable error is raised" do
      # Unable to use mocks to define the responses, so stub the methods instead
      def firestore_mock.begin_transaction path, options_: nil, options: nil
        if @first_begin_transaction.nil?
          @first_begin_transaction = true
          raise "bad first begin_transaction" unless options_.read_write.retry_transaction.empty?
          return Google::Firestore::V1beta1::BeginTransactionResponse.new(transaction: "transaction123")
        end

        raise "bad second begin_transaction" unless options_.read_write.retry_transaction == "transaction123"
        Google::Firestore::V1beta1::BeginTransactionResponse.new(transaction: "new_transaction_xyz")
      end
      def firestore_mock.commit database, writes, transaction: nil, options: nil
        if @first_commit.nil?
          @first_commit = true
          raise "bad first commit" unless transaction == "transaction123"
          gax_error = Google::Gax::GaxError.new "unavailable"
          gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(14, "unavailable")
          raise gax_error
        end

        raise "bad second commit" unless transaction == "new_transaction_xyz"
        Google::Firestore::V1beta1::CommitResponse.new(
          commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
          write_results: [Google::Firestore::V1beta1::WriteResult.new(
            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now))]
          )
      end

      firestore.transaction do |tx|
        tx.create(document_path, { name: "Mike" })
        tx.set(document_path, { name: "Mike" })
        tx.update(document_path, { name: "Mike" })
        tx.delete document_path
      end
    end

    it "retries when unavailable, succeeds if invalid arg raised after" do
      # Unable to use mocks to define the responses, so stub the methods instead
      def firestore_mock.begin_transaction path, options_: nil, options: nil
        if @first_begin_transaction.nil?
          @first_begin_transaction = true
          raise "bad first begin_transaction" unless options_.read_write.retry_transaction.empty?
          return Google::Firestore::V1beta1::BeginTransactionResponse.new(transaction: "transaction123")
        end

        raise "bad second begin_transaction" unless options_.read_write.retry_transaction == "transaction123"
        Google::Firestore::V1beta1::BeginTransactionResponse.new(transaction: "new_transaction_xyz")
      end
      def firestore_mock.commit database, writes, transaction: nil, options: nil
        if @first_commit.nil?
          @first_commit = true
          raise "bad first commit" unless transaction == "transaction123"
          gax_error = Google::Gax::GaxError.new "unavailable"
          gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(14, "unavailable")
          raise gax_error
        end

        raise "bad second commit" unless transaction == "new_transaction_xyz"
        gax_error = Google::Gax::GaxError.new "invalid"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(3, "invalid")
        raise gax_error
      end

      firestore.transaction do |tx|
        tx.create(document_path, { name: "Mike" })
        tx.set(document_path, { name: "Mike" })
        tx.update(document_path, { name: "Mike" })
        tx.delete document_path
      end
    end

    it "does not retry when an unsupported error is raised" do
      firestore_mock.expect :begin_transaction, begin_tx_resp, [database_path, options_: transaction_opt, options: default_options]
      firestore_mock.expect :rollback, nil, ["projects/#{project}/databases/(default)", transaction_id, options: default_options]

      # Unable to use mocks to raise an error, so stub the method instead
      def firestore_mock.commit database, writes, transaction: nil, options: nil
        raise "unsupported"
      end

      error = expect do
        firestore.transaction do |tx|
          tx.create(document_path, { name: "Mike" })
          tx.set(document_path, { name: "Mike" })
          tx.update(document_path, { name: "Mike" })
          tx.delete document_path
        end
      end.must_raise RuntimeError
      error.message.must_equal "unsupported"
    end
  end

  def assert_results_enum enum
    enum.must_be_kind_of Enumerator

    results = enum.to_a
    results.count.must_equal 2

    results.each do |result|
      result.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
      result.project_id.must_equal project
      result.database_id.must_equal "(default)"

      result.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      result.parent.project_id.must_equal project
      result.parent.database_id.must_equal "(default)"
      result.parent.collection_id.must_equal "users"
      result.parent.collection_path.must_equal "users"
      result.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

      result.ref.context.must_be_kind_of Google::Cloud::Firestore::Transaction
      result.parent.context.must_be_kind_of Google::Cloud::Firestore::Transaction
    end

    results.first.data.must_be_kind_of Hash
    results.first.data.must_equal({ name: "Mike" })
    results.first.created_at.must_equal read_time
    results.first.updated_at.must_equal read_time
    results.first.read_at.must_equal read_time

    results.last.data.must_be_kind_of Hash
    results.last.data.must_equal({ name: "Chris" })
    results.last.created_at.must_equal read_time
    results.last.updated_at.must_equal read_time
    results.last.read_at.must_equal read_time
  end
end
