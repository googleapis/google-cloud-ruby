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

describe Google::Cloud::Spanner::Pool, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:tx_opts) { Google::Spanner::V1::TransactionOptions.new(read_write: Google::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:pool) do
    session.instance_variable_set :@last_updated_at, Time.now
    p = client.instance_variable_get :@pool
    p.all_sessions = [session]
    p.session_queue = [session]
    p.transaction_queue = []
    p
  end

  after do
    shutdown_client! client
  end

  it "can checkout and checkin a session" do
    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1

    s = pool.checkout_session

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0

    pool.checkin_session s

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1
  end

  it "creates new sessions when needed" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1

    s1 = pool.checkout_session
    s2 = pool.checkout_session

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 0

    pool.checkin_session s1
    pool.checkin_session s2

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 2

    mock.verify
  end

  it "raises when checking out more than MAX sessions" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1

    s1 = pool.checkout_session
    s2 = pool.checkout_session
    s3 = pool.checkout_session
    s4 = pool.checkout_session

    assert_raises Google::Cloud::Spanner::SessionLimitError do
      pool.checkout_session
    end

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 0

    pool.checkin_session s1
    pool.checkin_session s2
    pool.checkin_session s3
    pool.checkin_session s4

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 4

    mock.verify
  end

  it "raises when checking in a session that does not belong" do
    outside_session = Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service

    checkin_error = assert_raises ArgumentError do
      pool.checkin_session outside_session
    end
    checkin_error.message.must_equal "Cannot checkin session"
  end

  it "uses existing transaction when checking out and checking in a transaction" do
    init_tx = Google::Cloud::Spanner::Transaction.from_grpc Google::Spanner::V1::Transaction.new(id: "tx-001-01"), pool.session_queue.shift
    pool.transaction_queue << init_tx

    mock = Minitest::Mock.new
    # created when checking in
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-02"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    # reload on session pool checkin
    mock.expect :get_session, session_grpc, [session_grpc.name, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-02"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 1
    pool.transaction_queue.first.must_equal init_tx

    tx = pool.checkout_transaction
    tx.must_equal init_tx

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 0

    pool.checkin_transaction tx

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 1
  end

  it "can create a transaction when checking out and checking in a transaction" do
    mock = Minitest::Mock.new
    # created when checking out
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    # created when checking in
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-02"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1
    pool.transaction_queue.size.must_equal 0

    tx = pool.checkout_transaction

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 0

    pool.checkin_transaction tx

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 1
  end

  it "creates new transaction when needed" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    # created when checking out
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-002-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1
    pool.transaction_queue.size.must_equal 0

    tx1 = pool.checkout_transaction
    tx2 = pool.checkout_transaction

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 0

    pool.checkin_transaction tx1
    pool.checkin_transaction tx2

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 2

    mock.verify
  end

  it "creates new transaction when needed using with_transaction" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    # created when checking out
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-002-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    # created when checking in
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-02"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-002-02"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1
    pool.transaction_queue.size.must_equal 0

    pool.with_transaction do |tx1|
      pool.with_transaction do |tx1|
        pool.all_sessions.size.must_equal 2
        pool.session_queue.size.must_equal 0
        pool.transaction_queue.size.must_equal 0
      end
    end

    shutdown_pool! pool

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 2

    mock.verify
  end

  it "raises when checking out more than MAX transaction" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), session: nil, options: default_options]
    # created when checking out
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-001-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-002-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-003-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-004-01"), [session_path(instance_id, database_id, session_id), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool.all_sessions.size.must_equal 1
    pool.session_queue.size.must_equal 1
    pool.transaction_queue.size.must_equal 0

    tx1 = pool.checkout_transaction
    tx2 = pool.checkout_transaction
    tx3 = pool.checkout_transaction
    tx4 = pool.checkout_transaction

    assert_raises Google::Cloud::Spanner::SessionLimitError do
      pool.checkout_transaction
    end

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 0

    pool.checkin_transaction tx1
    pool.checkin_transaction tx2
    pool.checkin_transaction tx3
    pool.checkin_transaction tx4

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 4

    s1 = pool.checkout_session
    s2 = pool.checkout_session

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 0
    pool.transaction_queue.size.must_equal 2

    pool.checkin_session s1
    pool.checkin_session s2

    pool.all_sessions.size.must_equal 4
    pool.session_queue.size.must_equal 2
    pool.transaction_queue.size.must_equal 2

    shutdown_pool! pool

    mock.verify
  end

  it "raises when checking in a transaction that does not belong" do
    outside_session = Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service
    outside_tx = Google::Cloud::Spanner::Transaction.from_grpc Google::Spanner::V1::Transaction.new(id: "outside-tx-001"), outside_session

    checkin_error = assert_raises ArgumentError do
      pool.checkin_transaction outside_tx
    end
    checkin_error.message.must_equal "Cannot checkin session"
  end
end
