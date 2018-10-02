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

describe Google::Cloud::Spanner::Transaction, :execute_update, :mock_spanner do
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
  let(:results_grpc) {
    Google::Spanner::V1::PartialResultSet.new(
      metadata: Google::Spanner::V1::ResultSetMetadata.new(
        row_type: Google::Spanner::V1::StructType.new(
          fields: []
        )
      ),
      values: [],
      stats: Google::Spanner::V1::ResultSetStats.new(
        row_count_exact: 1
      )
    )
  }
  let(:results_enum) { Array(results_grpc).to_enum }

  it "can execute a DML query" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET active = true", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET active = true"

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with bool param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET active = @active", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "active" => Google::Protobuf::Value.new(bool_value: true) }), param_types: { "active" => Google::Spanner::V1::Type.new(code: :BOOL) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET active = @active", params: { active: true }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with int param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET age = @age", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") }), param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET age = @age", params: { age: 29 }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with float param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET score = @score", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9) }), param_types: { "score" => Google::Spanner::V1::Type.new(code: :FLOAT64) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET score = @score", params: { score: 0.9 }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with Time param" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET updated_at = @updated_at", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "updated_at" => Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z") }), param_types: { "updated_at" => Google::Spanner::V1::Type.new(code: :TIMESTAMP) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET updated_at = @updated_at", params: { updated_at: timestamp }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with Date param" do
    date = Date.parse "2017-01-02"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET birthday = @birthday", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "birthday" => Google::Protobuf::Value.new(string_value: "2017-01-02") }), param_types: { "birthday" => Google::Spanner::V1::Type.new(code: :DATE) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET birthday = @birthday", params: { birthday: date }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with String param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET name = @name", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "name" => Google::Protobuf::Value.new(string_value: "Charlie") }), param_types: { "name" => Google::Spanner::V1::Type.new(code: :STRING) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET name = @name", params: { name: "Charlie" }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with IO-ish param" do
    file = StringIO.new "contents"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET avatar = @avatar", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "avatar" => Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")) }), param_types: { "avatar" => Google::Spanner::V1::Type.new(code: :BYTES) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET avatar = @avatar", params: { avatar: file }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with an Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET project_ids = @list", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET project_ids = @list", params: { list: [1,2,3] }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with an empty Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET project_ids = @list", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET project_ids = @list", params: { list: [] }, types: { list: [:INT64] }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with a simple Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "UPDATE users SET settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "production")])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING))])) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET settings = @dict", params: { dict: { env: :production } }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with a complex Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "UPDATE users SET settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "production"), Google::Protobuf::Value.new(number_value: 0.9), Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) ])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING)), Google::Spanner::V1::StructType::Field.new(name: "score", type: Google::Spanner::V1::Type.new(code: :FLOAT64)), Google::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)))] )) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET settings = @dict", params: { dict: { env: "production", score: 0.9, project_ids: [1,2,3] } }

    mock.verify

    row_count.must_equal 1
  end

  it "can execute a DML query with an empty Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [])) }, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    row_count = transaction.execute_update "UPDATE users SET settings = @dict", params: { dict: { } }

    mock.verify

    row_count.must_equal 1
  end

  it "raises InvalidArgumentError if the response does not contain stats" do
    no_stats_results_grpc = results_grpc.dup
    no_stats_results_grpc.stats = nil
    no_stats_results_enum = Array(no_stats_results_grpc).to_enum

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, no_stats_results_enum, [session_grpc.name, "UPDATE users SET active = true", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
    session.service.mocked_service = mock

    err = expect do
      transaction.execute_update "UPDATE users SET active = true"
    end.must_raise Google::Cloud::InvalidArgumentError

    mock.verify
  end
end
