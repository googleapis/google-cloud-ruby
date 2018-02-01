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

describe Google::Cloud::Spanner::BatchReadOnlyTransaction, :partition_read, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:batch_tx) { Google::Cloud::Spanner::BatchReadOnlyTransaction.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:columns) { [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids] }
  let(:columns_arg) { ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"] }
  let(:partitions_resp) { Google::Spanner::V1::PartitionResponse.new partitions: [Google::Spanner::V1::Partition.new(partition_token: "partition-token")] }

  it "can read all rows" do

    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(all: true)
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: nil, columns: columns_arg, partition_options: nil, options: default_options}]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_read "my-table", columns

    mock.verify

    assert_partitions partitions
  end

  it "can read rows by id" do

    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3]).list_value])
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: nil, columns: columns_arg, partition_options: nil, options: default_options}]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_read "my-table", columns, keys: [1, 2, 3]

    mock.verify

    assert_partitions partitions, keys: [1, 2, 3]
  end

  it "can read rows with index" do

    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1,1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2,2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3,3]).list_value])
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: "MyTableCompositeKey", columns: columns_arg, partition_options: nil, options: default_options}]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_read "my-table", columns, keys: [[1,1], [2,2], [3,3]], index: "MyTableCompositeKey"

    mock.verify

    assert_partitions partitions, keys: [[1,1], [2,2], [3,3]], index: "MyTableCompositeKey"
  end

  it "can read rows with index and range" do

    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(ranges: [Google::Cloud::Spanner::Convert.to_key_range([1,1]..[3,3])])
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: "MyTableCompositeKey", columns: columns_arg, partition_options: nil, options: default_options}]
    session.service.mocked_service = mock

    lookup_range = batch_tx.range [1,1], [3,3]
    partitions = batch_tx.partition_read "my-table", columns, keys: lookup_range, index: "MyTableCompositeKey"

    mock.verify

    assert_partitions partitions, keys: lookup_range, index: "MyTableCompositeKey"
  end

  it "can read all rows with partition_size_bytes" do
    partition_size_bytes = 65536
    partition_options = Google::Spanner::V1::PartitionOptions.new partition_size_bytes: partition_size_bytes, max_partitions: 0
    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(all: true)
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: nil, columns: columns_arg, partition_options: partition_options, options: default_options}]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_read "my-table", columns, partition_size_bytes: partition_size_bytes

    mock.verify

    assert_partitions partitions, partition_size_bytes: partition_size_bytes
  end

  it "can read all rows with max_partitions" do
    max_partitions = 4
    partition_options = Google::Spanner::V1::PartitionOptions.new partition_size_bytes: 0, max_partitions: max_partitions
    mock = Minitest::Mock.new
    key_set = Google::Spanner::V1::KeySet.new(all: true)
    mock.expect :partition_read, partitions_resp, [session_grpc.name, "my-table", key_set, {transaction: tx_selector, index: nil, columns: columns_arg, partition_options: partition_options, options: default_options}]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_read "my-table", columns, max_partitions: max_partitions

    mock.verify

    assert_partitions partitions, max_partitions: max_partitions
  end

  def assert_partitions partitions, keys: nil, index: nil, partition_size_bytes: nil, max_partitions: nil
    partitions.must_be_kind_of Array
    partitions.wont_be :empty?

    partitions.each do |partition|
      partition.partition_token.must_equal "partition-token"
      partition.table.must_equal "my-table"
      partition.keys.must_equal keys
      partition.columns.must_equal columns
      partition.index.must_equal index
      partition.sql.must_be_nil
      partition.params.must_be_nil
      partition.param_types.must_be_nil
      partition.partition_size_bytes.must_equal partition_size_bytes
      partition.max_partitions.must_equal max_partitions
    end
  end
end
