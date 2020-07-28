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

describe Google::Cloud::Spanner::Snapshot, :read, :mock_spanner do
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
  let :results_hash1 do
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
      }
    }
  end
  let :results_hash2 do
    {
      values: [
        { string_value: "1" },
        { string_value: "Charlie" },
        { bool_value: true},
        { string_value: "29" },
        { number_value: 0.9 },
        { string_value: "2017-01-02T03:04:05.060000000Z" },
        { string_value: "1950-01-01" },
        { string_value: "aW1hZ2U=" }
      ]
    }
  end
  let :results_hash3 do
    {
      values: [
        { list_value: { values: [ { string_value: "1"},
                                 { string_value: "2"},
                                 { string_value: "3"} ]}}
      ]
    }
  end
  let(:results_enum) do
    [Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash1),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash2),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_hash3)].to_enum
  end

  it "can read all rows" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: tx_selector, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns

    mock.verify

    assert_results results
  end

  it "can read rows by id" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value, Google::Cloud::Spanner::Convert.object_to_grpc_value([2]).list_value, Google::Cloud::Spanner::Convert.object_to_grpc_value([3]).list_value]),
      transaction: tx_selector, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns, keys: [1, 2, 3]

    mock.verify

    assert_results results
  end

  it "can read rows with index" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1,1]).list_value, Google::Cloud::Spanner::Convert.object_to_grpc_value([2,2]).list_value, Google::Cloud::Spanner::Convert.object_to_grpc_value([3,3]).list_value]),
      transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns, keys: [[1,1], [2,2], [3,3]], index: "MyTableCompositeKey"

    mock.verify

    assert_results results
  end

  it "can read rows with index and range" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(ranges: [Google::Cloud::Spanner::Convert.to_key_range([1,1]..[3,3])]),
      transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    lookup_range = snapshot.range [1,1], [3,3]
    results = snapshot.read "my-table", columns, keys: lookup_range, index: "MyTableCompositeKey"

    mock.verify

    assert_results results
  end

  it "can read rows with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: tx_selector, index: nil, limit: 5, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns, limit: 5

    mock.verify

    assert_results results
  end

  it "can read just one row with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value]),
      transaction: tx_selector, index: nil, limit: 1, resume_token: nil, partition_token: nil
    }, default_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns, keys: 1, limit: 1

    mock.verify

    assert_results results
  end

  it "can read all rows with custom timeout and retry policy" do
    timeout = 30
    retry_policy = {
      initial_delay: 0.25,
      max_delay:     32.0,
      multiplier:    1.3,
      retry_codes:   ["UNAVAILABLE"]
    }
    expect_options = default_options.merge timeout: timeout, retry_policy: retry_policy

    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [{
      session: session_grpc.name, table: "my-table",
      columns: ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"],
      key_set: Google::Cloud::Spanner::V1::KeySet.new(all: true),
      transaction: tx_selector, index: nil, limit: nil, resume_token: nil, partition_token: nil
    }, expect_options]
    session.service.mocked_service = mock

    results = snapshot.read "my-table", columns, timeout: timeout, retry_policy: retry_policy

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
