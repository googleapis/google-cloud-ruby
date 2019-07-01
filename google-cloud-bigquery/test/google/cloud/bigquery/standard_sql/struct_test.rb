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

describe Google::Cloud::Bigquery::StandardSql, :struct do
  it "represents a simple STRUCT field" do
    struct_hash = { fields: [{ name: "int_col", type: { typeKind: "INT64" } }] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 1

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_equal "int_col"
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.must_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.wont_be :struct?
  end

  it "represents an anonymous STRUCT field (missing)" do
    struct_hash = { fields: [{ type: { typeKind: "INT64" } }] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 1

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_be_nil
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.must_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.wont_be :struct?
  end

  it "represents an anonymous STRUCT field (empty)" do
    struct_hash = { fields: [{ name: "", type: { typeKind: "INT64" } }] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 1

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_be_nil
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.must_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.wont_be :struct?
  end

  it "represents an emtpy STRUCT field" do
    struct_hash = { fields: [] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 0
  end

  it "represents nested STRUCT fields" do
    nested_hash = { fields: [{ name: "int_col", type: { typeKind: "INT64" } }] }
    struct_hash = { fields: [
      { name: "nested_col", type: { typeKind: "STRUCT", structType: nested_hash } }
    ] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 1

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_equal "nested_col"
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "STRUCT"
    field.type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.wont_be_nil
    field.type.struct_type.fields[0].type.wont_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.must_be :struct?

    field.type.struct_type.fields[0].type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].type.struct_type.fields[0].name.must_equal "int_col"
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.must_be :int?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.struct_type.fields[0].type.wont_be :struct?
  end

  it "represents all types of value fields" do
    struct_hash = { fields: [
      { name: "int_col", type: { typeKind: "INT64" } },
      { name: "float_col", type: { typeKind: "FLOAT64" } },
      { name: "num_col", type: { typeKind: "NUMERIC" } },
      { name: "bool_col", type: { typeKind: "BOOL" } },
      { name: "str_col", type: { typeKind: "STRING" } },
      { name: "bytes_col", type: { typeKind: "BYTES" } },
      { name: "date_col", type: { typeKind: "DATE" } },
      { name: "datetime_col", type: { typeKind: "DATETIME" } },
      { name: "geo_col", type: { typeKind: "GEOGRAPHY" } },
      { name: "time_col", type: { typeKind: "TIME" } },
      { name: "ts_col", type: { typeKind: "TIMESTAMP" } }
    ] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 11

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_equal "int_col"
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.must_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.wont_be :array?
    field.type.struct_type.fields[0].type.wont_be :struct?

    field.type.struct_type.fields[1].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[1].name.must_equal "float_col"
    field.type.struct_type.fields[1].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[1].type.type_kind.must_equal "FLOAT64"
    field.type.struct_type.fields[1].type.array_element_type.must_be_nil
    field.type.struct_type.fields[1].type.struct_type.must_be_nil
    field.type.struct_type.fields[1].type.wont_be :int?
    field.type.struct_type.fields[1].type.must_be :float?
    field.type.struct_type.fields[1].type.wont_be :numeric?
    field.type.struct_type.fields[1].type.wont_be :boolean?
    field.type.struct_type.fields[1].type.wont_be :string?
    field.type.struct_type.fields[1].type.wont_be :bytes?
    field.type.struct_type.fields[1].type.wont_be :date?
    field.type.struct_type.fields[1].type.wont_be :datetime?
    field.type.struct_type.fields[1].type.wont_be :geography?
    field.type.struct_type.fields[1].type.wont_be :time?
    field.type.struct_type.fields[1].type.wont_be :timestamp?
    field.type.struct_type.fields[1].type.wont_be :array?
    field.type.struct_type.fields[1].type.wont_be :struct?

    field.type.struct_type.fields[2].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[2].name.must_equal "num_col"
    field.type.struct_type.fields[2].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[2].type.type_kind.must_equal "NUMERIC"
    field.type.struct_type.fields[2].type.array_element_type.must_be_nil
    field.type.struct_type.fields[2].type.struct_type.must_be_nil
    field.type.struct_type.fields[2].type.wont_be :int?
    field.type.struct_type.fields[2].type.wont_be :float?
    field.type.struct_type.fields[2].type.must_be :numeric?
    field.type.struct_type.fields[2].type.wont_be :boolean?
    field.type.struct_type.fields[2].type.wont_be :string?
    field.type.struct_type.fields[2].type.wont_be :bytes?
    field.type.struct_type.fields[2].type.wont_be :date?
    field.type.struct_type.fields[2].type.wont_be :datetime?
    field.type.struct_type.fields[2].type.wont_be :geography?
    field.type.struct_type.fields[2].type.wont_be :time?
    field.type.struct_type.fields[2].type.wont_be :timestamp?
    field.type.struct_type.fields[2].type.wont_be :array?
    field.type.struct_type.fields[2].type.wont_be :struct?

    field.type.struct_type.fields[3].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[3].name.must_equal "bool_col"
    field.type.struct_type.fields[3].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[3].type.type_kind.must_equal "BOOL"
    field.type.struct_type.fields[3].type.array_element_type.must_be_nil
    field.type.struct_type.fields[3].type.struct_type.must_be_nil
    field.type.struct_type.fields[3].type.wont_be :int?
    field.type.struct_type.fields[3].type.wont_be :float?
    field.type.struct_type.fields[3].type.wont_be :numeric?
    field.type.struct_type.fields[3].type.must_be :boolean?
    field.type.struct_type.fields[3].type.wont_be :string?
    field.type.struct_type.fields[3].type.wont_be :bytes?
    field.type.struct_type.fields[3].type.wont_be :date?
    field.type.struct_type.fields[3].type.wont_be :datetime?
    field.type.struct_type.fields[3].type.wont_be :geography?
    field.type.struct_type.fields[3].type.wont_be :time?
    field.type.struct_type.fields[3].type.wont_be :timestamp?
    field.type.struct_type.fields[3].type.wont_be :array?
    field.type.struct_type.fields[3].type.wont_be :struct?

    field.type.struct_type.fields[4].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[4].name.must_equal "str_col"
    field.type.struct_type.fields[4].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[4].type.type_kind.must_equal "STRING"
    field.type.struct_type.fields[4].type.array_element_type.must_be_nil
    field.type.struct_type.fields[4].type.struct_type.must_be_nil
    field.type.struct_type.fields[4].type.wont_be :int?
    field.type.struct_type.fields[4].type.wont_be :float?
    field.type.struct_type.fields[4].type.wont_be :numeric?
    field.type.struct_type.fields[4].type.wont_be :boolean?
    field.type.struct_type.fields[4].type.must_be :string?
    field.type.struct_type.fields[4].type.wont_be :bytes?
    field.type.struct_type.fields[4].type.wont_be :date?
    field.type.struct_type.fields[4].type.wont_be :datetime?
    field.type.struct_type.fields[4].type.wont_be :geography?
    field.type.struct_type.fields[4].type.wont_be :time?
    field.type.struct_type.fields[4].type.wont_be :timestamp?
    field.type.struct_type.fields[4].type.wont_be :array?
    field.type.struct_type.fields[4].type.wont_be :struct?

    field.type.struct_type.fields[5].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[5].name.must_equal "bytes_col"
    field.type.struct_type.fields[5].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[5].type.type_kind.must_equal "BYTES"
    field.type.struct_type.fields[5].type.array_element_type.must_be_nil
    field.type.struct_type.fields[5].type.struct_type.must_be_nil
    field.type.struct_type.fields[5].type.wont_be :int?
    field.type.struct_type.fields[5].type.wont_be :float?
    field.type.struct_type.fields[5].type.wont_be :numeric?
    field.type.struct_type.fields[5].type.wont_be :boolean?
    field.type.struct_type.fields[5].type.wont_be :string?
    field.type.struct_type.fields[5].type.must_be :bytes?
    field.type.struct_type.fields[5].type.wont_be :date?
    field.type.struct_type.fields[5].type.wont_be :datetime?
    field.type.struct_type.fields[5].type.wont_be :geography?
    field.type.struct_type.fields[5].type.wont_be :time?
    field.type.struct_type.fields[5].type.wont_be :timestamp?
    field.type.struct_type.fields[5].type.wont_be :array?
    field.type.struct_type.fields[5].type.wont_be :struct?

    field.type.struct_type.fields[6].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[6].name.must_equal "date_col"
    field.type.struct_type.fields[6].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[6].type.type_kind.must_equal "DATE"
    field.type.struct_type.fields[6].type.array_element_type.must_be_nil
    field.type.struct_type.fields[6].type.struct_type.must_be_nil
    field.type.struct_type.fields[6].type.wont_be :int?
    field.type.struct_type.fields[6].type.wont_be :float?
    field.type.struct_type.fields[6].type.wont_be :numeric?
    field.type.struct_type.fields[6].type.wont_be :boolean?
    field.type.struct_type.fields[6].type.wont_be :string?
    field.type.struct_type.fields[6].type.wont_be :bytes?
    field.type.struct_type.fields[6].type.must_be :date?
    field.type.struct_type.fields[6].type.wont_be :datetime?
    field.type.struct_type.fields[6].type.wont_be :geography?
    field.type.struct_type.fields[6].type.wont_be :time?
    field.type.struct_type.fields[6].type.wont_be :timestamp?
    field.type.struct_type.fields[6].type.wont_be :array?
    field.type.struct_type.fields[6].type.wont_be :struct?

    field.type.struct_type.fields[7].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[7].name.must_equal "datetime_col"
    field.type.struct_type.fields[7].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[7].type.type_kind.must_equal "DATETIME"
    field.type.struct_type.fields[7].type.array_element_type.must_be_nil
    field.type.struct_type.fields[7].type.struct_type.must_be_nil
    field.type.struct_type.fields[7].type.wont_be :int?
    field.type.struct_type.fields[7].type.wont_be :float?
    field.type.struct_type.fields[7].type.wont_be :numeric?
    field.type.struct_type.fields[7].type.wont_be :boolean?
    field.type.struct_type.fields[7].type.wont_be :string?
    field.type.struct_type.fields[7].type.wont_be :bytes?
    field.type.struct_type.fields[7].type.wont_be :date?
    field.type.struct_type.fields[7].type.must_be :datetime?
    field.type.struct_type.fields[7].type.wont_be :geography?
    field.type.struct_type.fields[7].type.wont_be :time?
    field.type.struct_type.fields[7].type.wont_be :timestamp?
    field.type.struct_type.fields[7].type.wont_be :array?
    field.type.struct_type.fields[7].type.wont_be :struct?

    field.type.struct_type.fields[8].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[8].name.must_equal "geo_col"
    field.type.struct_type.fields[8].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[8].type.type_kind.must_equal "GEOGRAPHY"
    field.type.struct_type.fields[8].type.array_element_type.must_be_nil
    field.type.struct_type.fields[8].type.struct_type.must_be_nil
    field.type.struct_type.fields[8].type.wont_be :int?
    field.type.struct_type.fields[8].type.wont_be :float?
    field.type.struct_type.fields[8].type.wont_be :numeric?
    field.type.struct_type.fields[8].type.wont_be :boolean?
    field.type.struct_type.fields[8].type.wont_be :string?
    field.type.struct_type.fields[8].type.wont_be :bytes?
    field.type.struct_type.fields[8].type.wont_be :date?
    field.type.struct_type.fields[8].type.wont_be :datetime?
    field.type.struct_type.fields[8].type.must_be :geography?
    field.type.struct_type.fields[8].type.wont_be :time?
    field.type.struct_type.fields[8].type.wont_be :timestamp?
    field.type.struct_type.fields[8].type.wont_be :array?
    field.type.struct_type.fields[8].type.wont_be :struct?

    field.type.struct_type.fields[9].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[9].name.must_equal "time_col"
    field.type.struct_type.fields[9].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[9].type.type_kind.must_equal "TIME"
    field.type.struct_type.fields[9].type.array_element_type.must_be_nil
    field.type.struct_type.fields[9].type.struct_type.must_be_nil
    field.type.struct_type.fields[9].type.wont_be :int?
    field.type.struct_type.fields[9].type.wont_be :float?
    field.type.struct_type.fields[9].type.wont_be :numeric?
    field.type.struct_type.fields[9].type.wont_be :boolean?
    field.type.struct_type.fields[9].type.wont_be :string?
    field.type.struct_type.fields[9].type.wont_be :bytes?
    field.type.struct_type.fields[9].type.wont_be :date?
    field.type.struct_type.fields[9].type.wont_be :datetime?
    field.type.struct_type.fields[9].type.wont_be :geography?
    field.type.struct_type.fields[9].type.must_be :time?
    field.type.struct_type.fields[9].type.wont_be :timestamp?
    field.type.struct_type.fields[9].type.wont_be :array?
    field.type.struct_type.fields[9].type.wont_be :struct?

    field.type.struct_type.fields[10].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[10].name.must_equal "ts_col"
    field.type.struct_type.fields[10].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[10].type.type_kind.must_equal "TIMESTAMP"
    field.type.struct_type.fields[10].type.array_element_type.must_be_nil
    field.type.struct_type.fields[10].type.struct_type.must_be_nil
    field.type.struct_type.fields[10].type.wont_be :int?
    field.type.struct_type.fields[10].type.wont_be :float?
    field.type.struct_type.fields[10].type.wont_be :numeric?
    field.type.struct_type.fields[10].type.wont_be :boolean?
    field.type.struct_type.fields[10].type.wont_be :string?
    field.type.struct_type.fields[10].type.wont_be :bytes?
    field.type.struct_type.fields[10].type.wont_be :date?
    field.type.struct_type.fields[10].type.wont_be :datetime?
    field.type.struct_type.fields[10].type.wont_be :geography?
    field.type.struct_type.fields[10].type.wont_be :time?
    field.type.struct_type.fields[10].type.must_be :timestamp?
    field.type.struct_type.fields[10].type.wont_be :array?
    field.type.struct_type.fields[10].type.wont_be :struct?
  end

  it "represents all types of array fields" do
    struct_hash = { fields: [
      { name: "int_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "INT64" } } },
      { name: "float_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "FLOAT64" } } },
      { name: "num_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "NUMERIC" } } },
      { name: "bool_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "BOOL" } } },
      { name: "str_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "STRING" } } },
      { name: "bytes_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "BYTES" } } },
      { name: "date_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "DATE" } } },
      { name: "datetime_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "DATETIME" } } },
      { name: "geo_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "GEOGRAPHY" } } },
      { name: "time_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "TIME" } } },
      { name: "ts_array_col", type: { typeKind: "ARRAY", arrayElementType: { typeKind: "TIMESTAMP" } } }
    ] }
    field = Google::Cloud::Bigquery::StandardSql::Field.from_gapi_json({ name: "struct_col", type: { typeKind: "STRUCT", structType: struct_hash } })

    field.name.must_equal "struct_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "STRUCT"
    field.type.array_element_type.must_be_nil
    field.type.struct_type.wont_be_nil

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
    field.type.wont_be :timestamp?
    field.type.wont_be :array?
    field.type.must_be :struct?

    field.type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    field.type.struct_type.fields.count.must_equal 11

    field.type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[0].name.must_equal "int_array_col"
    field.type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[0].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[0].type.array_element_type.type_kind.must_equal "INT64"
    field.type.struct_type.fields[0].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[0].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.struct_type.must_be_nil
    field.type.struct_type.fields[0].type.wont_be :int?
    field.type.struct_type.fields[0].type.wont_be :float?
    field.type.struct_type.fields[0].type.wont_be :numeric?
    field.type.struct_type.fields[0].type.wont_be :boolean?
    field.type.struct_type.fields[0].type.wont_be :string?
    field.type.struct_type.fields[0].type.wont_be :bytes?
    field.type.struct_type.fields[0].type.wont_be :date?
    field.type.struct_type.fields[0].type.wont_be :datetime?
    field.type.struct_type.fields[0].type.wont_be :geography?
    field.type.struct_type.fields[0].type.wont_be :time?
    field.type.struct_type.fields[0].type.wont_be :timestamp?
    field.type.struct_type.fields[0].type.must_be :array?
    field.type.struct_type.fields[0].type.wont_be :struct?

    field.type.struct_type.fields[1].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[1].name.must_equal "float_array_col"
    field.type.struct_type.fields[1].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[1].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[1].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[1].type.array_element_type.type_kind.must_equal "FLOAT64"
    field.type.struct_type.fields[1].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[1].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[1].type.struct_type.must_be_nil
    field.type.struct_type.fields[1].type.wont_be :int?
    field.type.struct_type.fields[1].type.wont_be :float?
    field.type.struct_type.fields[1].type.wont_be :numeric?
    field.type.struct_type.fields[1].type.wont_be :boolean?
    field.type.struct_type.fields[1].type.wont_be :string?
    field.type.struct_type.fields[1].type.wont_be :bytes?
    field.type.struct_type.fields[1].type.wont_be :date?
    field.type.struct_type.fields[1].type.wont_be :datetime?
    field.type.struct_type.fields[1].type.wont_be :geography?
    field.type.struct_type.fields[1].type.wont_be :time?
    field.type.struct_type.fields[1].type.wont_be :timestamp?
    field.type.struct_type.fields[1].type.must_be :array?
    field.type.struct_type.fields[1].type.wont_be :struct?

    field.type.struct_type.fields[2].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[2].name.must_equal "num_array_col"
    field.type.struct_type.fields[2].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[2].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[2].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[2].type.array_element_type.type_kind.must_equal "NUMERIC"
    field.type.struct_type.fields[2].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[2].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[2].type.struct_type.must_be_nil
    field.type.struct_type.fields[2].type.wont_be :int?
    field.type.struct_type.fields[2].type.wont_be :float?
    field.type.struct_type.fields[2].type.wont_be :numeric?
    field.type.struct_type.fields[2].type.wont_be :boolean?
    field.type.struct_type.fields[2].type.wont_be :string?
    field.type.struct_type.fields[2].type.wont_be :bytes?
    field.type.struct_type.fields[2].type.wont_be :date?
    field.type.struct_type.fields[2].type.wont_be :datetime?
    field.type.struct_type.fields[2].type.wont_be :geography?
    field.type.struct_type.fields[2].type.wont_be :time?
    field.type.struct_type.fields[2].type.wont_be :timestamp?
    field.type.struct_type.fields[2].type.must_be :array?
    field.type.struct_type.fields[2].type.wont_be :struct?

    field.type.struct_type.fields[3].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[3].name.must_equal "bool_array_col"
    field.type.struct_type.fields[3].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[3].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[3].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[3].type.array_element_type.type_kind.must_equal "BOOL"
    field.type.struct_type.fields[3].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[3].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[3].type.struct_type.must_be_nil
    field.type.struct_type.fields[3].type.wont_be :int?
    field.type.struct_type.fields[3].type.wont_be :float?
    field.type.struct_type.fields[3].type.wont_be :numeric?
    field.type.struct_type.fields[3].type.wont_be :boolean?
    field.type.struct_type.fields[3].type.wont_be :string?
    field.type.struct_type.fields[3].type.wont_be :bytes?
    field.type.struct_type.fields[3].type.wont_be :date?
    field.type.struct_type.fields[3].type.wont_be :datetime?
    field.type.struct_type.fields[3].type.wont_be :geography?
    field.type.struct_type.fields[3].type.wont_be :time?
    field.type.struct_type.fields[3].type.wont_be :timestamp?
    field.type.struct_type.fields[3].type.must_be :array?
    field.type.struct_type.fields[3].type.wont_be :struct?

    field.type.struct_type.fields[4].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[4].name.must_equal "str_array_col"
    field.type.struct_type.fields[4].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[4].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[4].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[4].type.array_element_type.type_kind.must_equal "STRING"
    field.type.struct_type.fields[4].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[4].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[4].type.struct_type.must_be_nil
    field.type.struct_type.fields[4].type.wont_be :int?
    field.type.struct_type.fields[4].type.wont_be :float?
    field.type.struct_type.fields[4].type.wont_be :numeric?
    field.type.struct_type.fields[4].type.wont_be :boolean?
    field.type.struct_type.fields[4].type.wont_be :string?
    field.type.struct_type.fields[4].type.wont_be :bytes?
    field.type.struct_type.fields[4].type.wont_be :date?
    field.type.struct_type.fields[4].type.wont_be :datetime?
    field.type.struct_type.fields[4].type.wont_be :geography?
    field.type.struct_type.fields[4].type.wont_be :time?
    field.type.struct_type.fields[4].type.wont_be :timestamp?
    field.type.struct_type.fields[4].type.must_be :array?
    field.type.struct_type.fields[4].type.wont_be :struct?

    field.type.struct_type.fields[5].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[5].name.must_equal "bytes_array_col"
    field.type.struct_type.fields[5].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[5].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[5].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[5].type.array_element_type.type_kind.must_equal "BYTES"
    field.type.struct_type.fields[5].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[5].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[5].type.struct_type.must_be_nil
    field.type.struct_type.fields[5].type.wont_be :int?
    field.type.struct_type.fields[5].type.wont_be :float?
    field.type.struct_type.fields[5].type.wont_be :numeric?
    field.type.struct_type.fields[5].type.wont_be :boolean?
    field.type.struct_type.fields[5].type.wont_be :string?
    field.type.struct_type.fields[5].type.wont_be :bytes?
    field.type.struct_type.fields[5].type.wont_be :date?
    field.type.struct_type.fields[5].type.wont_be :datetime?
    field.type.struct_type.fields[5].type.wont_be :geography?
    field.type.struct_type.fields[5].type.wont_be :time?
    field.type.struct_type.fields[5].type.wont_be :timestamp?
    field.type.struct_type.fields[5].type.must_be :array?
    field.type.struct_type.fields[5].type.wont_be :struct?

    field.type.struct_type.fields[6].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[6].name.must_equal "date_array_col"
    field.type.struct_type.fields[6].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[6].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[6].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[6].type.array_element_type.type_kind.must_equal "DATE"
    field.type.struct_type.fields[6].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[6].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[6].type.struct_type.must_be_nil
    field.type.struct_type.fields[6].type.wont_be :int?
    field.type.struct_type.fields[6].type.wont_be :float?
    field.type.struct_type.fields[6].type.wont_be :numeric?
    field.type.struct_type.fields[6].type.wont_be :boolean?
    field.type.struct_type.fields[6].type.wont_be :string?
    field.type.struct_type.fields[6].type.wont_be :bytes?
    field.type.struct_type.fields[6].type.wont_be :date?
    field.type.struct_type.fields[6].type.wont_be :datetime?
    field.type.struct_type.fields[6].type.wont_be :geography?
    field.type.struct_type.fields[6].type.wont_be :time?
    field.type.struct_type.fields[6].type.wont_be :timestamp?
    field.type.struct_type.fields[6].type.must_be :array?
    field.type.struct_type.fields[6].type.wont_be :struct?

    field.type.struct_type.fields[7].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[7].name.must_equal "datetime_array_col"
    field.type.struct_type.fields[7].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[7].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[7].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[7].type.array_element_type.type_kind.must_equal "DATETIME"
    field.type.struct_type.fields[7].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[7].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[7].type.struct_type.must_be_nil
    field.type.struct_type.fields[7].type.wont_be :int?
    field.type.struct_type.fields[7].type.wont_be :float?
    field.type.struct_type.fields[7].type.wont_be :numeric?
    field.type.struct_type.fields[7].type.wont_be :boolean?
    field.type.struct_type.fields[7].type.wont_be :string?
    field.type.struct_type.fields[7].type.wont_be :bytes?
    field.type.struct_type.fields[7].type.wont_be :date?
    field.type.struct_type.fields[7].type.wont_be :datetime?
    field.type.struct_type.fields[7].type.wont_be :geography?
    field.type.struct_type.fields[7].type.wont_be :time?
    field.type.struct_type.fields[7].type.wont_be :timestamp?
    field.type.struct_type.fields[7].type.must_be :array?
    field.type.struct_type.fields[7].type.wont_be :struct?

    field.type.struct_type.fields[8].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[8].name.must_equal "geo_array_col"
    field.type.struct_type.fields[8].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[8].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[8].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[8].type.array_element_type.type_kind.must_equal "GEOGRAPHY"
    field.type.struct_type.fields[8].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[8].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[8].type.struct_type.must_be_nil
    field.type.struct_type.fields[8].type.wont_be :int?
    field.type.struct_type.fields[8].type.wont_be :float?
    field.type.struct_type.fields[8].type.wont_be :numeric?
    field.type.struct_type.fields[8].type.wont_be :boolean?
    field.type.struct_type.fields[8].type.wont_be :string?
    field.type.struct_type.fields[8].type.wont_be :bytes?
    field.type.struct_type.fields[8].type.wont_be :date?
    field.type.struct_type.fields[8].type.wont_be :datetime?
    field.type.struct_type.fields[8].type.wont_be :geography?
    field.type.struct_type.fields[8].type.wont_be :time?
    field.type.struct_type.fields[8].type.wont_be :timestamp?
    field.type.struct_type.fields[8].type.must_be :array?
    field.type.struct_type.fields[8].type.wont_be :struct?

    field.type.struct_type.fields[9].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[9].name.must_equal "time_array_col"
    field.type.struct_type.fields[9].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[9].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[9].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[9].type.array_element_type.type_kind.must_equal "TIME"
    field.type.struct_type.fields[9].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[9].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[9].type.struct_type.must_be_nil
    field.type.struct_type.fields[9].type.wont_be :int?
    field.type.struct_type.fields[9].type.wont_be :float?
    field.type.struct_type.fields[9].type.wont_be :numeric?
    field.type.struct_type.fields[9].type.wont_be :boolean?
    field.type.struct_type.fields[9].type.wont_be :string?
    field.type.struct_type.fields[9].type.wont_be :bytes?
    field.type.struct_type.fields[9].type.wont_be :date?
    field.type.struct_type.fields[9].type.wont_be :datetime?
    field.type.struct_type.fields[9].type.wont_be :geography?
    field.type.struct_type.fields[9].type.wont_be :time?
    field.type.struct_type.fields[9].type.wont_be :timestamp?
    field.type.struct_type.fields[9].type.must_be :array?
    field.type.struct_type.fields[9].type.wont_be :struct?

    field.type.struct_type.fields[10].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    field.type.struct_type.fields[10].name.must_equal "ts_array_col"
    field.type.struct_type.fields[10].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[10].type.type_kind.must_equal "ARRAY"
    field.type.struct_type.fields[10].type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.struct_type.fields[10].type.array_element_type.type_kind.must_equal "TIMESTAMP"
    field.type.struct_type.fields[10].type.array_element_type.array_element_type.must_be_nil
    field.type.struct_type.fields[10].type.array_element_type.struct_type.must_be_nil
    field.type.struct_type.fields[10].type.struct_type.must_be_nil
    field.type.struct_type.fields[10].type.wont_be :int?
    field.type.struct_type.fields[10].type.wont_be :float?
    field.type.struct_type.fields[10].type.wont_be :numeric?
    field.type.struct_type.fields[10].type.wont_be :boolean?
    field.type.struct_type.fields[10].type.wont_be :string?
    field.type.struct_type.fields[10].type.wont_be :bytes?
    field.type.struct_type.fields[10].type.wont_be :date?
    field.type.struct_type.fields[10].type.wont_be :datetime?
    field.type.struct_type.fields[10].type.wont_be :geography?
    field.type.struct_type.fields[10].type.wont_be :time?
    field.type.struct_type.fields[10].type.wont_be :timestamp?
    field.type.struct_type.fields[10].type.must_be :array?
    field.type.struct_type.fields[10].type.wont_be :struct?
  end
end
