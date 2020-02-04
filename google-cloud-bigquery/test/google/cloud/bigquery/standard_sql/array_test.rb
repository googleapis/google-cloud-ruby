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

    field.name.must_equal "int_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "INT64"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a FLOAT64 Array field" do
    field = array_field "float_array_col", "FLOAT64"

    field.name.must_equal "float_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "FLOAT64"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a NUMERIC Array field" do
    field = array_field "num_array_col", "NUMERIC"

    field.name.must_equal "num_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "NUMERIC"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a BOOL Array field" do
    field = array_field "bool_array_col", "BOOL"

    field.name.must_equal "bool_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "BOOL"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a STRING Array field" do
    field = array_field "str_array_col", "STRING"

    field.name.must_equal "str_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "STRING"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a BYTES Array field" do
    field = array_field "bytes_array_col", "BYTES"

    field.name.must_equal "bytes_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "BYTES"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a DATE Array field" do
    field = array_field "date_array_col", "DATE"

    field.name.must_equal "date_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "DATE"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a DATETIME Array field" do
    field = array_field "datetime_array_col", "DATETIME"

    field.name.must_equal "datetime_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "DATETIME"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a GEOGRAPHY Array field" do
    field = array_field "geo_array_col", "GEOGRAPHY"

    field.name.must_equal "geo_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "GEOGRAPHY"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a TIME Array field" do
    field = array_field "time_array_col", "TIME"

    field.name.must_equal "time_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "TIME"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  it "represents a TIMESTAMP Array field" do
    field = array_field "ts_array_col", "TIMESTAMP"

    field.name.must_equal "ts_array_col"

    field.type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.type_kind.must_equal "ARRAY"
    field.type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    field.type.array_element_type.type_kind.must_equal "TIMESTAMP"
    field.type.array_element_type.array_element_type.must_be_nil
    field.type.array_element_type.struct_type.must_be_nil
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
    field.type.wont_be :timestamp?
    field.type.must_be :array?
    field.type.wont_be :struct?
  end

  def array_field name, type_kind
    array_element_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: type_kind
    array_data_type =Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: array_element_type
    Google::Cloud::Bigquery::StandardSql::Field.new name: name, type: array_data_type
  end
end
