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

describe Google::Cloud::Spanner::Client, :transaction, :rollback, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:transaction) { Google::Cloud::Spanner::Transaction.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash do
    {
      metadata: {
        rowType: {
          fields: [
            { name: "id",          type: { code: "INT64" } },
            { name: "name",        type: { code: "STRING" } },
            { name: "active",      type: { code: "BOOL" } },
            { name: "age",         type: { code: "INT64" } },
            { name: "score",       type: { code: "FLOAT64" } },
            { name: "updated_at",  type: { code: "TIMESTAMP" } },
            { name: "birthday",    type: { code: "DATE"} },
            { name: "avatar",      type: { code: "BYTES" } },
            { name: "project_ids", type: { code: "ARRAY",
                                           arrayElementType: { code: "INT64" } } }
          ]
        }
      },
      values: [
        { stringValue: "1" },
        { stringValue: "Charlie" },
        { boolValue: true},
        { stringValue: "29" },
        { numberValue: 0.9 },
        { stringValue: "2017-01-02T03:04:05.060000000Z" },
        { stringValue: "1950-01-01" },
        { stringValue: "aW1hZ2U=" },
        { listValue: { values: [ { stringValue: "1"},
                                 { stringValue: "2"},
                                 { stringValue: "3"} ]}}
      ]
    }
  end
  let(:results_json) { results_hash.to_json }
  let(:results_grpc) { Google::Spanner::V1::PartialResultSet.decode_json results_json }
  let(:results_enum) { Array(results_grpc).to_enum }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:tx_opts) { Google::Spanner::V1::TransactionOptions.new(read_write: Google::Spanner::V1::TransactionOptions::ReadWrite.new) }

  it "will rollback and not pass on the error when using Rollback" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "SELECT * FROM users", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, options: default_options]
    mock.expect :rollback, nil, [session_grpc.name, transaction_id, options: default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    results = nil
    timestamp = client.transaction do |tx|
      tx.must_be_kind_of Google::Cloud::Spanner::Transaction
      results = tx.execute "SELECT * FROM users"
      # This mutation will never be committed, so no mocks for it.
      tx.update "users", [{ id: 1, name: "Charlie", active: false }]
      # Cause an error
      raise Google::Cloud::Spanner::Rollback
    end
    timestamp.must_be :nil?

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "will rollback and pass on the error" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "SELECT * FROM users", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, options: default_options]
    mock.expect :rollback, nil, [session_grpc.name, transaction_id, options: default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    results = nil
    assert_raises ZeroDivisionError do
      client.transaction do |tx|
        tx.must_be_kind_of Google::Cloud::Spanner::Transaction
        results = tx.execute "SELECT * FROM users"
        # This mutation will never be committed, so no mocks for it.
        tx.update "users", [{ id: 1, name: "Charlie", active: false }]
        # Cause an error
        1/0
      end
    end

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "does not allow nested transactions" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    mock.expect :rollback, nil, [session_grpc.name, transaction_id, options: default_options]
    # transaction checkin
    mock.expect :begin_transaction, transaction_grpc, [session_grpc.name, tx_opts, options: default_options]
    spanner.service.mocked_service = mock

    nested_error = assert_raises RuntimeError do
      client.transaction do |tx|
        tx.update "users", [{ id: 1, name: "Charlie", active: false }]
        tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        tx.upsert "users", [{ id: 3, name: "Marley",  active: false }]
        tx.replace "users", [{ id: 4, name: "Henry",  active: true }]
        tx.delete "users", [1, 2, 3, 4, 5]

        # A nested transaction is not allowed
        client.transaction do |tx2|
          tx2.insert "users", [{ id: 6, name: "Barney",  active: true }]
        end
      end
    end
    nested_error.message.must_equal "Nested transactions are not allowed"

    shutdown_client! client

    mock.verify
  end

  def assert_results results
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 9
    results.fields[:id].must_equal          :INT64
    results.fields[:name].must_equal        :STRING
    results.fields[:active].must_equal      :BOOL
    results.fields[:age].must_equal         :INT64
    results.fields[:score].must_equal       :FLOAT64
    results.fields[:updated_at].must_equal  :TIMESTAMP
    results.fields[:birthday].must_equal    :DATE
    results.fields[:avatar].must_equal      :BYTES
    results.fields[:project_ids].must_equal [:INT64]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    row[:id].must_equal 1
    row[:name].must_equal "Charlie"
    row[:active].must_equal true
    row[:age].must_equal 29
    row[:score].must_equal 0.9
    row[:updated_at].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    row[:birthday].must_equal Date.parse("1950-01-01")
    row[:avatar].must_be_kind_of StringIO
    row[:avatar].read.must_equal "image"
    row[:project_ids].must_equal [1, 2, 3]
  end
end
