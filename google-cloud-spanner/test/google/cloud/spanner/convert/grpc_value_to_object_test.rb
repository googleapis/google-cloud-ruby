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
require "bigdecimal"

describe Google::Cloud::Spanner::Convert, :grpc_value_to_object, :mock_spanner do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "converts a BOOL value" do
    value = Google::Protobuf::Value.new(bool_value: true)
    type = Google::Cloud::Spanner::V1::Type.new(code: :BOOL)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal true
  end

  it "converts a INT64 value" do
    value = Google::Protobuf::Value.new(string_value: "29")
    type = Google::Cloud::Spanner::V1::Type.new(code: :INT64)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal 29
  end

  it "converts a FLOAT64 value" do
    value = Google::Protobuf::Value.new(number_value: 0.9)
    type = Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal 0.9
  end

  it "converts a FLOAT64 value (Infinity)" do
    value = Google::Protobuf::Value.new(string_value: "Infinity")
    type = Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal Float::INFINITY
  end

  it "converts a FLOAT64 value (-Infinity)" do
    value = Google::Protobuf::Value.new(string_value: "-Infinity")
    type = Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal -Float::INFINITY
  end

  it "converts a FLOAT64 value (NaN)" do
    value = Google::Protobuf::Value.new(string_value: "NaN")
    type = Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_be :nan? # equality checks on Float::NAN fails
  end

  it "converts a TIMESTAMP value" do
    value = Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z")
    type = Google::Cloud::Spanner::V1::Type.new(code: :TIMESTAMP)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal Time.parse("2017-01-02 03:04:05.06 UTC")
  end

  it "converts a DATE value" do
    value = Google::Protobuf::Value.new(string_value: "2017-01-02")
    type = Google::Cloud::Spanner::V1::Type.new(code: :DATE)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal Date.parse("2017-01-02")
  end

  it "converts a STRING value" do
    value = Google::Protobuf::Value.new(string_value: "Charlie")
    type = Google::Cloud::Spanner::V1::Type.new(code: :STRING)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal "Charlie"
  end

  it "converts a BYTES value" do
    value = Google::Protobuf::Value.new(string_value: Base64.encode64("contents"))
    type = Google::Cloud::Spanner::V1::Type.new(code: :BYTES)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_be_kind_of StringIO
    _(raw.read).must_equal "contents"
  end

  it "converts an ARRAY of INT64 values" do
    value = Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")]))
    type = Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal [1, 2, 3]
  end

  it "converts an ARRAY of STRING values" do
    value = Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "foo"), Google::Protobuf::Value.new(string_value: "bar"), Google::Protobuf::Value.new(string_value: "baz")]))
    type = Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal %w(foo bar baz)
  end

  it "converts a simple STRUCT value" do
    value = Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "bar")]))
    type = Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))]))
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal Google::Cloud::Spanner::Fields.new(foo: :STRING).struct(foo: "bar")
  end

  it "converts a complex STRUCT value" do
    value = Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [ Google::Protobuf::Value.new(string_value: "production"), Google::Protobuf::Value.new(number_value: 0.9), Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) ]))
    type = Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [ Google::Cloud::Spanner::V1::StructType::Field.new(name: "env", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "score", type: Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))) ] ))
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal Google::Cloud::Spanner::Fields.new(env: :STRING, score: :FLOAT64, project_ids: [:INT64]).struct({env: "production", score: 0.9, project_ids: [1,2,3]})
  end

  it "converts an emtpy STRUCT value" do
    value = Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: []))
    type = Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: []))
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal(Google::Cloud::Spanner::Fields.new([]).struct([]))
  end

  it "converts a NUMERIC value" do
    number = "99999999999999999999999999999.999999999"
    value = Google::Protobuf::Value.new(string_value: number)
    type = Google::Spanner::V1::Type.new(code: :NUMERIC)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal BigDecimal(number)
  end

  it "converts a JSON value" do
    venue_detail = { "name" => "ABC", "open" => true, "rating" => 10 }

    value = Google::Protobuf::Value.new(string_value: venue_detail.to_json)
    type = Google::Spanner::V1::Type.new(code: :JSON)
    raw = Google::Cloud::Spanner::Convert.grpc_value_to_object value, type
    _(raw).must_equal venue_detail
  end
end
