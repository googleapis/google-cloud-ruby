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

describe Google::Cloud::Bigquery::StandardSql, :array do
  it "represents a INT64 Array field" do
    field = array_field "int_array_col", "INT64"

    _(field.name).must_equal "int_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "INT64"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a FLOAT64 Array field" do
    field = array_field "float_array_col", "FLOAT64"

    _(field.name).must_equal "float_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "FLOAT64"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a NUMERIC Array field" do
    field = array_field "num_array_col", "NUMERIC"

    _(field.name).must_equal "num_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "NUMERIC"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BIGNUMERIC Array field" do
    field = array_field "bignumeric_array_col", "BIGNUMERIC"

    _(field.name).must_equal "bignumeric_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "BIGNUMERIC"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BOOL Array field" do
    field = array_field "bool_array_col", "BOOL"

    _(field.name).must_equal "bool_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "BOOL"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a STRING Array field" do
    field = array_field "str_array_col", "STRING"

    _(field.name).must_equal "str_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "STRING"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BYTES Array field" do
    field = array_field "bytes_array_col", "BYTES"

    _(field.name).must_equal "bytes_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "BYTES"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a DATE Array field" do
    field = array_field "date_array_col", "DATE"

    _(field.name).must_equal "date_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "DATE"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a DATETIME Array field" do
    field = array_field "datetime_array_col", "DATETIME"

    _(field.name).must_equal "datetime_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "DATETIME"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a GEOGRAPHY Array field" do
    field = array_field "geo_array_col", "GEOGRAPHY"

    _(field.name).must_equal "geo_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "GEOGRAPHY"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a TIME Array field" do
    field = array_field "time_array_col", "TIME"

    _(field.name).must_equal "time_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "TIME"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a TIMESTAMP Array field" do
    field = array_field "ts_array_col", "TIMESTAMP"

    _(field.name).must_equal "ts_array_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "ARRAY"
    _(field.type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.array_element_type.type_kind).must_equal "TIMESTAMP"
    _(field.type.array_element_type.array_element_type).must_be_nil
    _(field.type.array_element_type.struct_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).must_be :array?
    _(field.type).wont_be :struct?
  end

  def array_field name, type_kind
    array_element_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: type_kind
    array_data_type =Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: array_element_type
    Google::Cloud::Bigquery::StandardSql::Field.new name: name, type: array_data_type
  end
end
