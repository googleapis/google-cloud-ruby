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

describe Google::Cloud::Spanner::Convert, :to_query_params, :mock_spanner do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "converts a bool value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params active: true
    _(combined_params).must_equal({ "active" => [Google::Protobuf::Value.new(bool_value: true),
                                              Google::Cloud::Spanner::V1::Type.new(code: :BOOL)] })
  end

  it "converts a nil bool value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({active: nil}, {active: :BOOL})
    _(combined_params).must_equal({ "active" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                              Google::Cloud::Spanner::V1::Type.new(code: :BOOL)] })
  end

  it "converts a int value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params age: 29
    _(combined_params).must_equal({ "age" => [Google::Protobuf::Value.new(string_value: "29"),
                                           Google::Cloud::Spanner::V1::Type.new(code: :INT64)] })
  end

  it "converts a nil int value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({age: nil}, {age: :INT64})
    _(combined_params).must_equal({ "age" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                           Google::Cloud::Spanner::V1::Type.new(code: :INT64)] })
  end

  it "converts a float value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: 0.9
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(number_value: 0.9),
                                             Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (Infinity)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: Float::INFINITY
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "Infinity"),
                                             Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (-Infinity)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: -Float::INFINITY
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "-Infinity"),
                                             Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a float value (NaN)" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: Float::NAN
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(string_value: "NaN"),
                                             Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a nil float value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({score: nil}, {score: :FLOAT64})
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                             Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)] })
  end

  it "converts a Time value" do
    timestamp = Time.parse "2017-01-01 20:04:05.06 -0700"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params updated_at: timestamp
    _(combined_params).must_equal({ "updated_at" => [Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z"),
                                                  Google::Cloud::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a DateTime value" do
    timestamp = DateTime.parse "2017-01-01 20:04:05.06 -0700"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params updated_at: timestamp
    _(combined_params).must_equal({ "updated_at" => [Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z"),
                                                  Google::Cloud::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a nil value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({updated_at: nil}, {updated_at: :TIMESTAMP})
    _(combined_params).must_equal({ "updated_at" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                                  Google::Cloud::Spanner::V1::Type.new(code: :TIMESTAMP)] })
  end

  it "converts a Date value" do
    date = Date.parse "2017-01-02"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params birthday: date
    _(combined_params).must_equal({ "birthday" => [Google::Protobuf::Value.new(string_value: "2017-01-02"),
                                                Google::Cloud::Spanner::V1::Type.new(code: :DATE)] })
  end

  it "converts a nil Date value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({birthday: nil}, {birthday: :DATE})
    _(combined_params).must_equal({ "birthday" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                                Google::Cloud::Spanner::V1::Type.new(code: :DATE)] })
  end

  it "converts a String value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params name: "Charlie"
    _(combined_params).must_equal({ "name" => [Google::Protobuf::Value.new(string_value: "Charlie"),
                                            Google::Cloud::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a Symbol value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params name: :foo
    _(combined_params).must_equal({ "name" => [Google::Protobuf::Value.new(string_value: "foo"),
                                            Google::Cloud::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a nil String value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({name: nil}, {name: :STRING})
    _(combined_params).must_equal({ "name" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Cloud::Spanner::V1::Type.new(code: :STRING)] })
  end

  it "converts a IO-ish value" do
    file = StringIO.new "contents"

    combined_params = Google::Cloud::Spanner::Convert.to_query_params avatar: file
    _(combined_params).must_equal({ "avatar" => [Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")),
                                              Google::Cloud::Spanner::V1::Type.new(code: :BYTES)] })
  end

  it "converts a nil IO-ish value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({avatar: nil}, {avatar: :BYTES})
    _(combined_params).must_equal({ "avatar" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                              Google::Cloud::Spanner::V1::Type.new(code: :BYTES)] })
  end

  it "converts an Array of Integer values" do
    array = [1, 2, 3]

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts an empty Array of Integer values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, {list: [:INT64]})
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts a nil Array of Integer values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:INT64]})
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))] })
  end

  it "converts an Array of String values" do
    array = %w(foo bar baz)

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "foo"), Google::Protobuf::Value.new(string_value: "bar"), Google::Protobuf::Value.new(string_value: "baz")])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts an empty Array of String values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, list: [:STRING])
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts a nil Array of String values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:STRING]})
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))] })
  end

  it "converts an Array of IO-ish values" do
    array = [StringIO.new("foo"), StringIO.new("bar"), StringIO.new("baz")]

    foo, bar, baz = %w[ foo bar baz ].map {|raw| Base64.strict_encode64(raw) }

    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: array
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: foo), Google::Protobuf::Value.new(string_value: bar), Google::Protobuf::Value.new(string_value: baz)])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts an empty Array of IO-ish values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, list: [:BYTES])
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts a nil Array of IO-ish values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, {list: [:BYTES]})
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :BYTES))] })
  end

  it "converts a simple Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: { foo: :bar }
    _(combined_params).must_equal({ "settings" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "bar")])),
                                                Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))]))] })
  end

  it "converts a complex Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: { env: "production", score: 0.9, project_ids: [1,2,3] }
    _(combined_params).must_equal({ "settings" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [ Google::Protobuf::Value.new(string_value: "production"), Google::Protobuf::Value.new(number_value: 0.9), Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")] )) ])),
                                                Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [ Google::Cloud::Spanner::V1::StructType::Field.new(name: "env", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "score", type: Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64))) ] ))] })
  end

  it "converts an emtpy Hash value" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params settings: {}
    _(combined_params).must_equal({ "settings" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                                Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: []))] })
  end

  it "converts an empty Array of Data values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: []}, list: [fields(foo: :STRING)])
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))])))] })
  end

  it "converts a nil Array of Data values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params({list: nil}, list: [fields(foo: :STRING)])
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(null_value: :NULL_VALUE),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))])))] })
  end

  it "converts an Array of simple Data values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: [{ foo: :bar }]
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "bar")]))])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRUCT,struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "foo", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING))]))) ]})
  end

  it "converts an Array complex Data values" do
    combined_params = Google::Cloud::Spanner::Convert.to_query_params list: [{ env: "production", score: 0.9, project_ids: [1,2,3] }]
    _(combined_params).must_equal({ "list" => [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "production"), Google::Protobuf::Value.new(number_value: 0.9), Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")]))]))])),
                                            Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Cloud::Spanner::V1::StructType.new(fields: [Google::Cloud::Spanner::V1::StructType::Field.new(name: "env", type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "score", type: Google::Cloud::Spanner::V1::Type.new(code: :FLOAT64)), Google::Cloud::Spanner::V1::StructType::Field.new(name: "project_ids", type: Google::Cloud::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)))]))) ]})
  end

  it "converts a numeric (BigDecimal) value" do
    number = "99999999999999999999999999999.999999999"
    combined_params = Google::Cloud::Spanner::Convert.to_query_params score: BigDecimal(number)
    _(combined_params).must_equal({ "score" => [Google::Protobuf::Value.new(string_value: number),
                                             Google::Spanner::V1::Type.new(code: :NUMERIC)] })
  end

  it "converts a Hash to json value " do
    value = { name: "ABC", open: true, rating: 10 }
    combined_params = Google::Cloud::Spanner::Convert.to_query_params(
      { venue_detail: value }, { venue_detail: :JSON }
    )
    _(combined_params).must_equal({
      "venue_detail" => [ Google::Protobuf::Value.new(string_value: value.to_json),
                          Google::Spanner::V1::Type.new(code: :JSON)]
    })
  end

  describe "Struct Parameters Query Examples" do
    # Simple field access.
    # [parameters=STRUCT<threadf INT64, userf STRING>(1,"bob") AS struct_param, 10 as p4]
    # SELECT @struct_param.userf, @p4;
    describe "Simple field access" do
      it "with Hash" do
        params = { struct_param: { threadf: 1, userf: "bob" }, p4: 10 }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ],
          "p4" => [
            Google::Protobuf::Value.new(string_value: "10"),
            Google::Cloud::Spanner::V1::Type.new(code: :INT64)
          ]
        })
      end

      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        params = { struct_param: { threadf: 1, userf: "bob" }, p4: 10 }
        types = { struct_param: fields, p4: :INT64 }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ],
          "p4" => [
            Google::Protobuf::Value.new(string_value: "10"),
            Google::Cloud::Spanner::V1::Type.new(code: :INT64)
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        data = fields.struct threadf: 1, userf: "bob"
        params = { struct_param: data, p4: 10 }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ],
          "p4" => [
            Google::Protobuf::Value.new(string_value: "10"),
            Google::Cloud::Spanner::V1::Type.new(code: :INT64)
          ]
        })
      end
    end

    # # Simple field access on NULL struct value.
    # [parameters=CAST(NULL AS STRUCT<threadf INT64, userf STRING>) AS struct_param]
    # SELECT @struct_param.userf;
    describe "Simple field access on NULL struct value" do
      it "with nil and type" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        params = { struct_param: nil }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(null_value: :NULL_VALUE),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Nested struct field access.
    # [parameters=STRUCT<structf STRUCT<nestedf STRING>> (STRUCT<nestedf STRING>("bob")) AS struct_param]
    # SELECT @struct_param.structf.nestedf;
    describe "Nested struct field access" do
      it "with Hash" do
        params = { struct_param: { structf: { nestedf: "bob" } } }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "structf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :STRUCT,
                      struct_type: Google::Cloud::Spanner::V1::StructType.new(
                        fields: [
                          Google::Cloud::Spanner::V1::StructType::Field.new(
                            name: "nestedf",
                            type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                          )
                        ]
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new structf: Google::Cloud::Spanner::Fields.new(nestedf: :STRING)
        params = { struct_param: { structf: { nestedf: "bob" } } }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "structf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :STRUCT,
                      struct_type: Google::Cloud::Spanner::V1::StructType.new(
                        fields: [
                          Google::Cloud::Spanner::V1::StructType::Field.new(
                            name: "nestedf",
                            type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                          )
                        ]
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new structf: Google::Cloud::Spanner::Fields.new(nestedf: :STRING)
        data = fields.struct structf: { nestedf: "bob" }
        params = { struct_param: data }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "structf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :STRUCT,
                      struct_type: Google::Cloud::Spanner::V1::StructType.new(
                        fields: [
                          Google::Cloud::Spanner::V1::StructType::Field.new(
                            name: "nestedf",
                            type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                          )
                        ]
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Nested struct field access on NULL struct value.
    # [parameters=CAST(STRUCT(null) AS STRUCT<structf STRUCT<nestedf STRING>>) AS  struct_param]
    # SELECT @struct_param.structf.nestedf;
    describe "Nested struct field access on NULL struct value" do
      it "with nil and type" do
        fields = Google::Cloud::Spanner::Fields.new structf: Google::Cloud::Spanner::Fields.new(nestedf: :STRING)
        params = { struct_param: nil }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(null_value: :NULL_VALUE),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "structf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :STRUCT,
                      struct_type: Google::Cloud::Spanner::V1::StructType.new(
                        fields: [
                          Google::Cloud::Spanner::V1::StructType::Field.new(
                            name: "nestedf",
                            type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                          )
                        ]
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Non-NULL struct with no fields (empty struct).
    # [parameters=CAST(STRUCT() AS STRUCT<>) AS struct_param]
    # SELECT @struct_param IS NULL;
    describe "Non-NULL struct with no fields (empty struct)" do
      it "with Hash" do
        params = { struct_param: {} }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: []
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: []
              )
            )
          ]
        })
      end

      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new({})
        params = { struct_param: {} }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: []
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: []
              )
            )
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new({})
        data = fields.struct({})
        params = { struct_param: data }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: []
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: []
              )
            )
          ]
        })
      end
    end

    # # NULL struct with no fields.
    # [parameters=CAST(NULL AS STRUCT<>) AS struct_param]
    # SELECT @struct_param IS NULL
    describe "NULL struct with no fields" do
      it "with nil and type" do
        fields = Google::Cloud::Spanner::Fields.new({})
        params = { struct_param: nil }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(null_value: :NULL_VALUE),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: []
              )
            )
          ]
        })
      end
    end

    # # Struct with single NULL field.
    # [parameters=STRUCT<f1 INT64>(NULL) AS struct_param]
    # SELECT @struct_param.f1;
    describe "Struct with single NULL field" do
      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new f1: :INT64
        params = { struct_param: { f1: nil } }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(null_value: :NULL_VALUE)
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "f1",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new f1: :INT64
        data = fields.struct f1: nil
        params = { struct_param: data }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(null_value: :NULL_VALUE)
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "f1",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Equality check.
    # [parameters=STRUCT<threadf INT64, userf STRING>(1,"bob") AS struct_param]
    # SELECT @struct_param=STRUCT<threadf INT64, userf STRING>(1,"bob");
    describe "Equality check" do
      it "with Hash" do
        params = { struct_param: { threadf: 1, userf: "bob" } }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        params = { struct_param: { threadf: 1, userf: "bob" } }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        data = fields.struct threadf: 1, userf: "bob"
        params = { struct_param: data }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "1"),
                  Google::Protobuf::Value.new(string_value: "bob")
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "threadf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "userf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Nullness check.
    # [parameters=ARRAY<STRUCT<threadf INT64, userf STRING>> [(1,"bob")] AS struct_arr_param]
    # SELECT @struct_arr_param IS NULL;
    describe "Nullness check" do
      it "with Array of Hash" do
        params = { struct_arr_param: [{ threadf: 1, userf: "bob" }] }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_arr_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "1"),
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :ARRAY,
              array_element_type: Google::Cloud::Spanner::V1::Type.new(
                code: :STRUCT,
                struct_type: Google::Cloud::Spanner::V1::StructType.new(
                  fields: [
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "threadf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                    ),
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "userf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                    )
                  ]
                )
              )
            )
          ]
        })
      end

      it "with Array of Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        params = { struct_arr_param: [{ threadf: 1, userf: "bob" }] }
        types = { struct_arr_param: [fields] }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_arr_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "1"),
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :ARRAY,
              array_element_type: Google::Cloud::Spanner::V1::Type.new(
                code: :STRUCT,
                struct_type: Google::Cloud::Spanner::V1::StructType.new(
                  fields: [
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "threadf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                    ),
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "userf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                    )
                  ]
                )
              )
            )
          ]
        })
      end

      it "with Array of Data" do
        fields = Google::Cloud::Spanner::Fields.new threadf: :INT64, userf: :STRING
        data = fields.struct threadf: 1, userf: "bob"
        params = { struct_arr_param: [data] }
        types = nil
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_arr_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(
                    list_value: Google::Protobuf::ListValue.new(
                      values: [
                        Google::Protobuf::Value.new(string_value: "1"),
                        Google::Protobuf::Value.new(string_value: "bob")
                      ]
                    )
                  )
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :ARRAY,
              array_element_type: Google::Cloud::Spanner::V1::Type.new(
                code: :STRUCT,
                struct_type: Google::Cloud::Spanner::V1::StructType.new(
                  fields: [
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "threadf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                    ),
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "userf",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :STRING)
                    )
                  ]
                )
              )
            )
          ]
        })
      end
    end

    # # Null array of struct field.
    # [parameters=STRUCT<intf INT64, arraysf ARRAY<STRUCT<threadid INT64>>> (10,CAST(NULL AS ARRAY<STRUCT<threadid INT64>>)) AS struct_param]
    # SELECT a.threadid FROM UNNEST(@struct_param.arraysf) a;
    describe "Null array of struct field" do
      it "with Hash and type" do
        fields = Google::Cloud::Spanner::Fields.new intf: :INT64, arraysf: [Google::Cloud::Spanner::Fields.new(threadid: :INT64)]
        data = fields.struct intf: 10, arraysf: nil
        params = { struct_param: { intf: 10, arraysf: nil } }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "10"),
                  Google::Protobuf::Value.new(null_value: :NULL_VALUE)
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "intf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "arraysf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :ARRAY,
                      array_element_type: Google::Cloud::Spanner::V1::Type.new(
                        code: :STRUCT,
                        struct_type: Google::Cloud::Spanner::V1::StructType.new(
                          fields: [
                            Google::Cloud::Spanner::V1::StructType::Field.new(
                              name: "threadid",
                              type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                            )
                          ]
                        )
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end

      it "with Data" do
        fields = Google::Cloud::Spanner::Fields.new intf: :INT64, arraysf: [Google::Cloud::Spanner::Fields.new(threadid: :INT64)]
        data = fields.struct intf: 10, arraysf: nil
        params = { struct_param: data }
        types = { struct_param: fields }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_param" => [
            Google::Protobuf::Value.new(
              list_value: Google::Protobuf::ListValue.new(
                values: [
                  Google::Protobuf::Value.new(string_value: "10"),
                  Google::Protobuf::Value.new(null_value: :NULL_VALUE)
                ]
              )
            ),
            Google::Cloud::Spanner::V1::Type.new(
              code: :STRUCT,
              struct_type: Google::Cloud::Spanner::V1::StructType.new(
                fields: [
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "intf",
                    type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                  ),
                  Google::Cloud::Spanner::V1::StructType::Field.new(
                    name: "arraysf",
                    type: Google::Cloud::Spanner::V1::Type.new(
                      code: :ARRAY,
                      array_element_type: Google::Cloud::Spanner::V1::Type.new(
                        code: :STRUCT,
                        struct_type: Google::Cloud::Spanner::V1::StructType.new(
                          fields: [
                            Google::Cloud::Spanner::V1::StructType::Field.new(
                              name: "threadid",
                              type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                            )
                          ]
                        )
                      )
                    )
                  )
                ]
              )
            )
          ]
        })
      end
    end

    # # Null array of struct.
    # [parameters=CAST(NULL AS ARRAY<STRUCT<threadid INT64>>) as struct_arr_param]
    # SELECT a.threadid FROM UNNEST(@struct_arr_param) a;
    describe "Null array of struct" do
      it "with nil and type" do
        fields = Google::Cloud::Spanner::Fields.new threadid: :INT64
        params = { struct_arr_param: nil }
        types = { struct_arr_param: [fields] }
        combined_params = Google::Cloud::Spanner::Convert.to_query_params params, types
        _(combined_params).must_equal({
          "struct_arr_param" => [
            Google::Protobuf::Value.new(null_value: :NULL_VALUE),
            Google::Cloud::Spanner::V1::Type.new(
              code: :ARRAY,
              array_element_type: Google::Cloud::Spanner::V1::Type.new(
                code: :STRUCT,
                struct_type: Google::Cloud::Spanner::V1::StructType.new(
                  fields: [
                    Google::Cloud::Spanner::V1::StructType::Field.new(
                      name: "threadid",
                      type: Google::Cloud::Spanner::V1::Type.new(code: :INT64)
                    )
                  ]
                )
              )
            )
          ]
        })
      end
    end
  end

  def fields *args
    Google::Cloud::Spanner::Fields.new *args
  end
end
