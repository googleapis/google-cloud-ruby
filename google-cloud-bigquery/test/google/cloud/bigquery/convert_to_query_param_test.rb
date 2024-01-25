# Copyright 2019 Google LLC
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

describe Google::Cloud::Bigquery::Convert, :to_query_param do
  describe :BOOL do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "true"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param true
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "true"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "true", :BOOL
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :BOOL
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :INT64 do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "42"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param 42
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "42"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "42", :INT64
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :INT64
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :FLOAT64 do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "3.14"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param 3.14
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "3.14"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "3.14", :FLOAT64
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :FLOAT64
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :NUMERIC do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "NUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "123456798.987654321"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param BigDecimal("123456798.98765432100001")
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "NUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "123456798.987654321"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "123456798.987654321", :NUMERIC
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "NUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :NUMERIC
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :BIGNUMERIC do
    it "allows BigDecimal when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BIGNUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "123456798.98765432100001"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param BigDecimal("123456798.98765432100001"), :BIGNUMERIC
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BIGNUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "123456798.98765432100001"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "123456798.98765432100001", :BIGNUMERIC
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BIGNUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :BIGNUMERIC
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :STRING do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "foobar"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "foobar"
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :STRING
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :DATETIME do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATETIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "2001-12-19 23:59:59.000000"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param Time.parse("2001-12-19T23:59:59 UTC").utc.to_datetime
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATETIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "2001-12-19 23:59:59.000000"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "2001-12-19 23:59:59.000000", :DATETIME
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATETIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :DATETIME
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :DATE do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "1968-10-20"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param Date.parse("1968-10-20")
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "1968-10-20"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "1968-10-20", :DATE
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :DATE
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :GEOGRAPHY do
    it "does NOT identify by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "POINT(-122.335503 47.625536)"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "POINT(-122.335503 47.625536)"
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "GEOGRAPHY"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "POINT(-122.335503 47.625536)"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "POINT(-122.335503 47.625536)", :GEOGRAPHY
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "GEOGRAPHY"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :GEOGRAPHY
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :JSON do
    let(:json_value) { { "name" => "Alice", "age" => 30} }
    
    it "does NOT identify by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: json_value.to_json
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param json_value.to_json
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "JSON"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: json_value.to_json
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param json_value.to_json, :JSON
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "JSON"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :JSON
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :TIMESTAMP do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIMESTAMP"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "2001-12-19 23:59:59.000000+00:00"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param Time.parse("2001-12-19T23:59:59 UTC").utc
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIMESTAMP"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "2001-12-19 23:59:59.000000+00:00"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "2001-12-19 23:59:59.000000+00:00", :TIMESTAMP
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIMESTAMP"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :TIMESTAMP
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :TIME do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "04:00:00"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param Google::Cloud::Bigquery::Time.new("04:00:00")
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "04:00:00"
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param "04:00:00", :TIME
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :TIME
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :BYTES do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BYTES"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: Base64.strict_encode64(File.binread("acceptance/data/logo.jpg"))
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param StringIO.new(File.binread("acceptance/data/logo.jpg"))
      assert_equal expected.to_h, actual.to_h
    end

    it "allows string when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BYTES"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: Base64.strict_encode64(File.binread("acceptance/data/logo.jpg"))
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param Base64.strict_encode64(File.binread("acceptance/data/logo.jpg")), :BYTES
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BYTES"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, :BYTES
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :ARRAY do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "INT64"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          array_values: [
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "1"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "2"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "3")
          ]
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param [1, 2, 3]
      assert_equal expected.to_h, actual.to_h
    end

    it "allows empty when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "INT64"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          array_values: []
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param [], [:INT64]
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "INT64"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param nil, [:INT64]
      assert_equal expected.to_h, actual.to_h
    end
  end

  describe :STRUCT do
    it "identifies by value" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRUCT",
          struct_types: [
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "foo",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "STRING"
              )
            )
          ]
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          struct_values: {
            "foo" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "bar")
          }
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param({ foo: :bar })
      assert_equal expected.to_h, actual.to_h
    end

    it "allows empty when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRUCT",
          struct_types: [
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "foo",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "STRING"
              )
            )
          ]
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          struct_values: {}
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param({}, { foo: :STRING })
      assert_equal expected.to_h, actual.to_h
    end

    it "allows nil when using type" do
      expected = Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRUCT",
          struct_types: [
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "foo",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "STRING"
              )
            )
          ]
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: nil
        )
      )

      actual = Google::Cloud::Bigquery::Convert.to_query_param(nil, { foo: :STRING })
      assert_equal expected.to_h, actual.to_h
    end
  end
end
