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

describe Google::Cloud::Spanner::Client, :transaction, :retry, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Cloud::Spanner::V1::Transaction.new id: transaction_id }
  let(:transaction) { Google::Cloud::Spanner::Transaction.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Cloud::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let :results_hash do
    {
      metadata: {
        row_type: {
          fields: [
            { name: "id",          type: { code: :INT64 } },
            { name: "name",        type: { code: :STRING } },
            { name: "active",      type: { code: :BOOL } },
            { name: "age",         type: { code: :INT64 } },
            { name: "score",       type: { code: :FLOAT64 } },
            { name: "updated_at",  type: { code: :TIMESTAMP } },
            { name: "birthday",    type: { code: :DATE} },
            { name: "avatar",      type: { code: :BYTES } },
            { name: "project_ids", type: { code: :ARRAY,
                                           array_element_type: { code: :INT64 } } }
          ]
        }
      },
      values: [
        { string_value: "1" },
        { string_value: "Charlie" },
        { bool_value: true},
        { string_value: "29" },
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" },
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" },
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ]
    }
  end
  let(:results_grpc) { Google::Cloud::Spanner::V1::PartialResultSet.new results_hash }
  let(:results_enum) { Array(results_grpc).to_enum }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }

  it "retries aborted transactions without retry metadata" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]

    def mock.commit *args
      # first time called this will raise
      if @called == nil
        @called = true
        gax_error = Google::Cloud::AbortedError.new "aborted"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(10, "aborted")
        raise gax_error
      end
      # second call will return correct response
      Google::Cloud::Spanner::V1::CommitResponse.new commit_timestamp: Google::Protobuf::Timestamp.new()
    end
    mock.expect :sleep, nil, [1.3]

    client.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end

    results = nil
    client.transaction do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
    end

    assert_results results

    shutdown_client! client

    mock.verify
  end

  it "retries aborted transactions with retry metadata seconds" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]

    def mock.commit *args
      # first time called this will raise
      if @called == nil
        @called = true
        raise GRPC::Aborted.new "aborted", {"retryDelay"=>{"seconds"=>60}}
      end
      # second call will return correct response
      Google::Cloud::Spanner::V1::CommitResponse.new commit_timestamp: Google::Protobuf::Timestamp.new()
    end
    mock.expect :sleep, nil, [60]

    client.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end

    results = nil
    client.transaction do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
    end

    assert_results results

    shutdown_client! client

    mock.verify
  end

  it "retries aborted transactions with retry metadata seconds and nanos" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]

    def mock.commit *args
      # first time called this will raise
      if @called == nil
        @called = true
        raise GRPC::Aborted.new "aborted", {"retryDelay"=>{"seconds"=>123, "nanos"=>456000000}}
      end
      # second call will return correct response
      Google::Cloud::Spanner::V1::CommitResponse.new commit_timestamp: Google::Protobuf::Timestamp.new()
    end
    mock.expect :sleep, nil, [123.456]

    client.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end

    results = nil
    client.transaction do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
    end

    assert_results results

    shutdown_client! client

    mock.verify
  end

  it "retries multiple aborted transactions" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]

    def mock.commit *args
      # first time called this will raise
      if @called == nil
        @called = false
        raise GRPC::Aborted.new "aborted"
      end
      if @called == false
        @called = true
        raise GRPC::Aborted.new "aborted", {"retryDelay"=>{"seconds"=>30}}
      end
      # third call will return correct response
      Google::Cloud::Spanner::V1::CommitResponse.new commit_timestamp: Google::Protobuf::Timestamp.new()
    end
    mock.expect :sleep, nil, [1.3]
    mock.expect :sleep, nil, [30]

    client.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end

    results = nil
    client.transaction do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
    end

    assert_results results

    shutdown_client! client

    mock.verify
  end

  it "retries with incremental backoff until deadline has passed" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]

    def mock.commit *args
      raise GRPC::Aborted.new "aborted"
    end
    mock.expect :sleep, nil, [1.3]
    mock.expect :sleep, nil, [1.6900000000000002]
    mock.expect :sleep, nil, [2.1970000000000005]
    mock.expect :sleep, nil, [2.856100000000001]

    mock.expect :current_time, Time.now, []
    mock.expect :current_time, Time.now, []
    mock.expect :current_time, Time.now + 30, []
    mock.expect :current_time, Time.now + 60, []
    mock.expect :current_time, Time.now + 90, []
    mock.expect :current_time, Time.now + 125, []

    client.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end
    client.define_singleton_method :current_time do
      # call the mock to satisfy the expectation
      mock.current_time
    end

    assert_raises Google::Cloud::AbortedError do
      client.transaction do |tx|
        _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
        results = tx.execute_query "SELECT * FROM users"
        tx.update "users", [{ id: 1, name: "Charlie", active: false }]
      end
    end

    shutdown_client! client

    mock.verify
  end

  def assert_results results
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 9
    _(results.fields[:id]).must_equal          :INT64
    _(results.fields[:name]).must_equal        :STRING
    _(results.fields[:active]).must_equal      :BOOL
    _(results.fields[:age]).must_equal         :INT64
    _(results.fields[:score]).must_equal       :FLOAT64
    _(results.fields[:updated_at]).must_equal  :TIMESTAMP
    _(results.fields[:birthday]).must_equal    :DATE
    _(results.fields[:avatar]).must_equal      :BYTES
    _(results.fields[:project_ids]).must_equal [:INT64]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    _(row[:id]).must_equal 1
    _(row[:name]).must_equal "Charlie"
    _(row[:active]).must_equal true
    _(row[:age]).must_equal 29
    _(row[:score]).must_equal 0.9
    _(row[:updated_at]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(row[:birthday]).must_equal Date.parse("1950-01-01")
    _(row[:avatar]).must_be_kind_of StringIO
    _(row[:avatar].read).must_equal "image"
    _(row[:project_ids]).must_equal [1, 2, 3]
  end
end
