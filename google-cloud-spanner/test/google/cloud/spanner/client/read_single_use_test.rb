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

describe Google::Cloud::Spanner::Client, :read, :single_use, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
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
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.decode_json(results_hash.to_json)].to_enum
  end
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:columns) { [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids] }
  let(:time_obj) { Time.parse "2014-10-02T15:01:23.045123456Z" }
  let(:timestamp) { Google::Cloud::Spanner::Convert.time_to_timestamp time_obj }
  let(:duration) { Google::Cloud::Spanner::Convert.number_to_duration 120 }

  it "reads with strong" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          strong: true, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { strong: true }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with timestamp" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with read_timestamp" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { read_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with staleness" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          exact_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with exact_staleness" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          exact_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { exact_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with bounded_timestamp" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          min_read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { bounded_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with min_read_timestamp" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          min_read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { min_read_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with bounded_staleness" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          max_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { bounded_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with max_staleness" do
    transaction = Google::Spanner::V1::TransactionSelector.new(
      single_use: Google::Spanner::V1::TransactionOptions.new(
        read_only: Google::Spanner::V1::TransactionOptions::ReadOnly.new(
          max_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { max_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
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
