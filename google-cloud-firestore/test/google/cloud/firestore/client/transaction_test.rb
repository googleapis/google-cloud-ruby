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

describe Google::Cloud::Firestore::Client, :transaction, :mock_firestore do
  
  let(:transaction_opt) do
    Google::Cloud::Firestore::V1::TransactionOptions.new(
      read_write: Google::Cloud::Firestore::V1::TransactionOptions::ReadWrite.new
    )
  end
  let(:transaction_opt) do
    Google::Cloud::Firestore::V1::TransactionOptions.new(
      read_write: Google::Cloud::Firestore::V1::TransactionOptions::ReadWrite.new
    )
  end
  let(:read_time) { Time.now }
  let :query_results_enum do
    [
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        transaction: transaction_id,
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/alice",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/carol",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Bob") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

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
  let :begin_tx_resp do
    Google::Cloud::Firestore::V1::BeginTransactionResponse.new(
      transaction: transaction_id
    )
  end
  let :empty_commit_resp do
    Google::Cloud::Firestore::V1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
    )
  end
  let :write_commit_resp do
    Google::Cloud::Firestore::V1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Cloud::Firestore::V1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
    )
  end

  it "runs a simple query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, new_transaction: transaction_opt)
    firestore_mock.expect :commit, empty_commit_resp, commit_args(transaction: transaction_id)

    firestore.transaction do |tx|
      results_enum = tx.get firestore.col(:users).select(:name)
      assert_results_enum results_enum
    end
  end

  it "runs a complex query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, new_transaction: transaction_opt)
    firestore_mock.expect :commit, empty_commit_resp, commit_args(transaction: transaction_id)

    firestore.transaction do |tx|
      results_enum = tx.get firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar)
      assert_results_enum results_enum
    end
  end

  it "runs multiple queries" do
    first_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    second_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(first_query, new_transaction: transaction_opt)
    firestore_mock.expect :run_query, query_results_enum, run_query_args(second_query, transaction: transaction_id)
    firestore_mock.expect :commit, empty_commit_resp, commit_args(transaction: transaction_id)

    firestore.transaction do |tx|
      results_enum = tx.get firestore.col(:users).select(:name)
      assert_results_enum results_enum

      results_enum = tx.get firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar)
      assert_results_enum results_enum
    end
  end

  it "that does nothing makes no calls" do
    firestore.transaction do |tx|
      # no op
    end
  end

  it "creates a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: create_writes)

    resp = firestore.transaction commit_response: true do |tx|
      tx.create(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "creates a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: create_writes)

    doc = firestore.doc document_path
    resp = firestore.transaction commit_response: true do |tx|
      tx.create(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if create is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.create document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "sets a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: set_writes)

    resp = firestore.transaction commit_response: true do |tx|
      tx.set(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "sets a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: set_writes)

    doc = firestore.doc document_path
    resp = firestore.transaction commit_response: true do |tx|
      tx.set(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if set is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.set document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "updates a new document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: update_writes)

    resp = firestore.transaction commit_response: true do |tx|
      tx.update(document_path, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "updates a new document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: update_writes)

    doc = firestore.doc document_path
    resp = firestore.transaction commit_response: true do |tx|
      tx.update(doc, { name: "Alice" })
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "raises if update is not given a Hash" do
    error = expect do
      firestore.transaction do |tx|
        tx.update document_path, "not a hash"
      end
    end.must_raise ArgumentError
    _(error.message).must_equal "data is required"
  end

  it "deletes a document using string path" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: delete_writes)

    resp = firestore.transaction commit_response: true do |tx|
      tx.delete document_path
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "deletes a document using doc ref" do
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: delete_writes)

    doc = firestore.doc document_path
    resp = firestore.transaction commit_response: true do |tx|
      tx.delete doc
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "returns nil when the transaction is empty and commit_response is false or nil" do
    resp = firestore.transaction do |tx|
      # no op
    end

    _(resp).must_be :nil?
  end

  it "returns the user-provided return value from the transaction when commit_response is false or nil" do
    resp = firestore.transaction do |tx|
      # no op
      "my-return-value"
    end

    _(resp).must_equal "my-return-value"
  end

  it "returns commit_time nil when no work is done in the transaction with commit_response: true" do
    resp = firestore.transaction commit_response: true do |tx|
      "my-return-value"
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_be :nil?
  end

  it "performs multiple writes in the same commit (string)" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: all_writes)

    resp = firestore.transaction commit_response: true do |tx|
      tx.create(document_path, { name: "Alice" })
      tx.set(document_path, { name: "Alice" })
      tx.update(document_path, { name: "Alice" })
      tx.delete document_path
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "performs multiple writes in the same commit (doc ref)" do
    all_writes = create_writes + set_writes + update_writes + delete_writes
    firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
    firestore_mock.expect :commit, write_commit_resp, commit_args(transaction: transaction_id, writes: all_writes)

    doc_ref = firestore.doc document_path
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    resp = firestore.transaction commit_response: true do |tx|
      tx.create(doc_ref, { name: "Alice" })
      tx.set(doc_ref, { name: "Alice" })
      tx.update(doc_ref, { name: "Alice" })
      tx.delete doc_ref
    end

    _(resp).must_be_kind_of Google::Cloud::Firestore::CommitResponse
    _(resp.commit_time).must_equal commit_time
  end

  it "closed transactions cannot make changes" do
    doc_ref = firestore.doc document_path
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    outside_transaction_obj = nil

    resp = firestore.transaction commit_response: true do |tx|
      _(tx).wont_be :closed?
      _(tx.firestore).must_equal firestore

      outside_transaction_obj = tx
    end

    _(resp.commit_time).must_be :nil?

    _(outside_transaction_obj).must_be :closed?

    error = expect do
      firestore.batch do |b|
        outside_transaction_obj.create(doc_ref, { name: "Alice" })
      end
    end.must_raise RuntimeError
    _(error.message).must_equal "transaction is closed"
  end

  describe :retry do
    it "retries multiple times when an unavailable error is raised" do
      # Unable to use mocks to define the responses, so stub the methods instead
      def firestore_mock.begin_transaction req, options
        @begin_retries ||= 0
        @begin_retries += 1

        if @begin_retries < 4
          return Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "transaction_#{@begin_retries}")
        end

        raise "bad final begin_transaction" unless req[:options].read_write.retry_transaction == "transaction_3"
        Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "new_transaction_xyz")
      end
      def firestore_mock.commit req, options
        @commit_retries ||= 0
        @commit_retries += 1

        if @commit_retries < 4
          raise "bad commit" unless req[:transaction].start_with?("transaction_")
          raise Google::Cloud::UnavailableError.new("unavailable")
        end

        raise "bad final commit" unless req[:transaction] == "new_transaction_xyz"
        Google::Cloud::Firestore::V1::CommitResponse.new(
          commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
          write_results: [Google::Cloud::Firestore::V1::WriteResult.new(
            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now))]
          )
      end

      def firestore.set_sleep_mock sleep_mock
        @sleep_mock = sleep_mock
      end
      def firestore.sleep num
        @sleep_mock.sleep num
      end
      sleep_mock = Minitest::Mock.new
      sleep_mock.expect :sleep, nil, [1.0]
      sleep_mock.expect :sleep, nil, [1.3]
      sleep_mock.expect :sleep, nil, [1.3*1.3]
      firestore.set_sleep_mock sleep_mock

      do_transaction

      sleep_mock.verify
    end

    it "retries when unavailable, succeeds if invalid arg raised after" do
      # Unable to use mocks to define the responses, so stub the methods instead
      def firestore_mock.begin_transaction req, options
        if @first_begin_transaction.nil?
          @first_begin_transaction = true
          raise "bad first begin_transaction" unless req[:options].read_write.retry_transaction.empty?
          return Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "transaction123")
        end

        raise "bad second begin_transaction" unless req[:options].read_write.retry_transaction == "transaction123"
        Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "new_transaction_xyz")
      end
      def firestore_mock.commit req, options
        if @first_commit.nil?
          @first_commit = true
          raise "bad first commit" unless req[:transaction] == "transaction123"
          raise Google::Cloud::UnavailableError.new("unavailable")
        end

        raise "bad second commit" unless req[:transaction] == "new_transaction_xyz"
        raise Google::Cloud::InvalidArgumentError.new("invalid")
      end

      def firestore.set_sleep_mock sleep_mock
        @sleep_mock = sleep_mock
      end
      def firestore.sleep num
        @sleep_mock.sleep num
      end
      sleep_mock = Minitest::Mock.new
      sleep_mock.expect :sleep, nil, [1.0]
      firestore.set_sleep_mock sleep_mock

      do_transaction

      sleep_mock.verify
    end

    it "does not retry when an unsupported error is raised" do
      firestore_mock.expect :begin_transaction, begin_tx_resp, [{ database: database_path, options: transaction_opt }, default_options]
      firestore_mock.expect :rollback, nil, [{ database: database_path, transaction: transaction_id }, default_options]

      # Unable to use mocks to raise an error, so stub the method instead
      def firestore_mock.commit req, options
        raise "unsupported"
      end

      error = expect do
        do_transaction
      end.must_raise RuntimeError
      _(error.message).must_equal "unsupported"
    end

    describe "success on second attempt" do
      before do
        def firestore_mock.begin_transaction req, options
          if @first_begin_transaction.nil?
            @first_begin_transaction = true
            return Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "transaction123")
          end
          Google::Cloud::Firestore::V1::BeginTransactionResponse.new(transaction: "new_transaction_xyz")
        end

        def firestore_mock.set_commit_response_and_error resp, err
          @commit_resp = resp
          @first_commit_error = err
        end

        def firestore_mock.commit req, options
          if @first_commit.nil?
            @first_commit = true
            raise @first_commit_error
          end
          @commit_resp
        end

        @sleep_mock = Minitest::Mock.new
        @sleep_mock.expect :sleep, nil, [1.0]

        def firestore.set_sleep_mock sleep_mock
          @sleep_mock = sleep_mock
        end

        def firestore.sleep num
          @sleep_mock.sleep num
        end
        firestore.set_sleep_mock @sleep_mock
      end

      after do
        @sleep_mock.verify
      end

      it "retries when Google::Cloud::AbortedError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::AbortedError.new("aborted")
        do_transaction
      end

      it "retries when Google::Cloud::CanceledError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::CanceledError.new("canceled")
        do_transaction
      end

      it "retries when Google::Cloud::UnknownError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::UnknownError.new("unknown")
        do_transaction
      end

      it "retries when Google::Cloud::DeadlineExceededError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::DeadlineExceededError.new("deadline exceeded")
        do_transaction
      end

      it "retries when Google::Cloud::InternalError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::InternalError.new("internal")
        do_transaction
      end

      it "retries when Google::Cloud::UnauthenticatedError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::UnauthenticatedError.new("unauthenticated")
        do_transaction
      end

      it "retries when Google::Cloud::ResourceExhaustedError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::ResourceExhaustedError.new("resource exhausted")
        do_transaction
      end

      it "retries when Google::Cloud::UnavailableError is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::UnavailableError.new("unavailable")
        do_transaction
      end

      it "retries when Google::Cloud::InvalidArgumentError with message matching 'transaction has expired' is raised" do
        firestore_mock.set_commit_response_and_error write_commit_resp, Google::Cloud::InvalidArgumentError.new("The transaction has expired.")
        do_transaction
      end
    end

    def do_transaction
      firestore.transaction do |tx|
        tx.create(document_path, { name: "Alice" })
        tx.set(document_path, { name: "Alice" })
        tx.update(document_path, { name: "Alice" })
        tx.delete document_path
      end
    end
  end

  def assert_results_enum enum
    _(enum).must_be_kind_of Enumerator

    results = enum.to_a
    _(results.count).must_equal 2

    results.each do |result|
      _(result).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      _(result.ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(result.ref.client).must_equal firestore

      _(result.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(result.parent.collection_id).must_equal "users"
      _(result.parent.collection_path).must_equal "users"
      _(result.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"
      _(result.parent.client).must_equal firestore
    end

    _(results.first.data).must_be_kind_of Hash
    _(results.first.data).must_equal({ name: "Alice" })
    _(results.first.created_at).must_equal read_time
    _(results.first.updated_at).must_equal read_time
    _(results.first.read_at).must_equal read_time

    _(results.last.data).must_be_kind_of Hash
    _(results.last.data).must_equal({ name: "Bob" })
    _(results.last.created_at).must_equal read_time
    _(results.last.updated_at).must_equal read_time
    _(results.last.read_at).must_equal read_time
  end
end
