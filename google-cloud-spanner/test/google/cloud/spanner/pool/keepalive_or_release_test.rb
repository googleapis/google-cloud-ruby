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

describe Google::Cloud::Spanner::Pool, :keepalive_or_release, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Cloud::Spanner::V1::Transaction.new id: transaction_id }
  let(:transaction) { Google::Cloud::Spanner::Transaction.from_grpc transaction_grpc, session }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:pool) { client.instance_variable_get :@pool }
  let :results_hash do
    {
      metadata: {
        row_type: {
          fields: [
            { type: { code: :INT64 } }
          ]
        }
      },
      values: [ { string_value: "1" }]
    }
  end
  let(:results_grpc) { Google::Cloud::Spanner::V1::PartialResultSet.new results_hash }
  let(:results_enum) { Array(results_grpc).to_enum }

  before do
    # kill the background thread before starting the tests
    pool.instance_variable_get(:@keepalive_task).shutdown
  end

  after do
    shutdown_client! client
  end

  it "calls keepalive on the sessions that need it" do
    # update the session so it was last updated an hour ago
    session.instance_variable_set :@last_updated_at, Time.now - 60*60
    # set the session in the pool
    pool.all_sessions = [session]
    pool.session_queue = [session]

    mock = Minitest::Mock.new
    session.service.mocked_service = mock
    expect_execute_streaming_sql results_enum, session.path, "SELECT 1", options: default_options

    pool.keepalive_or_release!

    shutdown_pool! pool

    mock.verify
  end

  it "calls keepalive on the transactions that need it" do
    # update the session so it was last updated an hour ago
    session.instance_variable_set :@last_updated_at, Time.now - 60*60
    # set the session in the pool
    pool.all_sessions = [session]
    pool.transaction_queue = [transaction]

    mock = Minitest::Mock.new
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    session.service.mocked_service = mock

    pool.keepalive_or_release!

    shutdown_pool! pool

    mock.verify
  end

  it "doesn't call keepalive on sessions that don't need it" do
    # update the session so it was last updated now
    session.instance_variable_set :@last_updated_at, Time.now
    # set the session in the pool
    pool.all_sessions = [session]
    pool.session_queue = [session]

    mock = Minitest::Mock.new
    session.service.mocked_service = mock

    pool.keepalive_or_release!

    shutdown_pool! pool

    mock.verify
  end

  it "doesn't call keepalive on transactions that don't need it" do
    # update the session so it was last updated now
    session.instance_variable_set :@last_updated_at, Time.now
    # set the session in the pool
    pool.all_sessions = [session]
    pool.transaction_queue = [transaction]

    mock = Minitest::Mock.new
    session.service.mocked_service = mock

    pool.keepalive_or_release!

    shutdown_pool! pool

    mock.verify
  end
end
