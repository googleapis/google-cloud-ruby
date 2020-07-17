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
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
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
  let(:results_enum) do
    [Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash)].to_enum
  end
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:columns) { [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids] }
  let(:time_obj) { Time.parse "2014-10-02T15:01:23.045123456Z" }
  let(:timestamp) { Google::Cloud::Spanner::Convert.time_to_timestamp time_obj }
  let(:duration) { Google::Cloud::Spanner::Convert.number_to_duration 120 }

  it "reads with strong" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          strong: true, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { strong: true }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with timestamp" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with read_timestamp" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { read_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with staleness" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          exact_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with exact_staleness" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          exact_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { exact_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with bounded_timestamp" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          min_read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { bounded_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with min_read_timestamp" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          min_read_timestamp: timestamp, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { min_read_timestamp: time_obj }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with bounded_staleness" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          max_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { bounded_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "reads with max_staleness" do
    transaction = Google::Cloud::Spanner::V1::TransactionSelector.new(
      single_use: Google::Cloud::Spanner::V1::TransactionOptions.new(
        read_only: Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new(
          max_staleness: duration, return_read_timestamp: true
        )
      )
    )

    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: transaction, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    spanner.service.mocked_service = mock

    results = client.read "my-table", columns, single_use: { max_staleness: 120 }

    shutdown_client! client

    mock.verify

    assert_results results
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
