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

describe Google::Cloud::Spanner::Convert, :to_query_params, :mock_spanner do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "converts a bool value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params active: true
    combined_params.must_equal({ "active" => [Google::Protobuf::Value.new(bool_value: true),
                                              Google::Spanner::V1::Type.new(code: :BOOL)] })
  end

  it "converts a nil bool value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({active: nil}, {active: :BOOL})
    combined_params.must_equal({ "active" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                              Google::Spanner::V1::Type.new(code: :BOOL)] })
  end

  it "converts a int value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params age: 29
    combined_params.must_equal({ "age" => [Google::Protobuf::Value.new(string_value: "29"),
                                           Google::Spanner::V1::Type.new(code: :INT64)] })
  end

  it "converts a nil int value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({age: nil}, {age: :INT64})
    combined_params.must_equal({ "age" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                           Google::Spanner::V1::Type.new(code: :INT64)] })
  end

  it "converts a float value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: 0.9
    combined_params.must_equal({ "score" => [Google::Protobuf::Value.new(number_value: 0.9),
                                             Google::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (Infinity)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: Float::INFINITY
    combined_params.must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "Infinity"),
                                             Google::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (-Infinity)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: -Float::INFINITY
    combined_params.must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "-Infinity"),
                                             Google::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (NaN)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: Float::NAN
    combined_params.must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "NaN"),
                                             Google::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a nil float value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({score: nil}, {score: :FLOAT64})
    combined_params.must_equal({ "score" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                             Google::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a Time value" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params updated_at: timestamp
    combined_params.must_equal({ "updated_at" => [Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z"),
                                                  Google::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a DateTime value" do
    timestamp = DateTime.parse "2017-01-01 20:04:05.06 -0700"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params updated_at: timestamp
    combined_params.must_equal({ "updated_at" => [Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z"),
                                                  Google::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a nil value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({updated_at: nil}, {updated_at: :TIMESTAMP})
    combined_params.must_equal({ "updated_at" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                                  Google::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a Date value" do
    date = Date.parse "2017-01-02"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params birthday: date
    combined_params.must_equal({ "birthday" => [Google::Protobuf::Value.new(string_value: "2017-01-02"),
                                                Google::Spanner::V1::Type.new(code: :DATE)] })
  end

  it "converts a nil Date value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({birthday: nil}, {birthday: :DATE})
    combined_params.must_equal({ "birthday" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                                Google::Spanner::V1::Type.new(code: :DATE)] })
  end

  it "converts a String value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params name: "Charlie"
    combined_params.must_equal({ "name" => [Google::Protobuf::Value.new(string_value: "Charlie"),
                                            Google::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a Symbol value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params name: :foo
    combined_params.must_equal({ "name" => [Google::Protobuf::Value.new(string_value: "foo"),
                                            Google::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a nil String value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({name: nil}, {name: :STRING})
    combined_params.must_equal({ "name" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a IO-ish value" do
    file = StringIO.new "contents"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params avatar: file
    combined_params.must_equal({ "avatar" => [Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")),
                                              Google::Spanner::V1::Type.new(code: :BYTES)] })
  end

  it "converts a nil IO-ish value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({avatar: nil}, {avatar: :BYTES})
    combined_params.must_equal({ "avatar" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                              Google::Spanner::V1::Type.new(code: :BYTES)] })
  end

  it "converts an Array of Integer values" do
    array = [1, 2, 3]

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts an empty Array of Integer values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, {list: [:INT64]})
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts a nil Array of Integer values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:INT64]})
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts an Array of String values" do
    array = %w(foo bar baz)

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "foo"), Google::Protobuf::Value.new(string_value: "bar"), Google::Protobuf::Value.new(string_value: "baz")])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts an empty Array of String values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, list: [:STRING])
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts a nil Array of String values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:STRING]})
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts an Array of IO-ish values" do
    array = [StringIO.new("foo"), StringIO.new("bar"), StringIO.new("baz")]

    foo, bar, baz = %w[ foo bar baz ].map {|raw| Base64.strict_encode64(raw) }

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: foo), Google::Protobuf::Value.new(string_value: bar), Google::Protobuf::Value.new(string_value: baz)])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts an empty Array of IO-ish values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, list: [:BYTES])
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts a nil Array of IO-ish values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:BYTES]})
    combined_params.must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts a simple Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: { foo: :bar }
    combined_params.must_equal({ "settings" => [Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {"foo"=>Google::Protobuf::Value.new(string_value: "bar")})),
                                                Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Spanner::V1::Type.new(code: :STRING))]))] })
  end

  it "converts a complex Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: { env: "production", score: 0.9, project_ids: [1,2,3] }
    combined_params.must_equal({ "settings" => [Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: { "score"=>Google::Protobuf::Value.new(number_value: 0.9), "env"=>Google::Protobuf::Value.new(string_value: "production"), "project_ids"=>Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) })),
                                                Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [ Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING)), Google::Spanner::V1::StructType::Field.new(name: "score", type: Google::Spanner::V1::Type.new(code: :FLOAT64)), Google::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64))) ] ))] })
  end

  it "converts an emtpy Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: {}
    combined_params.must_equal({ "settings" => [Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: {})),
                                                Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: []))] })
  end
end
