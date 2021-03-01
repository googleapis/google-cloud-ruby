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
  let(:commit_resp) { Google::Cloud::Spanner::V1::CommitResponse.new commit_timestamp: commit_timestamp }
  let(:commit_stats_grpc) {
    Google::Cloud::Spanner::V1::CommitResponse::CommitStats.new(
      mutation_count: 5
    )
  }
  let(:commit_stats_resp_grpc) {
    Google::Cloud::Spanner::V1::CommitResponse.new(
      commit_timestamp: commit_timestamp, commit_stats: commit_stats_grpc
    )
  }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  it "commits using a block" do
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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.commit do |c|
      c.update "users", [{ id: 1, name: "Charlie", active: false }]
      c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      c.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      c.replace "users", [{ id: 4, name: "Henry",  active: true }]
      c.delete "users", [1, 2, 3, 4, 5]
    end
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.update "users", [{ id: 1, name: "Charlie", active: false }]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.insert "users", [{ id: 2, name: "Harvey",  active: true }]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.upsert "users", [{ id: 3, name: "Marley",  active: false }]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.save "users", [{ id: 3, name: "Marley",  active: false }]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.replace "users", [{ id: 4, name: "Henry",  active: true }]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", [1, 2, 3, 4, 5]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", [time1, time2, time3, time4]
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", 1..100
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", 5
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", time5
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users"
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, expect_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", call_options: call_options
    _(timestamp).must_equal commit_time

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
    mock.expect :commit, commit_resp, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts }, expect_options]
    spanner.service.mocked_service = mock

    timestamp = client.commit call_options: call_options do |c|
      c.update "users", [{ id: 1, name: "Charlie", active: false }]
      c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      c.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      c.replace "users", [{ id: 4, name: "Henry",  active: true }]
      c.delete "users", [1, 2, 3, 4, 5]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  describe "commit options" do
    let(:commit_options) { { return_commit_stats: true } }

    it "commit using block and return commits stats" do
      mutations = [Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )]
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
      mock.expect :commit, commit_stats_resp_grpc, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.commit commit_options: commit_options do |c|
        c.update "users", [{ id: 1, name: "Charlie", active: false }]
      end

      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end

    it "insert rows and return commits stats" do
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
      mock.expect :commit, commit_stats_resp_grpc, [{session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.insert "users", [{ id: 2, name: "Harvey", active: true }], commit_options: commit_options
      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end

    it "updates rows and return commits stats" do
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
      mock.expect :commit, commit_stats_resp_grpc, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.update "users", [{ id: 1, name: "Charlie", active: false }], commit_options: commit_options
      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end

    it "upsert rows and return commits stats" do
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
      mock.expect :commit, commit_stats_resp_grpc, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.save "users", [{ id: 3, name: "Marley",  active: false }], commit_options: commit_options
      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end

    it "delete rows and return commits stats" do
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
      mock.expect :commit, commit_stats_resp_grpc, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.delete "users", [1, 2, 3, 4, 5], commit_options: commit_options
      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end

    it "replace values and return commits stats" do
      mutations = [
        Google::Cloud::Spanner::V1::Mutation.new(
          replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
            table: "users", columns: %w(id name updated_at),
            values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", "spanner.commit_timestamp()"]).list_value]
          )
        )
      ]

      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :commit, commit_stats_resp_grpc, [{ session: session_grpc.name, mutations: mutations, transaction_id: nil, single_use_transaction: tx_opts, return_commit_stats: true }, default_options]
      spanner.service.mocked_service = mock

      commit_resp = client.replace "users", [{ id: 4, name: "Henry", updated_at: client.commit_timestamp }], commit_options: commit_options
      assert_commit_response commit_resp, commit_stats_resp_grpc

      shutdown_client! client
      mock.verify
    end
  end
end