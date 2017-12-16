# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Session, :execute, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
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
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users", transaction: nil, params: nil, param_types: nil, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users"

    mock.verify

    assert_results results
  end

  it "can execute a query with bool param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE active = @active", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "active" => Google::Protobuf::Value.new(bool_value: true) }), param_types: { "active" => Google::Spanner::V1::Type.new(code: :BOOL) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE active = @active", params: { active: true }

    mock.verify

    assert_results results
  end

  it "can execute a query with int param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE age = @age", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") }), param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE age = @age", params: { age: 29 }

    mock.verify

    assert_results results
  end

  it "can execute a query with float param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE score = @score", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9) }), param_types: { "score" => Google::Spanner::V1::Type.new(code: :FLOAT64) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE score = @score", params: { score: 0.9 }

    mock.verify

    assert_results results
  end

  it "can execute a query with Time param" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE updated_at = @updated_at", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "updated_at" => Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z") }), param_types: { "updated_at" => Google::Spanner::V1::Type.new(code: :TIMESTAMP) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE updated_at = @updated_at", params: { updated_at: timestamp }

    mock.verify

    assert_results results
  end

  it "can execute a query with Date param" do
    date = Date.parse "2017-01-02"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE birthday = @birthday", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "birthday" => Google::Protobuf::Value.new(string_value: "2017-01-02") }), param_types: { "birthday" => Google::Spanner::V1::Type.new(code: :DATE) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE birthday = @birthday", params: { birthday: date }

    mock.verify

    assert_results results
  end

  it "can execute a query with String param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE name = @name", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "name" => Google::Protobuf::Value.new(string_value: "Charlie") }), param_types: { "name" => Google::Spanner::V1::Type.new(code: :STRING) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE name = @name", params: { name: "Charlie" }

    mock.verify

    assert_results results
  end

  it "can execute a query with IO-ish param" do
    file = StringIO.new "contents"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE avatar = @avatar", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "avatar" => Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")) }), param_types: { "avatar" => Google::Spanner::V1::Type.new(code: :BYTES) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE avatar = @avatar", params: { avatar: file }

    mock.verify

    assert_results results
  end

  it "can execute a query with an Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE project_ids = @list", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE project_ids = @list", params: { list: [1,2,3] }

    mock.verify

    assert_results results
  end

  it "can execute a query with an empty Array param" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE project_ids = @list", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE project_ids = @list", params: { list: [] }, types: { list: [:INT64] }

    mock.verify

    assert_results results
  end

  it "can execute a query with a simple Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {"env"=>Google::Protobuf::Value.new(string_value: "production")})) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING))])) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE settings = @dict", params: { dict: { env: :production } }

    mock.verify

    assert_results results
  end

  it "can execute a query with a complex Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9), "env" => Google::Protobuf::Value.new(string_value: "production"), "project_ids" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) })) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING)), Google::Spanner::V1::StructType::Field.new(name: "score", type: Google::Spanner::V1::Type.new(code: :FLOAT64)), Google::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)))] )) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE settings = @dict", params: { dict: { env: "production", score: 0.9, project_ids: [1,2,3] } }

    mock.verify

    assert_results results
  end

  it "can execute a query with an empty Hash param" do
    skip "Spanner does not accept STRUCT values in query parameters"

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT * FROM users WHERE settings = @dict", transaction: nil, params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {})) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [])) }, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    results = session.execute "SELECT * FROM users WHERE settings = @dict", params: { dict: { } }

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
    # results.fields[:project_ids].must_equal [:INT64]

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
    # row[:project_ids].must_equal [1, 2, 3]
  end
end
