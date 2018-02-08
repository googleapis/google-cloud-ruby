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

describe Google::Cloud::Spanner::BatchReadOnlyTransaction, :execute, :mock_spanner do
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
  let(:partitions_resp) { Google::Spanner::V1::PartitionResponse.new partitions: [Google::Spanner::V1::Partition.new(partition_token: "partition-token")] }

  it "can execute a simple query" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users"
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: nil, param_types: nil, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql

    mock.verify

    assert_partitions partitions
  end

  it "can execute a query with bool param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE active = @active"
    params = Google::Protobuf::Struct.new(fields: { "active" => Google::Protobuf::Value.new(bool_value: true) })
    param_types = { "active" => Google::Spanner::V1::Type.new(code: :BOOL) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { active: true }

    mock.verify

    assert_partitions partitions, sql, params: { active: true }
  end

  it "can execute a query with int param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE age = @age"
    params = Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") })
    param_types = { "age" => Google::Spanner::V1::Type.new(code: :INT64) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { age: 29 }

    mock.verify

    assert_partitions partitions, sql, params: { age: 29 }
  end

  it "can execute a query with float param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE score = @score"
    params = Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9) })
    param_types = { "score" => Google::Spanner::V1::Type.new(code: :FLOAT64) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { score: 0.9 }

    mock.verify

    assert_partitions partitions, sql, params: { score: 0.9 }
  end

  it "can execute a query with Time param" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE updated_at = @updated_at"
    params = Google::Protobuf::Struct.new(fields: { "updated_at" => Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z") })
    param_types = { "updated_at" => Google::Spanner::V1::Type.new(code: :TIMESTAMP) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { updated_at: timestamp }

    mock.verify

    assert_partitions partitions, sql, params: { updated_at: timestamp }
  end

  it "can execute a query with Date param" do
    date = Date.parse "2017-01-02"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE birthday = @birthday"
    params = Google::Protobuf::Struct.new(fields: { "birthday" => Google::Protobuf::Value.new(string_value: "2017-01-02") })
    param_types = { "birthday" => Google::Spanner::V1::Type.new(code: :DATE) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { birthday: date }

    mock.verify

    assert_partitions partitions, sql, params: { birthday: date }
  end

  it "can execute a query with String param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE name = @name"
    params = Google::Protobuf::Struct.new(fields: { "name" => Google::Protobuf::Value.new(string_value: "Charlie") })
    param_types = { "name" => Google::Spanner::V1::Type.new(code: :STRING) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { name: "Charlie" }

    mock.verify

    assert_partitions partitions, sql, params: { name: "Charlie" }
  end

  it "can execute a query with IO-ish param" do
    file = StringIO.new "contents"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE avatar = @avatar"
    params = Google::Protobuf::Struct.new(fields: { "avatar" => Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")) })
    param_types = { "avatar" => Google::Spanner::V1::Type.new(code: :BYTES) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { avatar: file }

    mock.verify

    assert_partitions partitions, sql, params: { avatar: file }
  end

  it "can execute a query with an Array param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE project_ids = @list"
    params = Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])) })
    param_types = { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { list: [1,2,3] }

    mock.verify

    assert_partitions partitions, sql, params: { list: [1,2,3] }
  end

  it "can execute a query with an empty Array param" do
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE project_ids = @list"
    params = Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) })
    param_types = { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { list: [] }, types: { list: [:INT64] }

    mock.verify

    assert_partitions partitions, sql, params: { list: [] }, types: { list: [:INT64] }
  end

  it "can execute a query with a simple Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE settings = @dict"
    params = Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {"env"=>Google::Protobuf::Value.new(string_value: "production")})) })
    param_types = { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING))])) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { dict: { env: :production } }

    mock.verify

    assert_partitions partitions, sql, params: { dict: { env: :production } }
  end

  it "can execute a query with a complex Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE settings = @dict"
    params = Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9), "env" => Google::Protobuf::Value.new(string_value: "production"), "project_ids" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) })) })
    param_types = { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING)), Google::Spanner::V1::StructType::Field.new(name: "score", type: Google::Spanner::V1::Type.new(code: :FLOAT64)), Google::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)))] )) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { dict: { env: "production", score: 0.9, project_ids: [1,2,3] } }

    mock.verify

    assert_partitions partitions, sql, params: { dict: { env: "production", score: 0.9, project_ids: [1,2,3] } }
  end

  it "can execute a query with an empty Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    sql = "SELECT * FROM users WHERE settings = @dict"
    params = Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {})) })
    param_types = { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [])) }
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: params, param_types: param_types, partition_options: nil, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, params: { dict: { } }

    mock.verify

    assert_partitions partitions, sql, params: { dict: { } }
  end

  it "can execute a query with partition_size_bytes" do
    partition_size_bytes = 65536
    partition_options = Google::Spanner::V1::PartitionOptions.new partition_size_bytes: partition_size_bytes, max_partitions: 0
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users"
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: nil, param_types: nil, partition_options: partition_options, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, partition_size_bytes: partition_size_bytes

    mock.verify

    assert_partitions partitions
  end

  it "can execute a query with max_partitions" do
    max_partitions = 4
    partition_options = Google::Spanner::V1::PartitionOptions.new partition_size_bytes: 0, max_partitions: max_partitions
    mock = Minitest::Mock.new
    sql = "SELECT * FROM users"
    mock.expect :partition_query, partitions_resp, [session.path, sql, transaction: tx_selector, params: nil, param_types: nil, partition_options: partition_options, options: default_options]
    session.service.mocked_service = mock

    partitions = batch_tx.partition_query sql, max_partitions: max_partitions

    mock.verify

    assert_partitions partitions
  end

  def assert_partitions partitions, sql = "SELECT * FROM users", params: nil, types: nil
    partitions.must_be_kind_of Array
    partitions.wont_be :empty?

    partitions.each do |partition|
      partition.partition_token.must_equal "partition-token"
      partition.table.must_be_nil
      partition.keys.must_be_nil
      partition.columns.must_be_nil
      partition.index.must_be_nil
      partition.sql.must_equal sql
      partition.params.must_equal params
      partition.param_types.must_equal types
    end
  end
end
