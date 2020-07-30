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

describe Google::Cloud::Spanner::Client, :snapshot, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Cloud::Spanner::V1::Transaction.new id: transaction_id }
  let(:snapshot) { Google::Cloud::Spanner::Snapshot.from_grpc transaction_grpc, session }
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
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }
  let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new return_read_timestamp: true }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new read_only: snp_opts }

  def mock_builder
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    spanner.service.mocked_service = mock
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, options: default_options
    mock
  end

  it "can execute a simple query without any options" do
    mock = mock_builder()

    results = nil
    client.snapshot do |snp|
      _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
      results = snp.execute_query "SELECT * FROM users"
    end

    shutdown_client! client

    mock.verify

    assert_results results
  end

  it "does not allow multiple options to be given" do
    mock = Minitest::Mock.new
    spanner.service.mocked_service = mock

    assert_raises ArgumentError do
      client.snapshot strong: true, timestamp: Time.now do |snp|
        snp.execute_query "SELECT * FROM users"
      end
    end

    shutdown_client! client

    mock.verify
  end

  describe :strong do
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new strong: true, return_read_timestamp: true }

    it "can execute a simple query with the strong option" do
      mock = mock_builder()

      results = nil
      client.snapshot strong: true do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end
  end

  describe :timestamp do
    let(:snapshot_time) { Time.now }
    let(:snapshot_datetime) { snapshot_time.to_datetime }
    let(:snapshot_timestamp) { Google::Cloud::Spanner::Convert.time_to_timestamp snapshot_time }
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new read_timestamp: snapshot_timestamp, return_read_timestamp: true }

    it "can execute a simple query with the timestamp option (Time)" do
      mock = mock_builder()

      results = nil
      client.snapshot timestamp: snapshot_time do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end

    it "can execute a simple query with the read_timestamp option (Time)" do
      mock = mock_builder()

      results = nil
      client.snapshot read_timestamp: snapshot_time do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end

    it "can execute a simple query with the timestamp option (DateTime)" do
      mock = mock_builder()

      results = nil
      client.snapshot timestamp: snapshot_datetime do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end

    it "can execute a simple query with the read_timestamp option (DateTime)" do
      mock = mock_builder()

      results = nil
      client.snapshot read_timestamp: snapshot_datetime do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end
  end

  describe :staleness do
    let(:snapshot_staleness) { 60 }
    let(:duration_staleness) { Google::Cloud::Spanner::Convert.number_to_duration snapshot_staleness }
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new exact_staleness: duration_staleness, return_read_timestamp: true }

    it "can execute a simple query with the staleness option" do
      mock = mock_builder()

      results = nil
      client.snapshot staleness: snapshot_staleness do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end

    it "can execute a simple query with the exact_staleness option" do
      mock = mock_builder()

      results = nil
      client.snapshot exact_staleness: snapshot_staleness do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"
      end

      shutdown_client! client

      mock.verify

      assert_results results
    end
  end

  it "does not allow nested snapshots" do
    mock = mock_builder()

    results = nil
    results2 = nil

    nested_error = assert_raises RuntimeError do
      client.snapshot do |snp|
        _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
        results = snp.execute_query "SELECT * FROM users"

        client.snapshot do |snp2|
          _(snp2).must_be_kind_of Google::Cloud::Spanner::Snapshot
          results2 = snp2.execute_query "SELECT * FROM other_users"
        end
      end
    end
    _(nested_error.message).must_equal "Nested snapshots are not allowed"

    shutdown_client! client

    mock.verify

    assert_results results
    assert_nil results2
  end

  it "can create a snapshot with custom timeout and retry policy" do
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
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, expect_options]
    spanner.service.mocked_service = mock
    expect_execute_streaming_sql results_enum, session_grpc.name, "SELECT * FROM users", transaction: tx_selector, options: default_options

    results = nil
    client.snapshot call_options: call_options do |snp|
      _(snp).must_be_kind_of Google::Cloud::Spanner::Snapshot
      results = snp.execute_query "SELECT * FROM users"
    end

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
