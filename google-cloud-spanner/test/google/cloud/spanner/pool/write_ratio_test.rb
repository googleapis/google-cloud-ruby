# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Spanner::Pool, :write_ratio, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:tx_opts) { Google::Spanner::V1::TransactionOptions.new(read_write: Google::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client_pool) do
    session.instance_variable_set :@last_updated_at, Time.now
    p = client.instance_variable_get :@pool
    p.all_sessions = [session]
    p.session_queue = [session]
    p
  end

  after do
    # Close the client and release the keepalive thread
    client.instance_variable_get(:@pool).all_sessions = []
    client.close
  end

  def wait_until_thread_pool_is_done! pool
    thread_pool = pool.instance_variable_get :@thread_pool
    thread_pool.shutdown
    thread_pool.wait_for_termination 60
  end

  it "creates two sessions and one transaction" do
    mock = Minitest::Mock.new
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-002-01"), [session_path(instance_id, database_id, "session-002"), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool = Google::Cloud::Spanner::Pool.new client, min: 2, write_ratio: 0.5

    wait_until_thread_pool_is_done! pool

    pool.all_sessions.size.must_equal 2
    pool.session_queue.size.must_equal 1
    pool.transaction_queue.size.must_equal 1

    pool.session_queue.first.session_id.must_equal "session-001"
    pool.transaction_queue.first.transaction_id.must_equal "tx-002-01"
    pool.transaction_queue.first.session.session_id.must_equal "session-002"

    mock.verify
  end

  it "creates five sessions and three transactions" do
    mock = Minitest::Mock.new
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-003")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-004")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-005")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-003-01"), [session_path(instance_id, database_id, "session-003"), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-004-01"), [session_path(instance_id, database_id, "session-004"), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-005-01"), [session_path(instance_id, database_id, "session-005"), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool = Google::Cloud::Spanner::Pool.new client, min: 5, write_ratio: 0.5

    wait_until_thread_pool_is_done! pool

    pool.all_sessions.size.must_equal 5
    pool.session_queue.size.must_equal 2
    pool.transaction_queue.size.must_equal 3

    mock.verify
  end

  it "creates eight sessions and three transactions" do
    mock = Minitest::Mock.new
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-001")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-002")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-003")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-004")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-005")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-006")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-007")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, Google::Spanner::V1::Session.new(name: session_path(instance_id, database_id, "session-008")), [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-007-01"), [session_path(instance_id, database_id, "session-007"), tx_opts, options: default_options]
    mock.expect :begin_transaction, Google::Spanner::V1::Transaction.new(id: "tx-008-01"), [session_path(instance_id, database_id, "session-008"), tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    pool = Google::Cloud::Spanner::Pool.new client, min: 8, write_ratio: 0.3

    wait_until_thread_pool_is_done! pool

    pool.all_sessions.size.must_equal 8
    pool.session_queue.size.must_equal 6
    pool.transaction_queue.size.must_equal 2

    mock.verify
  end
end
