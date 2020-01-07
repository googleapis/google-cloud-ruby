# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::StandardSql, :value do
  describe "immutable constructors" do
    # TODO: move these tests someplace more logical...
    it "takes DataType as an argument" do
      parent = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRING"
      data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: parent

      data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      data_type.type_kind.must_equal "ARRAY"
      data_type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      data_type.array_element_type.type_kind.must_equal "STRING"
    end

    it "takes Hash as an argument" do
      data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: { type_kind: "STRING" }

      data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      data_type.type_kind.must_equal "ARRAY"
      data_type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      data_type.array_element_type.type_kind.must_equal "STRING"
    end
  end

  it "represents a INT64 field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "int_col", type: { typeKind: "INT64" } })

    field.name.must_equal "int_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "INT64"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.must_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a FLOAT64 field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "float_col", type: { typeKind: "FLOAT64" } })

    field.name.must_equal "float_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "FLOAT64"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.must_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a NUMERIC field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "num_col", type: { typeKind: "NUMERIC" } })

    field.name.must_equal "num_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "NUMERIC"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.must_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a BOOL field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "bool_col", type: { typeKind: "BOOL" } })

    field.name.must_equal "bool_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "BOOL"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.must_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a STRING field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "str_col", type: { typeKind: "STRING" } })

    field.name.must_equal "str_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRING"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.must_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a BYTES field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "bytes_col", type: { typeKind: "BYTES" } })

    field.name.must_equal "bytes_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "BYTES"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.must_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a DATE field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "date_col", type: { typeKind: "DATE" } })

    field.name.must_equal "date_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "DATE"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.must_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a DATETIME field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "datetime_col", type: { typeKind: "DATETIME" } })

    field.name.must_equal "datetime_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "DATETIME"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.must_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a GEOGRAPHY field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "geo_col", type: { typeKind: "GEOGRAPHY" } })

    field.name.must_equal "geo_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "GEOGRAPHY"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.must_be :geography?
    field.type.wont_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a TIME field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "time_col", type: { typeKind: "TIME" } })

    field.name.must_equal "time_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "TIME"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.must_be :time?
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end

  it "represents a TIMESTAMP field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "ts_col", type: { typeKind: "TIMESTAMP" } })

    field.name.must_equal "ts_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "TIMESTAMP"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.must_be_nil

    field.type.wont_be :int?
    field.type.wont_be :float?
    field.type.wont_be :numeric?
    field.type.wont_be :boolean?
    field.type.wont_be :string?
    field.type.wont_be :bytes?
    field.type.wont_be :date?
    field.type.wont_be :datetime?
    field.type.wont_be :geography?
    field.type.wont_be :time?
    field.type.must_be :timestamp?
    field.type.wont_be :array?
    field.type.wont_be :struct?
  end
end
