# Copyright 2018 Google LLC
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

describe Google::Cloud::Spanner::BatchSnapshot, :read, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:batch_snapshot) { Google::Cloud::Spanner::BatchSnapshot.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let :results_hash1 do
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
      }
    }
  end
  let :results_hash2 do
    {
      values: [
        { stringValue: "1" },
        { stringValue: "Charlie" },
        { boolValue: true},
        { stringValue: "29" },
        { numberValue: 0.9 },
        { stringValue: "2017-01-02T03:04:05.060000000Z" },
        { stringValue: "1950-01-01" },
        { stringValue: "aW1hZ2U=" }
      ]
    }
  end
  let :results_hash3 do
    {
      values: [
        { listValue: { values: [ { stringValue: "1"},
                                 { stringValue: "2"},
                                 { stringValue: "3"} ]}}
      ]
    }
  end
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.decode_json(results_hash1.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_hash2.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_hash3.to_json)].to_enum
  end

  it "can read all rows" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: tx_selector, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = batch_snapshot.read "my-table", columns

    mock.verify

    assert_results results
  end

  it "can read rows by id" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3]).list_value]), transaction: tx_selector, index: nil, limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = batch_snapshot.read "my-table", columns, keys: [1, 2, 3]

    mock.verify

    assert_results results
  end

  it "can read rows with index" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1,1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2,2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3,3]).list_value]), transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = batch_snapshot.read "my-table", columns, keys: [[1,1], [2,2], [3,3]], index: "MyTableCompositeKey"

    mock.verify

    assert_results results
  end

  it "can read rows with index and range" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(ranges: [Google::Cloud::Spanner::Convert.to_key_range([1,1]..[3,3])]), transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    lookup_range = Google::Cloud::Spanner::Range.new [1,1], [3,3]
    results = batch_snapshot.read "my-table", columns, keys: lookup_range, index: "MyTableCompositeKey"

    mock.verify

    assert_results results
  end

  it "can read rows with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: tx_selector, index: nil, limit: 5, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = batch_snapshot.read "my-table", columns, limit: 5

    mock.verify

    assert_results results
  end

  it "can read just one row with limit" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session_grpc.name, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value]), transaction: tx_selector, index: nil, limit: 1, resume_token: nil, partition_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = batch_snapshot.read "my-table", columns, keys: 1, limit: 1

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
