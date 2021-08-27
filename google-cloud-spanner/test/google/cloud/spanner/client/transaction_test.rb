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

describe Google::Cloud::Spanner::Client, :transaction, :mock_spanner do
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
  let(:update_results_grpc) {
    Google::Cloud::Spanner::V1::PartialResultSet.new(
      metadata: Google::Cloud::Spanner::V1::ResultSetMetadata.new(
        row_type: Google::Cloud::Spanner::V1::StructType.new(
          fields: []
        )
      ),
      values: [],
      stats: Google::Cloud::Spanner::V1::ResultSetStats.new(
        row_count_exact: 1
      )
    )
  }
  let(:update_results_enum) { Array(update_results_grpc).to_enum }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
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
  let(:mutations) {
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

  it "can execute a simple query" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: [], transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]

    results = nil
    timestamp = client.transaction do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "updates" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "inserts" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([2, "Harvey", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "upserts" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert_or_update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([3, "Marley", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
      }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.upsert "users", [{ id: 3, name: "Marley",  active: false }]
    end
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.save "users", [{ id: 3, name: "Marley",  active: false }]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "replaces" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        replace: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([4, "Henry", true]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.replace "users", [{ id: 4, name: "Henry",  active: true }]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of keys" do
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.delete "users", [1, 2, 3, 4, 5]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "deletes multiple rows of key ranges" do
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil,
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.delete "users", 1..100
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "deletes a single rows" do
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.delete "users", 5
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "deletes all rows" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true)
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.delete "users"
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "commits multiple mutations" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        update: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active address),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false, { postcode: 1234 }]).list_value]
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.transaction do |tx|
      tx.update "users", [{ id: 1, name: "Charlie", active: false, address: { "postcode" => 1234 } }]
      tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      tx.upsert "users", [{ id: 3, name: "Marley",  active: false }]
      tx.replace "users", [{ id: 4, name: "Henry",  active: true }]
      tx.delete "users", [1, 2, 3, 4, 5]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "can execute a simple query with custom timeout and retry policy" do
    timeout = 30
    retry_policy = {
      initial_delay: 0.25,
      max_delay:     32.0,
      multiplier:    1.3,
      retry_codes:   ["UNAVAILABLE"]
    }
    expect_options = default_options.merge timeout: timeout, retry_policy: retry_policy
    call_options = { timeout: timeout, retry_policy: retry_policy }

    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, options: default_options
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: [], transaction_id: transaction_id,
      single_use_transaction: nil, request_options: nil
    }, expect_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]

    results = nil
    timestamp = client.transaction call_options: call_options do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute_query "SELECT * FROM users"
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify

    assert_results results
  end

  describe "priority request options" do
    let(:request_options){
      { priority: :PRIORITY_MEDIUM }
    }

    it "commits multiple mutations" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
      }, default_options]
      mock.expect :commit, commit_resp, [{
        session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
        single_use_transaction: nil, request_options: request_options
      }, default_options]
      # transaction checkin
      mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
      }, default_options]
      spanner.service.mocked_service = mock

      timestamp = client.transaction request_options: request_options do |tx|
        tx.update "users", [{ id: 1, name: "Charlie", active: false }]
        tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        tx.upsert "users", [{ id: 3, name: "Marley",  active: false }]
        tx.replace "users", [{ id: 4, name: "Henry",  active: true }]
        tx.delete "users", [1, 2, 3, 4, 5]
      end
      _(timestamp).must_equal commit_time

      shutdown_client! client

      mock.verify
    end

    it "execute query" do
      mock = Minitest::Mock.new
      spanner.service.mocked_service = mock
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
      }, default_options]
      expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, seqno: 1, request_options: request_options, options: default_options
      mock.expect :commit, commit_resp, [{
        session: session_grpc.name, mutations: [], transaction_id: transaction_id,
        single_use_transaction: nil, request_options: nil
      }, default_options]
      # transaction checkin
      mock.expect :begin_transaction, transaction_grpc, [{
        session: session_grpc.name, options: tx_opts, request_options: nil
      }, default_options]

      timestamp = client.transaction do |tx|
        tx.execute_query "SELECT * FROM users", request_options: request_options
      end
      _(timestamp).must_equal commit_time

      shutdown_client! client

      mock.verify
    end
  end

  it "can execute a trasaction with transaction and request tag" do
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
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]

    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users",
                                 transaction: tx_selector, seqno: 1,
                                 request_options: { transaction_tag: "Tag-1", request_tag: "Tag-1-1" },
                                 options: default_options
    expect_execute_streaming_sql update_results_enum, session_grpc.name,
                                 "UPDATE users SET active = true", transaction: tx_selector,
                                 seqno: 2, request_options: { transaction_tag: "Tag-1", request_tag: "Tag-1-2" },
                                 options: default_options

    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: transaction_id,
      single_use_transaction: nil, request_options: { transaction_tag: "Tag-1" }
    }, default_options]

    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [{
      session: session_grpc.name, options: tx_opts, request_options: nil
    }, default_options]

    client.transaction request_options: { tag: "Tag-1" } do |tx|
      _(tx).must_be_kind_of Google::Cloud::Spanner::Transaction

      tx.execute_query "SELECT * FROM users", request_options: { tag: "Tag-1-1" }
      tx.execute_update "UPDATE users SET active = true", request_options: { tag: "Tag-1-2" }
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
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