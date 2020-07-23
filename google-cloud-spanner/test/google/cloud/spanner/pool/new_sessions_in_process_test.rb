# Copyright 2019 Google LLC
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

describe Google::Cloud::Spanner::Pool, :new_sessions_in_process, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
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

  it "does not increment new_sessions_in_process when create_session raises an error" do
    stub = Object.new
    def stub.create_session *args
      raise Google::Cloud::Error.from_error GRPC::BadStatus.new(11, "sumthin happen")
    end
    spanner.service.mocked_service = stub

    _(pool.all_sessions.size).must_equal 1
    _(pool.session_queue.size).must_equal 1
    _(pool.instance_variable_get(:@new_sessions_in_process)).must_equal 0

    s1 = pool.checkout_session # gets the one session from the queue

    _(pool.all_sessions.size).must_equal 1
    _(pool.session_queue.size).must_equal 0
    _(pool.instance_variable_get(:@new_sessions_in_process)).must_equal 0

    raised_error = assert_raises Google::Cloud::Error do
      pool.checkout_session
    end
    _(raised_error.message).must_equal "11:sumthin happen"

    _(pool.all_sessions.size).must_equal 1
    _(pool.session_queue.size).must_equal 0
    _(pool.instance_variable_get(:@new_sessions_in_process)).must_equal 0

    10.times do
      raised_error = assert_raises Google::Cloud::Error do
        pool.checkout_session
      end
      _(raised_error.message).must_equal "11:sumthin happen"
    end

    _(pool.all_sessions.size).must_equal 1
    _(pool.session_queue.size).must_equal 0
    _(pool.instance_variable_get(:@new_sessions_in_process)).must_equal 0

    pool.checkin_session s1

    shutdown_pool! pool

    _(pool.all_sessions.size).must_equal 1
    _(pool.session_queue.size).must_equal 1
    _(pool.instance_variable_get(:@new_sessions_in_process)).must_equal 0
  end
end
