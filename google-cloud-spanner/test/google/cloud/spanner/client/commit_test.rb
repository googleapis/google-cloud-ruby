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

describe Google::Cloud::Spanner::Client, :read, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:commit_time) { Time.now }
  let(:commit_timestamp) { Google::Cloud::Spanner::Convert.time_to_timestamp commit_time }
  let(:commit_resp) {
    Google::Cloud::Spanner::V1::CommitResponse.new(
      commit_timestamp: commit_timestamp,
      commit_stats: Google::Cloud::Spanner::V1::CommitResponse::CommitStats.new
    )
  }
  let(:commit_stats) {
    Google::Cloud::Spanner::V1::CommitResponse::CommitStats.new(
      mutation_count: 5, overload_delay: Google::Protobuf::Duration.new(seconds: 1, nanos: 100000000)
    )
  }
  let(:commit_resp_with_stats) {
    Google::Cloud::Spanner::V1::CommitResponse.new(
      commit_timestamp: commit_timestamp, commit_stats: commit_stats
    )
  }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:mutations){
   [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([2, "Harvey", true]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", true]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [1, 2, 3, 4, 5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]
  }

  it "commits using a block" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.commit do |c|
      c.update "users", [{ id: 1, name: "Charlie", active: false }]
      c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      c.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      c.replace "users", [{ id: 4, name: "Henry",  active: true }]
      c.delete "users", [1, 2, 3, 4, 5]
    end
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "commits using a block and with commit stats" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.commit commit_stats: true do |c|
      c.update "users", [{ id: 1, name: "Charlie", active: false }]
      c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      c.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      c.replace "users", [{ id: 4, name: "Henry",  active: true }]
      c.delete "users", [1, 2, 3, 4, 5]
    end

    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "updates directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.update "users", [{ id: 1, name: "Charlie", active: false }]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "updates directly and return commit stats" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.update "users", [{ id: 1, name: "Charlie", active: false }], commit_stats: true
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "inserts directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([2, "Harvey", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.insert "users", [{ id: 2, name: "Harvey",  active: true }]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "inserts directly and return commit status" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([2, "Harvey", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.insert "users", [{ id: 2, name: "Harvey",  active: true }], commit_stats: true
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "upserts directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.upsert "users", [{ id: 3, name: "Marley",  active: false }]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "upserts directly and return commit stats" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.upsert "users", [{ id: 3, name: "Marley",  active: false }], commit_stats: true
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "upserts using save alias" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.save "users", [{ id: 3, name: "Marley",  active: false }]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "replaces directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.replace "users", [{ id: 4, name: "Henry",  active: true }]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "replaces directly and return commit stats" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.replace "users", [{ id: 4, name: "Henry",  active: true }], commit_stats: true
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of keys directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [1, 2, 3, 4, 5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", [1, 2, 3, 4, 5]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of keys directly and return commit stats" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [1, 2, 3, 4, 5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp_with_stats, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", [1, 2, 3, 4, 5], commit_stats: true
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 5
    _(resp.stats.overload_delay).must_equal 1.1

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of keys (timestamp keys) directly" do
    time1 = Time.now - 5*60*60
    time2 = Time.now - 5*60*60
    time3 = Time.now - 5*60*60
    time4 = Time.now - 5*60*60

    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [time1, time2, time3, time4].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", [time1, time2, time3, time4]
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of key rangess directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            ranges: [Google::Cloud::Spanner::Convert.to_key_range(1..100)]
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", 1..100
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes a single rows directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", 5
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes a single rows (timestamp key) directly" do
    time5 = Time.now - 5*60*60

    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [time5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", time5
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes all rows directly" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, default_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users"
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "deletes all rows directly with custom timeout and retry policy" do
    timeout = 30
    retry_policy = {
      initial_delay: 0.25,
      max_delay:     32.0,
      multiplier:    1.3,
      retry_codes:   ["UNAVAILABLE"]
    }
    expect_options = default_options.merge timeout: timeout, retry_policy: retry_policy
    call_options = { timeout: timeout, retry_policy: retry_policy }

    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, expect_options]
    spanner.service.mocked_service = mock

    resp = client.delete "users", call_options: call_options
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end

  it "commits using a block with custom timeout and retry policy" do
    timeout = 30
    retry_policy = {
      initial_delay: 0.25,
      max_delay:     32.0,
      multiplier:    1.3,
      retry_codes:   ["UNAVAILABLE"]
    }
    expect_options = default_options.merge timeout: timeout, retry_policy: retry_policy
    call_options = { timeout: timeout, retry_policy: retry_policy }

    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([2, "Harvey", true]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", true]).list_value]
        )
      ),
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [1, 2, 3, 4, 5].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: nil }, expect_options]
    spanner.service.mocked_service = mock

    resp = client.commit call_options: call_options do |c|
      c.update "users", [{ id: 1, name: "Charlie", active: false }]
      c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      c.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      c.replace "users", [{ id: 4, name: "Henry",  active: true }]
      c.delete "users", [1, 2, 3, 4, 5]
    end
    _(resp.timestamp).must_equal commit_time
    _(resp.stats.mutation_count).must_equal 0
    _(resp.stats.overload_delay).must_be :nil?

    shutdown_client! client

    mock.verify
  end
end
