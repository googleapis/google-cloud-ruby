# Copyright 2020 Google LLC
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
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new(read_write: Google::Cloud::Spanner::V1::TransactionOptions::ReadWrite.new) }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  it "commits using a block" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        insert: Google::Cloud::Spanner::V1::Mutation::Write.new(
          table: "users", columns: %w(id name active),
          values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: nil,
      single_use_transaction: tx_opts, request_options: { transaction_tag: "Tag-1"}
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.commit request_options: { tag: "Tag-1"} do |c|
      c.insert "users", [{ id: 1, name: "Charlie", active: false }]
    end
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
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
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: nil,
      single_use_transaction: tx_opts, request_options: { transaction_tag: "Tag-2" }
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.update "users", [{ id: 1, name: "Charlie", active: false }],
                              request_options: { tag: "Tag-2" }
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
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: nil,
      single_use_transaction: tx_opts, request_options: { transaction_tag: "Tag-3" }
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.insert "users", [{ id: 2, name: "Harvey",  active: true }],
                              request_options: { tag: "Tag-3" }
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
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: nil,
      single_use_transaction: tx_opts, request_options: { transaction_tag: "Tag-4" }
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.upsert "users", [{ id: 3, name: "Marley",  active: false }],
                              request_options: { tag: "Tag-4" }
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end

  it "deletes" do
    mutations = [
      Google::Cloud::Spanner::V1::Mutation.new(
        delete: Google::Cloud::Spanner::V1::Mutation::Delete.new(
          table: "users", key_set: Google::Cloud::Spanner::V1::KeySet.new(
            keys: [1, 2].map do |i|
              Google::Cloud::Spanner::Convert.object_to_grpc_value([i]).list_value
            end
          )
        )
      )
    ]

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{database: database_path(instance_id, database_id), session: nil}, default_options]
    mock.expect :commit, commit_resp, [{
      session: session_grpc.name, mutations: mutations, transaction_id: nil,
      single_use_transaction: tx_opts, request_options: { transaction_tag: "Tag-5" }
    }, default_options]
    spanner.service.mocked_service = mock

    timestamp = client.delete "users", [1, 2], request_options: { tag: "Tag-5" }
    _(timestamp).must_equal commit_time

    shutdown_client! client

    mock.verify
  end
end
