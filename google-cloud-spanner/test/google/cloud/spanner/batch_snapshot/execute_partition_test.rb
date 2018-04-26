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

describe Google::Cloud::Spanner::BatchSnapshot, :execute_partition, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:batch_snapshot) { Google::Cloud::Spanner::BatchSnapshot.from_grpc transaction_grpc, session }
  let(:partition_token) { "my-partition" }
  let(:table) { "my-table" }
  let(:sql) { "SELECT * FROM users" }
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

  it "can execute a simple query" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, sql, transaction: tx_selector, params: nil, param_types: {}, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql: sql)

    mock.verify

    assert_results results
  end

  it "can execute a query with bool param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE active = @active", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "active" => Google::Protobuf::Value.new(bool_value: true) }), param_types: { "active" => Google::Spanner::V1::Type.new(code: :BOOL).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql: "SELECT * FROM users WHERE active = @active", params: { active: true } )

    mock.verify

    assert_results results
  end

  it "can execute a query with int param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE age = @age", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") }), param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE age = @age", params: { age: 29 } )

    mock.verify

    assert_results results
  end

  it "can execute a query with float param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE score = @score", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9) }), param_types: { "score" => Google::Spanner::V1::Type.new(code: :FLOAT64).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE score = @score", params: { score: 0.9 } )

    mock.verify

    assert_results results
  end

  it "can execute a query with Time param" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE updated_at = @updated_at", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "updated_at" => Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z") }), param_types: { "updated_at" => Google::Spanner::V1::Type.new(code: :TIMESTAMP).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE updated_at = @updated_at", params: { updated_at: timestamp } )

    mock.verify

    assert_results results
  end

  it "can execute a query with Date param" do
    date = Date.parse "2017-01-02"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE birthday = @birthday", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "birthday" => Google::Protobuf::Value.new(string_value: "2017-01-02") }), param_types: { "birthday" => Google::Spanner::V1::Type.new(code: :DATE).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE birthday = @birthday", params: { birthday: date } )

    mock.verify

    assert_results results
  end

  it "can execute a query with String param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE name = @name", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "name" => Google::Protobuf::Value.new(string_value: "Charlie") }), param_types: { "name" => Google::Spanner::V1::Type.new(code: :STRING).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE name = @name", params: { name: "Charlie" } )

    mock.verify

    assert_results results
  end

  it "can execute a query with IO-ish param" do
    file = StringIO.new "contents"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE avatar = @avatar", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "avatar" => Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")) }), param_types: { "avatar" => Google::Spanner::V1::Type.new(code: :BYTES).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE avatar = @avatar", params: { avatar: file } )

    mock.verify

    assert_results results
  end

  it "can execute a query with an Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE project_ids = @list", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE project_ids = @list", params: { list: [1,2,3] } )

    mock.verify

    assert_results results
  end

  it "can execute a query with an empty Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE project_ids = @list", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE project_ids = @list", params: { list: [] }, param_types: { list: [:INT64] } )

    mock.verify

    assert_results results
  end

  it "can execute a query with a simple Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "production")])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING))])).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE settings = @dict", params: { dict: { env: :production } } )

    mock.verify

    assert_results results
  end

  it "can execute a query with a complex Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [ Google::Protobuf::Value.new(string_value: "production"), Google::Protobuf::Value.new(number_value: 0.9), Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) ])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING)), Google::Spanner::V1::StructType::Field.new(name: "score", type: Google::Spanner::V1::Type.new(code: :FLOAT64)), Google::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)))] )).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE settings = @dict", params: { dict: { env: "production", score: 0.9, project_ids: [1,2,3] } } )

    mock.verify

    assert_results results
  end

  it "can execute a query with an empty Hash param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: tx_selector, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [])).to_h }, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(sql:  "SELECT * FROM users WHERE settings = @dict", params: { dict: { } } )

    mock.verify

    assert_results results
  end

  it "can read all rows" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(all: true), transaction: tx_selector, index: "", limit: nil, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(table: "my-table", columns: columns)

    mock.verify

    assert_results results
  end

  it "can read rows by id" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3]).list_value]), transaction: tx_selector, index: "", limit: nil, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(table: "my-table", columns: columns, keys: [1, 2, 3])

    mock.verify

    assert_results results
  end

  it "can read rows with index" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(keys: [Google::Cloud::Spanner::Convert.raw_to_value([1,1]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([2,2]).list_value, Google::Cloud::Spanner::Convert.raw_to_value([3,3]).list_value]), transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    results = batch_snapshot.execute_partition partition(table: "my-table", columns: columns, keys: [[1,1], [2,2], [3,3]], index: "MyTableCompositeKey")

    mock.verify

    assert_results results
  end

  it "can read rows with index and range" do
    columns = [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]

    mock = Minitest::Mock.new
    mock.expect :streaming_read, results_enum, [session.path, "my-table", ["id", "name", "active", "age", "score", "updated_at", "birthday", "avatar", "project_ids"], Google::Spanner::V1::KeySet.new(ranges: [Google::Cloud::Spanner::Convert.to_key_range([1,1]..[3,3])]), transaction: tx_selector, index: "MyTableCompositeKey", limit: nil, resume_token: nil, partition_token: partition_token, options: default_options]
    batch_snapshot.session.service.mocked_service = mock

    lookup_range = Google::Cloud::Spanner::Range.new [1,1], [3,3]
    results = batch_snapshot.execute_partition partition(table: "my-table", columns: columns, keys: lookup_range, index: "MyTableCompositeKey")

    mock.verify

    assert_results results
  end

  def partition table: nil, keys: nil, columns: nil, index: nil, sql: nil,
                params: nil, param_types: nil
    if table
      columns = Array(columns).map(&:to_s)
      keys = Google::Cloud::Spanner::Convert.to_key_set keys

      read_grpc = Google::Spanner::V1::ReadRequest.new(
        {
          session: session.path,
          table: table,
          columns: columns,
          key_set: keys,
          index: index,
          transaction: tx_selector,
          partition_token: partition_token
        }.delete_if { |_, v| v.nil? }
      )

      Google::Cloud::Spanner::Partition.from_read_grpc read_grpc
    else #sql
      params, param_types = Google::Cloud::Spanner::Convert.to_input_params_and_types params, param_types

      execute_grpc = Google::Spanner::V1::ExecuteSqlRequest.new(
        {
          session: session.path,
          sql: sql,
          params: params,
          param_types: param_types,
          transaction: tx_selector,
          partition_token: partition_token
        }.delete_if { |_, v| v.nil? }
      )

      Google::Cloud::Spanner::Partition.from_execute_grpc execute_grpc
    end
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
