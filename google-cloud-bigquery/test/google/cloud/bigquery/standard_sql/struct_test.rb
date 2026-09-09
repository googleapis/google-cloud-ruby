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
    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: [
      Google::Cloud::Bigquery::StandardSql::Field.new(name: "int_col", type: "INT64")
    ]
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 1

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_equal "int_col"
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type).wont_be :struct?
  end

  it "represents an anonymous STRUCT field (missing)" do
    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: [
      Google::Cloud::Bigquery::StandardSql::Field.new(type: "INT64")
    ]
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 1

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type).wont_be :struct?
  end

  it "represents an anonymous STRUCT field (empty)" do
    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: [
      Google::Cloud::Bigquery::StandardSql::Field.new(name: "", type: "INT64")
    ]
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 1

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type).wont_be :struct?
  end

  it "represents an emtpy STRUCT field" do
    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: []
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 0
  end

  it "represents nested STRUCT fields" do
    nested_struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: [
      Google::Cloud::Bigquery::StandardSql::Field.new(name: "int_col", type: "INT64")
    ]
    nested_struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: nested_struct_type
    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: [
      Google::Cloud::Bigquery::StandardSql::Field.new(name: "nested_col", type: nested_struct_data_type)
    ]
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 1

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_equal "nested_col"
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "STRUCT"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).wont_be_nil
    _(field.type.struct_type.fields[0].type).wont_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type).must_be :struct?

    _(field.type.struct_type.fields[0].type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].name).must_equal "int_col"
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).must_be :int?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type.struct_type.fields[0].type).wont_be :struct?
  end

  it "represents all types of value fields" do
    fields = [
      value_field("int_col", "INT64"),
      value_field("float_col", "FLOAT64"),
      value_field("num_col", "NUMERIC"),
      value_field("bool_col", "BOOL"),
      value_field("str_col", "STRING"),
      value_field("bytes_col", "BYTES"),
      value_field("date_col", "DATE"),
      value_field("datetime_col", "DATETIME"),
      value_field("geo_col", "GEOGRAPHY"),
      value_field("time_col", "TIME"),
      value_field("ts_col", "TIMESTAMP"),
      value_field("bignumeric_col", "BIGNUMERIC")
    ]

    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: fields
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 12

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_equal "int_col"
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type).must_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).wont_be :array?
    _(field.type.struct_type.fields[0].type).wont_be :struct?

    _(field.type.struct_type.fields[1]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[1].name).must_equal "float_col"
    _(field.type.struct_type.fields[1].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[1].type.type_kind).must_equal "FLOAT64"
    _(field.type.struct_type.fields[1].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[1].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[1].type).wont_be :int?
    _(field.type.struct_type.fields[1].type).must_be :float?
    _(field.type.struct_type.fields[1].type).wont_be :numeric?
    _(field.type.struct_type.fields[1].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[1].type).wont_be :boolean?
    _(field.type.struct_type.fields[1].type).wont_be :string?
    _(field.type.struct_type.fields[1].type).wont_be :bytes?
    _(field.type.struct_type.fields[1].type).wont_be :date?
    _(field.type.struct_type.fields[1].type).wont_be :datetime?
    _(field.type.struct_type.fields[1].type).wont_be :geography?
    _(field.type.struct_type.fields[1].type).wont_be :time?
    _(field.type.struct_type.fields[1].type).wont_be :timestamp?
    _(field.type.struct_type.fields[1].type).wont_be :array?
    _(field.type.struct_type.fields[1].type).wont_be :struct?

    _(field.type.struct_type.fields[2]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[2].name).must_equal "num_col"
    _(field.type.struct_type.fields[2].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[2].type.type_kind).must_equal "NUMERIC"
    _(field.type.struct_type.fields[2].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[2].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[2].type).wont_be :int?
    _(field.type.struct_type.fields[2].type).wont_be :float?
    _(field.type.struct_type.fields[2].type).must_be :numeric?
    _(field.type.struct_type.fields[2].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[2].type).wont_be :boolean?
    _(field.type.struct_type.fields[2].type).wont_be :string?
    _(field.type.struct_type.fields[2].type).wont_be :bytes?
    _(field.type.struct_type.fields[2].type).wont_be :date?
    _(field.type.struct_type.fields[2].type).wont_be :datetime?
    _(field.type.struct_type.fields[2].type).wont_be :geography?
    _(field.type.struct_type.fields[2].type).wont_be :time?
    _(field.type.struct_type.fields[2].type).wont_be :timestamp?
    _(field.type.struct_type.fields[2].type).wont_be :array?
    _(field.type.struct_type.fields[2].type).wont_be :struct?

    _(field.type.struct_type.fields[3]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[3].name).must_equal "bool_col"
    _(field.type.struct_type.fields[3].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[3].type.type_kind).must_equal "BOOL"
    _(field.type.struct_type.fields[3].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[3].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[3].type).wont_be :int?
    _(field.type.struct_type.fields[3].type).wont_be :float?
    _(field.type.struct_type.fields[3].type).wont_be :numeric?
    _(field.type.struct_type.fields[3].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[3].type).must_be :boolean?
    _(field.type.struct_type.fields[3].type).wont_be :string?
    _(field.type.struct_type.fields[3].type).wont_be :bytes?
    _(field.type.struct_type.fields[3].type).wont_be :date?
    _(field.type.struct_type.fields[3].type).wont_be :datetime?
    _(field.type.struct_type.fields[3].type).wont_be :geography?
    _(field.type.struct_type.fields[3].type).wont_be :time?
    _(field.type.struct_type.fields[3].type).wont_be :timestamp?
    _(field.type.struct_type.fields[3].type).wont_be :array?
    _(field.type.struct_type.fields[3].type).wont_be :struct?

    _(field.type.struct_type.fields[4]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[4].name).must_equal "str_col"
    _(field.type.struct_type.fields[4].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[4].type.type_kind).must_equal "STRING"
    _(field.type.struct_type.fields[4].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[4].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[4].type).wont_be :int?
    _(field.type.struct_type.fields[4].type).wont_be :float?
    _(field.type.struct_type.fields[4].type).wont_be :numeric?
    _(field.type.struct_type.fields[4].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[4].type).wont_be :boolean?
    _(field.type.struct_type.fields[4].type).must_be :string?
    _(field.type.struct_type.fields[4].type).wont_be :bytes?
    _(field.type.struct_type.fields[4].type).wont_be :date?
    _(field.type.struct_type.fields[4].type).wont_be :datetime?
    _(field.type.struct_type.fields[4].type).wont_be :geography?
    _(field.type.struct_type.fields[4].type).wont_be :time?
    _(field.type.struct_type.fields[4].type).wont_be :timestamp?
    _(field.type.struct_type.fields[4].type).wont_be :array?
    _(field.type.struct_type.fields[4].type).wont_be :struct?

    _(field.type.struct_type.fields[5]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[5].name).must_equal "bytes_col"
    _(field.type.struct_type.fields[5].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[5].type.type_kind).must_equal "BYTES"
    _(field.type.struct_type.fields[5].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[5].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[5].type).wont_be :int?
    _(field.type.struct_type.fields[5].type).wont_be :float?
    _(field.type.struct_type.fields[5].type).wont_be :numeric?
    _(field.type.struct_type.fields[5].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[5].type).wont_be :boolean?
    _(field.type.struct_type.fields[5].type).wont_be :string?
    _(field.type.struct_type.fields[5].type).must_be :bytes?
    _(field.type.struct_type.fields[5].type).wont_be :date?
    _(field.type.struct_type.fields[5].type).wont_be :datetime?
    _(field.type.struct_type.fields[5].type).wont_be :geography?
    _(field.type.struct_type.fields[5].type).wont_be :time?
    _(field.type.struct_type.fields[5].type).wont_be :timestamp?
    _(field.type.struct_type.fields[5].type).wont_be :array?
    _(field.type.struct_type.fields[5].type).wont_be :struct?

    _(field.type.struct_type.fields[6]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[6].name).must_equal "date_col"
    _(field.type.struct_type.fields[6].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[6].type.type_kind).must_equal "DATE"
    _(field.type.struct_type.fields[6].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[6].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[6].type).wont_be :int?
    _(field.type.struct_type.fields[6].type).wont_be :float?
    _(field.type.struct_type.fields[6].type).wont_be :numeric?
    _(field.type.struct_type.fields[6].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[6].type).wont_be :boolean?
    _(field.type.struct_type.fields[6].type).wont_be :string?
    _(field.type.struct_type.fields[6].type).wont_be :bytes?
    _(field.type.struct_type.fields[6].type).must_be :date?
    _(field.type.struct_type.fields[6].type).wont_be :datetime?
    _(field.type.struct_type.fields[6].type).wont_be :geography?
    _(field.type.struct_type.fields[6].type).wont_be :time?
    _(field.type.struct_type.fields[6].type).wont_be :timestamp?
    _(field.type.struct_type.fields[6].type).wont_be :array?
    _(field.type.struct_type.fields[6].type).wont_be :struct?

    _(field.type.struct_type.fields[7]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[7].name).must_equal "datetime_col"
    _(field.type.struct_type.fields[7].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[7].type.type_kind).must_equal "DATETIME"
    _(field.type.struct_type.fields[7].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[7].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[7].type).wont_be :int?
    _(field.type.struct_type.fields[7].type).wont_be :float?
    _(field.type.struct_type.fields[7].type).wont_be :numeric?
    _(field.type.struct_type.fields[7].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[7].type).wont_be :boolean?
    _(field.type.struct_type.fields[7].type).wont_be :string?
    _(field.type.struct_type.fields[7].type).wont_be :bytes?
    _(field.type.struct_type.fields[7].type).wont_be :date?
    _(field.type.struct_type.fields[7].type).must_be :datetime?
    _(field.type.struct_type.fields[7].type).wont_be :geography?
    _(field.type.struct_type.fields[7].type).wont_be :time?
    _(field.type.struct_type.fields[7].type).wont_be :timestamp?
    _(field.type.struct_type.fields[7].type).wont_be :array?
    _(field.type.struct_type.fields[7].type).wont_be :struct?

    _(field.type.struct_type.fields[8]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[8].name).must_equal "geo_col"
    _(field.type.struct_type.fields[8].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[8].type.type_kind).must_equal "GEOGRAPHY"
    _(field.type.struct_type.fields[8].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[8].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[8].type).wont_be :int?
    _(field.type.struct_type.fields[8].type).wont_be :float?
    _(field.type.struct_type.fields[8].type).wont_be :numeric?
    _(field.type.struct_type.fields[8].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[8].type).wont_be :boolean?
    _(field.type.struct_type.fields[8].type).wont_be :string?
    _(field.type.struct_type.fields[8].type).wont_be :bytes?
    _(field.type.struct_type.fields[8].type).wont_be :date?
    _(field.type.struct_type.fields[8].type).wont_be :datetime?
    _(field.type.struct_type.fields[8].type).must_be :geography?
    _(field.type.struct_type.fields[8].type).wont_be :time?
    _(field.type.struct_type.fields[8].type).wont_be :timestamp?
    _(field.type.struct_type.fields[8].type).wont_be :array?
    _(field.type.struct_type.fields[8].type).wont_be :struct?

    _(field.type.struct_type.fields[9]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[9].name).must_equal "time_col"
    _(field.type.struct_type.fields[9].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[9].type.type_kind).must_equal "TIME"
    _(field.type.struct_type.fields[9].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[9].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[9].type).wont_be :int?
    _(field.type.struct_type.fields[9].type).wont_be :float?
    _(field.type.struct_type.fields[9].type).wont_be :numeric?
    _(field.type.struct_type.fields[9].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[9].type).wont_be :boolean?
    _(field.type.struct_type.fields[9].type).wont_be :string?
    _(field.type.struct_type.fields[9].type).wont_be :bytes?
    _(field.type.struct_type.fields[9].type).wont_be :date?
    _(field.type.struct_type.fields[9].type).wont_be :datetime?
    _(field.type.struct_type.fields[9].type).wont_be :geography?
    _(field.type.struct_type.fields[9].type).must_be :time?
    _(field.type.struct_type.fields[9].type).wont_be :timestamp?
    _(field.type.struct_type.fields[9].type).wont_be :array?
    _(field.type.struct_type.fields[9].type).wont_be :struct?

    _(field.type.struct_type.fields[10]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[10].name).must_equal "ts_col"
    _(field.type.struct_type.fields[10].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[10].type.type_kind).must_equal "TIMESTAMP"
    _(field.type.struct_type.fields[10].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[10].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[10].type).wont_be :int?
    _(field.type.struct_type.fields[10].type).wont_be :float?
    _(field.type.struct_type.fields[10].type).wont_be :numeric?
    _(field.type.struct_type.fields[10].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[10].type).wont_be :boolean?
    _(field.type.struct_type.fields[10].type).wont_be :string?
    _(field.type.struct_type.fields[10].type).wont_be :bytes?
    _(field.type.struct_type.fields[10].type).wont_be :date?
    _(field.type.struct_type.fields[10].type).wont_be :datetime?
    _(field.type.struct_type.fields[10].type).wont_be :geography?
    _(field.type.struct_type.fields[10].type).wont_be :time?
    _(field.type.struct_type.fields[10].type).must_be :timestamp?
    _(field.type.struct_type.fields[10].type).wont_be :array?
    _(field.type.struct_type.fields[10].type).wont_be :struct?

    _(field.type.struct_type.fields[11]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[11].name).must_equal "bignumeric_col"
    _(field.type.struct_type.fields[11].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[11].type.type_kind).must_equal "BIGNUMERIC"
    _(field.type.struct_type.fields[11].type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[11].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[11].type).wont_be :int?
    _(field.type.struct_type.fields[11].type).wont_be :float?
    _(field.type.struct_type.fields[11].type).wont_be :numeric?
    _(field.type.struct_type.fields[11].type).must_be :bignumeric?
    _(field.type.struct_type.fields[11].type).wont_be :boolean?
    _(field.type.struct_type.fields[11].type).wont_be :string?
    _(field.type.struct_type.fields[11].type).wont_be :bytes?
    _(field.type.struct_type.fields[11].type).wont_be :date?
    _(field.type.struct_type.fields[11].type).wont_be :datetime?
    _(field.type.struct_type.fields[11].type).wont_be :geography?
    _(field.type.struct_type.fields[11].type).wont_be :time?
    _(field.type.struct_type.fields[11].type).wont_be :timestamp?
    _(field.type.struct_type.fields[11].type).wont_be :array?
    _(field.type.struct_type.fields[11].type).wont_be :struct?
  end

  it "represents all types of array fields" do
    fields = [
      array_field("int_array_col", "INT64"),
      array_field("float_array_col", "FLOAT64"),
      array_field("num_array_col", "NUMERIC"),
      array_field("bool_array_col", "BOOL"),
      array_field("str_array_col", "STRING"),
      array_field("bytes_array_col", "BYTES"),
      array_field("date_array_col", "DATE"),
      array_field("datetime_array_col", "DATETIME"),
      array_field("geo_array_col", "GEOGRAPHY"),
      array_field("time_array_col", "TIME"),
      array_field("ts_array_col", "TIMESTAMP"),
      array_field("bignumeric_col", "BIGNUMERIC")
    ]

    struct_type = Google::Cloud::Bigquery::StandardSql::StructType.new fields: fields
    struct_data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRUCT", struct_type: struct_type
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "struct_col", type: struct_data_type

    _(field.name).must_equal "struct_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRUCT"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).wont_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).must_be :struct?

    _(field.type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(field.type.struct_type.fields.count).must_equal 12

    _(field.type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[0].name).must_equal "int_array_col"
    _(field.type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[0].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[0].type.array_element_type.type_kind).must_equal "INT64"
    _(field.type.struct_type.fields[0].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[0].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[0].type).wont_be :int?
    _(field.type.struct_type.fields[0].type).wont_be :float?
    _(field.type.struct_type.fields[0].type).wont_be :numeric?
    _(field.type.struct_type.fields[0].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[0].type).wont_be :boolean?
    _(field.type.struct_type.fields[0].type).wont_be :string?
    _(field.type.struct_type.fields[0].type).wont_be :bytes?
    _(field.type.struct_type.fields[0].type).wont_be :date?
    _(field.type.struct_type.fields[0].type).wont_be :datetime?
    _(field.type.struct_type.fields[0].type).wont_be :geography?
    _(field.type.struct_type.fields[0].type).wont_be :time?
    _(field.type.struct_type.fields[0].type).wont_be :timestamp?
    _(field.type.struct_type.fields[0].type).must_be :array?
    _(field.type.struct_type.fields[0].type).wont_be :struct?

    _(field.type.struct_type.fields[1]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[1].name).must_equal "float_array_col"
    _(field.type.struct_type.fields[1].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[1].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[1].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[1].type.array_element_type.type_kind).must_equal "FLOAT64"
    _(field.type.struct_type.fields[1].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[1].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[1].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[1].type).wont_be :int?
    _(field.type.struct_type.fields[1].type).wont_be :float?
    _(field.type.struct_type.fields[1].type).wont_be :numeric?
    _(field.type.struct_type.fields[1].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[1].type).wont_be :boolean?
    _(field.type.struct_type.fields[1].type).wont_be :string?
    _(field.type.struct_type.fields[1].type).wont_be :bytes?
    _(field.type.struct_type.fields[1].type).wont_be :date?
    _(field.type.struct_type.fields[1].type).wont_be :datetime?
    _(field.type.struct_type.fields[1].type).wont_be :geography?
    _(field.type.struct_type.fields[1].type).wont_be :time?
    _(field.type.struct_type.fields[1].type).wont_be :timestamp?
    _(field.type.struct_type.fields[1].type).must_be :array?
    _(field.type.struct_type.fields[1].type).wont_be :struct?

    _(field.type.struct_type.fields[2]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[2].name).must_equal "num_array_col"
    _(field.type.struct_type.fields[2].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[2].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[2].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[2].type.array_element_type.type_kind).must_equal "NUMERIC"
    _(field.type.struct_type.fields[2].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[2].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[2].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[2].type).wont_be :int?
    _(field.type.struct_type.fields[2].type).wont_be :float?
    _(field.type.struct_type.fields[2].type).wont_be :numeric?
    _(field.type.struct_type.fields[2].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[2].type).wont_be :boolean?
    _(field.type.struct_type.fields[2].type).wont_be :string?
    _(field.type.struct_type.fields[2].type).wont_be :bytes?
    _(field.type.struct_type.fields[2].type).wont_be :date?
    _(field.type.struct_type.fields[2].type).wont_be :datetime?
    _(field.type.struct_type.fields[2].type).wont_be :geography?
    _(field.type.struct_type.fields[2].type).wont_be :time?
    _(field.type.struct_type.fields[2].type).wont_be :timestamp?
    _(field.type.struct_type.fields[2].type).must_be :array?
    _(field.type.struct_type.fields[2].type).wont_be :struct?

    _(field.type.struct_type.fields[3]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[3].name).must_equal "bool_array_col"
    _(field.type.struct_type.fields[3].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[3].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[3].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[3].type.array_element_type.type_kind).must_equal "BOOL"
    _(field.type.struct_type.fields[3].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[3].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[3].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[3].type).wont_be :int?
    _(field.type.struct_type.fields[3].type).wont_be :float?
    _(field.type.struct_type.fields[3].type).wont_be :numeric?
    _(field.type.struct_type.fields[3].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[3].type).wont_be :boolean?
    _(field.type.struct_type.fields[3].type).wont_be :string?
    _(field.type.struct_type.fields[3].type).wont_be :bytes?
    _(field.type.struct_type.fields[3].type).wont_be :date?
    _(field.type.struct_type.fields[3].type).wont_be :datetime?
    _(field.type.struct_type.fields[3].type).wont_be :geography?
    _(field.type.struct_type.fields[3].type).wont_be :time?
    _(field.type.struct_type.fields[3].type).wont_be :timestamp?
    _(field.type.struct_type.fields[3].type).must_be :array?
    _(field.type.struct_type.fields[3].type).wont_be :struct?

    _(field.type.struct_type.fields[4]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[4].name).must_equal "str_array_col"
    _(field.type.struct_type.fields[4].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[4].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[4].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[4].type.array_element_type.type_kind).must_equal "STRING"
    _(field.type.struct_type.fields[4].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[4].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[4].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[4].type).wont_be :int?
    _(field.type.struct_type.fields[4].type).wont_be :float?
    _(field.type.struct_type.fields[4].type).wont_be :numeric?
    _(field.type.struct_type.fields[4].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[4].type).wont_be :boolean?
    _(field.type.struct_type.fields[4].type).wont_be :string?
    _(field.type.struct_type.fields[4].type).wont_be :bytes?
    _(field.type.struct_type.fields[4].type).wont_be :date?
    _(field.type.struct_type.fields[4].type).wont_be :datetime?
    _(field.type.struct_type.fields[4].type).wont_be :geography?
    _(field.type.struct_type.fields[4].type).wont_be :time?
    _(field.type.struct_type.fields[4].type).wont_be :timestamp?
    _(field.type.struct_type.fields[4].type).must_be :array?
    _(field.type.struct_type.fields[4].type).wont_be :struct?

    _(field.type.struct_type.fields[5]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[5].name).must_equal "bytes_array_col"
    _(field.type.struct_type.fields[5].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[5].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[5].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[5].type.array_element_type.type_kind).must_equal "BYTES"
    _(field.type.struct_type.fields[5].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[5].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[5].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[5].type).wont_be :int?
    _(field.type.struct_type.fields[5].type).wont_be :float?
    _(field.type.struct_type.fields[5].type).wont_be :numeric?
    _(field.type.struct_type.fields[5].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[5].type).wont_be :boolean?
    _(field.type.struct_type.fields[5].type).wont_be :string?
    _(field.type.struct_type.fields[5].type).wont_be :bytes?
    _(field.type.struct_type.fields[5].type).wont_be :date?
    _(field.type.struct_type.fields[5].type).wont_be :datetime?
    _(field.type.struct_type.fields[5].type).wont_be :geography?
    _(field.type.struct_type.fields[5].type).wont_be :time?
    _(field.type.struct_type.fields[5].type).wont_be :timestamp?
    _(field.type.struct_type.fields[5].type).must_be :array?
    _(field.type.struct_type.fields[5].type).wont_be :struct?

    _(field.type.struct_type.fields[6]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[6].name).must_equal "date_array_col"
    _(field.type.struct_type.fields[6].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[6].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[6].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[6].type.array_element_type.type_kind).must_equal "DATE"
    _(field.type.struct_type.fields[6].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[6].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[6].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[6].type).wont_be :int?
    _(field.type.struct_type.fields[6].type).wont_be :float?
    _(field.type.struct_type.fields[6].type).wont_be :numeric?
    _(field.type.struct_type.fields[6].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[6].type).wont_be :boolean?
    _(field.type.struct_type.fields[6].type).wont_be :string?
    _(field.type.struct_type.fields[6].type).wont_be :bytes?
    _(field.type.struct_type.fields[6].type).wont_be :date?
    _(field.type.struct_type.fields[6].type).wont_be :datetime?
    _(field.type.struct_type.fields[6].type).wont_be :geography?
    _(field.type.struct_type.fields[6].type).wont_be :time?
    _(field.type.struct_type.fields[6].type).wont_be :timestamp?
    _(field.type.struct_type.fields[6].type).must_be :array?
    _(field.type.struct_type.fields[6].type).wont_be :struct?

    _(field.type.struct_type.fields[7]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[7].name).must_equal "datetime_array_col"
    _(field.type.struct_type.fields[7].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[7].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[7].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[7].type.array_element_type.type_kind).must_equal "DATETIME"
    _(field.type.struct_type.fields[7].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[7].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[7].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[7].type).wont_be :int?
    _(field.type.struct_type.fields[7].type).wont_be :float?
    _(field.type.struct_type.fields[7].type).wont_be :numeric?
    _(field.type.struct_type.fields[7].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[7].type).wont_be :boolean?
    _(field.type.struct_type.fields[7].type).wont_be :string?
    _(field.type.struct_type.fields[7].type).wont_be :bytes?
    _(field.type.struct_type.fields[7].type).wont_be :date?
    _(field.type.struct_type.fields[7].type).wont_be :datetime?
    _(field.type.struct_type.fields[7].type).wont_be :geography?
    _(field.type.struct_type.fields[7].type).wont_be :time?
    _(field.type.struct_type.fields[7].type).wont_be :timestamp?
    _(field.type.struct_type.fields[7].type).must_be :array?
    _(field.type.struct_type.fields[7].type).wont_be :struct?

    _(field.type.struct_type.fields[8]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[8].name).must_equal "geo_array_col"
    _(field.type.struct_type.fields[8].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[8].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[8].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[8].type.array_element_type.type_kind).must_equal "GEOGRAPHY"
    _(field.type.struct_type.fields[8].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[8].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[8].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[8].type).wont_be :int?
    _(field.type.struct_type.fields[8].type).wont_be :float?
    _(field.type.struct_type.fields[8].type).wont_be :numeric?
    _(field.type.struct_type.fields[8].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[8].type).wont_be :boolean?
    _(field.type.struct_type.fields[8].type).wont_be :string?
    _(field.type.struct_type.fields[8].type).wont_be :bytes?
    _(field.type.struct_type.fields[8].type).wont_be :date?
    _(field.type.struct_type.fields[8].type).wont_be :datetime?
    _(field.type.struct_type.fields[8].type).wont_be :geography?
    _(field.type.struct_type.fields[8].type).wont_be :time?
    _(field.type.struct_type.fields[8].type).wont_be :timestamp?
    _(field.type.struct_type.fields[8].type).must_be :array?
    _(field.type.struct_type.fields[8].type).wont_be :struct?

    _(field.type.struct_type.fields[9]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[9].name).must_equal "time_array_col"
    _(field.type.struct_type.fields[9].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[9].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[9].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[9].type.array_element_type.type_kind).must_equal "TIME"
    _(field.type.struct_type.fields[9].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[9].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[9].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[9].type).wont_be :int?
    _(field.type.struct_type.fields[9].type).wont_be :float?
    _(field.type.struct_type.fields[9].type).wont_be :numeric?
    _(field.type.struct_type.fields[9].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[9].type).wont_be :boolean?
    _(field.type.struct_type.fields[9].type).wont_be :string?
    _(field.type.struct_type.fields[9].type).wont_be :bytes?
    _(field.type.struct_type.fields[9].type).wont_be :date?
    _(field.type.struct_type.fields[9].type).wont_be :datetime?
    _(field.type.struct_type.fields[9].type).wont_be :geography?
    _(field.type.struct_type.fields[9].type).wont_be :time?
    _(field.type.struct_type.fields[9].type).wont_be :timestamp?
    _(field.type.struct_type.fields[9].type).must_be :array?
    _(field.type.struct_type.fields[9].type).wont_be :struct?

    _(field.type.struct_type.fields[10]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[10].name).must_equal "ts_array_col"
    _(field.type.struct_type.fields[10].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[10].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[10].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[10].type.array_element_type.type_kind).must_equal "TIMESTAMP"
    _(field.type.struct_type.fields[10].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[10].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[10].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[10].type).wont_be :int?
    _(field.type.struct_type.fields[10].type).wont_be :float?
    _(field.type.struct_type.fields[10].type).wont_be :numeric?
    _(field.type.struct_type.fields[10].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[10].type).wont_be :boolean?
    _(field.type.struct_type.fields[10].type).wont_be :string?
    _(field.type.struct_type.fields[10].type).wont_be :bytes?
    _(field.type.struct_type.fields[10].type).wont_be :date?
    _(field.type.struct_type.fields[10].type).wont_be :datetime?
    _(field.type.struct_type.fields[10].type).wont_be :geography?
    _(field.type.struct_type.fields[10].type).wont_be :time?
    _(field.type.struct_type.fields[10].type).wont_be :timestamp?
    _(field.type.struct_type.fields[10].type).must_be :array?
    _(field.type.struct_type.fields[10].type).wont_be :struct?

    _(field.type.struct_type.fields[11]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(field.type.struct_type.fields[11].name).must_equal "bignumeric_col"
    _(field.type.struct_type.fields[11].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[11].type.type_kind).must_equal "ARRAY"
    _(field.type.struct_type.fields[11].type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.struct_type.fields[11].type.array_element_type.type_kind).must_equal "BIGNUMERIC"
    _(field.type.struct_type.fields[11].type.array_element_type.array_element_type).must_be_nil
    _(field.type.struct_type.fields[11].type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type.fields[11].type.struct_type).must_be_nil
    _(field.type.struct_type.fields[11].type).wont_be :int?
    _(field.type.struct_type.fields[11].type).wont_be :float?
    _(field.type.struct_type.fields[11].type).wont_be :numeric?
    _(field.type.struct_type.fields[11].type).wont_be :bignumeric?
    _(field.type.struct_type.fields[11].type).wont_be :boolean?
    _(field.type.struct_type.fields[11].type).wont_be :string?
    _(field.type.struct_type.fields[11].type).wont_be :bytes?
    _(field.type.struct_type.fields[11].type).wont_be :date?
    _(field.type.struct_type.fields[11].type).wont_be :datetime?
    _(field.type.struct_type.fields[11].type).wont_be :geography?
    _(field.type.struct_type.fields[11].type).wont_be :time?
    _(field.type.struct_type.fields[11].type).wont_be :timestamp?
    _(field.type.struct_type.fields[11].type).must_be :array?
    _(field.type.struct_type.fields[11].type).wont_be :struct?
  end

  def value_field name, type_kind
    value_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: type_kind
    Google::Cloud::Bigquery::StandardSql::Field.new name: name, type: value_type
  end

  def array_field name, type_kind
    array_element_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: type_kind
    array_data_type =Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: array_element_type
    Google::Cloud::Bigquery::StandardSql::Field.new name: name, type: array_data_type
  end
end
