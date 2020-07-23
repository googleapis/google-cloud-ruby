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

describe Google::Cloud::Spanner::Pool, :write_ratio, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:client_pool) do
    session.instance_variable_set :@last_updated_at, Time.now
    p = client.instance_variable_get :@pool
    p.all_sessions = [session]
    p.session_queue = [session]
    p
  end

  after do
    shutdown_client! client
  end

  it "creates two sessions and one transaction" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    sessions = Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new(
      session: [
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002"))
      ]
    )
    mock.expect :batch_create_sessions, sessions, [{ database: database_path(instance_id, database_id), session_count: 2, session_template: nil }, default_options]
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-002-01"), tx_opts, default_options

    pool = Google::Cloud::Spanner::Pool.new client, min: 2, write_ratio: 0.5

    shutdown_pool! pool

    _(pool.all_sessions.size).must_equal 2
    _(pool.session_queue.size).must_equal 1
    _(pool.transaction_queue.size).must_equal 1

    mock.verify
  end

  it "calls batch_create_sessions until min number of sessions are returned" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    sessions = Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new(
      session: [
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")),
      ]
    )
    sessions_2 = Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new(
      session: [
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")),
      ]
    )
    mock.expect :batch_create_sessions, sessions, [{ database: database_path(instance_id, database_id), session_count: 2, session_template: nil }, default_options]
    mock.expect :batch_create_sessions, sessions_2, [{ database: database_path(instance_id, database_id), session_count: 1, session_template: nil }, default_options]
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-002-01"), tx_opts, default_options

    pool = Google::Cloud::Spanner::Pool.new client, min: 2, write_ratio: 0.5

    shutdown_pool! pool

    _(pool.all_sessions.size).must_equal 2
    _(pool.session_queue.size).must_equal 1
    _(pool.transaction_queue.size).must_equal 1

    mock.verify
  end

  it "creates five sessions and three transactions" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    sessions = Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new(
      session: [
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-003")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-004")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-005"))
      ]
    )
    mock.expect :batch_create_sessions, sessions, [{ database: database_path(instance_id, database_id), session_count: 5, session_template: nil }, default_options]
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-003-01"), tx_opts, default_options
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-004-01"), tx_opts, default_options
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-005-01"), tx_opts, default_options

    pool = Google::Cloud::Spanner::Pool.new client, min: 5, write_ratio: 0.5

    shutdown_pool! pool

    _(pool.all_sessions.size).must_equal 5
    _(pool.session_queue.size).must_equal 2
    _(pool.transaction_queue.size).must_equal 3

    mock.verify
  end

  it "creates eight sessions and three transactions" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    sessions = Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new(
      session: [
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-003")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-004")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-005")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-006")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-007")),
        Google::Cloud::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-008"))
      ]
    )
    mock.expect :batch_create_sessions, sessions, [{ database: database_path(instance_id, database_id), session_count: 8, session_template: nil }, default_options]
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-007-01"), tx_opts, default_options
    expect_begin_transaction Google::Cloud::Spanner::V1::Transaction.new(id: "tx-008-01"), tx_opts, default_options

    pool = Google::Cloud::Spanner::Pool.new client, min: 8, write_ratio: 0.3

    shutdown_pool! pool

    _(pool.all_sessions.size).must_equal 8
    _(pool.session_queue.size).must_equal 6
    _(pool.transaction_queue.size).must_equal 2

    mock.verify
  end
end
